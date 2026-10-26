import 'package:drift/drift.dart';

import 'database.dart';
import 'photo_store.dart';
import 'photo_templates.dart';

/// One row of the Tickets board.
class TicketBoardEntry {
  const TicketBoardEntry({
    required this.id,
    required this.number,
    required this.status,
    required this.customerName,
    required this.device,
    required this.complaint,
    required this.createdAt,
    this.shopTag,
    this.serial,
    this.serialMissing = false,
    this.deviceVariant,
    this.deviceSide,
  });

  final int id;
  final String number;
  final TicketStatus status;
  final String customerName;
  final String device;
  final String complaint;
  final DateTime createdAt;
  final String? shopTag;
  final String? serial;
  final bool serialMissing;

  /// Model number / revision typed on the ticket, e.g. `PSP-3000`.
  final String? deviceVariant;

  /// `left` or `right` when the device is booked one half at a time, e.g. a
  /// single Joy-Con.
  final String? deviceSide;

  /// Serial when recorded — factory or shop-applied — otherwise a note saying
  /// no serial was captured.
  String get identity =>
      serial ?? (serialMissing ? 'no serial sticker' : 'serial not recorded');

  /// `Sony PSP · PSP-3000` when a revision was noted, otherwise just the model.
  /// A single Joy-Con also carries its side: `Nintendo Joy-Con (single) · Left`.
  String get deviceWithVariant {
    final parts = [
      device,
      if (deviceSideLabel(deviceSide).isNotEmpty) deviceSideLabel(deviceSide),
      if (deviceVariant != null) deviceVariant!,
    ];
    return parts.join(' · ');
  }
}

/// Everything the ticket page shows.
class TicketDetailEntry {
  const TicketDetailEntry({
    required this.summary,
    this.diagnosis,
    this.notes,
    this.intakeNotes,
    this.report1CompletedAt,
    this.estimateCents = 0,
    this.dueAt,
    this.completedAt,
    this.pickedUpAt,
  });

  final TicketBoardEntry summary;
  final String? diagnosis;
  final String? notes;

  /// Report 1 condition notes: scratches, cracks, stickers, missing parts.
  final String? intakeNotes;

  /// When Report 1 was completed; `null` keeps Report 2 locked.
  final DateTime? report1CompletedAt;
  final int estimateCents;
  final DateTime? dueAt;
  final DateTime? completedAt;
  final DateTime? pickedUpAt;
}

