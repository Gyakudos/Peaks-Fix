import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vola_fix/data/database.dart';
import 'package:vola_fix/data/financials.dart';
import 'package:vola_fix/data/tickets_repository.dart';

void main() {
  late AppDatabase database;
  late DriftTicketsRepository repository;

  setUp(() {
    database = AppDatabase.withExecutor(NativeDatabase.memory());
    repository = DriftTicketsRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<int> newTicket(String name) async {
    final ticket = await database.createTicket(
      customerName: name,
      customerPhone: '555-0100',
      customerEmail: '$name@example.com',
      deviceName: 'Switch OLED',
      complaint: 'USB-C port',
    );
    return ticket.id;
  }

  Future<InventoryPart> readPart() async =>
      (await repository.watchInventoryParts().first).single;

  Future<void> closeTicket(int ticketId) async {
    await database.setTicketStatus(ticketId, TicketStatus.ready);
    await database.closeTicketAfterPayment(ticketId);
  }

  test('tube supply tracks tubes and uses; charge flag bills per use',
      () async {
    final tubeId = await database.createInventoryPart(
      name: 'Kryonaut',
      category: 'Shop Supplies',
      startingStock: 25,
      purchaseType: PartPurchaseType.tube,
      bulkQuantity: 10,
      bulkTotalCents: 2000,
      retailPriceCents: 270,
    );
    final freeId = await database.createInventoryPart(
      name: 'Free paste',
      category: 'Shop Supplies',
      startingStock: 5,
      retailPriceCents: 300,
    );
    final part = (await repository.watchInventoryParts().first)
        .firstWhere((p) => p.id == tubeId);
    expect(part.fullTubes, 2);
    expect(part.usesInOpenTube, 5);

    final ticket = await newTicket('tube');
    await database.addRequiredPart(
        ticketId: ticket, partId: tubeId, quantity: 1);
    await database.addRequiredPart(
        ticketId: ticket, partId: freeId, quantity: 1);
    var invoice = await repository.watchInvoice(ticket).first;
    expect(invoice!.lines.every((l) => l.lineTotalCents == 0), isTrue);

    final tubeLine =
        invoice.lines.firstWhere((l) => l.description == 'Kryonaut');
    await repository.setSupplyLineCharged(tubeLine.ticketItemId, true);
    invoice = await repository.watchInvoice(ticket).first;
    final lines = {for (final l in invoice!.lines) l.description: l};
    expect(lines['Kryonaut']!.lineTotalCents, 270);
    expect(lines['Free paste']!.lineTotalCents, 0);
  });

  test('labour brings its included parts onto the invoice at no charge',
      () async {
    final screen = await database.createInventoryPart(
      name: 'Screen',
      startingStock: 4,
      rawCostCents: 3000,
      retailPriceCents: 4050,
    );
    final labourId = await database.createInventoryPart(
      name: 'Screen swap',
      category: 'Labour',
      startingStock: 0,
      retailPriceCents: 6000,
    );
    await database.setLabourIncludedParts(
      labourId,
      [LabourIncludedPart(partId: screen, quantity: 1)],
    );
    expect(
      (await database.watchLabourIncludedParts().first)[labourId],
      hasLength(1),
    );

    final ticket = await newTicket('labour');
    await database.addRequiredPart(
        ticketId: ticket, partId: labourId, quantity: 2);
    final invoice = await repository.watchInvoice(ticket).first;
    final lines = {for (final l in invoice!.lines) l.description: l};
    expect(lines['Screen swap']!.lineTotalCents, 12000);
    expect(lines['Screen (included)']!.quantity, 2);
    expect(lines['Screen (included)']!.lineTotalCents, 0);

    await database.addRequiredPart(
        ticketId: ticket, partId: screen, quantity: 1);
    final again = await repository.watchInvoice(ticket).first;
    expect(
      again!.lines
          .where((l) => l.description == 'Screen')
          .single
          .lineTotalCents,
      4050,
    );
  });

  test('quick sale closes a paid ticket and takes stock out', () async {
    final partId = await database.createInventoryPart(
      name: 'Cable',
      startingStock: 4,
      retailPriceCents: 1000,
    );
    final id = await repository.createQuickSale(
      parts: [(partId: partId, quantity: 3)],
      customLines: [(description: 'Misc', quantity: 1, unitPriceCents: 500)],
      method: PaymentMethod.cash,
    );
    final ticket = await (database.select(database.tickets)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    expect(ticket.status, TicketStatus.closed);
    expect((await readPart()).stock, 1);
  });

  test('quick sale bills shop supplies at retail', () async {
    final partId = await database.createInventoryPart(
      name: 'Paste',
      category: 'Shop Supplies',
      startingStock: 5,
      retailPriceCents: 400,
    );
    final id = await repository.createQuickSale(
      parts: [(partId: partId, quantity: 2)],
      customLines: const [],
      method: PaymentMethod.cash,
    );
    final items = await (database.select(database.ticketItems)
          ..where((i) => i.ticketId.equals(id)))
        .get();
    expect(items.single.unitPriceCents, 400);
  });

  test('quick sale sells a tube whole at marked-up tube cost', () async {
    final partId = await database.createInventoryPart(
      name: 'Kryonaut',
      category: 'Shop Supplies',
      startingStock: 20,
      purchaseType: PartPurchaseType.tube,
      bulkQuantity: 10,
      bulkTotalCents: 2000,
    );
    final id = await repository.createQuickSale(
      parts: [(partId: partId, quantity: 1)],
      customLines: const [],
      method: PaymentMethod.cash,
    );
    final item = await (database.select(database.ticketItems)
          ..where((i) => i.ticketId.equals(id)))
        .getSingle();
    expect(item.quantity, 1);
    expect(item.unitPriceCents, 2700);
    expect((await readPart()).stock, 10);
  });

  test('intake deposit counts as a payment toward the invoice', () async {
    final ticket = await newTicket('deposit');
    await repository.recordTicketDeposit(
      ticketId: ticket,
      amountCents: 4500,
      method: PaymentMethod.cash,
    );
    final payments = await repository.watchTicketPayments(ticket).first;
    expect(payments.single.kind, PaymentKind.deposit);
    expect(payments.single.amountCents, 4500);
  });

  test('financial deposits track collected and held amounts', () async {
    final open = await newTicket('open');
    final closing = await newTicket('closing');
    for (final id in [open, closing]) {
      await repository.recordTicketDeposit(
        ticketId: id,
        amountCents: 4500,
        method: PaymentMethod.cash,
      );
    }
    await database.setTicketStatus(closing, TicketStatus.ready);
    await database.closeTicketAfterPayment(closing);
    final deposits = await database.watchFinancialDeposits().first;
    expect(deposits, hasLength(2));
    expect(deposits.where((d) => d.applied), hasLength(1));
    expect(deposits.where((d) => !d.applied && !d.cancelled), hasLength(1));
  });

  test('refund is capped at the net amount paid', () async {
    final id = await newTicket('refund');
    await repository.recordTicketDeposit(
      ticketId: id,
      amountCents: 4500,
      method: PaymentMethod.cash,
    );
    await database.recordTicketRefund(
      ticketId: id,
      amountCents: 1500,
      method: PaymentMethod.cash,
    );
    expect(
      () => database.recordTicketRefund(
        ticketId: id,
        amountCents: 3100,
        method: PaymentMethod.cash,
      ),
      throwsStateError,
    );
    await database.recordTicketRefund(
      ticketId: id,
      amountCents: 3000,
      method: PaymentMethod.cash,
    );
    final entries = await database.watchTicketPayments(id).first;
    expect(entries.where((e) => e.kind == PaymentKind.refund), hasLength(2));
  });

  test('committed counts parts on open tickets only', () async {
    final partId = await database.createInventoryPart(
      name: 'USB-C charging port',
      startingStock: 6,
    );
    final openTicket = await newTicket('open');
    final closingTicket = await newTicket('closing');
    final cancelledTicket = await newTicket('cancelled');

    await database.addRequiredPart(
      ticketId: openTicket,
      partId: partId,
      quantity: 2,
    );
    await database.addRequiredPart(
      ticketId: closingTicket,
      partId: partId,
      quantity: 3,
    );
    await database.addRequiredPart(
      ticketId: cancelledTicket,
      partId: partId,
      quantity: 4,
    );
    await database.setTicketStatus(cancelledTicket, TicketStatus.cancelled);

    // Adding a part to a ticket leaves the shelf count alone.
    var part = await readPart();
    expect(part.stock, 6);
    expect(part.committedQuantity, 5);

    // Closing a ticket takes its parts out of stock; the cancelled one never
    // counted.
    await closeTicket(closingTicket);
    part = await readPart();
    expect(part.stock, 3);
    expect(part.committedQuantity, 2);
  });

  test('closing a ticket records the part movement', () async {
    final partId = await database.createInventoryPart(
      name: 'USB-C charging port',
      startingStock: 4,
    );
    final ticketId = await newTicket('movement');
    await database.addRequiredPart(
      ticketId: ticketId,
      partId: partId,
      quantity: 2,
    );

    await closeTicket(ticketId);

    final movements = await database.select(database.partMovements).get();
    expect(movements, hasLength(2));
    final used = movements.firstWhere((row) => row.delta == -2);
    expect(used.partId, partId);
    expect(used.ticketId, ticketId);
    expect(used.note, 'Used on closed ticket');
  });

  test('reopening a ticket does not deduct its parts twice', () async {
    final partId = await database.createInventoryPart(
      name: 'Joy-Con rail',
      startingStock: 5,
    );
    final ticketId = await newTicket('warranty');
    await database.addRequiredPart(
      ticketId: ticketId,
      partId: partId,
      quantity: 2,
    );

    await closeTicket(ticketId);
    expect((await readPart()).stock, 3);

    // Reopen for warranty work. The fitted parts stay consumed, so the job
    // does not reserve them again.
    await database.setTicketStatus(ticketId, TicketStatus.inRepair);
    var part = await readPart();
    expect(part.stock, 3);
    expect(part.committedQuantity, 0);

    // A part added for the second visit is only taken out on the next close.
    await database.addRequiredPart(
      ticketId: ticketId,
      partId: partId,
      quantity: 1,
    );
    part = await readPart();
    expect(part.stock, 3);
    expect(part.committedQuantity, 1);

    await closeTicket(ticketId);
    part = await readPart();
    expect(part.stock, 2);
    expect(part.committedQuantity, 0);

    final movements = await database.select(database.partMovements).get();
    final used = movements.where((row) => row.delta < 0).toList();
    expect(used, hasLength(2));
    expect(used.map((row) => row.delta).reduce((a, b) => a + b), -3);
  });

  test('stock stops at zero when a ticket uses more than is on hand', () async {
    final partId = await database.createInventoryPart(
      name: 'Screen protector',
      startingStock: 1,
    );
    final ticketId = await newTicket('short');
    await database.addRequiredPart(
      ticketId: ticketId,
      partId: partId,
      quantity: 3,
    );

    await closeTicket(ticketId);

    expect((await readPart()).stock, 0);
    final movements = await database.select(database.partMovements).get();
    final used = movements.firstWhere((row) => row.delta < 0);
    expect(used.delta, -1);
    expect(used.note, 'Used on closed ticket (stock short by 2)');
  });

  test('committed follows quantity edits and removed lines', () async {
    final partId = await database.createInventoryPart(
      name: 'USB-C charging port',
      startingStock: 10,
    );
    final ticketId = await newTicket('edits');

    await database.addRequiredPart(
      ticketId: ticketId,
      partId: partId,
      quantity: 1,
    );
    expect((await readPart()).committedQuantity, 1);

    // Adding the same part again stacks onto the existing ticket line.
    await database.addRequiredPart(
      ticketId: ticketId,
      partId: partId,
      quantity: 3,
    );
    expect((await readPart()).committedQuantity, 4);

    final line = (await repository.watchRequiredParts(ticketId).first).single;
    await repository.removeRequiredPart(
      ticketId: ticketId,
      ticketItemId: line.ticketItemId,
    );
    expect((await readPart()).committedQuantity, 0);
    expect((await readPart()).stock, 10);
  });

  test('shop supplies are listed on the invoice but not billed', () async {
    final partId = await database.createInventoryPart(
      name: 'Thermal paste',
      category: 'Shop Supplies',
      startingStock: 5,
      rawCostCents: 300,
      retailPriceCents: 900,
    );
    final ticketId = await newTicket('paste');
    await database.addRequiredPart(
      ticketId: ticketId,
      partId: partId,
      quantity: 1,
    );
    await database.addRequiredPart(
      ticketId: ticketId,
      partId: partId,
      quantity: 1,
    );

    final invoice = await repository.watchInvoice(ticketId).first;
    final line = invoice!.lines.single;
    expect(line.isShopSupply, isTrue);
    expect(line.quantity, 2);
    expect(line.unitPriceCents, 0);
    expect(invoice.subtotalCents, 0);

    await closeTicket(ticketId);
    expect((await readPart()).stock, 3);

    final financial = (await database.watchFinancialTickets().first).single;
    expect(financial.supplyQuantity, 2);
    expect(financial.supplyCostCents, 600);
    expect(financial.revenueCents, 0);
    expect(financial.partsCostCents, 0);
    expect(financial.costCents, 600);
  });

  test('committed ignores parts on tickets that were deleted', () async {
    final partId = await database.createInventoryPart(
      name: 'Screen protector',
      startingStock: 2,
    );
    final ticketId = await newTicket('deleted');
    await database.addRequiredPart(
      ticketId: ticketId,
      partId: partId,
      quantity: 1,
    );
    expect((await readPart()).committedQuantity, 1);

    await database.deleteTicket(ticketId);
    expect((await readPart()).committedQuantity, 0);
  });
}
