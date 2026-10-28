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

    // The $20 discount is split across the $60 merch and $120 labour lines.
    expect(ticket.partsRevenueCents, 0);
    expect(ticket.partsCostCents, 0);
    expect(ticket.partsQuantity, 0);
    expect(ticket.merchRevenueCents, 5334);
    expect(ticket.merchCostCents, 2000);
    expect(ticket.merchQuantity, 2);
    expect(ticket.merchProfitCents, 3334);
    expect(ticket.servicesRevenueCents, 10666);
    expect(
      ticket.partsRevenueCents +
          ticket.merchRevenueCents +
          ticket.servicesRevenueCents,
      ticket.revenueCents,
    );
  });

  test('parts and merchandise keep separate revenue, cost and profit',
      () async {
    final ticket = await database.createTicket(
      customerName: 'Split Customer',
      customerPhone: '555-0210',
      customerEmail: 'split@example.com',
      deviceName: 'Switch Lite',
      complaint: 'Charging port and cable',
    );
    await database.setTicketStatus(ticket.id, TicketStatus.ready);
    final partId = await database.createInventoryPart(
      name: 'USB-C charging port',
      startingStock: 4,
      rawCostCents: 1000,
      retailPriceCents: 4000,
    );
    await database.addRequiredPart(
      ticketId: ticket.id,
      partId: partId,
      quantity: 2,
    );
    await database.addInvoiceLaborLine(
      ticketId: ticket.id,
      description: 'Port replacement',
      quantity: 1,
      unitPriceCents: 5000,
    );
    await database.addCheckoutMerchLine(
      ticketId: ticket.id,
      description: 'USB-C cable',
      quantity: 1,
      unitCostCents: 500,
      unitPriceCents: 2000,
    );
    await database.setInvoiceDiscount(
      ticketId: ticket.id,
      kind: InvoiceDiscountKind.fixed,
      value: 1500,
    );
    await database.recordTicketPayment(
      ticketId: ticket.id,
      amountCents: 13500,
      method: PaymentMethod.card,
    );
    await database.closeTicketAfterPayment(ticket.id);

    final row = (await database.watchFinancialTickets().first).single;
    expect(row.revenueCents, 13500);
    expect(row.partsRevenueCents, 7200);
    expect(row.partsCostCents, 2000);
    expect(row.partsQuantity, 2);
    expect(row.partsProfitCents, 5200);
    expect(row.merchRevenueCents, 1800);
    expect(row.merchCostCents, 500);
    expect(row.merchQuantity, 1);
    expect(row.merchProfitCents, 1300);
    expect(row.servicesRevenueCents, 4500);
    expect(row.costCents, 2500);
    expect(row.profitCents, 11000);

    final summary = summarizeFinancials(
      tickets: [row],
      staff: const [],
      now: DateTime.now(),
    );
    expect(summary.partsRevenueCents, 7200);
    expect(summary.partsCostCents, 2000);
    expect(summary.partsQuantity, 2);
    expect(summary.partsProfitCents, 5200);
    expect(summary.merchRevenueCents, 1800);
    expect(summary.merchCostCents, 500);
    expect(summary.merchQuantity, 1);
    expect(summary.merchProfitCents, 1300);
    expect(summary.servicesRevenueCents, 4500);
    // Cost is the combined parts + merchandise cost.
    expect(summary.costCents, 2500);
    expect(summary.grossProfitCents, 11000);
  });

  test('discount cents split without losing or inventing a cent', () {
    final split = splitDiscountedRevenue(
      partsSubtotalCents: 333,
      merchSubtotalCents: 333,
      servicesSubtotalCents: 334,
      discountCents: 100,
    );
    expect(
      split.partsCents + split.merchCents + split.servicesCents,
      900,
    );

    final full = splitDiscountedRevenue(
      partsSubtotalCents: 1000,
      merchSubtotalCents: 2000,
      servicesSubtotalCents: 0,
      discountCents: 5000,
    );
    expect(full.partsCents, 0);
    expect(full.merchCents, 0);
    expect(full.servicesCents, 0);
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

  test('financial summary combines revenue, cost and staff pay', () {
    final summary = summarizeFinancials(
      tickets: [
        FinancialTicket(
          ticketId: 1,
          number: 'PF-000001',
          customerName: 'Alex Customer',
          device: 'Switch OLED',
          closedAt: DateTime(2026, 10, 19),
          revenueCents: 16000,
          costCents: 2000,
        ),
      ],
      staff: [
        FinancialStaff(
          id: 'alex',
          name: 'Alex Tech',
          job: 'Tech 2',
          isActive: true,
          hourlyRateCents: 2500,
          shifts: [
            FinancialShift(
              start: DateTime(2026, 10, 20, 9),
              end: DateTime(2026, 10, 20, 11),
            ),
          ],
        ),
      ],
      now: DateTime(2026, 10, 20, 12),
    );

    expect(summary.revenueCents, 16000);
    expect(summary.costCents, 2000);
    expect(summary.grossProfitCents, 14000);
    expect(summary.tracked, const Duration(hours: 2));
    expect(summary.staffPayCents, 5000);
    expect(summary.netEstimateCents, 9000);
    expect(summary.ticketCount, 1);
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
    expect(find.text('Net \$102.50'), findsOneWidget);
    expect(find.text('Revenue'), findsOneWidget);
    expect(find.byKey(const Key('financial-parts-tracker')), findsOneWidget);
    expect(find.byKey(const Key('financial-merch-tracker')), findsOneWidget);
    expect(find.text('Parts'), findsOneWidget);
    expect(find.text('Merchandise'), findsOneWidget);
    expect(find.text('Gross profit'), findsWidgets);
    expect(find.text('Staff pay'), findsOneWidget);
    expect(find.text('Net estimate'), findsOneWidget);

    // Revenue after the $20 discount, and the $20 of recorded merch cost.
    expect(find.text('\$160.00'), findsWidgets);
    expect(find.text('\$140.00'), findsWidgets);
    expect(find.text('\$37.50'), findsWidgets);
    expect(find.text('\$53.34'), findsWidgets);
    expect(find.text('\$33.34'), findsWidgets);
    expect(
      find.byKey(const Key('financial-services-revenue')),
      findsOneWidget,
    );

    expect(find.text('Hours by staff'), findsOneWidget);
    expect(find.text('Alex Tech'), findsOneWidget);
    expect(find.text('1h 30m'), findsWidgets);
    expect(find.text('Closed tickets'), findsOneWidget);
    expect(find.textContaining('PF-000001'), findsOneWidget);
    expect(find.textContaining('parts cost \$0.00'), findsOneWidget);
    expect(find.textContaining('merch cost \$20.00'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });
}
