import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'payment_processor.dart';

typedef HelcimResponse = ({int status, String body});

/// Sends one HTTP request; replaced in tests.
typedef HelcimTransport = Future<HelcimResponse> Function(
  String method,
  Uri uri,
  Map<String, String> headers,
  String? body,
);

Future<HelcimResponse> _httpTransport(
  String method,
  Uri uri,
  Map<String, String> headers,
  String? body,
) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 20);
  try {
    final request = await client.openUrl(method, uri);
    headers.forEach(request.headers.set);
    if (body != null) request.add(utf8.encode(body));
    final response = await request.close().timeout(const Duration(seconds: 30));
    final text = await response.transform(utf8.decoder).join();
    return (status: response.statusCode, body: text);
  } finally {
    client.close(force: true);
  }
}

/// Helcim Smart Terminal / Card Reader through the Payment Hardware API.
///
/// A purchase lights up the paired terminal for the customer; the app then
/// looks for the resulting card transaction by its unique invoice number.
class HelcimProcessor extends PaymentProcessor {
  HelcimProcessor(
    this.config, {
    required this.log,
    HelcimTransport? transport,
    this.pollInterval = const Duration(seconds: 3),
    this.timeout = const Duration(minutes: 3),
  }) : _send = transport ?? _httpTransport;

  final ProcessorConfig config;
  final ProcessorTransactionLog log;
  final Duration pollInterval;
  final Duration timeout;
  final HelcimTransport _send;

  static const _base = 'https://api.helcim.com/v2';

  @override
  ProcessorKind get kind => ProcessorKind.helcim;

  String get _device => config.value('device_code').trim().toUpperCase();

  String get _currency {
    final value = config.value('currency').trim().toUpperCase();
    return value.isEmpty ? 'USD' : value;
  }

  Map<String, String> get _headers => {
        'api-token': config.value('api_token').trim(),
        'accept': 'application/json',
        'content-type': 'application/json',
      };

  @override
  Future<ProcessorResult> charge({
    required int amountCents,
    required String reference,
    ProcessorCancelToken? cancel,
  }) async {
    if (config.value('api_token').trim().isEmpty || _device.length != 4) {
      return const ProcessorResult.failure(
        'Enter the Helcim API token and the 4-character terminal device code '
        'in Settings.',
      );
    }
    final invoice = 'PF-${reference.replaceAll(RegExp(r'[^A-Za-z0-9]'), '')}-'
        '${DateTime.now().millisecondsSinceEpoch}';
    try {
      final start = await _send(
        'POST',
        Uri.parse('$_base/devices/$_device/payment/purchase'),
        _headers,
        jsonEncode({
          'currency': _currency,
          'transactionAmount': amountCents / 100,
          'invoiceNumber': invoice,
        }),
      );
      if (start.status != 202 && start.status != 200) {
        return ProcessorResult.failure(_describe(start));
      }
      return await _awaitPayment(invoice, reference, amountCents, cancel);
    } catch (error) {
      return ProcessorResult.failure('Could not reach Helcim: $error');
    }
  }

  Future<ProcessorResult> _awaitPayment(
    String invoice,
    String reference,
    int amountCents,
    ProcessorCancelToken? cancel,
  ) async {
    final deadline = DateTime.now().add(timeout);
    final now = DateTime.now().toUtc();
    final uri = Uri.parse('$_base/card-transactions').replace(
      queryParameters: {
        'invoiceNumber': invoice,
        'dateFrom': _date(now.subtract(const Duration(days: 1))),
        'dateTo': _date(now.add(const Duration(days: 1))),
      },
    );
    while (DateTime.now().isBefore(deadline)) {
      if (cancel?.cancelled ?? false) {
        return const ProcessorResult.failure('Cancelled.');
      }
      await Future<void>.delayed(pollInterval);
      if (cancel?.cancelled ?? false) {
        return const ProcessorResult.failure('Cancelled.');
      }
      final response = await _send('GET', uri, _headers, null);
      if (response.status != 200) continue;
      final decoded = jsonDecode(response.body);
      if (decoded is! List) continue;
      for (final item in decoded.whereType<Map>()) {
        if (item['type'] != 'purchase') continue;
        final status = '${item['status']}'.toUpperCase();
        if (status == 'APPROVED') {
          final id = '${(item['transactionId'] as num).toInt()}';
          await log.add(reference, id, amountCents);
          return ProcessorResult.success(reference: id);
        }
        if (status == 'DECLINED') {
          return const ProcessorResult.failure('The card was declined.');
        }
      }
    }
    return const ProcessorResult.failure(
      'No payment was completed on the terminal.',
    );
  }

  @override
  Future<ProcessorResult> refund({
    required int amountCents,
    required String reference,
  }) async {
    if (config.value('api_token').trim().isEmpty) {
      return const ProcessorResult.failure(
        'Enter the Helcim API token in Settings.',
      );
    }
    final original = await log.refundable(reference, amountCents);
    if (original == null) {
      return ProcessorResult.failure(
        'No Helcim card payment recorded for $reference covers a refund of '
        '\$${(amountCents / 100).toStringAsFixed(2)}. Refund it from your '
        'Helcim account instead.',
      );
    }
    try {
      final response = await _send(
        'POST',
        Uri.parse('$_base/payment/refund'),
        {..._headers, 'idempotency-key': _uuid()},
        jsonEncode({
          'originalTransactionId': int.parse(original.id),
          'amount': amountCents / 100,
          'ipAddress': '127.0.0.1',
        }),
      );
      if (response.status != 200) {
        return ProcessorResult.failure(_describe(response));
      }
      final decoded = jsonDecode(response.body);
      if (decoded is Map &&
          '${decoded['status']}'.toUpperCase() == 'APPROVED') {
        await log.markRefunded(reference, original.id, amountCents);
        return ProcessorResult.success(
          reference: '${(decoded['transactionId'] as num?)?.toInt() ?? ''}',
        );
      }
      return const ProcessorResult.failure('Helcim declined the refund.');
    } catch (error) {
      return ProcessorResult.failure('Could not reach Helcim: $error');
    }
  }

  @override
  Future<void> attachReference(String from, String to) => log.move(from, to);

  String _describe(HelcimResponse response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['errors'] is List) {
        final errors = (decoded['errors'] as List).join(' ');
        if (errors.isNotEmpty) return 'Helcim: $errors';
      }
    } catch (_) {}
    return switch (response.status) {
      403 => 'Helcim rejected the API token or its permissions.',
      404 => 'Helcim does not know that terminal device code.',
      409 => 'The terminal is not listening. Check that it is on, awake and '
          'in Paired mode.',
      _ => 'Helcim returned an error (${response.status}).',
    };
  }

  static String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  static String _uuid() {
    final random = Random.secure();
    String hex(int length) => List.generate(
          length,
          (_) => random.nextInt(16).toRadixString(16),
        ).join();
    return '${hex(8)}-${hex(4)}-4${hex(3)}-a${hex(3)}-${hex(12)}';
  }
}
