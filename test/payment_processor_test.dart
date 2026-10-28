import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vola_fix/data/database.dart';
import 'package:vola_fix/data/payments/helcim_processor.dart';
import 'package:vola_fix/data/payments/payment_processor.dart';
import 'package:vola_fix/data/payments/secret_store.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase.withExecutor(NativeDatabase.memory()));
  tearDown(() => database.close());

  test('DPAPI seals a secret so it is not stored as plain text', () {
    final store = DpapiSecretStore();
    final sealed = store.seal('sk_live_abc123');
    expect(sealed, isNotEmpty);
    expect(sealed.contains('abc123'), isFalse);
    expect(store.open(sealed), 'sk_live_abc123');
    expect(store.open('not-valid'), '');
  });

  test('processor config round-trips with secrets encrypted at rest', () async {
    final store = ProcessorConfigStore(database, secrets: DpapiSecretStore());
    expect((await store.load()).kind, ProcessorKind.manual);

    await store.save(const ProcessorConfig(
      kind: ProcessorKind.square,
      values: {'access_token': 'tok_secret', 'location_id': 'LOC1'},
    ));
    final loaded = await store.load();
    expect(loaded.kind, ProcessorKind.square);
    expect(loaded.value('access_token'), 'tok_secret');
    expect(loaded.value('location_id'), 'LOC1');

    final raw = await database.readSetting('payment_processor_fields', '');
    expect(raw.contains('tok_secret'), isFalse);
    expect(raw.contains('LOC1'), isTrue);
  });

  test('legacy plain token is migrated and cleared', () async {
    await database.writeSetting('payment_processor_kind', 'other');
    await database.writeSetting('payment_processor_token', 'old-token');
    final store = ProcessorConfigStore(database, secrets: DpapiSecretStore());
    expect((await store.load()).value('api_token'), 'old-token');
    expect(await database.readSetting('payment_processor_token', 'x'), '');
    expect((await store.load()).value('api_token'), 'old-token');
  });

  test('helcim charges via the terminal, then refunds the same payment',
      () async {
    final calls = <String>[];
    Future<HelcimResponse> transport(
      String method,
      Uri uri,
      Map<String, String> headers,
      String? body,
    ) async {
      calls.add('$method ${uri.path}');
      expect(headers['api-token'], 'tok');
      if (uri.path.endsWith('/payment/purchase')) {
        final sent = jsonDecode(body!) as Map;
        expect(sent['transactionAmount'], 12.34);
        expect(sent['currency'], 'USD');
        return (status: 202, body: '');
      }
      if (uri.path.endsWith('/card-transactions')) {
        return (
          status: 200,
          body: jsonEncode([
            {'type': 'purchase', 'status': 'APPROVED', 'transactionId': 555},
          ]),
        );
      }
      expect(headers['idempotency-key'], isNotEmpty);
      final sent = jsonDecode(body!) as Map;
      expect(sent['originalTransactionId'], 555);
      return (
        status: 200,
        body: jsonEncode({'status': 'APPROVED', 'transactionId': 556}),
      );
    }

    final helcim = HelcimProcessor(
      const ProcessorConfig(
        kind: ProcessorKind.helcim,
        values: {'api_token': 'tok', 'device_code': 'ab12'},
      ),
      log: ProcessorTransactionLog(database),
      transport: transport,
      pollInterval: Duration.zero,
    );
    final paid = await helcim.charge(amountCents: 1234, reference: 'Deposit1');
    expect(paid.success, isTrue);
    expect(paid.reference, '555');
    await helcim.attachReference('Deposit1', 'T-9');

    final tooMuch = await helcim.refund(amountCents: 2000, reference: 'T-9');
    expect(tooMuch.success, isFalse);
    final refunded = await helcim.refund(amountCents: 1234, reference: 'T-9');
    expect(refunded.success, isTrue);
    final again = await helcim.refund(amountCents: 100, reference: 'T-9');
    expect(again.success, isFalse);
    expect(calls.where((c) => c.contains('payment/refund')), hasLength(1));
  });

  test('helcim reports a declined card and an unreachable terminal', () async {
    HelcimProcessor build(HelcimTransport transport) => HelcimProcessor(
          const ProcessorConfig(
            kind: ProcessorKind.helcim,
            values: {'api_token': 'tok', 'device_code': 'AB12'},
          ),
          log: ProcessorTransactionLog(database),
          transport: transport,
          pollInterval: Duration.zero,
        );

    final declined = await build((method, uri, headers, body) async {
      if (uri.path.endsWith('/payment/purchase')) {
        return (status: 202, body: '');
      }
      return (
        status: 200,
        body: jsonEncode([
          {'type': 'purchase', 'status': 'DECLINED', 'transactionId': 1},
        ]),
      );
    }).charge(amountCents: 500, reference: 'T-1');
    expect(declined.success, isFalse);
    expect(declined.message, contains('declined'));

    final offline = await build((method, uri, headers, body) async {
      return (status: 409, body: '');
    }).charge(amountCents: 500, reference: 'T-1');
    expect(offline.message, contains('Paired mode'));

    final unset = await HelcimProcessor(
      const ProcessorConfig(kind: ProcessorKind.helcim),
      log: ProcessorTransactionLog(database),
    ).charge(amountCents: 500, reference: 'T-1');
    expect(unset.success, isFalse);
  });

  test('manual succeeds; other processors report not available', () async {
    final manual = PaymentProcessors.adapterFor(const ProcessorConfig());
    expect((await manual.charge(amountCents: 100, reference: 'T1')).success,
        isTrue);
    final stripe = PaymentProcessors.adapterFor(
      const ProcessorConfig(kind: ProcessorKind.stripe),
    );
    final result = await stripe.charge(amountCents: 100, reference: 'T1');
    expect(result.success, isFalse);
    expect(result.message, contains('Stripe'));
  });
}
