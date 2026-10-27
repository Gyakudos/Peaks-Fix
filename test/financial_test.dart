import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vola_fix/data/database.dart';
import 'package:vola_fix/data/financials.dart';
import 'package:vola_fix/features/financial/financial_page.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.withExecutor(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> writeSetting(String key, Object value) async {
    await database.into(database.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(key: key, value: jsonEncode(value)),
        );
  }

  Future<int> createClosedTicket() async {
    final ticket = await database.createTicket(
      customerName: 'Warranty Customer',
      customerPhone: '555-0199',
      customerEmail: 'warranty@example.com',
      deviceName: 'Switch OLED',
      complaint: 'USB-C port',
    );
    await database.setTicketStatus(ticket.id, TicketStatus.ready);
    await database.addInvoiceLaborLine(
      ticketId: ticket.id,
      description: 'USB-C port replacement',
      quantity: 1,
      unitPriceCents: 12000,
    );
    await database.addCheckoutMerchLine(
      ticketId: ticket.id,
      description: 'USB-C cable',
      quantity: 2,
      unitCostCents: 1000,
      unitPriceCents: 3000,
    );
    await database.setInvoiceDiscount(
      ticketId: ticket.id,
      kind: InvoiceDiscountKind.fixed,
      value: 2000,
    );
    await database.recordTicketPayment(
      ticketId: ticket.id,
      amountCents: 16000,
      method: PaymentMethod.card,
    );
    await database.closeTicketAfterPayment(ticket.id);
    return ticket.id;
  }

  test('closed tickets report revenue, cost and gross profit after discounts',
      () async {
    final ticketId = await createClosedTicket();

    final tickets = await database.watchFinancialTickets().first;

    expect(tickets, hasLength(1));
    final ticket = tickets.single;
    expect(ticket.ticketId, ticketId);
    expect(ticket.number, 'PF-000001');
    expect(ticket.customerName, 'Warranty Customer');
    expect(ticket.device, 'Switch OLED');
    expect(ticket.revenueCents, 16000);
    expect(ticket.costCents, 2000);
    expect(ticket.profitCents, 14000);
    expect(ticket.margin, closeTo(0.875, 0.0001));
    expect(ticket.closedAt, isNotNull);
  });

  test('reopening a closed ticket removes it from closed-ticket financials',
      () async {
    final ticketId = await createClosedTicket();

    await database.setTicketStatus(ticketId, TicketStatus.inRepair);

    final tickets = await database.watchFinancialTickets().first;
    expect(tickets, isEmpty);

    final row = await (database.select(database.tickets)
          ..where((ticket) => ticket.id.equals(ticketId)))
        .getSingle();
    expect(row.status, TicketStatus.inRepair);
    expect(row.completedAt, isNull);
    expect(row.pickedUpAt, isNull);
  });

  test('staff hours and pay are read from the roster and time clock', () async {
    await writeSetting('staff_roster', [
      {
        'id': 'alex',
        'name': 'Alex Tech',
        'job': 'Tech 2',
        'isActive': true,
        'hourlyRateCents': 2500,
      },
      {
        'id': 'sam',
        'name': 'Sam Desk',
        'job': 'Front Desk',
        'isActive': true,
        'hourlyRateCents': 1500,
      },
      {
        'id': 'casey',
        'name': 'Casey Helper',
        'job': 'Tech 1',
        'isActive': false,
      },
    ]);
    await writeSetting('staff_clock_sessions', [
      {
        'id': 'shift-1',
        'staffId': 'alex',
        'name': 'Alex Tech',
        'job': 'Tech 2',
        'clockInAt': '2026-10-19T09:00:00.000',
        'clockOutAt': '2026-10-19T11:30:00.000',
      },
      {
        'id': 'shift-2',
        'staffId': 'alex',
        'name': 'Alex Tech',
        'job': 'Tech 2',
        'clockInAt': '2026-10-20T09:00:00.000',
        'clockOutAt': null,
      },
      {
        'id': 'shift-3',
        'staffId': 'sam',
        'name': 'Sam Desk',
        'job': 'Front Desk',
        'clockInAt': '2026-10-20T09:00:00.000',
        'clockOutAt': '2026-10-20T17:00:00.000',
      },
    ]);

    final staff = await database.watchFinancialStaff().first;
    expect(staff, hasLength(3));

    final alex = staff.singleWhere((member) => member.id == 'alex');
    final cutoff = DateTime(2026, 10, 20, 10);
    expect(
      alex.trackedIn(null, cutoff),
      const Duration(hours: 3, minutes: 30),
    );
    expect(
      alex.trackedIn(DateTime(2026, 10, 20), cutoff),
      const Duration(hours: 1),
    );
    expect(
      alex.payCentsFor(const Duration(hours: 3, minutes: 30)),
      8750,
    );
    expect(alex.isClockedIn, isTrue);

    final sam = staff.singleWhere((member) => member.id == 'sam');
    expect(sam.trackedIn(null, cutoff), const Duration(hours: 1));
    expect(sam.payCentsFor(const Duration(hours: 8)), 12000);

    final casey = staff.singleWhere((member) => member.id == 'casey');
    expect(casey.payCentsFor(const Duration(hours: 1)), isNull);
    expect(casey.isActive, isFalse);
  });

  test('period boundaries are calculated from the report date', () {
    final now = DateTime(2026, 10, 27, 12);
    expect(FinancialPeriod.allTime.startFrom(now), isNull);
    expect(FinancialPeriod.thisMonth.startFrom(now), DateTime(2026, 10, 1));
    expect(FinancialPeriod.thisYear.startFrom(now), DateTime(2026));
    expect(
      FinancialPeriod.last30Days.startFrom(now),
      DateTime(2026, 9, 27, 12),
    );
    expect(
      FinancialPeriod.thisMonth.contains(DateTime(2026, 10, 1), now),
      isTrue,
    );
    expect(
      FinancialPeriod.thisMonth.contains(DateTime(2026, 9, 30), now),
      isFalse,
    );
  });

  testWidgets('financial page shows closed-ticket profit and staff pay',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.now();
    await createClosedTicket();
    await writeSetting('staff_roster', [
      {
        'id': 'alex',
        'name': 'Alex Tech',
        'job': 'Tech 2',
        'isActive': true,
        'hourlyRateCents': 2500,
      },
    ]);
    await writeSetting('staff_clock_sessions', [
      {
        'id': 'shift-1',
        'staffId': 'alex',
        'name': 'Alex Tech',
        'job': 'Tech 2',
        'clockInAt': now.subtract(const Duration(hours: 2)).toIso8601String(),
        'clockOutAt':
            now.subtract(const Duration(minutes: 30)).toIso8601String(),
      },
    ]);

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: FinancialPage(database: database))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Financial'), findsOneWidget);
    expect(find.text('Revenue'), findsOneWidget);
    expect(find.text('Parts & merch cost'), findsOneWidget);
    expect(find.text('Gross profit'), findsOneWidget);
    expect(find.text('Staff pay'), findsOneWidget);
    expect(find.text('Net estimate'), findsOneWidget);

    // Revenue after the $20 discount, and the $20 of recorded merch cost.
    expect(find.text('\$160.00'), findsWidgets);
    expect(find.text('\$140.00'), findsWidgets);
    expect(find.text('\$37.50'), findsWidgets);

    expect(find.text('Hours by staff'), findsOneWidget);
    expect(find.text('Alex Tech'), findsOneWidget);
    expect(find.text('1h 30m'), findsWidgets);
    expect(find.text('Closed tickets'), findsOneWidget);
    expect(find.textContaining('PF-000001'), findsOneWidget);
    expect(find.textContaining('cost \$20.00'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });
}
