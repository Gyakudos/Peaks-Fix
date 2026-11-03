import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vola_fix/data/database.dart';
import 'package:vola_fix/data/till.dart';

void main() {
  test('tallies coins and bills', () {
    expect(tallyCents({5: 3, 25: 4, 200: 2, 2000: 1, 10000: 1}), 12515);
    expect(tillMoney(12515), '\$125.15');
  });

  test('close event keeps what is left after the deposit', () {
    final close = TillEvent(
      type: TillEventType.close,
      at: DateTime(2026, 11, 1, 18),
      by: 'Sam',
      counts: {2000: 10, 100: 5},
      expectedCents: 20500,
      depositCents: 15000,
    );
    expect(close.countedCents, 20500);
    expect(close.varianceCents, 0);
    expect(close.keptCents, 5500);
    expect(expectedOpeningCents([close]), 5500);
    final back = TillEvent.fromJson(close.toJson());
    expect(back.counts, close.counts);
    expect(back.keptCents, 5500);
  });

  test('open event with no history expects nothing', () {
    expect(expectedOpeningCents(const []), 0);
  });

  test('clocks out only running shifts', () async {
    final db = AppDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    await db.writeSetting(
      'staff_clock_sessions',
      jsonEncode([
        {'id': 'a', 'staffId': 's1', 'clockInAt': '2026-11-03T09:00:00'},
        {
          'id': 'b',
          'staffId': 's2',
          'clockInAt': '2026-11-03T08:00:00',
          'clockOutAt': '2026-11-03T12:00:00',
        },
      ]),
    );
    final at = DateTime(2026, 11, 3, 18);
    expect(await clockOutAllStaff(db, at: at), 1);
    final saved = jsonDecode(await db.readSetting('staff_clock_sessions', '[]'))
        as List<dynamic>;
    expect(saved[0]['clockOutAt'], at.toIso8601String());
    expect(saved[1]['clockOutAt'], '2026-11-03T12:00:00');
    expect(await clockOutAllStaff(db, at: at), 0);
  });

  test('takings net refunds by method', () {
    final at = DateTime(2026, 11, 1);
    Payment p(int amount, PaymentMethod m, PaymentKind k) => Payment(
          id: 1,
          ticketId: 1,
          at: at,
          amountCents: amount,
          method: m,
          kind: k,
        );
    final t = summarizeTakings([
      p(10000, PaymentMethod.cash, PaymentKind.balance),
      p(2500, PaymentMethod.cash, PaymentKind.refund),
      p(4000, PaymentMethod.card, PaymentKind.deposit),
    ]);
    expect(t.cashCents, 7500);
    expect(t.cardCents, 4000);
    expect(t.totalCents, 11500);
  });
}
