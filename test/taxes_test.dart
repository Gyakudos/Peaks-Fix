import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vola_fix/data/database.dart';
import 'package:vola_fix/data/financials.dart';
import 'package:vola_fix/data/taxes.dart';
import 'package:vola_fix/data/tickets_repository.dart';
import 'package:vola_fix/features/financial/financial_page.dart';
import 'package:vola_fix/features/settings/settings_page.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.withExecutor(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('GST and PST are calculated on the discounted subtotal', () {
    const config = TaxConfig(
      gstEnabled: true,
      gstRateBp: 500,
      pstEnabled: true,
      pstRateBp: 725,
    );
    final lines = config.linesFor(9000);

    expect(lines, hasLength(2));
    expect(lines.first.label, 'GST');
    expect(lines.first.rateLabel, '5%');
    expect(lines.first.amountCents, 450);
    expect(lines.last.label, 'PST');
    expect(lines.last.rateLabel, '7.25%');
    expect(lines.last.amountCents, 653);
    expect(config.taxCentsFor(9000), 1103);
  });

  test('missing tax settings leave tax disabled', () async {
    final config = await database.taxConfig();

    expect(config.gstEnabled, isFalse);
    expect(config.pstEnabled, isFalse);
    expect(config.gstRateBp, TaxConfig.defaultGstRateBp);
    expect(config.pstRateBp, TaxConfig.defaultPstRateBp);
    expect(config.linesFor(10000), isEmpty);
  });

  test('first-run seed enables 5% GST and leaves 7% PST off', () async {
    await database.ensureSeeded();

    final config = await database.taxConfig();
    expect(config.gstEnabled, isTrue);
    expect(config.gstRateBp, 500);
    expect(config.pstEnabled, isFalse);
    expect(config.pstRateBp, 700);
  });

  test('settings updates flow into the invoice totals', () async {
    final ticket = await database.createTicket(
      customerName: 'Tax Customer',
      customerPhone: '555-0121',
      customerEmail: 'tax@example.com',
      deviceName: 'Switch OLED',
      complaint: 'Charging port',
    );
    await database.addInvoiceLaborLine(
      ticketId: ticket.id,
      description: 'Repair labour',
      quantity: 1,
      unitPriceCents: 10000,
    );
    await database.setInvoiceDiscount(
      ticketId: ticket.id,
      kind: InvoiceDiscountKind.fixed,
      value: 1000,
    );
    await database.setTaxConfig(
      const TaxConfig(
        gstEnabled: true,
        gstRateBp: 500,
        pstEnabled: true,
        pstRateBp: 700,
      ),
    );

    final invoice =
        await DriftTicketsRepository(database).watchInvoice(ticket.id).first;

    expect(invoice, isNotNull);
    expect(invoice!.taxableCents, 9000);
    expect(invoice.taxLines.map((line) => line.label), ['GST', 'PST']);
    expect(invoice.taxCents, 1080);
    expect(invoice.totalCents, 10080);
  });

  test('closing snapshots tax and Financial reports GST and PST separately',
      () async {
    await database.setTaxConfig(
      const TaxConfig(
        gstEnabled: true,
        gstRateBp: 500,
        pstEnabled: true,
        pstRateBp: 700,
      ),
    );
    final ticket = await database.createTicket(
      customerName: 'Closed Tax Customer',
      customerPhone: '555-0122',
      customerEmail: 'closed-tax@example.com',
      deviceName: 'PS5',
      complaint: 'HDMI port',
    );
    await database.setTicketStatus(ticket.id, TicketStatus.ready);
    await database.addInvoiceLaborLine(
      ticketId: ticket.id,
      description: 'HDMI port replacement',
      quantity: 1,
      unitPriceCents: 10000,
    );
    await database.recordTicketPayment(
      ticketId: ticket.id,
      amountCents: 11200,
      method: PaymentMethod.card,
    );
    await database.closeTicketAfterPayment(ticket.id);

    final row = await (database.select(database.tickets)
          ..where((row) => row.id.equals(ticket.id)))
        .getSingle();
    expect(row.gstCents, 500);
    expect(row.pstCents, 700);

    final tickets = await database.watchFinancialTickets().first;
    expect(tickets.single.revenueCents, 10000);
    expect(tickets.single.gstCents, 500);
    expect(tickets.single.pstCents, 700);
    expect(tickets.single.taxCents, 1200);

    final summary = summarizeFinancials(
      tickets: tickets,
      staff: const [],
      now: DateTime.now(),
    );
    expect(summary.gstCents, 500);
    expect(summary.pstCents, 700);
  });

  test('payment cannot exceed the invoice plus tax', () async {
    await database.setTaxConfig(
      const TaxConfig(
        gstEnabled: true,
        gstRateBp: 500,
        pstEnabled: false,
      ),
    );
    final ticket = await database.createTicket(
      customerName: 'Overpay Customer',
      customerPhone: '555-0123',
      customerEmail: 'overpay@example.com',
      deviceName: 'Switch',
      complaint: 'Battery',
    );
    await database.setTicketStatus(ticket.id, TicketStatus.ready);
    await database.addInvoiceLaborLine(
      ticketId: ticket.id,
      description: 'Battery replacement',
      quantity: 1,
      unitPriceCents: 10000,
    );

    await expectLater(
      database.recordTicketPayment(
        ticketId: ticket.id,
        amountCents: 10501,
        method: PaymentMethod.cash,
      ),
      throwsStateError,
    );
    await database.recordTicketPayment(
      ticketId: ticket.id,
      amountCents: 10500,
      method: PaymentMethod.cash,
    );
    await database.closeTicketAfterPayment(ticket.id);
  });

  testWidgets('Financial starts on this month and toggles to the year view',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1500, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await database.setTaxConfig(
      const TaxConfig(
        gstEnabled: true,
        gstRateBp: 500,
        pstEnabled: true,
        pstRateBp: 700,
      ),
    );
    final ticket = await database.createTicket(
      customerName: 'Showcase Customer',
      customerPhone: '555-0124',
      customerEmail: 'showcase@example.com',
      deviceName: 'Switch OLED',
      complaint: 'USB-C port',
    );
    await database.setTicketStatus(ticket.id, TicketStatus.ready);
    await database.addInvoiceLaborLine(
      ticketId: ticket.id,
      description: 'USB-C port replacement',
      quantity: 1,
      unitPriceCents: 10000,
    );
    await database.recordTicketPayment(
      ticketId: ticket.id,
      amountCents: 11200,
      method: PaymentMethod.card,
    );
    await database.closeTicketAfterPayment(ticket.id);

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: FinancialPage(database: database))),
    );
    await tester.pumpAndSettle();

    expect(find.text('This month'), findsOneWidget);
    expect(find.byKey(const Key('financial-header-gst')), findsOneWidget);
    expect(find.byKey(const Key('financial-header-pst')), findsOneWidget);
    expect(find.text('GST'), findsOneWidget);
    expect(find.text('PST'), findsOneWidget);
    expect(find.text('Yearly view'), findsOneWidget);

    await tester.tap(find.byKey(const Key('financial-year-toggle')));
    await tester.pumpAndSettle();

    expect(find.text('Monthly view'), findsOneWidget);
    expect(find.text('This year'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('Settings saves the GST and PST toggles and rates',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await database.setTaxConfig(
      const TaxConfig(
        gstEnabled: true,
        gstRateBp: 500,
        pstEnabled: false,
        pstRateBp: 700,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: SettingsPage(database: database)),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('tax-gst-enabled')),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    final gstTile = tester.widget<SwitchListTile>(
      find.byKey(const Key('tax-gst-enabled')),
    );
    expect(gstTile.value, isTrue);

    await tester.tap(find.byKey(const Key('tax-pst-enabled')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('tax-pst-rate')), '8.25');
    await tester.ensureVisible(find.byKey(const Key('tax-save')));
    await tester.tap(find.byKey(const Key('tax-save')));
    await tester.pumpAndSettle();

    final config = await database.taxConfig();
    expect(config.gstEnabled, isTrue);
    expect(config.gstRateBp, 500);
    expect(config.pstEnabled, isTrue);
    expect(config.pstRateBp, 825);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });
}