class CustomerRecord {
  const CustomerRecord({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.notes,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final String? phone;
  final String? email;
  final String? notes;
  final DateTime updatedAt;
}

class CustomerDeviceEntry {
  const CustomerDeviceEntry({
    required this.id,
    required this.label,
    required this.serial,
    required this.serialMissing,
    this.modelId,
    this.category,
    this.modelName,
    this.deviceVariant,
    this.deviceSide,
  });

  final int id;
  final String label;
  final String? serial;
  final bool serialMissing;
  final int? modelId;
  final String? category;
  final String? modelName;
  final String? deviceVariant;
  final String? deviceSide;
}

/// A device the intake form can pick, flattened from category → brand → model.
class DeviceOption {
  const DeviceOption({
    required this.modelId,
    required this.category,
    required this.modelName,
    required this.label,
  });

  final int modelId;
  final String category;

  /// The bare catalog name, e.g. `3DS`, used to pick the photo checklist.
  final String modelName;

  /// e.g. `Nintendo 3DS`.
  final String label;
}

class InventoryPart {
  const InventoryPart({
    required this.id,
    required this.name,
    required this.stock,
    this.rawCostCents = 0,
    this.retailPriceCents = 0,
    this.sku,
    this.category,
    this.location,
  });

  final int id;
  final String name;
  final int stock;
  final int rawCostCents;
  final int retailPriceCents;
  final String? sku;
  final String? category;
  final String? location;
}

class RequiredPart {
  const RequiredPart({
    required this.ticketItemId,
    required this.partId,
    required this.name,
    required this.quantity,
    required this.stock,
    this.rawCostCents = 0,
    this.retailPriceCents = 0,
    this.sku,
    this.location,
  });

  final int ticketItemId;
  final int partId;
  final String name;
  final int quantity;
  final int stock;
  final int rawCostCents;
  final int retailPriceCents;
  final String? sku;
  final String? location;
}

class InvoiceLine {
  const InvoiceLine({
    required this.ticketItemId,
    required this.kind,
    required this.description,
    required this.quantity,
    required this.unitPriceCents,
  });

  final int ticketItemId;
  final TicketItemKind kind;
  final String description;
  final int quantity;
  final int unitPriceCents;

  int get lineTotalCents => quantity * unitPriceCents;
}

class InvoiceDraft {
  const InvoiceDraft({
    required this.discountKind,
    required this.discountValue,
    required this.lines,
  });

  final InvoiceDiscountKind discountKind;
  final int discountValue;
  final List<InvoiceLine> lines;

  int get subtotalCents =>
      lines.fold(0, (total, line) => total + line.lineTotalCents);

  int get discountCents {
    switch (discountKind) {
      case InvoiceDiscountKind.none:
        return 0;
      case InvoiceDiscountKind.percentage:
        return (subtotalCents * discountValue + 50) ~/ 100;
      case InvoiceDiscountKind.fixed:
        return discountValue > subtotalCents ? subtotalCents : discountValue;
    }
  }

  int get totalCents => subtotalCents - discountCents;
}

/// One numbered shot on a ticket's Report 1 checklist.
class TicketPhotoSlotEntry {
  const TicketPhotoSlotEntry({
    required this.sortOrder,
    required this.label,
    this.hint,
    this.required = true,
    this.photoPath,
  });

  final int sortOrder;
  final String label;
  final String? hint;
  final bool required;
  final String? photoPath;

  bool get captured => photoPath != null;
}

/// The Report 1 photo checklist copied onto a ticket at intake.
class PhotoChecklist {
  const PhotoChecklist({
    required this.templateKey,
    required this.templateName,
    required this.slots,
  });

  final String? templateKey;
  final String? templateName;
  final List<TicketPhotoSlotEntry> slots;

  bool get isEmpty => slots.isEmpty;
  bool get isComplete =>
      slots.isNotEmpty &&
      slots.every((slot) => slot.captured || !slot.required);
}

class TechnicalReportBlock {
  const TechnicalReportBlock({
    required this.id,
    required this.sortOrder,
    required this.kind,
    this.parentEntryId,
    this.text,
    this.photoPath,
    this.caption,
  });

  final int id;
  final int sortOrder;
  final TechnicalEntryKind kind;
  final int? parentEntryId;
  final String? text;
  final String? photoPath;
  final String? caption;
}

class ClientReportBlock {
  const ClientReportBlock({
    required this.id,
    required this.sortOrder,
    required this.kind,
    required this.contentEdited,
    required this.inclusionEdited,
    required this.included,
    this.sourceEntryId,
    this.parentSourceEntryId,
    this.text,
    this.photoPath,
    this.caption,
  });

  final int id;
  final int sortOrder;
  final TechnicalEntryKind kind;
  final bool contentEdited;
  final bool inclusionEdited;
  final bool included;
  final int? sourceEntryId;
  final int? parentSourceEntryId;
  final String? text;
  final String? photoPath;
  final String? caption;
}

/// `Sony PlayStation 5`, but `Nintendo 64` rather than `Nintendo Nintendo 64`
/// when the model name already carries the brand, and `ColecoVision` rather
/// than `Coleco ColecoVision`.
String deviceLabel(String brand, String model) {
  final prefix = brand.trim();
  final name = model.trim();
  if (prefix.isEmpty) return name;
  if (name.toLowerCase().startsWith(prefix.toLowerCase())) return name;
  return '$prefix $name';
}

/// `left` / `right` as shown to people; empty when the device has no side.
String deviceSideLabel(String? side) {
  switch (side) {
    case 'left':
      return 'Left';
    case 'right':
      return 'Right';
    default:
      return '';
  }
}

/// Whether intake should ask which half of a two-part device this is. A single
/// Joy-Con is booked on its own, so its model name does not identify the unit.
bool deviceSideRequired(String? modelName) =>
    modelName != null && modelName.toLowerCase().contains('(single)');

/// What the UI needs from storage. Kept as an interface so widget tests can run
/// without opening SQLite.
abstract class TicketsRepository {
  Stream<List<CustomerRecord>> watchCustomers();

  Future<List<CustomerRecord>> findCustomersByContact(String phoneOrEmail);

  Future<int> saveCustomer({
    int? customerId,
    required String name,
    required String phone,
    required String email,
    required String notes,
  });

  Stream<List<CustomerDeviceEntry>> watchCustomerDevices(int customerId);

  Stream<List<TicketBoardEntry>> watchCustomerTickets(int customerId);

  Stream<List<TicketBoardEntry>> watchBoard();

  Future<void> deleteTicket(int ticketId);

  Stream<List<InventoryPart>> watchInventoryParts();

  Stream<List<RequiredPart>> watchRequiredParts(int ticketId);

  Future<void> createInventoryPart({
    required String name,
    String? sku,
    String? category,
    String? location,
    required int startingStock,
    int rawCostCents = 0,
    int retailPriceCents = 0,
  });

  Future<void> updateInventoryPart({
    required int partId,
    required String name,
    String? sku,
    String? category,
    String? location,
    required int stock,
    required int rawCostCents,
    required int retailPriceCents,
  });

  Future<void> removeInventoryPart(int partId);

  Future<void> addRequiredPart({
    required int ticketId,
    required int partId,
    required int quantity,
  });

  Future<void> removeRequiredPart({
    required int ticketId,
    required int ticketItemId,
  });

  Stream<InvoiceDraft?> watchInvoice(int ticketId);

  Future<void> addInvoiceLaborLine({
    required int ticketId,
    required String description,
    required int quantity,
    required int unitPriceCents,
  });

  Future<void> removeInvoiceLaborLine({
    required int ticketId,
    required int ticketItemId,
  });

  Future<void> setInvoiceDiscount({
    required int ticketId,
    required InvoiceDiscountKind kind,
    required int value,
  });

  Stream<TicketDetailEntry?> watchTicket(int ticketId);

  /// The Report 1 shot list stored on the ticket, in the order it was seeded.
  Stream<PhotoChecklist> watchPhotoChecklist(int ticketId);

  Future<void> addOptionalPhotoSlot({
    required int ticketId,
    required String label,
  });

  Future<List<DeviceOption>> deviceCatalog();

  Future<List<String>> deviceCategories();

  /// A fresh `PFS-#########` for a device whose factory serial sticker is
  /// missing. Previewed in intake before the ticket exists.
  Future<String> nextShopSerial();

  /// Stores a photo captured on the paired phone and points the Report 1 slot
  /// at the new file. Retaking replaces the previous file. Returns the new
  /// file path.
  Future<String> savePhotoSlot({
    required int ticketId,
    required int sortOrder,
    required Uint8List bytes,
    required String extension,
  });

  /// Saves the Report 1 condition notes. Whitespace-only text clears the field.
  Future<void> saveIntakeNotes(int ticketId, String notes);

  /// Marks Report 1 complete (unlocking Report 2) or reopens it.
  Future<void> setReport1Completed(int ticketId, bool completed);

  Future<void> ensureTechnicalReports(int ticketId);

  Stream<List<TechnicalReportBlock>> watchTechnicalEntries(int ticketId);

  Stream<List<ClientReportBlock>> watchClientReportEntries(int ticketId);

  Future<void> addTechnicalNote(int ticketId);

  Future<String> addTechnicalPhoto({
    required int ticketId,
    required Uint8List bytes,
    required String extension,
    int? parentEntryId,
  });

  Future<void> updateTechnicalEntry({
    required int ticketId,
    required int entryId,
    required TechnicalEntryKind kind,
    String? text,
    String? caption,
  });

  Future<void> deleteTechnicalEntry(int ticketId, int entryId);

  Future<void> updateClientReportEntry({
    required int entryId,
    required TechnicalEntryKind kind,
    String? text,
    String? caption,
    bool? included,
  });

  Future<NewTicket> createTicket({
    int? customerId,
    required String customerName,
    required String customerPhone,
    required String customerEmail,
    int? deviceModelId,
    String? deviceName,
    String? deviceVariant,
    String? deviceSide,
    int? customerDeviceId,
    String? serial,
    bool serialMissing = false,
    String? photoTemplateKey,
    required String complaint,
  });

  Future<void> updateStatus(int ticketId, TicketStatus status);
}

class TicketPhotoCleanupException implements Exception {
  const TicketPhotoCleanupException(this.cause);

  final Object cause;

  @override
  String toString() => cause.toString();
}

/// SQLite implementation, backed by [AppDatabase].
class DriftTicketsRepository implements TicketsRepository {
  DriftTicketsRepository(this._db);

  final AppDatabase _db;

  late final Stream<List<TicketBoardEntry>> _board = _watchBoard();

  @override
  Stream<List<CustomerRecord>> watchCustomers() => (_db.select(_db.customers)
        ..orderBy([
          (customer) => OrderingTerm.asc(customer.name),
        ]))
      .watch()
      .map((rows) => [for (final row in rows) _customer(row)]);

  @override
  Future<List<CustomerRecord>> findCustomersByContact(
    String phoneOrEmail,
  ) async {
    final input = phoneOrEmail.trim().toLowerCase();
    final normalizedInput = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (input.isEmpty) return [];
    final rows = await _db.select(_db.customers).get();
    return [
      for (final row in rows)
        if ((row.email ?? '').toLowerCase().contains(input) ||
            (normalizedInput.isNotEmpty &&
                (row.phone ?? '')
                    .replaceAll(RegExp(r'[^0-9]'), '')
                    .contains(normalizedInput)))
          _customer(row),
    ];
  }

  @override
  Future<int> saveCustomer({
    int? customerId,
    required String name,
    required String phone,
    required String email,
    required String notes,
  }) =>
      _db.saveCustomer(
        customerId: customerId,
        name: name,
        phone: phone,
        email: email,
        notes: notes,
      );

  @override
  Stream<List<CustomerDeviceEntry>> watchCustomerDevices(int customerId) {
    final query = _db.select(_db.customerDevices).join([
      leftOuterJoin(
        _db.deviceModels,
        _db.deviceModels.id.equalsExp(_db.customerDevices.deviceModelId),
      ),
      leftOuterJoin(
        _db.deviceBrands,
        _db.deviceBrands.id.equalsExp(_db.deviceModels.brandId),
      ),
      leftOuterJoin(
        _db.deviceCategories,
        _db.deviceCategories.id.equalsExp(_db.deviceBrands.categoryId),
      ),
    ])
      ..where(_db.customerDevices.customerId.equals(customerId))
      ..orderBy([OrderingTerm.asc(_db.customerDevices.id)]);
    return query.watch().map(
          (rows) => [
            for (final row in rows)
              _customerDevice(
                row.readTable(_db.customerDevices),
                row.readTableOrNull(_db.deviceModels),
                row.readTableOrNull(_db.deviceBrands),
                row.readTableOrNull(_db.deviceCategories),
              ),
          ],
        );
  }

  @override
  Stream<List<TicketBoardEntry>> watchCustomerTickets(int customerId) =>
      (_ticketQuery()..where(_db.tickets.customerId.equals(customerId)))
          .watch()
          .map((rows) => [for (final row in rows) _readBoardRow(row)]);

  @override
  Stream<List<TicketBoardEntry>> watchBoard() => _board;

  @override
  Future<void> deleteTicket(int ticketId) async {
    final deleted = await _db.deleteTicket(ticketId);
    if (!deleted) return;
    try {
      await PhotoStore.deleteTicketPhotos(ticketId);
    } catch (error) {
      throw TicketPhotoCleanupException(error);
    }
  }

  @override
  Stream<List<InventoryPart>> watchInventoryParts() => (_db.select(_db.parts)
        ..where((part) => part.isActive.equals(true))
        ..orderBy([(part) => OrderingTerm.asc(part.name)]))
      .watch()
      .map(
        (rows) => [
          for (final part in rows)
            InventoryPart(
              id: part.id,
              name: part.name,
              stock: part.stock,
              rawCostCents: part.costCents,
              retailPriceCents: part.priceCents,
              sku: part.sku,
              category: part.category,
              location: part.location,
            ),
        ],
      );

  @override
  Stream<List<RequiredPart>> watchRequiredParts(int ticketId) {
    final query = _db.select(_db.ticketItems).join([
      innerJoin(
        _db.parts,
        _db.parts.id.equalsExp(_db.ticketItems.partId),
      ),
    ])
      ..where(
        _db.ticketItems.ticketId.equals(ticketId) &
            _db.ticketItems.kind.equals(TicketItemKind.part.index),
      )
      ..orderBy([OrderingTerm.asc(_db.ticketItems.id)]);
    return query.watch().map(
          (rows) => [
            for (final row in rows)
              RequiredPart(
                ticketItemId: row.readTable(_db.ticketItems).id,
                partId: row.readTable(_db.parts).id,
                name: row.readTable(_db.parts).name,
                quantity: row.readTable(_db.ticketItems).quantity,
                stock: row.readTable(_db.parts).stock,
                rawCostCents: row.readTable(_db.ticketItems).unitCostCents ??
                    row.readTable(_db.parts).costCents,
                retailPriceCents: row.readTable(_db.ticketItems).unitPriceCents,
                sku: row.readTable(_db.parts).sku,
                location: row.readTable(_db.parts).location,
              ),
          ],
        );
  }

  @override
  Stream<InvoiceDraft?> watchInvoice(int ticketId) {
    final query = _db.select(_db.tickets).join([
      leftOuterJoin(
        _db.ticketItems,
        _db.ticketItems.ticketId.equalsExp(_db.tickets.id),
      ),
      leftOuterJoin(
        _db.parts,
        _db.parts.id.equalsExp(_db.ticketItems.partId),
      ),
    ])
      ..where(_db.tickets.id.equals(ticketId))
      ..orderBy([OrderingTerm.asc(_db.ticketItems.id)]);
    return query.watch().map((rows) {
      if (rows.isEmpty) return null;
      final ticket = rows.first.readTable(_db.tickets);
      return InvoiceDraft(
        discountKind: ticket.invoiceDiscountKind,
        discountValue: ticket.invoiceDiscountValue,
        lines: [
          for (final row in rows)
            if (row.readTableOrNull(_db.ticketItems) case final item?)
              InvoiceLine(
                ticketItemId: item.id,
                kind: item.kind,
                description: item.description,
                quantity: item.quantity,
                unitPriceCents: item.unitPriceCents,
              ),
        ],
      );
    });
  }

  @override
  Future<void> addInvoiceLaborLine({
    required int ticketId,
    required String description,
    required int quantity,
    required int unitPriceCents,
  }) =>
      _db.addInvoiceLaborLine(
        ticketId: ticketId,
        description: description,
        quantity: quantity,
        unitPriceCents: unitPriceCents,
      );

  @override
  Future<void> removeInvoiceLaborLine({
    required int ticketId,
    required int ticketItemId,
  }) =>
      _db.removeInvoiceLaborLine(
        ticketId: ticketId,
        ticketItemId: ticketItemId,
      );

  @override
  Future<void> setInvoiceDiscount({
    required int ticketId,
    required InvoiceDiscountKind kind,
    required int value,
  }) =>
      _db.setInvoiceDiscount(
        ticketId: ticketId,
        kind: kind,
        value: value,
      );

  @override
  Future<void> createInventoryPart({
    required String name,
    String? sku,
    String? category,
    String? location,
    required int startingStock,
    int rawCostCents = 0,
    int retailPriceCents = 0,
  }) async {
    await _db.createInventoryPart(
      name: name,
      sku: sku,
      category: category,
      location: location,
      startingStock: startingStock,
      rawCostCents: rawCostCents,
      retailPriceCents: retailPriceCents,
    );
  }

  @override
  Future<void> updateInventoryPart({
    required int partId,
    required String name,
    String? sku,
    String? category,
    String? location,
    required int stock,
    required int rawCostCents,
    required int retailPriceCents,
  }) =>
      _db.updateInventoryPart(
        partId: partId,
        name: name,
        sku: sku,
        category: category,
        location: location,
        stock: stock,
        rawCostCents: rawCostCents,
        retailPriceCents: retailPriceCents,
      );

  @override
  Future<void> removeInventoryPart(int partId) =>
      _db.removeInventoryPart(partId);

  @override
  Future<void> addRequiredPart({
    required int ticketId,
    required int partId,
    required int quantity,
  }) =>
      _db.addRequiredPart(
        ticketId: ticketId,
        partId: partId,
        quantity: quantity,
      );

  @override
  Future<void> removeRequiredPart({
    required int ticketId,
    required int ticketItemId,
  }) =>
      _db.removeRequiredPart(
        ticketId: ticketId,
        ticketItemId: ticketItemId,
      );

  @override
  Stream<TicketDetailEntry?> watchTicket(int ticketId) {
    final query = _ticketQuery()..where(_db.tickets.id.equals(ticketId));
    return query.watchSingleOrNull().map((row) {
      if (row == null) return null;
      return TicketDetailEntry(
        summary: _readBoardRow(row),
        diagnosis: row.readTable(_db.tickets).diagnosis,
        notes: row.readTable(_db.tickets).notes,
        intakeNotes: row.readTable(_db.tickets).intakeNotes,
        report1CompletedAt: row.readTable(_db.tickets).report1CompletedAt,
        estimateCents: row.readTable(_db.tickets).estimateCents,
        dueAt: row.readTable(_db.tickets).dueAt,
        completedAt: row.readTable(_db.tickets).completedAt,
        pickedUpAt: row.readTable(_db.tickets).pickedUpAt,
      );
    });
  }

  @override
  Stream<PhotoChecklist> watchPhotoChecklist(int ticketId) {
    final query = _db.select(_db.ticketPhotoSlots)
      ..where((s) => s.ticketId.equals(ticketId))
      ..orderBy([(s) => OrderingTerm.asc(s.sortOrder)]);
    return query.watch().asyncMap((rows) async {
      final ticket = await (_db.select(_db.tickets)
            ..where((t) => t.id.equals(ticketId)))
          .getSingleOrNull();
      final key = ticket?.photoTemplateKey;
      final template = photoTemplateSeed(key);
      return PhotoChecklist(
        templateKey: key,
        templateName: key == 'general_electronics' &&
                (ticket?.deviceName ?? '').isNotEmpty
            ? ticket!.deviceName
            : template?.name,
        slots: [
          for (final row in rows)
            TicketPhotoSlotEntry(
              sortOrder: row.sortOrder,
              label: row.label,
              hint: row.hint,
              required: row.required,
              photoPath: row.photoPath,
            ),
        ],
      );
    });
  }

  @override
  Future<void> addOptionalPhotoSlot({
    required int ticketId,
    required String label,
  }) =>
      _db.addOptionalPhotoSlot(ticketId: ticketId, label: label);

  @override
  Future<List<DeviceOption>> deviceCatalog() async {
    final rows = await (_db.select(_db.deviceModels).join([
      innerJoin(
        _db.deviceBrands,
        _db.deviceBrands.id.equalsExp(_db.deviceModels.brandId),
      ),
      innerJoin(
        _db.deviceCategories,
        _db.deviceCategories.id.equalsExp(_db.deviceBrands.categoryId),
      ),
    ])
          ..where(_db.deviceModels.isActive.equals(true))
          ..orderBy([
            OrderingTerm.asc(_db.deviceCategories.sortOrder),
            OrderingTerm.asc(_db.deviceBrands.name),
            OrderingTerm.asc(_db.deviceModels.sortOrder),
            OrderingTerm.asc(_db.deviceModels.name),
          ]))
        .get();

    return [
      for (final row in rows)
        DeviceOption(
          modelId: row.readTable(_db.deviceModels).id,
          category: row.readTable(_db.deviceCategories).name,
          modelName: row.readTable(_db.deviceModels).name,
          label: deviceLabel(
            row.readTable(_db.deviceBrands).name,
            row.readTable(_db.deviceModels).name,
          ),
        ),
    ];
  }

  @override
  Future<List<String>> deviceCategories() async {
    final rows = await (_db.select(_db.deviceCategories)
          ..where((category) => category.isActive.equals(true))
          ..orderBy([(category) => OrderingTerm.asc(category.sortOrder)]))
        .get();
    return [for (final category in rows) category.name];
  }

  @override
  Future<String> nextShopSerial() => _db.nextShopSerial();

  @override
  Future<String> savePhotoSlot({
    required int ticketId,
    required int sortOrder,
    required Uint8List bytes,
    required String extension,
  }) async {
    final path = await PhotoStore.saveTicketSlot(
      ticketId: ticketId,
      sortOrder: sortOrder,
      bytes: bytes,
      extension: extension,
    );
    await _db.setTicketPhotoPath(
      ticketId: ticketId,
      sortOrder: sortOrder,
      path: path,
    );
    return path;
  }

  @override
  Future<void> saveIntakeNotes(int ticketId, String notes) =>
      _db.setTicketIntakeNotes(ticketId, notes);

  @override
  Future<void> setReport1Completed(int ticketId, bool completed) =>
      _db.setReport1Completed(ticketId, completed);

  @override
  Future<void> ensureTechnicalReports(int ticketId) =>
      _db.ensureTechnicalReports(ticketId);

  @override
  Stream<List<TechnicalReportBlock>> watchTechnicalEntries(int ticketId) {
    final query = _db.select(_db.technicalReportEntries).join([
      innerJoin(
        _db.ticketReports,
        _db.ticketReports.id.equalsExp(_db.technicalReportEntries.reportId),
      ),
    ])
      ..where(
        _db.ticketReports.ticketId.equals(ticketId) &
            _db.ticketReports.kind.equals(ReportKind.technical.index),
      )
      ..orderBy([
        OrderingTerm.asc(_db.technicalReportEntries.sortOrder),
        OrderingTerm.asc(_db.technicalReportEntries.id),
      ]);
    return query.watch().map(
          (rows) => [
            for (final row in rows)
              _technicalEntry(row.readTable(_db.technicalReportEntries)),
          ],
        );
  }

  @override
  Stream<List<ClientReportBlock>> watchClientReportEntries(int ticketId) {
    final query = _db.select(_db.clientReportEntries).join([
      innerJoin(
        _db.ticketReports,
        _db.ticketReports.id.equalsExp(_db.clientReportEntries.reportId),
      ),
    ])
      ..where(
        _db.ticketReports.ticketId.equals(ticketId) &
            _db.ticketReports.kind.equals(ReportKind.client.index) &
            _db.ticketReports.status.equals(ReportStatus.draft.index),
      )
      ..orderBy([
        OrderingTerm.asc(_db.clientReportEntries.sortOrder),
        OrderingTerm.asc(_db.clientReportEntries.id),
      ]);
    return query.watch().map(
          (rows) => [
            for (final row in rows)
              _clientReportEntry(row.readTable(_db.clientReportEntries)),
          ],
        );
  }

  @override
  Future<void> addTechnicalNote(int ticketId) async {
    await _db.addTechnicalEntry(
      ticketId: ticketId,
      kind: TechnicalEntryKind.note,
    );
  }

  @override
  Future<String> addTechnicalPhoto({
    required int ticketId,
    required Uint8List bytes,
    required String extension,
    int? parentEntryId,
  }) async {
    final path = await PhotoStore.saveReportPhoto(
      ticketId: ticketId,
      bytes: bytes,
      extension: extension,
    );
    await _db.addTechnicalEntry(
      ticketId: ticketId,
      kind: TechnicalEntryKind.photo,
      parentEntryId: parentEntryId,
      photoPath: path,
    );
    return path;
  }

  @override
  Future<void> updateTechnicalEntry({
    required int ticketId,
    required int entryId,
    required TechnicalEntryKind kind,
    String? text,
    String? caption,
  }) =>
      _db.updateTechnicalEntry(
        ticketId: ticketId,
        entryId: entryId,
        kind: kind,
        text: text,
        caption: caption,
      );

  @override
  Future<void> deleteTechnicalEntry(int ticketId, int entryId) =>
      _db.deleteTechnicalEntry(ticketId: ticketId, entryId: entryId);

  @override
  Future<void> updateClientReportEntry({
    required int entryId,
    required TechnicalEntryKind kind,
    String? text,
    String? caption,
    bool? included,
  }) =>
      _db.updateClientReportEntry(
        entryId: entryId,
        kind: kind,
        text: text,
        caption: caption,
        included: included,
      );

  @override
  Future<NewTicket> createTicket({
    int? customerId,
    required String customerName,
    required String customerPhone,
    required String customerEmail,
    int? deviceModelId,
    String? deviceName,
    String? deviceVariant,
    String? deviceSide,
    int? customerDeviceId,
    String? serial,
    bool serialMissing = false,
    String? photoTemplateKey,
    required String complaint,
  }) {
    return _db.createTicket(
      existingCustomerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      customerEmail: customerEmail,
      deviceModelId: deviceModelId,
      deviceName: deviceName,
      deviceVariant: deviceVariant,
      deviceSide: deviceSide,
      customerDeviceId: customerDeviceId,
      serial: serial,
      serialMissing: serialMissing,
      photoTemplateKey: photoTemplateKey,
      complaint: complaint,
    );
  }

  @override
  Future<void> updateStatus(int ticketId, TicketStatus status) =>
      _db.setTicketStatus(ticketId, status);

  Stream<List<TicketBoardEntry>> _watchBoard() {
    return _ticketQuery().watch().map(
          (rows) => [for (final row in rows) _readBoardRow(row)],
        );
  }

  JoinedSelectStatement<HasResultSet, dynamic> _ticketQuery() {
    return _db.select(_db.tickets).join([
      innerJoin(
        _db.customers,
        _db.customers.id.equalsExp(_db.tickets.customerId),
      ),
      leftOuterJoin(
        _db.deviceModels,
        _db.deviceModels.id.equalsExp(_db.tickets.deviceModelId),
      ),
    ])
      ..orderBy([OrderingTerm.desc(_db.tickets.createdAt)]);
  }

  TicketBoardEntry _readBoardRow(TypedResult row) {
    final ticket = row.readTable(_db.tickets);
    final customer = row.readTable(_db.customers);
    final model = row.readTableOrNull(_db.deviceModels);
    return TicketBoardEntry(
      id: ticket.id,
      number: ticket.number,
      status: ticket.status,
      customerName: customer.name,
      device: model?.name ?? ticket.deviceName ?? 'Unlisted device',
      complaint: ticket.complaint,
      createdAt: ticket.createdAt,
      shopTag: ticket.shopTag,
      serial: ticket.serial,
      serialMissing: ticket.serialMissing,
      deviceVariant: ticket.deviceVariant,
      deviceSide: ticket.deviceSide,
    );
  }

  TechnicalReportBlock _technicalEntry(TechnicalReportEntry entry) {
    return TechnicalReportBlock(
      id: entry.id,
      sortOrder: entry.sortOrder,
      kind: entry.kind,
      parentEntryId: entry.parentEntryId,
      text: entry.body,
      photoPath: entry.photoPath,
      caption: entry.caption,
    );
  }

  ClientReportBlock _clientReportEntry(ClientReportEntry entry) {
    return ClientReportBlock(
      id: entry.id,
      sortOrder: entry.sortOrder,
      kind: entry.kind,
      contentEdited: entry.contentEdited,
      inclusionEdited: entry.inclusionEdited,
      included: entry.included,
      sourceEntryId: entry.sourceEntryId,
      parentSourceEntryId: entry.parentSourceEntryId,
      text: entry.body,
      photoPath: entry.photoPath,
      caption: entry.caption,
    );
  }

  CustomerRecord _customer(Customer row) => CustomerRecord(
        id: row.id,
        name: row.name,
        phone: row.phone,
        email: row.email,
        notes: row.notes,
        updatedAt: row.updatedAt,
      );

  CustomerDeviceEntry _customerDevice(
    CustomerDevice row,
    DeviceModel? model,
    DeviceBrand? brand,
    DeviceCategory? category,
  ) {
    final label = model == null
        ? row.deviceName ?? 'Unspecified device'
        : deviceLabel(brand?.name ?? '', model.name);
    return CustomerDeviceEntry(
      id: row.id,
      label: label,
      serial: row.serial,
      serialMissing: row.serialMissing,
      modelId: model?.id,
      category: category?.name,
      modelName: model?.name,
      deviceVariant: row.deviceVariant,
      deviceSide: row.deviceSide,
    );
  }
}
