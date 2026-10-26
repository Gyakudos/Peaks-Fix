import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'photo_templates.dart';

part 'database.g.dart';

/// Where a ticket is in the repair workflow.
enum TicketStatus {
  received,
  diagnosing,
  awaitingApproval,
  awaitingParts,
  inRepair,
  testing,
  ready,
  pickedUp,
  closed,
  cancelled,
}

extension TicketStatusLabel on TicketStatus {
  String get label => switch (this) {
        TicketStatus.received => 'Received',
        TicketStatus.diagnosing => 'Diagnosing',
        TicketStatus.awaitingApproval => 'Awaiting approval',
        TicketStatus.awaitingParts => 'Awaiting parts',
        TicketStatus.inRepair => 'In repair',
        TicketStatus.testing => 'Testing',
        TicketStatus.ready => 'Ready',
        TicketStatus.pickedUp => 'Picked up',
        TicketStatus.closed => 'Closed',
        TicketStatus.cancelled => 'Cancelled',
      };

  /// Still in the shop, i.e. on the board above the finished jobs.
  bool get isActive =>
      this != TicketStatus.pickedUp &&
      this != TicketStatus.closed &&
      this != TicketStatus.cancelled;
}

/// The three reports per ticket; see `REPORTS.md`.
enum ReportKind { intake, technical, client }

enum ReportStatus { draft, finalised, sent }

/// Fixed intake shots plus free-form extras. The first five are required.
enum PhotoSlot { leftSide, rightSide, front, back, serialLabel, extra }

/// When the shot was taken, so the client report can pair before and after.
enum PhotoStage { intake, repair, completion }

enum CosmeticCondition { good, scuffed, scratched, cracked, missing }

enum Severity { low, medium, high }

enum TicketItemKind { service, part, custom }

enum PaymentKind { deposit, balance, refund }

enum PaymentMethod { cash, card, other }

enum ContactMethod { phone, text, email, inPerson }

enum ContactOutcome { contacted, approved, declined, noAnswer }

enum ReportOutcome { repaired, unrepairable, declined, noFaultFound }

class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class DeviceCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {name},
      ];
}

class DeviceBrands extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(DeviceCategories, #id)();
  TextColumn get name => text().withLength(min: 1, max: 60)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {categoryId, name},
      ];
}

class DeviceModels extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get brandId => integer().references(DeviceBrands, #id)();
  TextColumn get name => text().withLength(min: 1, max: 80)();

  /// Position inside the brand's model list. Seeded models are numbered, so the
  /// picker can show `DualShock 1 … 4, DualSense 5` in generation order instead
  /// of alphabetically. `0` means "not chosen yet" and sorts after the rest.
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// Free-form specs (serial format, RAM/SSD, ...) so new categories do not
  /// need a schema change.
  TextColumn get attributes => text().withDefault(const Constant('{}'))();

  /// Which Report 1 photo checklist this model gets, e.g. `hinged`.
  TextColumn get photoTemplateKey => text().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {brandId, name},
      ];
}

/// Report 1 photo checklists, one per device family (hinged handheld, slab,
/// console, PC, controller). Templates are seeded and can be edited; each
/// ticket copies its slots at intake so later edits never rewrite an open job.
class PhotoTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get key => text().withLength(min: 1, max: 40)();
  TextColumn get name => text().withLength(min: 1, max: 80)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {key},
      ];
}

class PhotoTemplateSlots extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get templateId => integer().references(PhotoTemplates, #id)();
  IntColumn get sortOrder => integer()();
  TextColumn get label => text().withLength(min: 1, max: 80)();
  TextColumn get hint => text().nullable()();
  BoolColumn get required => boolean().withDefault(const Constant(true))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {templateId, sortOrder},
      ];
}

