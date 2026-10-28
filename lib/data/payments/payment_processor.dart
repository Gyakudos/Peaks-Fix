import 'dart:convert';

import '../database.dart';
import 'helcim_processor.dart';
import 'secret_store.dart';

/// One credential or setting a processor needs.
class ProcessorField {
  const ProcessorField(this.key, this.label, {this.secret = false});

  final String key;
  final String label;

  /// Secret fields are hidden in the UI and stored encrypted.
  final bool secret;
}

/// The processors a shop can choose. Add a value here, then an adapter in
/// [PaymentProcessors.adapterFor].
enum ProcessorKind {
  manual('Manual (no processor)', []),
  helcim('Helcim', [
    ProcessorField('api_token', 'API token', secret: true),
    ProcessorField('device_code', 'Terminal device code (4 characters)'),
    ProcessorField('currency', 'Currency (USD or CAD)'),
  ]),
  square('Square', [
    ProcessorField('access_token', 'Access token', secret: true),
    ProcessorField('location_id', 'Location ID'),
  ]),
  stripe('Stripe', [
    ProcessorField('secret_key', 'Secret key', secret: true),
    ProcessorField('reader_id', 'Terminal reader ID'),
  ]),
  clover('Clover', [
    ProcessorField('api_token', 'API token', secret: true),
    ProcessorField('merchant_id', 'Merchant ID'),
  ]),
  other('Other', [
    ProcessorField('api_token', 'API token', secret: true),
    ProcessorField('base_url', 'API base URL'),
  ]);

  const ProcessorKind(this.label, this.fields);

  final String label;
  final List<ProcessorField> fields;
}

class ProcessorConfig {
  const ProcessorConfig({
    this.kind = ProcessorKind.manual,
    this.values = const {},
  });

  final ProcessorKind kind;
  final Map<String, String> values;

  String value(String key) => values[key] ?? '';
}

class ProcessorResult {
  const ProcessorResult.success({this.reference})
      : success = true,
        message = null;
  const ProcessorResult.failure(this.message)
      : success = false,
        reference = null;

  final bool success;

  /// The processor's transaction id, when it gives one.
  final String? reference;
  final String? message;
}

/// What checkout talks to. Every processor implements this one interface.
abstract class PaymentProcessor {
  const PaymentProcessor();

  ProcessorKind get kind;

  /// Takes a card payment. [reference] is usually the ticket number.
  Future<ProcessorResult> charge({
    required int amountCents,
    required String reference,
    ProcessorCancelToken? cancel,
  });

  /// Returns money to the card used for the payments made under [reference].
  Future<ProcessorResult> refund({
    required int amountCents,
    required String reference,
  });

  /// Moves payments taken under a temporary [from] reference (such as an
  /// intake deposit, taken before the ticket number exists) to [to].
  Future<void> attachReference(String from, String to) async {}
}

/// Lets the user stop waiting for a customer to pay.
class ProcessorCancelToken {
  bool cancelled = false;
}

/// Money is taken outside the app and only recorded here.
class ManualProcessor extends PaymentProcessor {
  const ManualProcessor();

  @override
  ProcessorKind get kind => ProcessorKind.manual;

  @override
  Future<ProcessorResult> charge({
    required int amountCents,
    required String reference,
    ProcessorCancelToken? cancel,
  }) async =>
      const ProcessorResult.success();

  @override
  Future<ProcessorResult> refund({
    required int amountCents,
    required String reference,
  }) async =>
      const ProcessorResult.success();
}

/// Placeholder until a real adapter is written for [kind].
class UnsupportedProcessor extends PaymentProcessor {
  const UnsupportedProcessor(this.kind);

  @override
  final ProcessorKind kind;

  ProcessorResult get _failure => ProcessorResult.failure(
        '${kind.label} payments are not available in this version yet.',
      );

  @override
  Future<ProcessorResult> charge({
    required int amountCents,
    required String reference,
    ProcessorCancelToken? cancel,
  }) async =>
      _failure;

  @override
  Future<ProcessorResult> refund({
    required int amountCents,
    required String reference,
  }) async =>
      _failure;
}

class PaymentProcessors {
  const PaymentProcessors._();

