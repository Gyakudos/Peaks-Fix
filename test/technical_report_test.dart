import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vola_fix/data/database.dart';
import 'package:vola_fix/data/tickets_repository.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.withExecutor(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('technical entries sync into the client draft without overwriting edits',
      () async {
    final ticket = await database.createTicket(
      customerName: 'Test Customer',
      customerPhone: '555-0100',
      customerEmail: 'test@example.com',
      deviceName: 'Test console',
      complaint: 'Does not power on',
    );
    await database.ensureTechnicalReports(ticket.id);

    final technicalReport = await (database.select(database.ticketReports)
          ..where((report) =>
              report.ticketId.equals(ticket.id) &
              report.kind.equals(ReportKind.technical.index)))
        .getSingle();
    final clientReport = await (database.select(database.ticketReports)
          ..where((report) =>
              report.ticketId.equals(ticket.id) &
              report.kind.equals(ReportKind.client.index)))
        .getSingle();

    final noteId = await database.addTechnicalEntry(
      ticketId: ticket.id,
      kind: TechnicalEntryKind.note,
      text: 'Bench observation',
    );
    final photoId = await database.addTechnicalEntry(
      ticketId: ticket.id,
      kind: TechnicalEntryKind.photo,
      parentEntryId: noteId,
      photoPath: 'report-photo.jpg',
      caption: 'Corroded power connector',
    );

    var copied = await (database.select(database.clientReportEntries)
          ..where((entry) => entry.reportId.equals(clientReport.id))
          ..orderBy([(entry) => OrderingTerm.asc(entry.sortOrder)]))
        .get();
    expect(copied, hasLength(2));
    expect(copied.map((entry) => entry.sourceEntryId), [noteId, photoId]);
    expect(copied.last.photoPath, 'report-photo.jpg');
    expect(copied.last.parentSourceEntryId, noteId);

    await database.updateClientReportEntry(
      entryId: copied.first.id,
      kind: TechnicalEntryKind.note,
      text: 'Customer-friendly explanation',
    );
    await database.updateTechnicalEntry(
      ticketId: ticket.id,
      entryId: noteId,
      kind: TechnicalEntryKind.note,
      text: 'Updated internal bench observation',
    );
    await database.updateClientReportEntry(
      entryId: copied.last.id,
      kind: TechnicalEntryKind.photo,
      included: false,
    );
    await database.updateTechnicalEntry(
      ticketId: ticket.id,
      entryId: photoId,
      kind: TechnicalEntryKind.photo,
      caption: 'Connector corrosion at close range',
    );

    copied = await (database.select(database.clientReportEntries)
          ..where((entry) => entry.reportId.equals(clientReport.id))
          ..orderBy([(entry) => OrderingTerm.asc(entry.sortOrder)]))
        .get();
    expect(copied.first.body, 'Customer-friendly explanation');
    expect(copied.first.contentEdited, isTrue);
    expect(copied.last.caption, 'Connector corrosion at close range');
    expect(copied.last.included, isFalse);
    expect(copied.last.inclusionEdited, isTrue);
    expect(technicalReport.kind, ReportKind.technical);
  });

  test('deleting a ticket removes report data and retains customer and tag',
      () async {
    final ticket = await database.createTicket(
      customerName: 'Retained Customer',
      customerPhone: '555-0101',
      customerEmail: 'retained@example.com',
      deviceName: 'Test console',
      complaint: 'Does not power on',
    );
    await database.ensureTechnicalReports(ticket.id);
    await database.addTechnicalEntry(
      ticketId: ticket.id,
      kind: TechnicalEntryKind.note,
      text: 'Bench observation',
    );
    await database.into(database.ticketPhotoSlots).insert(
          TicketPhotoSlotsCompanion.insert(
            ticketId: ticket.id,
            sortOrder: 1,
            label: 'Front',
          ),
        );
    await database.into(database.ticketItems).insert(
          TicketItemsCompanion.insert(
            ticketId: ticket.id,
            kind: TicketItemKind.custom,
            description: 'Bench fee',
            unitPriceCents: const Value(500),
          ),
        );
    await database.into(database.payments).insert(
          PaymentsCompanion.insert(
            ticketId: ticket.id,
            amountCents: 500,
            method: PaymentMethod.cash,
            kind: PaymentKind.deposit,
          ),
        );

    final deleted = await database.deleteTicket(ticket.id);

    expect(deleted, isTrue);
    expect(
      await (database.select(database.tickets)
            ..where((row) => row.id.equals(ticket.id)))
          .getSingleOrNull(),
      equals(null),
    );
    expect(
      await (database.select(database.ticketReports)
            ..where((row) => row.ticketId.equals(ticket.id)))
          .get(),
      isEmpty,
    );
    expect(
        await database.select(database.technicalReportEntries).get(), isEmpty);
    expect(await database.select(database.clientReportEntries).get(), isEmpty);
    expect(await database.select(database.ticketPhotoSlots).get(), isEmpty);
    expect(await database.select(database.ticketItems).get(), isEmpty);
    expect(await database.select(database.payments).get(), isEmpty);
    expect(
      await (database.select(database.customers)
            ..where((row) => row.id.equals(ticket.customerId)))
          .getSingleOrNull(),
      isNot(equals(null)),
    );
    final tag = await (database.select(database.shopTags)
          ..where((row) => row.tag.equals(ticket.shopTag)))
        .getSingle();
    expect(tag.ticketId, equals(null));
    expect(await database.deleteTicket(ticket.id), isFalse);
  });

  test('required ticket parts link inventory without changing stock', () async {
    final ticket = await database.createTicket(
      customerName: 'Parts Customer',
      customerPhone: '555-0102',
      customerEmail: 'parts@example.com',
      deviceName: 'Test console',
      complaint: 'Damaged charging port',
    );
    final partId = await database.createInventoryPart(
      name: 'USB-C charging port',
      sku: 'USB-C-01',
      category: 'Ports',
      location: 'Shelf A1',
      startingStock: 4,
      rawCostCents: 1234,
      retailPriceCents: 1666,
    );

    await database.addRequiredPart(
      ticketId: ticket.id,
      partId: partId,
      quantity: 1,
    );
    await database.addRequiredPart(
      ticketId: ticket.id,
      partId: partId,
      quantity: 2,
    );

    final linked = await (database.select(database.ticketItems)
          ..where((item) => item.ticketId.equals(ticket.id)))
        .getSingle();
    final part = await (database.select(database.parts)
          ..where((row) => row.id.equals(partId)))
        .getSingle();
    expect(linked.kind, TicketItemKind.part);
    expect(linked.partId, partId);
    expect(linked.quantity, 3);
    expect(linked.unitPriceCents, 1666);
    expect(linked.unitCostCents, 1234);
    expect(part.stock, 4);
    expect(part.costCents, 1234);
    expect(part.priceCents, 1666);

    await database.updateInventoryPart(
      partId: partId,
      name: 'USB-C replacement port',
      sku: 'USB-C-02',
      category: 'Ports',
      location: 'Bin B4',
      stock: 6,
      rawCostCents: 2000,
      retailPriceCents: 2700,
    );
    final edited = await (database.select(database.parts)
          ..where((row) => row.id.equals(partId)))
        .getSingle();
    expect(edited.name, 'USB-C replacement port');
    expect(edited.sku, 'USB-C-02');
    expect(edited.location, 'Bin B4');
    expect(edited.stock, 6);
    expect(edited.costCents, 2000);
    expect(edited.priceCents, 2700);
    final movements = await (database.select(database.partMovements)
          ..where((movement) => movement.partId.equals(partId))
          ..orderBy([(movement) => OrderingTerm.asc(movement.id)]))
        .get();
    expect(movements.map((movement) => movement.delta), [4, 2]);

    await database.removeRequiredPart(
      ticketId: ticket.id,
      ticketItemId: linked.id,
    );
    expect(
      await (database.select(database.ticketItems)
            ..where((item) => item.ticketId.equals(ticket.id)))
          .get(),
      isEmpty,
    );
  });

  test('invoice totals required parts, labor, and discounts', () async {
    final ticket = await database.createTicket(
      customerName: 'Invoice Customer',
      customerPhone: '555-0104',
      customerEmail: 'invoice@example.com',
      deviceName: 'Test console',
      complaint: 'Needs repair',
    );
    final partId = await database.createInventoryPart(
      name: 'Replacement part',
      startingStock: 2,
      rawCostCents: 800,
      retailPriceCents: 1666,
    );
    await database.addRequiredPart(
      ticketId: ticket.id,
      partId: partId,
      quantity: 2,
    );
    await database.addInvoiceLaborLine(
      ticketId: ticket.id,
      description: 'Repair labor',
      quantity: 1,
      unitPriceCents: 2500,
    );
    await database.setInvoiceDiscount(
      ticketId: ticket.id,
      kind: InvoiceDiscountKind.percentage,
      value: 10,
    );

    final repository = DriftTicketsRepository(database);
    var invoice = await repository.watchInvoice(ticket.id).first;
    expect(invoice, isA<InvoiceDraft>());
    expect(invoice!.lines, hasLength(2));
    expect(invoice.subtotalCents, 5832);
    expect(invoice.discountCents, 583);
    expect(invoice.totalCents, 5249);

    await database.setInvoiceDiscount(
      ticketId: ticket.id,
      kind: InvoiceDiscountKind.fixed,
      value: 7000,
    );
    invoice = await repository.watchInvoice(ticket.id).first;
    expect(invoice!.discountKind, InvoiceDiscountKind.fixed);
    expect(invoice.discountCents, invoice.subtotalCents);
    expect(invoice.totalCents, 0);
  });

  test('customer devices link multiple repair tickets to one record', () async {
    final repository = DriftTicketsRepository(database);
    final first = await database.createTicket(
      customerName: 'Device History Customer',
      customerPhone: '(555) 0105',
      customerEmail: 'device-history@example.com',
      deviceName: 'Test handheld',
      serial: 'ABC123',
      complaint: 'First repair',
    );
    final second = await database.createTicket(
      existingCustomerId: first.customerId,
      customerName: 'Device History Customer',
      customerPhone: '555-0105',
      customerEmail: 'device-history@example.com',
      customerDeviceId: first.customerDeviceId,
      deviceName: 'Test handheld',
      serial: 'ABC123',
      complaint: 'Second repair',
    );

    expect(first.customerDeviceId, isA<int>());
    expect(second.customerDeviceId, first.customerDeviceId);
    final customer = (await repository.watchCustomers().first).single;
    expect(customer.name, 'Device History Customer');
    expect(customer.phone, '555-0105');

    final devices =
        await repository.watchCustomerDevices(first.customerId).first;
    expect(devices, hasLength(1));
    expect(devices.single.serial, 'ABC123');

    final tickets =
        await repository.watchCustomerTickets(first.customerId).first;
    expect(tickets.map((ticket) => ticket.complaint),
        containsAll(['First repair', 'Second repair']));

    final contactMatches =
        await repository.findCustomersByContact('device-history@example.com');
    expect(contactMatches.map((match) => match.id), [first.customerId]);

    await repository.saveCustomer(
      customerId: first.customerId,
      name: 'Updated Customer',
      phone: '555-0105',
      email: 'device-history@example.com',
      notes: 'Prefers text',
    );
    expect(
      (await repository.watchCustomers().first).single.notes,
      'Prefers text',
    );
  });

  test('device catalog includes common vacuum models by brand', () async {
    await database.ensureSeeded();
    final repository = DriftTicketsRepository(database);
    final catalog = await repository.deviceCatalog();
    final vacuums =
        catalog.where((device) => device.category == 'Vacuum').toList();

    expect(vacuums, isNotEmpty);
    expect(
      vacuums.map((device) => device.label),
      containsAll([
        'Dyson V8',
        'Dyson V15 Detect',
        'Kirby Avalir 2',
        'Kirby Sentria II',
        'Dirt Devil Scorpion',
        'Dirt Devil Endura Reach',
        'Shark Navigator Lift-Away',
        'Shark Stratos',
      ]),
    );
    expect(
      await repository.deviceCategories(),
      contains('General Electronics'),
    );
  });

  test('vacuum checklist has three required shots and optional photo slots',
      () async {
    await database.ensureSeeded();
    final catalog = await DriftTicketsRepository(database).deviceCatalog();
    final vacuum = catalog.firstWhere(
      (device) => device.category == 'Vacuum' && device.modelName == 'V8',
    );
    final ticket = await database.createTicket(
      customerName: 'Vacuum Customer',
      customerPhone: '555-0111',
      customerEmail: 'vacuum@example.com',
      deviceModelId: vacuum.modelId,
      serial: 'VAC-001',
      complaint: 'Not charging',
    );
    final repository = DriftTicketsRepository(database);
    var checklist = await repository.watchPhotoChecklist(ticket.id).first;

    expect(checklist.templateName, 'Vacuum');
    expect(checklist.slots.map((slot) => slot.label),
        ['Front', 'Back', 'Charge Port']);
    expect(checklist.slots.every((slot) => slot.required), isTrue);

    await repository.addOptionalPhotoSlot(
      ticketId: ticket.id,
      label: 'Cracked dust bin',
    );
    checklist = await repository.watchPhotoChecklist(ticket.id).first;
    expect(checklist.slots, hasLength(4));
    expect(checklist.slots.last.label, 'Cracked dust bin');
    expect(checklist.slots.last.required, isFalse);
    expect(checklist.isComplete, isFalse);

    for (final slot in checklist.slots.where((slot) => slot.required)) {
      await database.setTicketPhotoPath(
        ticketId: ticket.id,
        sortOrder: slot.sortOrder,
        path: 'vacuum-${slot.sortOrder}.jpg',
      );
    }
    checklist = await repository.watchPhotoChecklist(ticket.id).first;
    expect(checklist.isComplete, isTrue);
    expect(checklist.slots.last.captured, isFalse);
  });

  test('general electronics checklist uses the device name and photo slots',
      () async {
    await database.ensureSeeded();
    final ticket = await database.createTicket(
      customerName: 'Electronics Customer',
      customerPhone: '555-0112',
      customerEmail: 'electronics@example.com',
      deviceName: 'Ninja Grill',
      photoTemplateKey: 'general_electronics',
      serial: 'NG-001',
      complaint: 'Does not heat',
    );

    final checklist = await DriftTicketsRepository(database)
        .watchPhotoChecklist(ticket.id)
        .first;
    expect(checklist.templateName, 'Ninja Grill');
    expect(
      checklist.slots.map((slot) => slot.label),
      ['Front', 'Back', 'Details', 'Serial / model label'],
    );
    expect(checklist.slots.every((slot) => slot.required), isTrue);
  });

  test('removing an inventory part keeps linked ticket history', () async {
    final ticket = await database.createTicket(
      customerName: 'History Customer',
      customerPhone: '555-0103',
      customerEmail: 'history@example.com',
      deviceName: 'Test console',
      complaint: 'Needs a replacement port',
    );
    final partId = await database.createInventoryPart(
      name: 'USB-C charging port',
      startingStock: 3,
    );
    await database.addRequiredPart(
      ticketId: ticket.id,
      partId: partId,
      quantity: 1,
    );

    await database.removeInventoryPart(partId);

    final part = await (database.select(database.parts)
          ..where((row) => row.id.equals(partId)))
        .getSingle();
    final linkedItems = await (database.select(database.ticketItems)
          ..where((item) => item.ticketId.equals(ticket.id)))
        .get();
    final activeParts = await (database.select(database.parts)
          ..where((row) => row.isActive.equals(true)))
        .get();
    expect(part.isActive, isFalse);
    expect(linkedItems, hasLength(1));
    expect(linkedItems.single.partId, partId);
    expect(activeParts, isEmpty);
  });
}