class Services extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  IntColumn get categoryId =>
      integer().nullable().references(DeviceCategories, #id)();
  IntColumn get defaultPriceCents => integer().withDefault(const Constant(0))();
  IntColumn get defaultMinutes => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

class Tickets extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Human-facing job number, e.g. `VF-000123`. Never reused.
  TextColumn get number => text().withLength(min: 1, max: 24)();

  IntColumn get customerId => integer().references(Customers, #id)();

  /// Null when the device is not in the catalog yet; [deviceName] is then the
  /// free-text description.
  IntColumn get deviceModelId =>
      integer().nullable().references(DeviceModels, #id)();
  TextColumn get deviceName => text().nullable()();

  /// Model number or variant within a catalog family, e.g. `PSP-3000`,
  /// `New 3DS XL`, `PS5 Slim (disc)`. Kept free-text so one catalog row can
  /// cover a whole family without inventing rows for every revision.
  TextColumn get deviceVariant => text().nullable()();

  /// Which half of a two-part device this job is: `left` or `right`. Set for a
  /// single Joy-Con, where the model alone does not identify the unit.
  TextColumn get deviceSide => text().nullable()();

  TextColumn get serial => text().nullable()();

  /// No readable factory serial/IMEI sticker was present. The shop tag still
  /// identifies the unit; this flag records why the serial is blank.
  BoolColumn get serialMissing =>
      boolean().withDefault(const Constant(false))();

  /// The tag currently stuck on the device, e.g. `G-482913057`. The full issue
  /// history lives in [ShopTags]; this is the value printed on the paperwork.
  TextColumn get shopTag => text().nullable()();

  TextColumn get complaint => text()();
  TextColumn get diagnosis => text().nullable()();

  /// Report 1 checklist family this job was booked under, e.g. `hinged`. The
  /// slots themselves are copied into [TicketPhotoSlots] at intake.
  TextColumn get photoTemplateKey => text().nullable()();

  IntColumn get status => intEnum<TicketStatus>()();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  IntColumn get estimateCents => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get dueAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get pickedUpAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {number},
      ];
}

/// Shop-applied tracking stickers: a random number such as `G-482913057`,
/// written once and never issued again. Two copies go on each device — one on
/// the outside, one inside. The tag is what identifies a unit at pickup, in the
/// workshop and on the client report, even when the factory serial is gone.
class ShopTags extends Table {
  TextColumn get tag => text().withLength(min: 1, max: 24)();

  /// Null only if the ticket was removed; the tag is kept either way so it can
  /// never be handed out a second time.
  IntColumn get ticketId => integer().nullable().references(Tickets, #id)();

  DateTimeColumn get issuedAt => dateTime().withDefault(currentDateAndTime)();

  /// Set when a sticker is lost and replaced, so only one tag is current.
  DateTimeColumn get retiredAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {tag};
}

class TicketItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get ticketId => integer().references(Tickets, #id)();
  IntColumn get kind => intEnum<TicketItemKind>()();
  IntColumn get serviceId => integer().nullable().references(Services, #id)();
  IntColumn get partId => integer().nullable().references(Parts, #id)();
  TextColumn get description => text()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  IntColumn get unitPriceCents => integer().withDefault(const Constant(0))();
  IntColumn get unitCostCents => integer().nullable()();
}

class TicketPhotos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get ticketId => integer().references(Tickets, #id)();
  IntColumn get slot => intEnum<PhotoSlot>()();

  /// Intake "before" shots, repair progress, or completion "after" shots.
  IntColumn get stage => intEnum<PhotoStage>().withDefault(const Constant(0))();
  TextColumn get path => text()();
  TextColumn get caption => text().nullable()();
  BoolColumn get visibleToClient =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get takenAt => dateTime().withDefault(currentDateAndTime)();
}

/// The Report 1 checklist as it was at intake, copied from
/// [PhotoTemplateSlots] so editing a template later leaves this job alone.
///
/// [photoPath] stays null until the shot is captured; the "Final" stage is the
/// only one that needs every slot filled.
class TicketPhotoSlots extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get ticketId => integer().references(Tickets, #id)();
  IntColumn get sortOrder => integer()();
  TextColumn get label => text().withLength(min: 1, max: 80)();
  TextColumn get hint => text().nullable()();
  BoolColumn get required => boolean().withDefault(const Constant(true))();
  TextColumn get photoPath => text().nullable()();
  DateTimeColumn get capturedAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {ticketId, sortOrder},
      ];
}

class TicketReports extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get ticketId => integer().references(Tickets, #id)();
  IntColumn get kind => intEnum<ReportKind>()();
  IntColumn get status => intEnum<ReportStatus>()();
  TextColumn get author => text().withLength(min: 1, max: 120)();

  /// Bumped when a sent report is edited; earlier revisions are kept.
  IntColumn get revision => integer().withDefault(const Constant(1))();

  // Client-report overrides. Everything else is projected from the ticket.
  TextColumn get summary => text().nullable()();

  /// Warranty length in days, counted from [warrantyStartAt].
  IntColumn get warrantyDays => integer().nullable()();

  /// Start of cover — normally the pickup/completion date, captured when the
  /// client report is finalised, not when it was drafted.
  DateTimeColumn get warrantyStartAt => dateTime().nullable()();

  /// What the warranty covers and excludes, frozen with this revision.
  TextColumn get warrantyTerms => text().nullable()();

  IntColumn get outcome => intEnum<ReportOutcome>().nullable()();

  /// Shop tag printed on this revision, e.g. `G-482913057`. Copied in when the
  /// report is written so a sent report keeps the tag it was issued with, even
  /// if the sticker is later replaced.
  TextColumn get shopTag => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get finalizedAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {ticketId, kind, revision},
      ];
}

class ReportCosmeticItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get reportId => integer().references(TicketReports, #id)();
  TextColumn get area => text().withLength(min: 1, max: 60)();
  IntColumn get condition => intEnum<CosmeticCondition>()();
  TextColumn get note => text().nullable()();
}

class ReportFindings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get reportId => integer().references(TicketReports, #id)();
  TextColumn get area => text().withLength(min: 1, max: 60)();
  TextColumn get symptom => text()();
  TextColumn get cause => text().nullable()();
  IntColumn get severity => intEnum<Severity>()();
  TextColumn get proposedFix => text().nullable()();
}

class ReportContactLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get reportId => integer().references(TicketReports, #id)();
  DateTimeColumn get at => dateTime().withDefault(currentDateAndTime)();
  IntColumn get method => intEnum<ContactMethod>()();
  IntColumn get outcome => intEnum<ContactOutcome>()();
  TextColumn get note => text().nullable()();
}

class Parts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get sku => text().nullable()();
  TextColumn get category => text().nullable()();
  IntColumn get stock => integer().withDefault(const Constant(0))();
  IntColumn get costCents => integer().withDefault(const Constant(0))();
  IntColumn get priceCents => integer().withDefault(const Constant(0))();
  IntColumn get reorderLevel => integer().withDefault(const Constant(0))();
  TextColumn get supplier => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

class PartMovements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get partId => integer().references(Parts, #id)();
  IntColumn get ticketId => integer().nullable().references(Tickets, #id)();
  IntColumn get delta => integer()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get at => dateTime().withDefault(currentDateAndTime)();
}

class MerchProducts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get category => text().nullable()();
  TextColumn get description => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

class MerchVariants extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().references(MerchProducts, #id)();

  /// Size / colour / fit, e.g. `L / Black`.
  TextColumn get label => text().withLength(min: 1, max: 60)();
  TextColumn get sku => text().nullable()();
  TextColumn get barcode => text().nullable()();
  IntColumn get stock => integer().withDefault(const Constant(0))();
  IntColumn get costCents => integer().withDefault(const Constant(0))();
  IntColumn get priceCents => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {productId, label},
      ];
}

class MerchSales extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get number => text().withLength(min: 1, max: 24)();
  IntColumn get customerId => integer().nullable().references(Customers, #id)();
  DateTimeColumn get at => dateTime().withDefault(currentDateAndTime)();
  IntColumn get paymentMethod => intEnum<PaymentMethod>()();
  IntColumn get totalCents => integer().withDefault(const Constant(0))();
  TextColumn get note => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {number},
      ];
}

class MerchSaleLines extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleId => integer().references(MerchSales, #id)();
  IntColumn get variantId => integer().references(MerchVariants, #id)();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  IntColumn get unitPriceCents => integer()();
  IntColumn get unitCostCents => integer().nullable()();
}

class Payments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get ticketId => integer().references(Tickets, #id)();
  DateTimeColumn get at => dateTime().withDefault(currentDateAndTime)();
  IntColumn get amountCents => integer()();
  IntColumn get method => intEnum<PaymentMethod>()();
  IntColumn get kind => intEnum<PaymentKind>()();
  TextColumn get note => text().nullable()();
}

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [
  Customers,
  DeviceCategories,
  DeviceBrands,
  DeviceModels,
  PhotoTemplates,
  PhotoTemplateSlots,
  Services,
  Tickets,
  ShopTags,
  TicketItems,
  TicketPhotos,
  TicketPhotoSlots,
  TicketReports,
  ReportCosmeticItems,
  ReportFindings,
  ReportContactLog,
  Parts,
  PartMovements,
  MerchProducts,
  MerchVariants,
  MerchSales,
  MerchSaleLines,
  Payments,
  Settings,
])
class AppDatabase extends _$AppDatabase {
  /// The database lives with the app's own support files, never in Documents:
  /// a shop database must not sync to OneDrive or be casually moved.
  AppDatabase()
      : super(
          driftDatabase(
            name: 'vola_fix',
            native: const DriftNativeOptions(
              databaseDirectory: getApplicationSupportDirectory,
            ),
          ),
        );

  AppDatabase.withExecutor(super.executor);

  /// One database for the app. Local-first; no server, no accounts.
  static final AppDatabase instance = AppDatabase();

  /// Secure source for shop tags: a random number tells the customer nothing
  /// about how many jobs the shop has done.
  static final Random _random = Random.secure();

  @override
  int get schemaVersion => 5;

  /// v2 added `tickets.device_variant` (model number / revision note).
  /// v3 added per-device Report 1 checklists: templates, a template key on the
  /// model and ticket, and the slot snapshot copied at intake.
  /// v4 added `device_models.sort_order` so the picker follows the catalog's
  /// own order (controllers 1 → 5) rather than the alphabet.
  /// v5 added `tickets.device_side` for devices booked one half at a time,
  /// starting with the single Joy-Con.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(tickets, tickets.deviceVariant);
          }
          if (from < 3) {
            await m.createTable(photoTemplates);
            await m.createTable(photoTemplateSlots);
            await m.addColumn(deviceModels, deviceModels.photoTemplateKey);
            await m.addColumn(tickets, tickets.photoTemplateKey);
            await m.createTable(ticketPhotoSlots);
          }
          if (from < 4) {
            await m.addColumn(deviceModels, deviceModels.sortOrder);
          }
          if (from < 5) {
            await m.addColumn(tickets, tickets.deviceSide);
          }
        },
      );

  Future<String> _setting(String key, String fallback) async {
    final row = await (select(settings)..where((s) => s.key.equals(key)))
        .getSingleOrNull();
    return row?.value ?? fallback;
  }

  Future<void> _putSetting(String key, String value) async {
    await into(settings).insertOnConflictUpdate(
      SettingsCompanion.insert(key: key, value: value),
    );
  }

  /// Creates the catalog and default settings on first run, and adds anything
  /// new to an existing catalog on later runs.
  ///
  /// Everything is matched by name: a row is only inserted when it is missing,
  /// so shop edits (renames, prices, custom models) are never overwritten.
  Future<void> ensureSeeded() async {
    await transaction(() async {
      const defaults = <(String, String)>[
        ('shop_name', 'Vola Fix'),
        ('ticket_prefix', 'VF'),
        ('tag_prefix', 'G'),
        ('ticket_seq', '0'),
        ('currency', 'CAD'),
        ('warranty_days', '90'),
        (
          'warranty_terms',
          'Covers the work and parts listed on this report for the period '
              'shown. Excludes accidental or liquid damage, tampering or '
              'repairs by anyone else, normal wear, software or account '
              'problems, and data loss. The shop tag must still be on the '
              'device.',
        ),
      ];
      for (final (key, value) in defaults) {
        await into(settings).insert(
          SettingsCompanion.insert(key: key, value: value),
          mode: InsertMode.insertOrIgnore,
        );
      }

      Future<void> photoTemplate(PhotoTemplateSeed seed) async {
        final row = await (select(photoTemplates)
              ..where((t) => t.key.equals(seed.key)))
            .getSingleOrNull();
        final templateId = row?.id ??
            await into(photoTemplates).insert(
              PhotoTemplatesCompanion.insert(key: seed.key, name: seed.name),
            );
        for (var index = 0; index < seed.slots.length; index++) {
          final slot = seed.slots[index];
          final sortOrder = index + 1;
          final existing = await (select(photoTemplateSlots)
                ..where(
                  (s) =>
                      s.templateId.equals(templateId) &
                      s.sortOrder.equals(sortOrder),
                ))
              .getSingleOrNull();
          if (existing != null) continue;
          await into(photoTemplateSlots).insert(
            PhotoTemplateSlotsCompanion.insert(
              templateId: templateId,
              sortOrder: sortOrder,
              label: slot.label,
              hint: Value(slot.hint),
            ),
          );
        }
      }

      for (final seed in photoTemplateSeeds) {
        await photoTemplate(seed);
      }

      Future<int> category(String name, int sortOrder) async {
        final row = await (select(deviceCategories)
              ..where((c) => c.name.equals(name)))
            .getSingleOrNull();
        if (row != null) return row.id;
        return into(deviceCategories).insert(
          DeviceCategoriesCompanion.insert(
            name: name,
            sortOrder: Value(sortOrder),
          ),
        );
      }

      Future<int> brand(int categoryId, String name) async {
        final row = await (select(deviceBrands)
              ..where(
                (b) => b.categoryId.equals(categoryId) & b.name.equals(name),
              ))
            .getSingleOrNull();
        if (row != null) return row.id;
        return into(deviceBrands).insert(
          DeviceBrandsCompanion.insert(categoryId: categoryId, name: name),
        );
      }

      Future<void> model(int brandId, String name, int sortOrder) async {
        final row = await (select(deviceModels)
              ..where((m) => m.brandId.equals(brandId) & m.name.equals(name)))
            .getSingleOrNull();
        if (row == null) {
          await into(deviceModels).insert(
            DeviceModelsCompanion.insert(
              brandId: brandId,
              name: name,
              sortOrder: Value(sortOrder),
            ),
          );
          return;
        }
        // Keep the whole seeded list in catalog order. Renumbering also repairs
        // positions when a model is inserted into the middle of a list, while
        // shop-added models (never in the seed) keep their own value.
        if (row.sortOrder != sortOrder) {
          await (update(deviceModels)..where((m) => m.id.equals(row.id)))
              .write(DeviceModelsCompanion(sortOrder: Value(sortOrder)));
        }
      }

      Future<void> service(String name, int priceCents, int minutes) async {
        final row = await (select(services)..where((s) => s.name.equals(name)))
            .getSingleOrNull();
        if (row != null) return;
        await into(services).insert(
          ServicesCompanion.insert(
            name: name,
            defaultPriceCents: Value(priceCents),
            defaultMinutes: Value(minutes),
          ),
        );
      }

      final consoles = await category('Consoles', 0);
      final retro = await category('Retro consoles', 1);
      final portables = await category('Portable Consoles', 2);
      final handhelds = await category('Handheld PCs', 3);
      final controllers = await category('Controllers', 4);

      // Built-in categories moved down when new ones were inserted ahead of
      // them (Handheld PCs was 1, then 2; Controllers was 3). Only values below
      // the current slot are rewritten, so a deliberate ordering is left alone.
      await (update(deviceCategories)
            ..where((c) =>
                c.name.equals('Handheld PCs') &
                c.sortOrder.isSmallerThanValue(3)))
          .write(const DeviceCategoriesCompanion(sortOrder: Value(3)));
      await (update(deviceCategories)
            ..where((c) =>
                c.name.equals('Controllers') &
                c.sortOrder.isSmallerThanValue(4)))
          .write(const DeviceCategoriesCompanion(sortOrder: Value(4)));

      final catalog = <(int, String, List<String>)>[
        (
          consoles,
          'Sony',
          ['PlayStation 5', 'PlayStation 5 Slim', 'PlayStation 4'],
        ),
        (
          consoles,
          'Microsoft',
          ['Xbox Series X', 'Xbox Series S', 'Xbox One'],
        ),
        (
          consoles,
          'Nintendo',
          ['Switch 2', 'Switch OLED', 'Switch', 'Switch Lite'],
        ),
        // The retro shelf: consoles the shop sees for caps, lasers, cartridge
        // slots and save batteries rather than HDMI ports.
        (
          retro,
          'Nintendo',
          [
            'Nintendo Entertainment System (NES)',
            'Super NES (SNES)',
            'Nintendo 64',
            'GameCube',
            'Wii',
          ],
        ),
        (
          retro,
          'Sega',
          [
            'Master System',
            'Genesis / Mega Drive',
            'Saturn',
            'Dreamcast',
          ],
        ),
        (
          retro,
          'Sony',
          ['PlayStation (PS1)', 'PlayStation 2 (fat)', 'PlayStation 2 Slim'],
        ),
        (
          retro,
          'Atari',
          ['2600', '5200', '7800', 'Jaguar'],
        ),
        (
          retro,
          'NEC',
          ['TurboGrafx-16 / PC Engine'],
        ),
        (
          retro,
          'SNK',
          ['Neo Geo AES', 'Neo Geo CD'],
        ),
        (
          retro,
          'Microsoft',
          ['Xbox (original)'],
        ),
        (
          retro,
          'Coleco',
          ['ColecoVision'],
        ),
        (
          retro,
          'Mattel',
          ['Intellivision'],
        ),
        (
          retro,
          '3DO',
          ['3DO Interactive Multiplayer'],
        ),
        (
          retro,
          'Philips',
          ['CD-i'],
        ),
        // Handheld consoles: separate from Retro consoles because they are
        // brought in for screens, batteries and charge ports at least as often
        // as for recaps, and separate from Handheld PCs (Steam Deck class).
        (
          portables,
          'Nintendo',
          [
            'Game Boy',
            'Game Boy Color',
            'Game Boy Advance',
            'Game Boy Advance SP',
            'DS',
            'DS Lite',
            'DSi',
            '3DS',
            '3DS XL',
            'New 3DS',
            'New 3DS XL',
            '2DS',
            '2DS XL',
          ],
        ),
        (
          portables,
          'Sony',
          ['PSP', 'PS Vita', 'PS Vita Slim'],
        ),
        (
          portables,
          'Sega',
          ['Game Gear', 'Nomad'],
        ),
        (
          portables,
          'Atari',
          ['Lynx'],
        ),
        (
          portables,
          'SNK',
          ['Neo Geo Pocket Color'],
        ),
        (
          portables,
          'Bandai',
          ['WonderSwan', 'WonderSwan Color'],
        ),
        (
          portables,
          'NEC',
          ['TurboExpress'],
        ),
        (
          handhelds,
          'Valve',
          ['Steam Deck LCD', 'Steam Deck OLED'],
        ),
        (
          handhelds,
          'ASUS',
          ['ROG Ally', 'ROG Ally X'],
        ),
        (
          handhelds,
          'Lenovo',
          ['Legion Go'],
        ),
        (
          handhelds,
          'MSI',
          ['Claw'],
        ),
        // Controllers are their own category: stick drift, triggers, USB ports
        // and shell swaps, with no console to bring in alongside them.
        (
          controllers,
          'Sony',
          [
            'DualShock 1 (PS1)',
            'DualShock 2 (PS2)',
            'DualShock 3 (PS3)',
            'DualShock 4 (PS4)',
            'DualSense 5 (PS5)',
          ],
        ),
        (
          controllers,
          'Microsoft',
          [
            'Xbox Wireless Controller (Series X|S)',
            'Xbox Elite Series 2',
            'Xbox One Controller',
          ],
        ),
        (
          controllers,
          'Nintendo',
          [
            'Switch 2 Pro Controller',
            'Switch Pro Controller',
            'Joy-Con (pair)',
            'Joy-Con (single)',
            'GameCube Controller',
          ],
        ),
        (
          controllers,
          '8BitDo',
          ['Pro 2', 'Ultimate'],
        ),
      ];

      // Renames of seeded rows, applied before the catalog below so the new
      // name is not inserted twice. Labels are brand + model, so a model that
      // repeated the brand read badly in the picker.
      final renames = <(String, String)>[
        ('Super Nintendo (SNES)', 'Super NES (SNES)'),
        ('DualSense (PS5)', 'DualSense 5 (PS5)'),
      ];
      for (final (from, to) in renames) {
        final row = await (select(deviceModels)
              ..where((m) => m.name.equals(from)))
            .getSingleOrNull();
        if (row != null) {
          await (update(deviceModels)..where((m) => m.id.equals(row.id)))
              .write(DeviceModelsCompanion(name: Value(to)));
        }
      }

      // One catalog row per family: the PSP revisions are retired instead of
      // deleted, so an existing ticket keeps resolving its original model.
      // The shop types the revision (`PSP-3000`) into the ticket's model note.
      const retiredModels = <String>[
        'PSP-1000',
        'PSP-2000',
        'PSP-3000',
        'PSP Go',
      ];
      for (final name in retiredModels) {
        await (update(deviceModels)
              ..where((m) => m.name.equals(name) & m.isActive.equals(true)))
            .write(const DeviceModelsCompanion(isActive: Value(false)));
      }

      for (final (categoryId, brandName, models) in catalog) {
        final brandId = await brand(categoryId, brandName);
        for (var index = 0; index < models.length; index++) {
          await model(brandId, models[index], index + 1);
        }
      }

      // Anything still unordered is shop-added rather than seeded. Park it after
      // the seeded models for its brand instead of ahead of them.
      await (update(deviceModels)..where((m) => m.sortOrder.equals(0)))
          .write(const DeviceModelsCompanion(sortOrder: Value(1000)));

      // Every catalog model gets its Report 1 family. Only blank keys are
      // filled, so a shop that changes a model's checklist keeps that choice.
      final unkeyed = await (select(deviceModels).join([
        innerJoin(
          deviceBrands,
          deviceBrands.id.equalsExp(deviceModels.brandId),
        ),
        innerJoin(
          deviceCategories,
          deviceCategories.id.equalsExp(deviceBrands.categoryId),
        ),
      ])
            ..where(deviceModels.photoTemplateKey.isNull()))
          .get();
      for (final row in unkeyed) {
        final model = row.readTable(deviceModels);
        await (update(deviceModels)..where((m) => m.id.equals(model.id))).write(
          DeviceModelsCompanion(
            photoTemplateKey: Value(
              photoTemplateKeyFor(
                row.readTable(deviceCategories).name,
                model.name,
              ),
            ),
          ),
        );
      }

      const serviceCatalog = <(String, int, int)>[
        ('Diagnostics', 5000, 30),
        ('HDMI port replacement', 12000, 120),
        ('USB-C port replacement', 10000, 120),
        ('Screen / digitizer replacement', 15000, 90),
        ('Battery replacement', 8000, 45),
        ('Thermal repaste', 6000, 60),
        ('Deep clean', 4000, 45),
        ('Button / stick replacement', 5000, 45),
        ('Capacitor replacement (recap)', 9000, 120),
        ('Disc drive / laser service', 12000, 120),
        ('Cartridge slot cleaning', 2500, 30),
        ('Save battery replacement', 4000, 45),
      ];
      for (final (name, priceCents, minutes) in serviceCatalog) {
        await service(name, priceCents, minutes);
      }
    });
  }

  /// Next job number, e.g. `VF-000123`.
  ///
  /// Numbered from a counter in [settings] rather than the row id, so deleting
  /// a ticket can never cause a number to be reused.
  Future<String> nextTicketNumber() => transaction(_allocateTicketNumber);

  Future<String> _allocateTicketNumber() async {
    final prefix = await _setting('ticket_prefix', 'VF');
    final current = int.tryParse(await _setting('ticket_seq', '0')) ?? 0;
    final next = current + 1;
    await _putSetting('ticket_seq', '$next');
    return '$prefix-${next.toString().padLeft(6, '0')}';
  }

  /// Issues a shop tag, e.g. `G-482913057`: the prefix from settings plus nine
  /// random digits.
  ///
  /// Every tag is recorded in [shopTags] and is never issued twice, even after
  /// a ticket is deleted. Two stickers are printed per tag — one for the
  /// outside of the device, one for the inside. When [ticketId] is given the
  /// ticket's current tag is updated to match.
  Future<String> issueShopTag({int? ticketId}) =>
      transaction(() => _allocateShopTag(ticketId: ticketId));

  Future<String> _allocateShopTag({int? ticketId}) async {
    final prefix = await _setting('tag_prefix', 'G');
    for (var attempt = 0; attempt < 64; attempt++) {
      final digits = _random.nextInt(1000000000).toString().padLeft(9, '0');
      final tag = '$prefix-$digits';
      final taken = await (select(shopTags)..where((t) => t.tag.equals(tag)))
          .getSingleOrNull();
      if (taken != null) {
        continue;
      }
      await into(shopTags).insert(
        ShopTagsCompanion.insert(tag: tag, ticketId: Value(ticketId)),
      );
      if (ticketId != null) {
        await (update(tickets)..where((t) => t.id.equals(ticketId))).write(
          TicketsCompanion(
              shopTag: Value(tag), updatedAt: Value(DateTime.now())),
        );
      }
      return tag;
    }
    throw StateError('Could not allocate an unused shop tag.');
  }

  /// The tag currently on the device, or null if none has been issued yet.
  Future<String?> shopTagFor(int ticketId) async {
    final row = await (select(shopTags)
          ..where((t) => t.ticketId.equals(ticketId) & t.retiredAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.issuedAt)])
          ..limit(1))
        .getSingleOrNull();
    return row?.tag;
  }

  /// Retires the current tag and issues a replacement, for when a sticker is
  /// lost or damaged. The old number is kept on record but never reused.
  Future<String> replaceShopTag(int ticketId) {
    return transaction(() async {
      await (update(shopTags)
            ..where(
              (t) => t.ticketId.equals(ticketId) & t.retiredAt.isNull(),
            ))
          .write(ShopTagsCompanion(retiredAt: Value(DateTime.now())));
      return _allocateShopTag(ticketId: ticketId);
    });
  }

  /// Creates a customer if needed and the ticket, in one transaction: number,
  /// row and shop tag either all exist or none do.
  ///
  /// Phone and email are required: the shop has to be able to reach the owner
  /// of a device it is holding, and the client report is sent by email.
  Future<NewTicket> createTicket({
    required String customerName,
    required String customerPhone,
    required String customerEmail,
    int? deviceModelId,
    String? deviceName,
    String? deviceVariant,
    String? deviceSide,
    String? serial,
    bool serialMissing = false,
    String? photoTemplateKey,
    required String complaint,
  }) {
    return transaction(() async {
      final name = customerName.trim();
      final phone = customerPhone.trim();
      final email = customerEmail.trim();
      final side = (deviceSide ?? '').trim().toLowerCase();
      if (side.isNotEmpty && side != 'left' && side != 'right') {
        throw ArgumentError.value(deviceSide, 'deviceSide', 'left or right');
      }
      if (phone.isEmpty) {
        throw ArgumentError.value(customerPhone, 'customerPhone', 'required');
      }
      if (email.isEmpty) {
        throw ArgumentError.value(customerEmail, 'customerEmail', 'required');
      }

      // Resolve the Report 1 family before the ticket row is written, so the
      // ticket and its slot snapshot agree from the start. A catalog model's
      // own key wins (the shop can override it); free-text devices use the key
      // the intake form derived from the chosen category.
      var templateKey = (photoTemplateKey ?? '').trim().isEmpty
          ? null
          : photoTemplateKey!.trim();
      if (deviceModelId != null) {
        final row = await (select(deviceModels).join([
          innerJoin(
            deviceBrands,
            deviceBrands.id.equalsExp(deviceModels.brandId),
          ),
          innerJoin(
            deviceCategories,
            deviceCategories.id.equalsExp(deviceBrands.categoryId),
          ),
        ])
              ..where(deviceModels.id.equals(deviceModelId)))
            .getSingleOrNull();
        final model = row?.readTable(deviceModels);
        if (model != null) {
          templateKey = model.photoTemplateKey ??
              templateKey ??
              photoTemplateKeyFor(
                row!.readTable(deviceCategories).name,
                model.name,
              );
        }
      }

      final existing = await (select(customers)
            ..where((c) => c.name.lower().equals(name.toLowerCase())))
          .getSingleOrNull();
      final customerId = existing?.id ??
          await into(customers).insert(
            CustomersCompanion.insert(
              name: name,
              phone: Value(phone),
              email: Value(email),
            ),
          );

      // A returning customer keeps their history, but the contact details on
      // the newest job win: phone numbers and addresses change.
      if (existing != null) {
        await (update(customers)..where((c) => c.id.equals(existing.id))).write(
          CustomersCompanion(
            phone: Value(phone),
            email: Value(email),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }

      final number = await _allocateTicketNumber();
      final ticketId = await into(tickets).insert(
        TicketsCompanion.insert(
          number: number,
          customerId: customerId,
          deviceModelId: Value(deviceModelId),
          deviceName: Value(
            (deviceName ?? '').trim().isEmpty ? null : deviceName!.trim(),
          ),
          deviceVariant: Value(
            (deviceVariant ?? '').trim().isEmpty ? null : deviceVariant!.trim(),
          ),
          deviceSide: Value(side.isEmpty ? null : side),
          serial: Value(
            (serial ?? '').trim().isEmpty ? null : serial!.trim(),
          ),
          serialMissing: Value(serialMissing),
          complaint: complaint.trim(),
          photoTemplateKey: Value(templateKey),
          status: TicketStatus.received,
        ),
      );
      final tag = await _allocateShopTag(ticketId: ticketId);

      // Copy the checklist onto the job. Editing the template later must not
      // change a job that is already open, and the slots keep their order.
      if (templateKey != null) {
        final template = await (select(photoTemplates)
              ..where((t) => t.key.equals(templateKey!)))
            .getSingleOrNull();
        if (template != null) {
          final slots = await (select(photoTemplateSlots)
                ..where((s) => s.templateId.equals(template.id))
                ..orderBy([(s) => OrderingTerm.asc(s.sortOrder)]))
              .get();
          for (final slot in slots) {
            await into(ticketPhotoSlots).insert(
              TicketPhotoSlotsCompanion.insert(
                ticketId: ticketId,
                sortOrder: slot.sortOrder,
                label: slot.label,
                hint: Value(slot.hint),
                required: Value(slot.required),
              ),
            );
          }
        }
      }

      return NewTicket(
        id: ticketId,
        number: number,
        shopTag: tag,
        customerId: customerId,
      );
    });
  }

  /// Moves a ticket along the workflow. Never blocked: a solo shop works out of
  /// order, so this only records what happened.
  Future<void> setTicketStatus(int ticketId, TicketStatus status) async {
    await (update(tickets)..where((t) => t.id.equals(ticketId))).write(
      TicketsCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
        completedAt: Value(
          status == TicketStatus.ready || status == TicketStatus.pickedUp
              ? DateTime.now()
              : null,
        ),
        pickedUpAt: Value(
          status == TicketStatus.pickedUp ? DateTime.now() : null,
        ),
      ),
    );
  }
}

/// What [AppDatabase.createTicket] hands back: enough to open the new ticket
/// and to print the shop tag.
class NewTicket {
  const NewTicket({
    required this.id,
    required this.number,
    required this.shopTag,
    required this.customerId,
  });

  final int id;
  final String number;
  final String shopTag;
  final int customerId;
}