  static PaymentProcessor adapterFor(
    ProcessorConfig config, {
    ProcessorTransactionLog? log,
    HelcimTransport? transport,
  }) {
    switch (config.kind) {
      case ProcessorKind.manual:
        return const ManualProcessor();
      case ProcessorKind.helcim:
        if (log == null) return UnsupportedProcessor(config.kind);
        return HelcimProcessor(config, log: log, transport: transport);
      case ProcessorKind.square:
      case ProcessorKind.stripe:
      case ProcessorKind.clover:
      case ProcessorKind.other:
        return UnsupportedProcessor(config.kind);
    }
  }
}

/// Remembers the processor's transaction ids so a refund can find them.
class ProcessorTransactionLog {
  ProcessorTransactionLog(this.database);

  final AppDatabase database;

  static const _key = 'payment_processor_transactions';

  Future<Map<String, List<Map<String, dynamic>>>> _read() async {
    try {
      final decoded = jsonDecode(await database.readSetting(_key, '{}'));
      if (decoded is Map) {
        return {
          for (final entry in decoded.entries)
            '${entry.key}': [
              for (final item in entry.value as List)
                Map<String, dynamic>.from(item as Map),
            ],
        };
      }
    } catch (_) {}
    return {};
  }

  Future<void> _write(Map<String, List<Map<String, dynamic>>> data) =>
      database.writeSetting(_key, jsonEncode(data));

  Future<void> add(String reference, String transactionId, int cents) async {
    final data = await _read();
    (data[reference] ??= []).add({'id': transactionId, 'c': cents, 'r': 0});
    await _write(data);
  }

  /// A card payment under [reference] with at least [cents] left to refund.
  Future<({String id, int cents})?> refundable(
    String reference,
    int cents,
  ) async {
    final data = await _read();
    for (final item in (data[reference] ?? []).reversed) {
      final left = (item['c'] as int) - (item['r'] as int);
      if (left >= cents) return (id: '${item['id']}', cents: left);
    }
    return null;
  }

  Future<void> markRefunded(String reference, String id, int cents) async {
    final data = await _read();
    for (final item in data[reference] ?? const <Map<String, dynamic>>[]) {
      if ('${item['id']}' == id) item['r'] = (item['r'] as int) + cents;
    }
    await _write(data);
  }

  Future<void> move(String from, String to) async {
    final data = await _read();
    final moved = data.remove(from);
    if (moved == null) return;
    (data[to] ??= []).addAll(moved);
    await _write(data);
  }
}

/// Reads and writes the processor choice; secrets are stored encrypted.
class ProcessorConfigStore {
  ProcessorConfigStore(this.database, {SecretStore? secrets})
      : _secrets = secrets ?? defaultSecretStore();

  final AppDatabase database;
  final SecretStore _secrets;

  static const _kindKey = 'payment_processor_kind';
  static const _fieldsKey = 'payment_processor_fields';
  static const _legacyTokenKey = 'payment_processor_token';

  Future<ProcessorConfig> load() async {
    final kindName = await database.readSetting(_kindKey, 'manual');
    final kind = ProcessorKind.values.firstWhere(
      (k) => k.name == kindName,
      orElse: () => ProcessorKind.manual,
    );
    final stored = _decode(await database.readSetting(_fieldsKey, '{}'));
    final legacy = await database.readSetting(_legacyTokenKey, '');
    final values = <String, String>{};
    for (final field in kind.fields) {
      final raw = stored['${kind.name}.${field.key}'] ?? '';
      values[field.key] = field.secret ? _secrets.open(raw) : raw;
    }
    if (legacy.isNotEmpty) {
      // Plain-text token from the first version: seal it and drop the copy.
      final secretFields = kind.fields.where((f) => f.secret);
      if (secretFields.isNotEmpty &&
          (values[secretFields.first.key] ?? '').isEmpty) {
        values[secretFields.first.key] = legacy;
        await save(ProcessorConfig(kind: kind, values: values));
      }
      await database.writeSetting(_legacyTokenKey, '');
    }
    return ProcessorConfig(kind: kind, values: values);
  }

  Future<void> save(ProcessorConfig config) async {
    final stored = _decode(await database.readSetting(_fieldsKey, '{}'));
    for (final field in config.kind.fields) {
      final value = config.value(field.key).trim();
      stored['${config.kind.name}.${field.key}'] =
          field.secret ? _secrets.seal(value) : value;
    }
    await database.writeSetting(_fieldsKey, jsonEncode(stored));
    await database.writeSetting(_kindKey, config.kind.name);
  }

  Map<String, String> _decode(String json) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry('$k', '$v'));
      }
    } catch (_) {}
    return {};
  }
}
