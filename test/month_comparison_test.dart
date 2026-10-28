import 'package:flutter_test/flutter_test.dart';
import 'package:vola_fix/data/financials.dart';
import 'package:vola_fix/features/financial/month_comparison.dart';

FinancialTicket _ticket(DateTime closedAt, int revenue, int cost) =>
    FinancialTicket(
      ticketId: closedAt.millisecondsSinceEpoch,
      number: 'PF',
      customerName: 'c',
      device: 'd',
      closedAt: closedAt,
      revenueCents: revenue,
      costCents: cost,
    );

void main() {
  test('monthly totals group closed tickets by calendar month', () {
    final totals = buildMonthlyTotals(
      tickets: [
        _ticket(DateTime(2026, 10, 31, 23), 10000, 2000),
        _ticket(DateTime(2026, 11, 1), 5000, 1000),
        _ticket(DateTime(2026, 11, 20), 7000, 3000),
      ],
      staff: const [],
      now: DateTime(2026, 11, 25),
      months: 3,
    );
    expect(totals.map((m) => m.month.month), [9, 10, 11]);
    expect(totals[0].ticketCount, 0);
    expect(totals[1].revenueCents, 10000);
    expect(totals[2].ticketCount, 2);
    expect(totals[2].revenueCents, 12000);
    expect(totals[2].grossProfitCents, 8000);
  });
}
