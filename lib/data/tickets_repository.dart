import 'package:drift/drift.dart';

import 'database.dart';
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

  /// Serial when it exists, otherwise the shop tag that replaces it.
  String get identity =>
      serial ?? (serialMissing ? 'no serial sticker' : 'serial not recorded');

  /// `Sony PSP · PSP-3000` when a revision was noted, otherwise just the model.
  String get deviceWithVariant =>
      deviceVariant == null ? device : '$device · $deviceVariant';
}

/// Everything the ticket page shows.
class TicketDetailEntry {
  const TicketDetailEntry({
    required this.summary,
    this.diagnosis,
    this.notes,
    this.estimateCents = 0,
    this.dueAt,
    this.completedAt,
    this.pickedUpAt,
  });

  final TicketBoardEntry summary;
  final String? diagnosis;
  final String? notes;
  final int estimateCents;
  final DateTime? dueAt;
  final DateTime? completedAt;
  final DateTime? pickedUpAt;
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

/// What the UI needs from storage. Kept as an interface so widget tests can run
/// without opening SQLite.
abstract class TicketsRepository {
  Stream<List<TicketBoardEntry>> watchBoard();

  Stream<TicketDetailEntry?> watchTicket(int ticketId);

  /// The Report 1 shot list stored on the ticket, in the order it was seeded.
  Stream<PhotoChecklist> watchPhotoChecklist(int ticketId);

  Future<List<DeviceOption>> deviceCatalog();

  Future<NewTicket> createTicket({
    required String customerName,
    required String customerPhone,
    required String customerEmail,
    int? deviceModelId,
    String? deviceName,
    String? deviceVariant,
    String? serial,
    bool serialMissing = false,
    String? photoTemplateKey,
    required String complaint,
  });

  Future<void> updateStatus(int ticketId, TicketStatus status);
}

/// SQLite implementation, backed by [AppDatabase].
class DriftTicketsRepository implements TicketsRepository {
  DriftTicketsRepository(this._db);

  final AppDatabase _db;

  late final Stream<List<TicketBoardEntry>> _board = _watchBoard();

  @override
  Stream<List<TicketBoardEntry>> watchBoard() => _board;

  @override
  Stream<TicketDetailEntry?> watchTicket(int ticketId) {
    final query = _ticketQuery()..where(_db.tickets.id.equals(ticketId));
    return query.watchSingleOrNull().map((row) {
      if (row == null) return null;
      return TicketDetailEntry(
        summary: _readBoardRow(row),
        diagnosis: row.readTable(_db.tickets).diagnosis,
        notes: row.readTable(_db.tickets).notes,
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
      return PhotoChecklist(
        templateKey: key,
        templateName: photoTemplateSeed(key)?.name,
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
  Future<NewTicket> createTicket({
    required String customerName,
    required String customerPhone,
    required String customerEmail,
    int? deviceModelId,
    String? deviceName,
    String? deviceVariant,
    String? serial,
    bool serialMissing = false,
    String? photoTemplateKey,
    required String complaint,
  }) {
    return _db.createTicket(
      customerName: customerName,
      customerPhone: customerPhone,
      customerEmail: customerEmail,
      deviceModelId: deviceModelId,
      deviceName: deviceName,
      deviceVariant: deviceVariant,
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
    );
  }
}
