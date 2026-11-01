import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'part_skus.dart';
import 'photo_templates.dart';
import 'taxes.dart';
import 'ticket_due.dart';
import 'warranty.dart';

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

  /// A priced-up estimate with no intake. Appended last so stored status
  /// indexes keep their meaning; it expires after [quoteLifetimeDays].
  quote,
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
        TicketStatus.quote => 'Quote',
      };

  /// Still in the shop, i.e. on the board above the finished jobs.
  bool get isActive =>
      this != TicketStatus.pickedUp &&
      this != TicketStatus.closed &&
      this != TicketStatus.cancelled &&
      this != TicketStatus.quote;
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

/// Whether an inventory category marks a shop supply: something used up on a
/// repair (thermal paste, flux) that is listed on the invoice but not billed.
bool isShopSupplyCategory(String? category) => const {
      'shop',
      'supplies',
      'shop supply',
      'shop supplies',
    }.contains((category ?? '').trim().toLowerCase());

/// Discount on an invoice: the manual discount (on the whole subtotal) plus
/// the partner's percentages of the parts and of the labour, capped at the
/// subtotal.
int invoiceDiscountCentsFor({
  required int subtotalCents,
  required int partsCents,
  required int labourCents,
  required InvoiceDiscountKind kind,
  required int value,
  int partnerPartsPercent = 0,
  int partnerLabourPercent = 0,
}) {
  final manual = switch (kind) {
    InvoiceDiscountKind.none => 0,
    InvoiceDiscountKind.percentage => (subtotalCents * value + 50) ~/ 100,
    InvoiceDiscountKind.fixed => value,
  };
  final partner = (partsCents * partnerPartsPercent + 50) ~/ 100 +
      (labourCents * partnerLabourPercent + 50) ~/ 100;
  return (manual + partner).clamp(0, subtotalCents).toInt();
}

/// A part that comes with a labour item. It is listed on the invoice at no
/// charge, because its cost is covered by the labour price.
class LabourIncludedPart {
  const LabourIncludedPart({required this.partId, required this.quantity});

  final int partId;
  final int quantity;
}

bool isLabourCategory(String? category) =>
    (category ?? '').trim().toLowerCase() == 'labour';

const _labourPartsSettingKey = 'labour_included_parts';

Map<int, List<LabourIncludedPart>> _decodeLabourParts(String? raw) {
  if (raw == null || raw.isEmpty) return const {};
  try {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return {
      for (final entry in decoded.entries)
        int.parse(entry.key): [
          for (final item in entry.value as List<dynamic>)
            LabourIncludedPart(
              partId: (item as Map<String, dynamic>)['p'] as int,
              quantity: item['q'] as int,
            ),
        ],
    };
  } catch (_) {
    return const {};
  }
}

/// What one unit of [part] bills when first added to an invoice. Shop supplies
/// start free; the invoice's "R" box switches a line to the retail price.
int _billedUnitCents(Part part) =>
    isShopSupplyCategory(part.category) ? 0 : part.priceCents;

enum InvoiceDiscountKind { none, percentage, fixed }

/// Whether a part was bought on its own or as part of a bulk lot.
enum PartPurchaseType { single, bulk, tube }

extension PartPurchaseTypeLabel on PartPurchaseType {
  String get label => switch (this) {
        PartPurchaseType.single => 'Single item',
        PartPurchaseType.bulk => 'Bulk purchase',
        PartPurchaseType.tube => 'Tube',
      };

  /// Bought as a lot (or tube) whose cost is split across [Parts.bulkQuantity]
  /// items or uses.
  bool get isLot => this != PartPurchaseType.single;
}

enum PaymentKind { deposit, balance, refund }

/// Appended last: the index is what gets stored.
enum PaymentMethod {
  cash('Cash'),
  card('Card'),
  other('Other'),
  eTransfer('E-transfer');

  const PaymentMethod(this.label);

  final String label;
}

/// Thrown to roll back a sale when the card payment was declined or cancelled.
class PaymentCancelledException implements Exception {
  const PaymentCancelledException();

  @override
  String toString() => 'Payment cancelled';
}

enum ContactMethod { phone, text, email, inPerson }

enum ContactOutcome { contacted, approved, declined, noAnswer }

enum ReportOutcome { repaired, unrepairable, declined, noFaultFound }

enum TechnicalEntryKind { note, photo }

class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class CustomerDevices extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get customerId => integer().references(Customers, #id)();
  IntColumn get deviceModelId =>
      integer().nullable().references(DeviceModels, #id)();
  TextColumn get deviceName => text().nullable()();
  TextColumn get deviceVariant => text().nullable()();
  TextColumn get deviceSide => text().nullable()();
  TextColumn get serial => text().nullable()();
  BoolColumn get serialMissing =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class DeviceCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// Warranty length offered on Report 3 for devices in this category.
  IntColumn get warrantyDays =>
      integer().withDefault(const Constant(WarrantyConfig.defaultDays))();
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
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

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

/// Report 1 photo checklists, one per device family. Templates are seeded and
/// can be edited; each ticket copies its slots at intake so later edits never
/// rewrite an open job.
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

  /// Human-facing job number, e.g. `PF-000123`. Never reused.
  TextColumn get number => text().withLength(min: 1, max: 24)();

  IntColumn get customerId => integer().references(Customers, #id)();
  IntColumn get customerDeviceId =>
      integer().nullable().references(CustomerDevices, #id)();

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

  /// Serial exactly as printed on the device, or the shop-applied serial
  /// (`PFS-482913057`) when the factory sticker is gone.
  TextColumn get serial => text().nullable()();

  /// No readable factory serial/IMEI sticker was present. [serial] then holds
  /// the shop-applied serial, so a missing sticker still has a stable identity.
  BoolColumn get serialMissing =>
      boolean().withDefault(const Constant(false))();

  /// The tag currently stuck on the device, e.g. `G-482913057`. The full issue
  /// history lives in [ShopTags]; this is the value printed on the paperwork.
  TextColumn get shopTag => text().nullable()();

  TextColumn get complaint => text()();
  TextColumn get diagnosis => text().nullable()();

  /// Report 1 condition notes: scratches, cracks, stickers, missing parts and
  /// anything else the photos do not make obvious.
  TextColumn get intakeNotes => text().nullable()();

  /// When Report 1 was marked complete. Report 2 stays locked until this is
  /// set; reopening Report 1 clears it.
  DateTimeColumn get report1CompletedAt => dateTime().nullable()();

  /// When the technical (report 2) stage was marked complete. The client report
  /// stays editable either way.
  DateTimeColumn get report2CompletedAt => dateTime().nullable()();

  /// When the client report (report 3) was marked complete. Completing it also
  /// moves the ticket to [TicketStatus.ready] so it appears in Checkout.
  DateTimeColumn get report3CompletedAt => dateTime().nullable()();

  /// Shop workflow dates. Drop-off falls back to the ticket creation date on
  /// older records; pickup reuses [pickedUpAt].
  DateTimeColumn get dropOffAt => dateTime().nullable()();
  DateTimeColumn get technicianStartAt => dateTime().nullable()();
  DateTimeColumn get partsArriveAt => dateTime().nullable()();
  DateTimeColumn get customerContactedAt => dateTime().nullable()();

  /// Report 1 checklist family this job was booked under, e.g. `hinged`. The
  /// slots themselves are copied into [TicketPhotoSlots] at intake.
  TextColumn get photoTemplateKey => text().nullable()();

  IntColumn get status => intEnum<TicketStatus>()();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  IntColumn get estimateCents => integer().withDefault(const Constant(0))();
  IntColumn get invoiceDiscountKind =>
      intEnum<InvoiceDiscountKind>().withDefault(const Constant(0))();
  IntColumn get invoiceDiscountValue =>
      integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();

  /// The partner (drop-off location) the ticket came through, kept as text so
  /// it survives the partner being removed.
  TextColumn get partnerName => text().withDefault(const Constant(''))();

  /// Partner discount, as a percentage of the parts and of the labour on the
  /// invoice. Applied on top of the manual discount.
  IntColumn get partnerPartsPercent =>
      integer().withDefault(const Constant(0))();
  IntColumn get partnerLabourPercent =>
      integer().withDefault(const Constant(0))();

  /// Tax snapshot taken when the ticket is closed, so later rate changes never
  /// rewrite an old invoice. Revenue stays pre-tax on Financial.
  IntColumn get gstCents => integer().withDefault(const Constant(0))();
  IntColumn get pstCents => integer().withDefault(const Constant(0))();

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

  /// How many of a part line have already been taken out of stock by closing
  /// its ticket. Reopened tickets keep this value, so closing again only
  /// deducts the parts added since.
  IntColumn get consumedQuantity => integer().withDefault(const Constant(0))();
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

/// Ordered technical notes and photos. Photo rows can be children of a note,
/// or standalone entries in the bench log.
class TechnicalReportEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get reportId => integer().references(TicketReports, #id)();
  IntColumn get sortOrder => integer()();
  IntColumn get kind => intEnum<TechnicalEntryKind>()();
  IntColumn get parentEntryId => integer().nullable()();
  TextColumn get body => text().nullable()();
  TextColumn get photoPath => text().nullable()();
  TextColumn get caption => text().nullable()();
}

/// Editable client-facing copies of technical entries. The source link lets
/// draft sync update untouched content without overwriting client edits.
class ClientReportEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get reportId => integer().references(TicketReports, #id)();
  IntColumn get sourceEntryId => integer().nullable()();
  IntColumn get parentSourceEntryId => integer().nullable()();
  IntColumn get sortOrder => integer()();
  IntColumn get kind => intEnum<TechnicalEntryKind>()();
  TextColumn get body => text().nullable()();
  TextColumn get photoPath => text().nullable()();
  TextColumn get caption => text().nullable()();
  BoolColumn get contentEdited =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get inclusionEdited =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get included => boolean().withDefault(const Constant(true))();
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
  TextColumn get description => text().nullable()();

  /// Shop SKU in `NNN-NNN` form. Blank SKUs are assigned at creation time.
  TextColumn get sku => text().nullable()();

  /// Where the part is purchased, e.g. a supplier account or store name.
  TextColumn get vendorId => text().nullable()();

  /// The vendor's catalogue SKU for the exact item ordered.
  TextColumn get vendorSku => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get location => text().nullable()();
  IntColumn get stock => integer().withDefault(const Constant(0))();
  IntColumn get costCents => integer().withDefault(const Constant(0))();
  IntColumn get priceCents => integer().withDefault(const Constant(0))();

  /// Single-item or bulk-lot purchase. [costCents] is always the per-item cost.
  IntColumn get purchaseType =>
      intEnum<PartPurchaseType>().withDefault(const Constant(0))();

  /// How many items were in the bulk lot (1 for a single item).
  IntColumn get bulkQuantity => integer().withDefault(const Constant(1))();

  /// What the whole bulk lot cost, kept so the calculator can be reopened.
  IntColumn get bulkTotalCents => integer().withDefault(const Constant(0))();

  /// Shop supplies only: bill the retail price per use instead of nothing.
  BoolColumn get chargeShopSupply =>
      boolean().withDefault(const Constant(false))();
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

  /// Shop SKU in `NNN-NNN` form, separate from the parts SKU sequence.
  TextColumn get sku => text().nullable()();
  TextColumn get location => text().nullable()();
  IntColumn get stock => integer().withDefault(const Constant(0))();
  IntColumn get costCents => integer().withDefault(const Constant(0))();
  IntColumn get priceCents => integer().withDefault(const Constant(0))();
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
  CustomerDevices,
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
  TechnicalReportEntries,
  ClientReportEntries,
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
  AppDatabase() : super(openLocalExecutor());

  AppDatabase.withExecutor(super.executor);

  /// The shop's database file on this PC.
  static QueryExecutor openLocalExecutor() => driftDatabase(
        name: 'vola_fix',
        native: const DriftNativeOptions(
          databaseDirectory: getApplicationSupportDirectory,
        ),
      );

  /// Compared between host and clients so a mismatched build can't migrate or
  /// misread the shared database.
  static const int currentSchemaVersion = 26;

  /// The app's database: local, shared as a host, or a host's, chosen at
  /// startup in `main`.
  static AppDatabase instance = AppDatabase();

  /// Secure source for shop tags: a random number tells the customer nothing
  /// about how many jobs the shop has done.
  static final Random _random = Random.secure();

  /// v15 added the inventory part vendor ID and vendor SKU, plus purchase type
  /// and bulk-lot quantity/total so cost per item can be recalculated.
  /// v16 added the part description and assigned `NNN-NNN` SKUs to parts that
  /// did not have one.
  /// v17 added a warranty period to each device category, feeding the default
  /// on Report 3.
  /// v18 gave merchandise products their own SKU, location, stock, cost and
  /// retail price so the Merch page mirrors the parts inventory.
  /// v19 records how much of each part line has already left stock when its
  /// ticket was closed.
  /// v20 adds a minimum stock threshold separate from on-hand inventory.
  @override
  int get schemaVersion => currentSchemaVersion;

  /// v2 added `tickets.device_variant` (model number / revision note).
  /// v3 added per-device Report 1 checklists: templates, a template key on the
  /// model and ticket, and the slot snapshot copied at intake.
  /// v4 added `device_models.sort_order` so the picker follows the catalog's
  /// own order (controllers 1 → 5) rather than the alphabet.
  /// v5 added `tickets.device_side` for devices booked one half at a time,
  /// starting with the single Joy-Con.
  /// v6 added `tickets.intake_notes` for the Report 1 condition notes.
  /// v7 added `tickets.report1_completed_at`, which unlocks Report 2.
  /// v8 added ordered Report 2 entries and separately editable Report 3 copies.
  /// v9 added the inventory part location.
  /// v10 added saved invoice discounts and backfilled Required Parts prices.
  /// v11 added customer-owned device records and linked tickets to them.
  /// v12 added ticket drop-off, technician-start, parts-arrival, and
  /// customer-contacted dates. Pickup already existed as `picked_up_at`.
  /// v13 added `report2_completed_at` and `report3_completed_at` so the
  /// technical and client stages can be marked complete.
  /// v14 added the GST/PST amounts snapshotted when a ticket closes.
  /// v15 added the inventory part vendor ID and vendor SKU.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          Future<bool> _columnExists(String table, String column) async {
            final result = await customSelect(
              "SELECT COUNT(*) AS cnt FROM pragma_table_info('$table') WHERE name = '$column'",
            ).getSingle();
            final cnt = result.data['cnt'] as int? ?? 0;
            return cnt > 0;
          }

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
          if (from < 6) {
            await m.addColumn(tickets, tickets.intakeNotes);
          }
          if (from < 7) {
            await m.addColumn(tickets, tickets.report1CompletedAt);
          }
          if (from < 8) {
            await m.createTable(technicalReportEntries);
            await m.createTable(clientReportEntries);
          }
          if (from < 9) {
            await m.addColumn(parts, parts.location);
          }
          if (from < 10) {
            await m.addColumn(tickets, tickets.invoiceDiscountKind);
            await m.addColumn(tickets, tickets.invoiceDiscountValue);
            await customStatement(
              'UPDATE ticket_items '
              'SET unit_price_cents = COALESCE(('
              'SELECT price_cents FROM parts '
              'WHERE parts.id = ticket_items.part_id), 0), '
              'unit_cost_cents = ('
              'SELECT cost_cents FROM parts '
              'WHERE parts.id = ticket_items.part_id) '
              'WHERE kind = ${TicketItemKind.part.index} '
              'AND part_id IS NOT NULL',
            );
          }
          if (from < 11) {
            await m.createTable(customerDevices);
            await m.addColumn(tickets, tickets.customerDeviceId);
            await customStatement(
              'INSERT INTO customer_devices '
              '(customer_id, device_model_id, device_name, device_variant, '
              'device_side, serial, serial_missing, created_at, updated_at) '
              'SELECT customer_id, device_model_id, device_name, '
              'device_variant, device_side, serial, serial_missing, '
              'MIN(created_at), MAX(updated_at) FROM tickets '
              'GROUP BY customer_id, CASE '
              'WHEN serial IS NOT NULL AND TRIM(serial) != \'\' '
              'THEN LOWER(serial) ELSE \'ticket:\' || id END',
            );
            await customStatement(
              'UPDATE tickets SET customer_device_id = ('
              'SELECT customer_devices.id FROM customer_devices '
              'WHERE customer_devices.customer_id = tickets.customer_id '
              'AND ((tickets.serial IS NOT NULL AND '
              'LOWER(customer_devices.serial) = LOWER(tickets.serial)) OR '
              '(tickets.serial IS NULL AND customer_devices.serial IS NULL '
              'AND customer_devices.device_model_id IS '
              'tickets.device_model_id '
              'AND customer_devices.device_name IS tickets.device_name '
              'AND customer_devices.device_variant IS '
              'tickets.device_variant '
              'AND customer_devices.device_side IS tickets.device_side '
              'AND customer_devices.serial_missing = tickets.serial_missing)) '
              'LIMIT 1)',
            );
          }
          if (from < 12) {
            await m.addColumn(tickets, tickets.dropOffAt);
            await m.addColumn(tickets, tickets.technicianStartAt);
            await m.addColumn(tickets, tickets.partsArriveAt);
            await m.addColumn(tickets, tickets.customerContactedAt);
            await customStatement(
              'UPDATE tickets SET drop_off_at = created_at '
              'WHERE drop_off_at IS NULL',
            );
          }
          if (from < 13) {
            if (!await _columnExists('tickets', 'report2_completed_at')) {
              await m.addColumn(tickets, tickets.report2CompletedAt);
            }
            if (!await _columnExists('tickets', 'report3_completed_at')) {
              await m.addColumn(tickets, tickets.report3CompletedAt);
            }
          }
          if (from < 14) {
            if (!await _columnExists('tickets', 'gst_cents')) {
              await m.addColumn(tickets, tickets.gstCents);
            }
            if (!await _columnExists('tickets', 'pst_cents')) {
              await m.addColumn(tickets, tickets.pstCents);
            }
          }
          if (from < 15) {
            if (!await _columnExists('parts', 'vendor_id')) {
              await m.addColumn(parts, parts.vendorId);
            }
            if (!await _columnExists('parts', 'vendor_sku')) {
              await m.addColumn(parts, parts.vendorSku);
            }
            if (!await _columnExists('parts', 'purchase_type')) {
              await m.addColumn(parts, parts.purchaseType);
            }
            if (!await _columnExists('parts', 'bulk_quantity')) {
              await m.addColumn(parts, parts.bulkQuantity);
            }
            if (!await _columnExists('parts', 'bulk_total_cents')) {
              await m.addColumn(parts, parts.bulkTotalCents);
            }
          }
          if (from < 16) {
            if (!await _columnExists('parts', 'description')) {
              await m.addColumn(parts, parts.description);
            }
            await _backfillPartSkus();
          }
          if (from < 17) {
            if (!await _columnExists('device_categories', 'warranty_days')) {
              await m.addColumn(
                  deviceCategories, deviceCategories.warrantyDays);
            }
          }
          if (from < 18) {
            if (!await _columnExists('merch_products', 'sku')) {
              await m.addColumn(merchProducts, merchProducts.sku);
            }
            if (!await _columnExists('merch_products', 'location')) {
              await m.addColumn(merchProducts, merchProducts.location);
            }
            if (!await _columnExists('merch_products', 'stock')) {
              await m.addColumn(merchProducts, merchProducts.stock);
            }
            if (!await _columnExists('merch_products', 'cost_cents')) {
              await m.addColumn(merchProducts, merchProducts.costCents);
            }
            if (!await _columnExists('merch_products', 'price_cents')) {
              await m.addColumn(merchProducts, merchProducts.priceCents);
            }
          }
          if (from < 19) {
            if (!await _columnExists('ticket_items', 'consumed_quantity')) {
              await m.addColumn(ticketItems, ticketItems.consumedQuantity);
            }
            // Parts on tickets that closed before this change never left stock,
            // so mark them consumed. Upgrading cannot drop their stock now, and
            // reopening an old job for warranty does not deduct them either.
            await customStatement(
              'UPDATE ticket_items SET consumed_quantity = quantity '
              'WHERE kind = ${TicketItemKind.part.index} AND ticket_id IN ('
              'SELECT id FROM tickets '
              'WHERE status = ${TicketStatus.closed.index})',
            );
          }
          if (from < 20) {
            if (!await _columnExists('parts', 'reorder_level')) {
              await m.addColumn(parts, parts.reorderLevel);
            }
            // Old columns kept for compatibility; parts now track inventory
            // separately from the minimum stock threshold.
          }
          if (from < 21) {
            // Tickets that were closed and reopened before parts were taken out
            // of stock were marked consumed by the v19 backfill without any
            // stock movement, so closing them again deducted nothing. Parts on
            // tickets that are still open and never had a deduction are
            // outstanding again.
            await customStatement(
              'UPDATE ticket_items SET consumed_quantity = 0 '
              'WHERE kind = ${TicketItemKind.part.index} '
              'AND consumed_quantity > 0 AND ticket_id IN ('
              'SELECT id FROM tickets WHERE status NOT IN ('
              '${TicketStatus.closed.index}, ${TicketStatus.cancelled.index})) '
              'AND NOT EXISTS ('
              'SELECT 1 FROM part_movements m '
              'WHERE m.ticket_id = ticket_items.ticket_id '
              'AND m.part_id = ticket_items.part_id AND m.delta < 0)',
            );
          }
          if (from < 22) {
            if (!await _columnExists('parts', 'charge_shop_supply')) {
              await m.addColumn(parts, parts.chargeShopSupply);
            }
          }
          if (from < 23) {
            // Shop supplies are free unless a line is marked "R" on the
            // invoice, so clear any price stored before that existed.
            await customStatement(
              'UPDATE ticket_items SET unit_price_cents = 0 '
              'WHERE part_id IN (SELECT id FROM parts WHERE lower(trim('
              "category)) IN ('shop','supplies','shop supply','shop supplies'))",
            );
          }
          if (from < 24) {
            // Brand headings can be switched off per shop.
            await m.addColumn(deviceBrands, deviceBrands.isActive);
          }
          if (from < 25) {
            await m.addColumn(tickets, tickets.partnerName);
          }
          if (from < 26) {
            await m.addColumn(tickets, tickets.partnerPartsPercent);
            await m.addColumn(tickets, tickets.partnerLabourPercent);
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

  Future<String> readSetting(String key, String fallback) =>
      _setting(key, fallback);

  Future<void> writeSetting(String key, String value) =>
      _putSetting(key, value);

  Future<int> markupPercent(String key, int fallback) async {
    final value = int.tryParse(await _setting(key, '$fallback')) ?? fallback;
    return value.clamp(0, 500).toInt();
  }

  Future<void> setMarkupPercent(String key, int value) async {
    if (value < 0 || value > 500) {
      throw ArgumentError.value(value, 'value', 'must be between 0 and 500');
    }
    await _putSetting(key, '$value');
  }

  /// Current GST/PST setup. Missing keys mean tax is off, so databases created
  /// before the tax feature keep working until [ensureSeeded] adds defaults.
  Future<TaxConfig> taxConfig() async {
    final rows = await (select(settings)
          ..where((row) => row.key.isIn(TaxConfig.settingKeys)))
        .get();
    return TaxConfig.fromSettings({
      for (final row in rows) row.key: row.value,
    });
  }

  Stream<TaxConfig> watchTaxConfig() {
    final query = select(settings)
      ..where((row) => row.key.isIn(TaxConfig.settingKeys));
    return query.watch().map(
          (rows) => TaxConfig.fromSettings({
            for (final row in rows) row.key: row.value,
          }),
        );
  }

  Future<void> setTaxConfig(TaxConfig config) async {
    if (config.gstRateBp < 0 ||
        config.gstRateBp > TaxConfig.maxRateBp ||
        config.pstRateBp < 0 ||
        config.pstRateBp > TaxConfig.maxRateBp) {
      throw ArgumentError(
        'Tax rates must be between 0% and ${TaxConfig.maxRateBp ~/ 100}%.',
      );
    }
    await transaction(() async {
      for (final entry in config.toSettings().entries) {
        await _putSetting(entry.key, entry.value);
      }
    });
  }

  /// Creates the catalog and default settings on first run, and adds anything
  /// new to an existing catalog on later runs.
  ///
  /// Everything is matched by name: a row is only inserted when it is missing,
  /// so shop edits (renames, prices, custom models) are never overwritten.
  Future<void> ensureSeeded() async {
    await transaction(() async {
      const defaults = <(String, String)>[
        ('shop_name', 'Peaks Fix'),
        ('ticket_prefix', 'PF'),
        ('serial_prefix', 'PFS'),
        ('tag_prefix', 'G'),
        ('ticket_seq', '0'),
        ('currency', 'CAD'),
        ('parts_markup_percent', '35'),
        ('merch_markup_percent', '45'),
        (TaxConfig.gstEnabledKey, 'true'),
        (TaxConfig.gstRateKey, '${TaxConfig.defaultGstRateBp}'),
        (TaxConfig.pstEnabledKey, 'false'),
        (TaxConfig.pstRateKey, '${TaxConfig.defaultPstRateBp}'),
        (WarrantyConfig.daysKey, '${WarrantyConfig.defaultDays}'),
        (WarrantyConfig.termsKey, WarrantyConfig.defaultTerms),
      ];
      for (final (key, value) in defaults) {
        await into(settings).insert(
          SettingsCompanion.insert(key: key, value: value),
          mode: InsertMode.insertOrIgnore,
        );
      }

      // The app was renamed from Vola Fix. Carry the old defaults across, but
      // never overwrite values the operator has already changed.
      await (update(settings)
            ..where(
              (s) => s.key.equals('shop_name') & s.value.equals('Vola Fix'),
            ))
          .write(const SettingsCompanion(value: Value('Peaks Fix')));
      await (update(settings)
            ..where(
              (s) => s.key.equals('ticket_prefix') & s.value.equals('VF'),
            ))
          .write(const SettingsCompanion(value: Value('PF')));

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
      final vacuums = await category('Vacuum', 5);
      await category('General Electronics', 6);
      final ebikes = await category('Ebikes', 7);

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
        (
          vacuums,
          'Dyson',
          [
            'V8',
            'V10',
            'V11',
            'V15 Detect',
            'Ball Animal 3',
            'Gen5detect',
          ],
        ),
        (
          vacuums,
          'Kirby',
          [
            'Avalir 2',
            'Avalir Platinum',
            'Sentria II',
            'Sentria',
            'Ultimate G',
            'Generation 3',
          ],
        ),
        (
          vacuums,
          'Dirt Devil',
          [
            'Scorpion',
            'Endura Reach',
            'Power Express',
            'Vibe',
          ],
        ),
        (
          vacuums,
          'Shark',
          [
            'Navigator Lift-Away',
            'Rotator',
            'Rocket',
            'Vertex',
            'Stratos',
            'Detect Pro',
          ],
        ),
        (
          ebikes,
          'Biktrix',
          [
            'Juggernaut Classic',
            'Juggernaut Classic Duo',
            'Juggernaut Hub Duo',
            'Juggernaut Ultra',
            'Juggernaut Ultra Duo',
            'Juggernaut Ultra FS',
            'Juggernaut FS Pro',
            'Juggernaut Lite',
            'Monte Capro Lite',
            'Monte Capro Ultra',
            'Kutty',
            'Kutty X',
            'Kutty FS',
            'RogueHawk FS',
            'Stunner LT',
            'Stunner X',
            'Stunner Step-Over',
            'Stunner Step-Thru',
            'Swift',
            'Swift Lite',
            'Swift CVT',
            'Skycap',
            'Moto Challenger',
            'Moto Volt',
          ],
        ),
        (
          ebikes,
          'Rize',
          [
            'RX',
            'RX Pro',
            'RX Dual',
            'Rover',
            'X',
            'City',
            'City MD',
            'Leisure',
            'Blade',
            'Bolt',
            'Fixie',
          ],
        ),
        (
          ebikes,
          'Envo',
          [
            'Flex',
            'Flex Overland',
            'Flex TR',
            'Flex Urban',
            'Flex SUV',
            'Flex Trike',
            'Drive D20',
            'Drive D35',
            'Drive D50',
            'Drive ST50',
            'Drive U50',
            'Drive M50',
            'Drive X50',
            'Stash',
            'Snowbike',
          ],
        ),
        // Bikes the shop can't identify by brand.
        (
          ebikes,
          'Unknown',
          ['Generic Ebike'],
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

  /// Next job number, e.g. `PF-000123`.
  ///
  /// Numbered from a counter in [settings] rather than the row id, so deleting
  /// a ticket can never cause a number to be reused.
  Future<String> nextTicketNumber() => transaction(_allocateTicketNumber);

  Future<String> _allocateTicketNumber() async {
    final prefix = await _setting('ticket_prefix', 'PF');
    final current = int.tryParse(await _setting('ticket_seq', '0')) ?? 0;
    final next = current + 1;
    await _putSetting('ticket_seq', '$next');
    return '$prefix-${next.toString().padLeft(6, '0')}';
  }

  /// Issues a shop-applied serial, e.g. `PFS-482913057`, for a device whose
  /// factory serial sticker is missing, worn or illegible.
  ///
  /// Random rather than sequential: the value is written on the shop's own
  /// sticker and read back by eye, so it must not be guessable from another
  /// ticket. Checked against [tickets] so no two jobs ever share one.
  Future<String> nextShopSerial() => transaction(_allocateShopSerial);

  Future<String> _allocateShopSerial() async {
    final prefix = await _setting('serial_prefix', 'PFS');
    for (var attempt = 0; attempt < 64; attempt++) {
      final digits = _random.nextInt(1000000000).toString().padLeft(9, '0');
      final serial = '$prefix-$digits';
      final taken = await (select(tickets)
            ..where((t) => t.serial.equals(serial)))
          .getSingleOrNull();
      if (taken != null) continue;
      return serial;
    }
    throw StateError('Could not allocate an unused shop-applied serial.');
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
    int? existingCustomerId,
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
    DateTime? dropOffAt,
    DateTime? technicianStartAt,
    DateTime? partsArriveAt,
    DateTime? customerContactedAt,
    DateTime? pickedUpAt,
    String partnerName = '',
    required String complaint,
  }) {
    return transaction(() async {
      final name = customerName.trim();
      final partner = partnerName.trim();
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

      final existing = existingCustomerId == null
          ? await (select(customers)
                ..where((c) => c.name.lower().equals(name.toLowerCase())))
              .getSingleOrNull()
          : await (select(customers)
                ..where((c) => c.id.equals(existingCustomerId)))
              .getSingleOrNull();
      if (existingCustomerId != null && existing == null) {
        throw ArgumentError.value(
          existingCustomerId,
          'customerId',
          'not found',
        );
      }
      final resolvedCustomerId = existing?.id ??
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
            name: Value(name),
            phone: Value(phone),
            email: Value(email),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }

      final number = await _allocateTicketNumber();
      DateTime dateOnly(DateTime? date) => date == null
          ? DateTime.now()
          : DateTime(date.year, date.month, date.day);
      // A missing sticker always gets a shop-applied serial, even if the
      // caller only ticked the box and sent no value.
      final typedSerial = (serial ?? '').trim();
      final effectiveSerial = typedSerial.isNotEmpty
          ? typedSerial
          : serialMissing
              ? await _allocateShopSerial()
              : '';
      final device = customerDeviceId == null
          ? typedSerial.isEmpty
              ? null
              : await (select(customerDevices)
                    ..where((row) =>
                        row.customerId.equals(resolvedCustomerId) &
                        row.serial.lower().equals(typedSerial.toLowerCase())))
                  .getSingleOrNull()
          : await (select(customerDevices)
                ..where((row) =>
                    row.id.equals(customerDeviceId) &
                    row.customerId.equals(resolvedCustomerId)))
              .getSingleOrNull();
      if (customerDeviceId != null && device == null) {
        throw ArgumentError.value(
          customerDeviceId,
          'customerDeviceId',
          'not found for this customer',
        );
      }
      final deviceValues = CustomerDevicesCompanion(
        customerId: Value(resolvedCustomerId),
        deviceModelId: Value(deviceModelId),
        deviceName: Value(
          (deviceName ?? '').trim().isEmpty ? null : deviceName!.trim(),
        ),
        deviceVariant: Value(
          (deviceVariant ?? '').trim().isEmpty ? null : deviceVariant!.trim(),
        ),
        deviceSide: Value(side.isEmpty ? null : side),
        serial: Value(effectiveSerial.isEmpty ? null : effectiveSerial),
        serialMissing: Value(serialMissing),
        updatedAt: Value(DateTime.now()),
      );
      final resolvedDeviceId = device == null
          ? await into(customerDevices).insert(
              CustomerDevicesCompanion.insert(
                customerId: resolvedCustomerId,
                deviceModelId: Value(deviceModelId),
                deviceName: Value(
                  (deviceName ?? '').trim().isEmpty ? null : deviceName!.trim(),
                ),
                deviceVariant: Value(
                  (deviceVariant ?? '').trim().isEmpty
                      ? null
                      : deviceVariant!.trim(),
                ),
                deviceSide: Value(side.isEmpty ? null : side),
                serial: Value(effectiveSerial.isEmpty ? null : effectiveSerial),
                serialMissing: Value(serialMissing),
              ),
            )
          : device.id;
      if (device != null) {
        await (update(customerDevices)
              ..where((row) => row.id.equals(device.id)))
            .write(deviceValues);
      }
      final ticketId = await into(tickets).insert(
        TicketsCompanion.insert(
          number: number,
          customerId: resolvedCustomerId,
          customerDeviceId: Value(resolvedDeviceId),
          deviceModelId: Value(deviceModelId),
          deviceName: Value(
            (deviceName ?? '').trim().isEmpty ? null : deviceName!.trim(),
          ),
          deviceVariant: Value(
            (deviceVariant ?? '').trim().isEmpty ? null : deviceVariant!.trim(),
          ),
          deviceSide: Value(side.isEmpty ? null : side),
          serial: Value(effectiveSerial.isEmpty ? null : effectiveSerial),
          serialMissing: Value(serialMissing),
          complaint: complaint.trim(),
          partnerName: Value(partner),
          photoTemplateKey: Value(templateKey),
          dropOffAt: Value(dateOnly(dropOffAt)),
          technicianStartAt: Value(
            technicianStartAt == null ? null : dateOnly(technicianStartAt),
          ),
          partsArriveAt: Value(
            partsArriveAt == null ? null : dateOnly(partsArriveAt),
          ),
          customerContactedAt: Value(
            customerContactedAt == null ? null : dateOnly(customerContactedAt),
          ),
          pickedUpAt: Value(
            pickedUpAt == null ? null : dateOnly(pickedUpAt),
          ),
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
        customerId: resolvedCustomerId,
        customerDeviceId: resolvedDeviceId,
      );
    });
  }

  Future<int> saveCustomer({
    int? customerId,
    required String name,
    required String phone,
    required String email,
    required String notes,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'must not be empty');
    }
    final companion = CustomersCompanion(
      name: Value(cleanName),
      phone: Value(_clean(phone)),
      email: Value(_clean(email)),
      notes: Value(_clean(notes)),
      updatedAt: Value(DateTime.now()),
    );
    if (customerId == null) {
      return into(customers).insert(
        CustomersCompanion.insert(
          name: cleanName,
          phone: Value(_clean(phone)),
          email: Value(_clean(email)),
          notes: Value(_clean(notes)),
        ),
      );
    }
    final updated = await (update(customers)
          ..where((row) => row.id.equals(customerId)))
        .write(companion);
    if (updated == 0) {
      throw ArgumentError.value(customerId, 'customerId', 'not found');
    }
    return customerId;
  }

  /// Records a capture against one Report 1 slot. The file has already been
  /// written by the photo store; this only points the ticket at it.
  Future<void> setTicketPhotoPath({
    required int ticketId,
    required int sortOrder,
    required String path,
  }) async {
    await transaction(() async {
      await (update(ticketPhotoSlots)
            ..where(
              (s) =>
                  s.ticketId.equals(ticketId) & s.sortOrder.equals(sortOrder),
            ))
          .write(
        TicketPhotoSlotsCompanion(
          photoPath: Value(path),
          capturedAt: Value(DateTime.now()),
        ),
      );
      await (update(tickets)..where((t) => t.id.equals(ticketId))).write(
        TicketsCompanion(updatedAt: Value(DateTime.now())),
      );
    });
  }

  Future<void> addOptionalPhotoSlot({
    required int ticketId,
    required String label,
  }) async {
    final cleanLabel = label.trim();
    if (cleanLabel.isEmpty || cleanLabel.length > 80) {
      throw ArgumentError.value(
        label,
        'label',
        'must be between 1 and 80 characters',
      );
    }
    await transaction(() async {
      final ticket = await (select(tickets)
            ..where((row) => row.id.equals(ticketId)))
          .getSingleOrNull();
      if (ticket == null) {
        throw ArgumentError.value(ticketId, 'ticketId', 'not found');
      }
      final last = await (select(ticketPhotoSlots)
            ..where((slot) => slot.ticketId.equals(ticketId))
            ..orderBy([(slot) => OrderingTerm.desc(slot.sortOrder)])
            ..limit(1))
          .getSingleOrNull();
      await into(ticketPhotoSlots).insert(
        TicketPhotoSlotsCompanion.insert(
          ticketId: ticketId,
          sortOrder: (last?.sortOrder ?? 0) + 1,
          label: cleanLabel,
          hint: const Value('Optional reference photo'),
          required: const Value(false),
        ),
      );
      await (update(tickets)..where((row) => row.id.equals(ticketId))).write(
        TicketsCompanion(updatedAt: Value(DateTime.now())),
      );
    });
  }

  /// Saves the free-text Report 1 condition notes. Whitespace-only input is
  /// stored as null so the report shows "not noted" rather than an empty box.
  Future<void> setTicketIntakeNotes(int ticketId, String notes) async {
    final trimmed = notes.trim();
    await (update(tickets)..where((t) => t.id.equals(ticketId))).write(
      TicketsCompanion(
        intakeNotes: Value(trimmed.isEmpty ? null : trimmed),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Marks Report 1 complete or reopens it. The timestamp is the record; report
  /// 2 is unlocked whenever it is non-null.
  Future<void> setReport1Completed(int ticketId, bool completed) async {
    await (update(tickets)..where((t) => t.id.equals(ticketId))).write(
      TicketsCompanion(
        report1CompletedAt: Value(completed ? DateTime.now() : null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Marks the technical stage (Report 2) complete or reopens it. The report
  /// stays editable either way; the timestamp only records the hand-off.
  Future<void> setReport2Completed(int ticketId, bool completed) async {
    await (update(tickets)..where((t) => t.id.equals(ticketId))).write(
      TicketsCompanion(
        report2CompletedAt: Value(completed ? DateTime.now() : null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Marks the client report (Report 3) complete or reopens it. Completing it
  /// sends the ticket to Checkout by moving it to [TicketStatus.ready], unless
  /// the job is already closed, cancelled or picked up.
  ///
  /// Completing also freezes the warranty length and terms onto the report and
  /// stamps [TicketReports.warrantyStartAt], so later catalog or shop-default
  /// changes do not rewrite an issued warranty.
  Future<void> setReport3Completed(int ticketId, bool completed) async {
    await transaction(() async {
      final ticket = await (select(tickets)
            ..where((t) => t.id.equals(ticketId)))
          .getSingle();
      final reportId = await _ensureClientDraftReport(ticketId);
      final report = await (select(ticketReports)
            ..where((row) => row.id.equals(reportId)))
          .getSingle();
      final now = DateTime.now();
      if (completed) {
        final days = report.warrantyDays ??
            await _warrantyDaysForDevice(ticket.deviceModelId);
        final terms = _clean(report.warrantyTerms) ??
            await _setting(
                WarrantyConfig.termsKey, WarrantyConfig.defaultTerms);
        await (update(ticketReports)..where((row) => row.id.equals(reportId)))
            .write(
          TicketReportsCompanion(
            warrantyDays: Value(days),
            warrantyTerms: Value(terms),
            warrantyStartAt: Value(now),
            updatedAt: Value(now),
          ),
        );
      } else {
        await (update(ticketReports)..where((row) => row.id.equals(reportId)))
            .write(
          TicketReportsCompanion(
            warrantyStartAt: const Value(null),
            updatedAt: Value(now),
          ),
        );
      }
      final sendToCheckout = completed &&
          ticket.status != TicketStatus.closed &&
          ticket.status != TicketStatus.cancelled &&
          ticket.status != TicketStatus.pickedUp;
      await (update(tickets)..where((t) => t.id.equals(ticketId))).write(
        TicketsCompanion(
          report3CompletedAt: Value(completed ? now : null),
          status: sendToCheckout
              ? const Value(TicketStatus.ready)
              : const Value.absent(),
          updatedAt: Value(now),
        ),
      );
    });
  }

  /// The Report 3 warranty block for [ticketId], with the device-category or
  /// shop default already filled in until the report freezes its own values.
  Stream<ClientReportWarranty> watchClientReportWarranty(int ticketId) {
    final query = select(tickets).join([
      leftOuterJoin(
        ticketReports,
        ticketReports.ticketId.equalsExp(tickets.id) &
            ticketReports.kind.equals(ReportKind.client.index) &
            ticketReports.status.equals(ReportStatus.draft.index),
      ),
      leftOuterJoin(
        deviceModels,
        deviceModels.id.equalsExp(tickets.deviceModelId),
      ),
      leftOuterJoin(
        deviceBrands,
        deviceBrands.id.equalsExp(deviceModels.brandId),
      ),
      leftOuterJoin(
        deviceCategories,
        deviceCategories.id.equalsExp(deviceBrands.categoryId),
      ),
    ])
      ..where(tickets.id.equals(ticketId))
      ..orderBy([OrderingTerm.desc(ticketReports.revision)])
      ..limit(1);
    return query.watch().asyncMap((rows) async {
      final row = rows.isEmpty ? null : rows.first;
      final report = row?.readTableOrNull(ticketReports);
      final category = row?.readTableOrNull(deviceCategories);
      final defaultDays = category?.warrantyDays ?? await _shopWarrantyDays();
      final defaultTerms = await _setting(
        WarrantyConfig.termsKey,
        WarrantyConfig.defaultTerms,
      );
      return ClientReportWarranty(
        defaultDays: defaultDays,
        defaultTerms: defaultTerms,
        days: report?.warrantyDays,
        terms: report?.warrantyTerms,
        startAt: report?.warrantyStartAt,
        categoryName: category?.name,
      );
    });
  }

  /// Saves the per-ticket warranty length and/or terms. An empty terms string
  /// clears the override so the shop default applies again.
  Future<void> saveClientReportWarranty({
    required int ticketId,
    int? days,
    String? terms,
  }) async {
    if (days != null) WarrantyConfig.requireDays(days);
    await transaction(() async {
      final reportId = await _ensureClientDraftReport(ticketId);
      await (update(ticketReports)..where((row) => row.id.equals(reportId)))
          .write(
        TicketReportsCompanion(
          warrantyDays: days == null ? const Value.absent() : Value(days),
          warrantyTerms:
              terms == null ? const Value.absent() : Value(_clean(terms)),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await _touchTicket(ticketId);
    });
  }

  Future<int> _ensureClientDraftReport(int ticketId) async {
    final existing = await _draftReportId(ticketId, ReportKind.client);
    if (existing != null) return existing;
    final ticket = await (select(tickets)
          ..where((row) => row.id.equals(ticketId)))
        .getSingle();
    return into(ticketReports).insert(
      TicketReportsCompanion.insert(
        ticketId: ticketId,
        kind: ReportKind.client,
        status: ReportStatus.draft,
        author: 'Shop',
        shopTag: Value(ticket.shopTag),
      ),
    );
  }

  Future<int> _shopWarrantyDays() async {
    final value = int.tryParse(
      await _setting(WarrantyConfig.daysKey, '${WarrantyConfig.defaultDays}'),
    );
    return (value ?? WarrantyConfig.defaultDays)
        .clamp(1, WarrantyConfig.maxDays)
        .toInt();
  }

  Future<int> _warrantyDaysForDevice(int? deviceModelId) async {
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
      if (row != null) return row.readTable(deviceCategories).warrantyDays;
    }
    return _shopWarrantyDays();
  }

  Future<void> ensureTechnicalReports(int ticketId) async {
    await transaction(() async {
      final ticket = await (select(tickets)
            ..where((t) => t.id.equals(ticketId)))
          .getSingle();
      final technicalId =
          await _draftReportId(ticketId, ReportKind.technical) ??
              await into(ticketReports).insert(
                TicketReportsCompanion.insert(
                  ticketId: ticketId,
                  kind: ReportKind.technical,
                  status: ReportStatus.draft,
                  author: 'Shop',
                  shopTag: Value(ticket.shopTag),
                ),
              );
      final clientId = await _draftReportId(ticketId, ReportKind.client) ??
          await into(ticketReports).insert(
            TicketReportsCompanion.insert(
              ticketId: ticketId,
              kind: ReportKind.client,
              status: ReportStatus.draft,
              author: 'Shop',
              shopTag: Value(ticket.shopTag),
            ),
          );
      await _syncClientDraft(technicalId, clientId);
    });
  }

  Future<int> addTechnicalEntry({
    required int ticketId,
    required TechnicalEntryKind kind,
    int? parentEntryId,
    String? text,
    String? photoPath,
    String? caption,
  }) async {
    return transaction(() async {
      final reportId = await _draftReportId(ticketId, ReportKind.technical);
      if (reportId == null) {
        throw StateError('Technical report has not been initialized.');
      }
      if (parentEntryId != null) {
        if (kind != TechnicalEntryKind.photo) {
          throw ArgumentError.value(
            kind,
            'kind',
            'only photos can be attached to a note',
          );
        }
        final parent = await (select(technicalReportEntries)
              ..where((entry) =>
                  entry.id.equals(parentEntryId) &
                  entry.reportId.equals(reportId) &
                  entry.kind.equals(TechnicalEntryKind.note.index)))
            .getSingleOrNull();
        if (parent == null) {
          throw ArgumentError.value(
            parentEntryId,
            'parentEntryId',
            'must identify a note in this technical report',
          );
        }
      }
      final entries = await (select(technicalReportEntries)
            ..where((entry) => entry.reportId.equals(reportId))
            ..orderBy([(entry) => OrderingTerm.desc(entry.sortOrder)])
            ..limit(1))
          .get();
      final sortOrder = entries.isEmpty ? 0 : entries.first.sortOrder + 1;
      final id = await into(technicalReportEntries).insert(
        TechnicalReportEntriesCompanion.insert(
          reportId: reportId,
          sortOrder: sortOrder,
          kind: kind,
          parentEntryId: Value(parentEntryId),
          body: Value(_clean(text)),
          photoPath: Value(photoPath),
          caption: Value(_clean(caption)),
        ),
      );
      await _syncClientDraftForTechnicalReport(reportId);
      await _touchReport(reportId);
      await _touchTicket(ticketId);
      return id;
    });
  }

  Future<void> updateTechnicalEntry({
    required int ticketId,
    required int entryId,
    required TechnicalEntryKind kind,
    String? text,
    String? caption,
  }) async {
    await transaction(() async {
      final entry = await (select(technicalReportEntries)
            ..where((row) => row.id.equals(entryId)))
          .getSingle();
      final report = await (select(ticketReports)
            ..where((row) => row.id.equals(entry.reportId)))
          .getSingle();
      if (report.ticketId != ticketId ||
          report.kind != ReportKind.technical ||
          report.status != ReportStatus.draft ||
          entry.kind != kind) {
        throw ArgumentError.value(entryId, 'entryId', 'not a matching entry');
      }
      await (update(technicalReportEntries)
            ..where((row) => row.id.equals(entryId)))
          .write(
        TechnicalReportEntriesCompanion(
          body: kind == TechnicalEntryKind.note
              ? Value(_clean(text))
              : const Value.absent(),
          caption: kind == TechnicalEntryKind.photo
              ? Value(_clean(caption))
              : const Value.absent(),
        ),
      );
      await _syncClientDraftForTechnicalReport(entry.reportId);
      await _touchReport(entry.reportId);
      await _touchTicket(ticketId);
    });
  }

  Future<void> deleteTechnicalEntry({
    required int ticketId,
    required int entryId,
  }) async {
    await transaction(() async {
      final entry = await (select(technicalReportEntries)
            ..where((row) => row.id.equals(entryId)))
          .getSingle();
      final report = await (select(ticketReports)
            ..where((row) => row.id.equals(entry.reportId)))
          .getSingle();
      if (report.ticketId != ticketId ||
          report.kind != ReportKind.technical ||
          report.status != ReportStatus.draft) {
        throw ArgumentError.value(entryId, 'entryId', 'not in this ticket');
      }
      await (delete(technicalReportEntries)
            ..where((row) =>
                row.id.equals(entryId) | row.parentEntryId.equals(entryId)))
          .go();
      await _syncClientDraftForTechnicalReport(entry.reportId);
      await _touchReport(entry.reportId);
      await _touchTicket(ticketId);
    });
  }

  Future<void> updateClientReportEntry({
    required int entryId,
    required TechnicalEntryKind kind,
    String? text,
    String? caption,
    bool? included,
  }) async {
    await transaction(() async {
      final entry = await (select(clientReportEntries)
            ..where((row) => row.id.equals(entryId)))
          .getSingle();
      final report = await (select(ticketReports)
            ..where((row) => row.id.equals(entry.reportId)))
          .getSingle();
      if (entry.kind != kind ||
          report.kind != ReportKind.client ||
          report.status != ReportStatus.draft) {
        throw ArgumentError.value(entryId, 'entryId', 'wrong entry kind');
      }
      await (update(clientReportEntries)
            ..where((row) => row.id.equals(entryId)))
          .write(
        ClientReportEntriesCompanion(
          body: kind == TechnicalEntryKind.note
              ? Value(_clean(text))
              : const Value.absent(),
          caption: kind == TechnicalEntryKind.photo
              ? Value(_clean(caption))
              : const Value.absent(),
          included: included == null ? const Value.absent() : Value(included),
          contentEdited: text != null || caption != null
              ? const Value(true)
              : const Value.absent(),
          inclusionEdited:
              included == null ? const Value.absent() : const Value(true),
        ),
      );
      await (update(ticketReports)
            ..where((report) => report.id.equals(entry.reportId)))
          .write(TicketReportsCompanion(updatedAt: Value(DateTime.now())));
    });
  }

  Future<void> _syncClientDraftForTechnicalReport(int technicalReportId) async {
    final technicalReport = await (select(ticketReports)
          ..where((report) => report.id.equals(technicalReportId)))
        .getSingle();
    final clientReportId =
        await _draftReportId(technicalReport.ticketId, ReportKind.client);
    if (clientReportId == null) return;
    await _syncClientDraft(technicalReportId, clientReportId);
  }

  Future<void> _syncClientDraft(
      int technicalReportId, int clientReportId) async {
    final sourceEntries = await (select(technicalReportEntries)
          ..where((entry) => entry.reportId.equals(technicalReportId))
          ..orderBy([(entry) => OrderingTerm.asc(entry.sortOrder)]))
        .get();
    final copiedEntries = await (select(clientReportEntries)
          ..where((entry) => entry.reportId.equals(clientReportId)))
        .get();
    final copiedBySource = {
      for (final entry in copiedEntries)
        if (entry.sourceEntryId != null) entry.sourceEntryId!: entry,
    };
    final sourceIds = sourceEntries.map((entry) => entry.id).toSet();

    for (final source in sourceEntries) {
      final copied = copiedBySource[source.id];
      if (copied == null) {
        await into(clientReportEntries).insert(
          ClientReportEntriesCompanion.insert(
            reportId: clientReportId,
            sourceEntryId: Value(source.id),
            parentSourceEntryId: Value(source.parentEntryId),
            sortOrder: source.sortOrder,
            kind: source.kind,
            body: Value(source.body),
            photoPath: Value(source.photoPath),
            caption: Value(source.caption),
          ),
        );
      } else if (!copied.contentEdited) {
        await (update(clientReportEntries)
              ..where((entry) => entry.id.equals(copied.id)))
            .write(
          ClientReportEntriesCompanion(
            sortOrder: Value(source.sortOrder),
            parentSourceEntryId: Value(source.parentEntryId),
            kind: Value(source.kind),
            body: Value(source.body),
            photoPath: Value(source.photoPath),
            caption: Value(source.caption),
            included: copied.inclusionEdited
                ? const Value.absent()
                : const Value(true),
          ),
        );
      }
    }

    for (final copied in copiedEntries) {
      final sourceId = copied.sourceEntryId;
      if (sourceId != null &&
          !sourceIds.contains(sourceId) &&
          !copied.inclusionEdited) {
        await (update(clientReportEntries)
              ..where((entry) => entry.id.equals(copied.id)))
            .write(const ClientReportEntriesCompanion(included: Value(false)));
      }
    }

    await (update(ticketReports)
          ..where((report) => report.id.equals(clientReportId)))
        .write(TicketReportsCompanion(updatedAt: Value(DateTime.now())));
  }

  Future<int?> _draftReportId(int ticketId, ReportKind kind) async {
    final report = await (select(ticketReports)
          ..where((row) =>
              row.ticketId.equals(ticketId) &
              row.kind.equals(kind.index) &
              row.status.equals(ReportStatus.draft.index))
          ..orderBy([(row) => OrderingTerm.desc(row.revision)])
          ..limit(1))
        .getSingleOrNull();
    return report?.id;
  }

  Future<void> _touchTicket(int ticketId) async {
    await (update(tickets)..where((ticket) => ticket.id.equals(ticketId)))
        .write(
      TicketsCompanion(updatedAt: Value(DateTime.now())),
    );
  }

  Future<void> _touchReport(int reportId) async {
    await (update(ticketReports)..where((report) => report.id.equals(reportId)))
        .write(TicketReportsCompanion(updatedAt: Value(DateTime.now())));
  }

  String? _clean(String? text) {
    final trimmed = text?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  /// Moves a ticket along the workflow. Never blocked: a solo shop works out of
  /// order, so this only records what happened.
  Future<void> setTicketStatus(int ticketId, TicketStatus status) async {
    if (status == TicketStatus.closed) {
      await closeTicketAfterPayment(ticketId);
      return;
    }
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

  Future<void> setTicketDates({
    required int ticketId,
    required DateTime? dropOffAt,
    required DateTime? technicianStartAt,
    required DateTime? partsArriveAt,
    required DateTime? customerContactedAt,
    required DateTime? pickedUpAt,
    DateTime? dueAt,
  }) async {
    DateTime? dateOnly(DateTime? date) =>
        date == null ? null : DateTime(date.year, date.month, date.day);

    await (update(tickets)..where((ticket) => ticket.id.equals(ticketId)))
        .write(
      TicketsCompanion(
        dropOffAt: Value(dateOnly(dropOffAt)),
        technicianStartAt: Value(dateOnly(technicianStartAt)),
        partsArriveAt: Value(dateOnly(partsArriveAt)),
        customerContactedAt: Value(dateOnly(customerContactedAt)),
        pickedUpAt: Value(dateOnly(pickedUpAt)),
        dueAt: Value(dateOnly(dueAt)),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// The next free shop SKU in `NNN-NNN` form.
  Future<String> nextPartSku() async {
    final query = selectOnly(parts)..addColumns([parts.sku]);
    final rows = await query.get();
    return PartSku.next(rows.map((row) => row.read(parts.sku)));
  }

  /// Gives every part without a SKU the next formatted code, while keeping all
  /// existing SKUs exactly as the shop entered them.
  Future<void> _backfillPartSkus() async {
    final rows = await select(parts).get();
    var highest = PartSku.highestSequence(rows.map((part) => part.sku));
    if (highest < PartSku.firstSequence) {
      highest = PartSku.firstSequence - 1;
    }
    for (final part in rows) {
      if (_clean(part.sku) != null) continue;
      highest++;
      await (update(parts)..where((row) => row.id.equals(part.id))).write(
        PartsCompanion(sku: Value(PartSku.format(highest))),
      );
    }
  }

  Future<int> createInventoryPart({
    required String name,
    String? description,
    String? sku,
    String? vendorId,
    String? vendorSku,
    String? category,
    String? location,
    required int startingStock,
    int rawCostCents = 0,
    int retailPriceCents = 0,
    PartPurchaseType purchaseType = PartPurchaseType.single,
    int bulkQuantity = 1,
    int bulkTotalCents = 0,
    int minimumStock = 0,
    bool chargeShopSupply = false,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'must not be empty');
    }
    if (startingStock < 0) {
      throw ArgumentError.value(
        startingStock,
        'startingStock',
        'must not be negative',
      );
    }
    if (purchaseType.isLot && bulkQuantity < 1) {
      throw ArgumentError.value(
        bulkQuantity,
        'bulkQuantity',
        'must be at least 1',
      );
    }
    if (bulkTotalCents < 0) {
      throw ArgumentError('Part costs must not be negative.');
    }
    final isBulk = purchaseType.isLot;
    final unitCostCents =
        isBulk ? (bulkTotalCents / bulkQuantity).round() : rawCostCents;
    if (unitCostCents < 0 || retailPriceCents < 0) {
      throw ArgumentError('Part costs must not be negative.');
    }
    final cleanSku = _clean(sku);
    return transaction(() async {
      final partId = await into(parts).insert(
        PartsCompanion.insert(
          name: cleanName,
          description: Value(_clean(description)),
          sku: Value(cleanSku ?? await nextPartSku()),
          vendorId: Value(_clean(vendorId)),
          vendorSku: Value(_clean(vendorSku)),
          category: Value(_clean(category)),
          location: Value(_clean(location)),
          stock: Value(startingStock),
          costCents: Value(unitCostCents),
          priceCents: Value(retailPriceCents),
          purchaseType: Value(purchaseType),
          bulkQuantity: Value(isBulk ? bulkQuantity : 1),
          bulkTotalCents: Value(isBulk ? bulkTotalCents : 0),
          chargeShopSupply: Value(chargeShopSupply),
          reorderLevel: Value(minimumStock),
        ),
      );
      if (startingStock > 0) {
        await into(partMovements).insert(
          PartMovementsCompanion.insert(
            partId: partId,
            delta: startingStock,
            note: const Value('Initial stock'),
          ),
        );
      }
      return partId;
    });
  }

  Future<void> updateInventoryPart({
    required int partId,
    required String name,
    String? description,
    String? sku,
    String? vendorId,
    String? vendorSku,
    String? category,
    String? location,
    required int stock,
    required int rawCostCents,
    required int retailPriceCents,
    PartPurchaseType purchaseType = PartPurchaseType.single,
    int bulkQuantity = 1,
    int bulkTotalCents = 0,
    int minimumStock = 0,
    bool chargeShopSupply = false,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'must not be empty');
    }
    if (stock < 0) {
      throw ArgumentError.value(stock, 'stock', 'must not be negative');
    }
    if (purchaseType.isLot && bulkQuantity < 1) {
      throw ArgumentError.value(
        bulkQuantity,
        'bulkQuantity',
        'must be at least 1',
      );
    }
    if (bulkTotalCents < 0) {
      throw ArgumentError('Part costs must not be negative.');
    }
    final isBulk = purchaseType.isLot;
    final unitCostCents =
        isBulk ? (bulkTotalCents / bulkQuantity).round() : rawCostCents;
    if (unitCostCents < 0 || retailPriceCents < 0) {
      throw ArgumentError('Part costs must not be negative.');
    }
    final cleanSku = _clean(sku);
    await transaction(() async {
      final existing = await (select(parts)
            ..where((part) => part.id.equals(partId)))
          .getSingleOrNull();
      if (existing == null) {
        throw StateError('The inventory part was not found.');
      }

      await (update(parts)..where((part) => part.id.equals(partId))).write(
        PartsCompanion(
          name: Value(cleanName),
          description: Value(_clean(description)),
          sku: Value(
            cleanSku ?? _clean(existing.sku) ?? await nextPartSku(),
          ),
          vendorId: Value(_clean(vendorId)),
          vendorSku: Value(_clean(vendorSku)),
          category: Value(_clean(category)),
          location: Value(_clean(location)),
          stock: Value(stock),
          costCents: Value(unitCostCents),
          priceCents: Value(retailPriceCents),
          purchaseType: Value(purchaseType),
          bulkQuantity: Value(isBulk ? bulkQuantity : 1),
          bulkTotalCents: Value(isBulk ? bulkTotalCents : 0),
          chargeShopSupply: Value(chargeShopSupply),
          reorderLevel: Value(minimumStock),
        ),
      );
      final stockDelta = stock - existing.stock;
      if (stockDelta != 0) {
        await into(partMovements).insert(
          PartMovementsCompanion.insert(
            partId: partId,
            delta: stockDelta,
            note: const Value('Stock adjustment'),
          ),
        );
      }
    });
  }

  Future<void> removeInventoryPart(int partId) async {
    await (update(parts)..where((part) => part.id.equals(partId))).write(
      const PartsCompanion(isActive: Value(false)),
    );
  }

  /// The next free merchandise SKU in `NNN-NNN` form.
  ///
  /// Merchandise has its own sequence so the retail list starts clean and
  /// adding a shirt never skips a repair part number.
  Future<String> nextMerchSku() async {
    final query = selectOnly(merchProducts)..addColumns([merchProducts.sku]);
    final rows = await query.get();
    return PartSku.next(rows.map((row) => row.read(merchProducts.sku)));
  }

  Future<int> createMerchItem({
    required String name,
    String? description,
    String? sku,
    String? category,
    String? location,
    required int startingStock,
    int costCents = 0,
    int priceCents = 0,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'must not be empty');
    }
    if (startingStock < 0) {
      throw ArgumentError.value(
        startingStock,
        'startingStock',
        'must not be negative',
      );
    }
    if (costCents < 0 || priceCents < 0) {
      throw ArgumentError('Merchandise costs must not be negative.');
    }
    final cleanSku = _clean(sku);
    return transaction(() async {
      return into(merchProducts).insert(
        MerchProductsCompanion.insert(
          name: cleanName,
          description: Value(_clean(description)),
          sku: Value(cleanSku ?? await nextMerchSku()),
          category: Value(_clean(category)),
          location: Value(_clean(location)),
          stock: Value(startingStock),
          costCents: Value(costCents),
          priceCents: Value(priceCents),
        ),
      );
    });
  }

  Future<void> updateMerchItem({
    required int itemId,
    required String name,
    String? description,
    String? sku,
    String? category,
    String? location,
    required int stock,
    required int costCents,
    required int priceCents,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'must not be empty');
    }
    if (stock < 0) {
      throw ArgumentError.value(stock, 'stock', 'must not be negative');
    }
    if (costCents < 0 || priceCents < 0) {
      throw ArgumentError('Merchandise costs must not be negative.');
    }
    final cleanSku = _clean(sku);
    await transaction(() async {
      final existing = await (select(merchProducts)
            ..where((item) => item.id.equals(itemId)))
          .getSingleOrNull();
      if (existing == null) {
        throw StateError('The merchandise item was not found.');
      }
      await (update(merchProducts)..where((item) => item.id.equals(itemId)))
          .write(
        MerchProductsCompanion(
          name: Value(cleanName),
          description: Value(_clean(description)),
          sku: Value(
            cleanSku ?? _clean(existing.sku) ?? await nextMerchSku(),
          ),
          category: Value(_clean(category)),
          location: Value(_clean(location)),
          stock: Value(stock),
          costCents: Value(costCents),
          priceCents: Value(priceCents),
        ),
      );
    });
  }

  Future<void> removeMerchItem(int itemId) async {
    await (update(merchProducts)..where((item) => item.id.equals(itemId)))
        .write(
      const MerchProductsCompanion(isActive: Value(false)),
    );
  }

  Stream<Map<int, List<LabourIncludedPart>>> watchLabourIncludedParts() =>
      (select(settings)..where((s) => s.key.equals(_labourPartsSettingKey)))
          .watchSingleOrNull()
          .map((row) => _decodeLabourParts(row?.value));

  Future<void> setLabourIncludedParts(
    int labourId,
    List<LabourIncludedPart> included,
  ) async {
    await transaction(() async {
      final all = Map<int, List<LabourIncludedPart>>.of(
        _decodeLabourParts(await _setting(_labourPartsSettingKey, '')),
      );
      final cleaned = [
        for (final item in included)
          if (item.quantity > 0) item,
      ];
      if (cleaned.isEmpty) {
        all.remove(labourId);
      } else {
        all[labourId] = cleaned;
      }
      await _putSetting(
        _labourPartsSettingKey,
        jsonEncode({
          for (final entry in all.entries)
            '${entry.key}': [
              for (final item in entry.value)
                {'p': item.partId, 'q': item.quantity},
            ],
        }),
      );
    });
  }

  Future<void> addRequiredPart({
    required int ticketId,
    required int partId,
    required int quantity,
  }) async {
    if (quantity < 1) {
      throw ArgumentError.value(quantity, 'quantity', 'must be at least 1');
    }
    await transaction(() async {
      final part = await (select(parts)
            ..where((row) => row.id.equals(partId) & row.isActive.equals(true)))
          .getSingleOrNull();
      if (part == null) throw StateError('The inventory part is unavailable.');
      final existing = await (select(ticketItems)
            ..where(
              (item) =>
                  item.ticketId.equals(ticketId) &
                  item.partId.equals(partId) &
                  item.kind.equals(TicketItemKind.part.index) &
                  item.description.like('% (included)').not(),
            ))
          .getSingleOrNull();
      if (existing == null) {
        await into(ticketItems).insert(
          TicketItemsCompanion.insert(
            ticketId: ticketId,
            kind: TicketItemKind.part,
            partId: Value(partId),
            description: part.name,
            quantity: Value(quantity),
            unitPriceCents: Value(_billedUnitCents(part)),
            unitCostCents: Value(part.costCents),
          ),
        );
      } else {
        await (update(ticketItems)
              ..where((item) => item.id.equals(existing.id)))
            .write(
          TicketItemsCompanion(
            quantity: Value(existing.quantity + quantity),
            description: Value(part.name),
            unitPriceCents: Value(_billedUnitCents(part)),
            unitCostCents: Value(part.costCents),
          ),
        );
      }
      if (isLabourCategory(part.category)) {
        final included = _decodeLabourParts(
          await _setting(_labourPartsSettingKey, ''),
        )[partId];
        for (final item in included ?? const <LabourIncludedPart>[]) {
          await _addIncludedPartLine(
            ticketId: ticketId,
            partId: item.partId,
            quantity: item.quantity * quantity,
          );
        }
      }
    });
  }

  /// Lists a part that comes with a labour item: it uses stock and counts as a
  /// job cost, but bills nothing.
  Future<void> _addIncludedPartLine({
    required int ticketId,
    required int partId,
    required int quantity,
  }) async {
    final part = await (select(parts)
          ..where((row) => row.id.equals(partId) & row.isActive.equals(true)))
        .getSingleOrNull();
    if (part == null) return;
    final description = '${part.name} (included)';
    final existing = await (select(ticketItems)
          ..where(
            (item) =>
                item.ticketId.equals(ticketId) &
                item.partId.equals(partId) &
                item.kind.equals(TicketItemKind.part.index) &
                item.description.equals(description),
          ))
        .getSingleOrNull();
    if (existing == null) {
      await into(ticketItems).insert(
        TicketItemsCompanion.insert(
          ticketId: ticketId,
          kind: TicketItemKind.part,
          partId: Value(partId),
          description: description,
          quantity: Value(quantity),
          unitPriceCents: const Value(0),
          unitCostCents: Value(part.costCents),
        ),
      );
    } else {
      await (update(ticketItems)..where((item) => item.id.equals(existing.id)))
          .write(
        TicketItemsCompanion(quantity: Value(existing.quantity + quantity)),
      );
    }
  }

  /// Marks a shop-supply invoice line as charged (retail price per use) or
  /// free again.
  Future<void> setSupplyLineCharged(int ticketItemId, bool charged) async {
    final item = await (select(ticketItems)
          ..where((row) => row.id.equals(ticketItemId)))
        .getSingleOrNull();
    if (item?.partId == null) return;
    final part = await (select(parts)
          ..where((row) => row.id.equals(item!.partId!)))
        .getSingleOrNull();
    if (part == null) return;
    await (update(ticketItems)..where((row) => row.id.equals(ticketItemId)))
        .write(
      TicketItemsCompanion(
        unitPriceCents: Value(charged ? part.priceCents : 0),
      ),
    );
  }

  /// Opens a quote: a ticket with no device or intake, used to build up an
  /// invoice. [purgeExpiredQuotes] removes it if intake never happens.
  Future<NewTicket> createQuote({String? customerName}) {
    return transaction(() async {
      final name = (customerName ?? '').trim();
      final created = await createTicket(
        customerName: name.isEmpty ? quoteCustomerName : name,
        customerPhone: '-',
        customerEmail: '-',
        deviceName: 'Quote',
        complaint: 'Quote',
      );
      await (update(tickets)..where((row) => row.id.equals(created.id))).write(
        const TicketsCompanion(status: Value(TicketStatus.quote)),
      );
      return created;
    });
  }

  /// Deletes quotes older than [quoteLifetimeDays]; returns the ticket ids.
  Future<List<int>> expiredQuoteIds({DateTime? now}) async {
    final cutoff = (now ?? DateTime.now())
        .subtract(const Duration(days: quoteLifetimeDays));
    final rows = await (select(tickets)
          ..where(
            (row) =>
                row.status.equals(TicketStatus.quote.index) &
                row.createdAt.isSmallerThanValue(cutoff),
          ))
        .get();
    return [for (final row in rows) row.id];
  }

  /// Moves a quote's invoice onto the repair ticket created at intake, then
  /// removes the quote.
  Future<void> adoptQuote({
    required int quoteId,
    required int ticketId,
  }) =>
      transaction(() async {
        final quote = await (select(tickets)
              ..where((row) => row.id.equals(quoteId)))
            .getSingleOrNull();
        if (quote == null || quote.status != TicketStatus.quote) return;
        await (update(ticketItems)
              ..where((item) => item.ticketId.equals(quoteId)))
            .write(TicketItemsCompanion(ticketId: Value(ticketId)));
        await (update(tickets)..where((row) => row.id.equals(ticketId))).write(
          TicketsCompanion(
            invoiceDiscountKind: Value(quote.invoiceDiscountKind),
            invoiceDiscountValue: Value(quote.invoiceDiscountValue),
            partnerPartsPercent: Value(quote.partnerPartsPercent),
            partnerLabourPercent: Value(quote.partnerLabourPercent),
          ),
        );
        await deleteTicket(quoteId);
      });

  /// Rings up a direct sale: a closed, paid ticket with no device.
  Future<int> createQuickSale({
    String? customerName,
    required List<({int partId, int quantity})> parts,
    required List<({String description, int quantity, int unitPriceCents})>
        customLines,
    required PaymentMethod method,
    Future<bool> Function(int dueCents)? authorizePayment,
  }) async {
    if (parts.isEmpty && customLines.isEmpty) {
      throw ArgumentError('Add at least one item to the sale.');
    }
    return transaction(() async {
      final name = (customerName ?? '').trim();
      final created = await createTicket(
        customerName: name.isEmpty ? 'Quick Sale' : name,
        customerPhone: '-',
        customerEmail: '-',
        deviceName: 'Quick Sale',
        complaint: 'Direct sale',
      );
      final ticketId = created.id;
      for (final line in parts) {
        await addRequiredPart(
          ticketId: ticketId,
          partId: line.partId,
          quantity: line.quantity,
        );
        final item = await (select(ticketItems)
              ..where(
                (row) =>
                    row.ticketId.equals(ticketId) &
                    row.partId.equals(line.partId),
              ))
            .getSingle();
        final part = await (select(this.parts)
              ..where((row) => row.id.equals(line.partId)))
            .getSingle();
        if (part.purchaseType == PartPurchaseType.tube) {
          // A tube sells whole, marked up on the full tube cost. The invoice
          // quantity counts tubes, so the other uses of each tube come out of
          // stock here (closing the ticket takes the first one).
          final markup = await markupPercent('parts_markup_percent', 35);
          final tubePrice = (part.bulkTotalCents * (100 + markup) + 50) ~/ 100;
          await (update(ticketItems)..where((row) => row.id.equals(item.id)))
              .write(
            TicketItemsCompanion(
              description: Value('${part.name} (full tube)'),
              unitPriceCents: Value(tubePrice),
            ),
          );
          final extraUses = line.quantity * (part.bulkQuantity - 1);
          final taken = extraUses > part.stock ? part.stock : extraUses;
          await (update(this.parts)..where((row) => row.id.equals(part.id)))
              .write(PartsCompanion(stock: Value(part.stock - taken)));
        } else {
          // Direct sales bill shop supplies at their retail price.
          await setSupplyLineCharged(item.id, true);
        }
      }
      for (final line in customLines) {
        await addInvoiceLaborLine(
          ticketId: ticketId,
          description: line.description,
          quantity: line.quantity,
          unitPriceCents: line.unitPriceCents,
        );
      }
      await (update(tickets)..where((row) => row.id.equals(ticketId))).write(
        TicketsCompanion(
          status: const Value(TicketStatus.ready),
          updatedAt: Value(DateTime.now()),
        ),
      );
      final items = await (select(ticketItems)
            ..where((item) => item.ticketId.equals(ticketId)))
          .get();
      final subtotal = items.fold<int>(
        0,
        (sum, item) => sum + item.quantity * item.unitPriceCents,
      );
      final taxes = await taxConfig();
      final due = subtotal + taxes.taxCentsFor(subtotal);
      if (due > 0 && authorizePayment != null && !await authorizePayment(due)) {
        throw const PaymentCancelledException();
      }
      if (due > 0) {
        await recordTicketPayment(
          ticketId: ticketId,
          amountCents: due,
          method: method,
        );
      }
      await closeTicketAfterPayment(ticketId);
      return ticketId;
    });
  }

  Future<void> addInvoiceLaborLine({
    required int ticketId,
    required String description,
    required int quantity,
    required int unitPriceCents,
  }) async {
    final cleanDescription = description.trim();
    if (cleanDescription.isEmpty) {
      throw ArgumentError.value(
          description, 'description', 'must not be empty');
    }
    if (quantity < 1) {
      throw ArgumentError.value(quantity, 'quantity', 'must be at least 1');
    }
    if (unitPriceCents < 0) {
      throw ArgumentError.value(
        unitPriceCents,
        'unitPriceCents',
        'must not be negative',
      );
    }
    await into(ticketItems).insert(
      TicketItemsCompanion.insert(
        ticketId: ticketId,
        kind: TicketItemKind.custom,
        description: cleanDescription,
        quantity: Value(quantity),
        unitPriceCents: Value(unitPriceCents),
      ),
    );
  }

  Future<void> addCheckoutMerchLine({
    required int ticketId,
    required String description,
    required int quantity,
    required int unitCostCents,
    required int unitPriceCents,
  }) async {
    final cleanDescription = description.trim();
    if (cleanDescription.isEmpty || quantity < 1) {
      throw ArgumentError('Enter a merchandise name and quantity.');
    }
    if (unitCostCents < 0 || unitPriceCents < 0) {
      throw ArgumentError('Merchandise costs and prices must not be negative.');
    }
    final ticket = await (select(tickets)
          ..where((row) => row.id.equals(ticketId)))
        .getSingleOrNull();
    if (ticket?.status != TicketStatus.ready) {
      throw StateError('Merchandise can only be added during checkout.');
    }
    await into(ticketItems).insert(
      TicketItemsCompanion.insert(
        ticketId: ticketId,
        kind: TicketItemKind.custom,
        description: cleanDescription,
        quantity: Value(quantity),
        unitPriceCents: Value(unitPriceCents),
        unitCostCents: Value(unitCostCents),
      ),
    );
  }

  Stream<List<Payment>> watchTicketPayments(int ticketId) => (select(payments)
        ..where((payment) => payment.ticketId.equals(ticketId))
        ..orderBy([(payment) => OrderingTerm.asc(payment.at)]))
      .watch();

  /// Records the drop-off deposit; it counts toward the final invoice.
  Future<void> recordTicketDeposit({
    required int ticketId,
    required int amountCents,
    required PaymentMethod method,
  }) async {
    if (amountCents < 1) {
      throw ArgumentError.value(amountCents, 'amountCents', 'must be positive');
    }
    await into(payments).insert(
      PaymentsCompanion.insert(
        ticketId: ticketId,
        amountCents: amountCents,
        method: method,
        kind: PaymentKind.deposit,
      ),
    );
  }

  /// Gives money back on a ticket; it can never exceed what was paid net of
  /// earlier refunds.
  Future<void> recordTicketRefund({
    required int ticketId,
    required int amountCents,
    required PaymentMethod method,
  }) async {
    if (amountCents < 1) {
      throw ArgumentError.value(amountCents, 'amountCents', 'must be positive');
    }
    await transaction(() async {
      final rows = await (select(payments)
            ..where((payment) => payment.ticketId.equals(ticketId)))
          .get();
      final paid = rows.fold<int>(
        0,
        (sum, payment) =>
            sum +
            (payment.kind == PaymentKind.refund
                ? -payment.amountCents
                : payment.amountCents),
      );
      if (amountCents > paid) {
        throw StateError('Refund exceeds the amount paid on this ticket.');
      }
      await into(payments).insert(
        PaymentsCompanion.insert(
          ticketId: ticketId,
          amountCents: amountCents,
          method: method,
          kind: PaymentKind.refund,
        ),
      );
    });
  }

  Future<void> recordTicketPayment({
    required int ticketId,
    required int amountCents,
    required PaymentMethod method,
  }) async {
    if (amountCents < 1) {
      throw ArgumentError.value(amountCents, 'amountCents', 'must be positive');
    }
    await transaction(() async {
      final ticket = await (select(tickets)
            ..where((row) => row.id.equals(ticketId)))
          .getSingleOrNull();
      if (ticket?.status != TicketStatus.ready) {
        throw StateError('Payment can only be recorded during checkout.');
      }
      final items = await (select(ticketItems)
            ..where((item) => item.ticketId.equals(ticketId)))
          .get();
      final subtotal = items.fold<int>(
        0,
        (sum, item) => sum + item.quantity * item.unitPriceCents,
      );
      final discount = await _ticketDiscountCents(ticket!, items);
      final total = subtotal - discount;
      final taxes = await taxConfig();
      final amountDue = total + taxes.taxCentsFor(total);
      final paymentsForTicket = await (select(payments)
            ..where((payment) => payment.ticketId.equals(ticketId)))
          .get();
      final paid = paymentsForTicket.fold<int>(
        0,
        (sum, payment) =>
            sum +
            (payment.kind == PaymentKind.refund
                ? -payment.amountCents
                : payment.amountCents),
      );
      if (amountCents > amountDue - paid) {
        throw StateError('Payment exceeds the outstanding balance.');
      }
      await into(payments).insert(
        PaymentsCompanion.insert(
          ticketId: ticketId,
          amountCents: amountCents,
          method: method,
          kind: PaymentKind.balance,
        ),
      );
    });
  }

  Future<void> closeTicketAfterPayment(int ticketId) async {
    await transaction(() async {
      final ticket = await (select(tickets)
            ..where((row) => row.id.equals(ticketId)))
          .getSingleOrNull();
      if (ticket == null) throw StateError('Ticket was not found.');
      if (ticket.status != TicketStatus.ready) {
        throw StateError('Only ready tickets can be closed from checkout.');
      }
      final items = await (select(ticketItems)
            ..where((item) => item.ticketId.equals(ticketId)))
          .get();
      final subtotal = items.fold<int>(
        0,
        (sum, item) => sum + item.quantity * item.unitPriceCents,
      );
      final discount = await _ticketDiscountCents(ticket, items);
      final taxable = subtotal - discount;
      final taxes = await taxConfig();
      final gst = taxes.gstCentsFor(taxable);
      final pst = taxes.pstCentsFor(taxable);
      final total = taxable + gst + pst;
      final paymentsForTicket = await (select(payments)
            ..where((payment) => payment.ticketId.equals(ticketId)))
          .get();
      final paid = paymentsForTicket.fold<int>(
        0,
        (sum, payment) =>
            sum +
            (payment.kind == PaymentKind.refund
                ? -payment.amountCents
                : payment.amountCents),
      );
      if (paid < total) {
        throw StateError(
            'The invoice must be paid before closing this ticket.');
      }
      final now = DateTime.now();
      await (update(tickets)..where((row) => row.id.equals(ticketId))).write(
        TicketsCompanion(
          status: const Value(TicketStatus.closed),
          completedAt: Value(now),
          pickedUpAt: Value(now),
          updatedAt: Value(now),
          gstCents: Value(gst),
          pstCents: Value(pst),
        ),
      );
      await _consumeTicketParts(ticketId);
    });
  }

  /// Takes the parts fitted to [ticketId] out of stock when the ticket closes.
  ///
  /// Only the outstanding quantity per line is deducted, so reopening a closed
  /// job and closing it again leaves the original parts alone and only counts
  /// what was added for the new visit. Stock never drops below zero; any
  /// shortfall is written into the movement note so the count can be fixed.
  Future<void> _consumeTicketParts(int ticketId) async {
    final lines = await (select(ticketItems)
          ..where(
            (item) =>
                item.ticketId.equals(ticketId) &
                item.kind.equals(TicketItemKind.part.index) &
                item.partId.isNotNull(),
          ))
        .get();
    for (final line in lines) {
      final outstanding = line.quantity - line.consumedQuantity;
      if (outstanding <= 0) continue;
      final part = await (select(parts)
            ..where((row) => row.id.equals(line.partId!)))
          .getSingleOrNull();
      if (part == null) continue;
      final deducted = outstanding > part.stock ? part.stock : outstanding;
      if (deducted > 0) {
        await (update(parts)..where((row) => row.id.equals(part.id))).write(
          PartsCompanion(stock: Value(part.stock - deducted)),
        );
        final short = outstanding - deducted;
        await into(partMovements).insert(
          PartMovementsCompanion.insert(
            partId: part.id,
            ticketId: Value(ticketId),
            delta: -deducted,
            note: Value(
              short > 0
                  ? 'Used on closed ticket (stock short by $short)'
                  : 'Used on closed ticket',
            ),
          ),
        );
      }
      await (update(ticketItems)..where((item) => item.id.equals(line.id)))
          .write(
        TicketItemsCompanion(consumedQuantity: Value(line.quantity)),
      );
    }
  }

  Future<void> removeInvoiceLaborLine({
    required int ticketId,
    required int ticketItemId,
  }) async {
    await (delete(ticketItems)
          ..where(
            (item) =>
                item.id.equals(ticketItemId) &
                item.ticketId.equals(ticketId) &
                item.kind.equals(TicketItemKind.custom.index),
          ))
        .go();
  }

  /// Total discount on a ticket: the manual discount plus the partner's
  /// parts and labour percentages, never more than the subtotal.
  Future<int> _ticketDiscountCents(
    Ticket ticket,
    List<TicketItem> items,
  ) async {
    var subtotal = 0;
    var parts = 0;
    var labour = 0;
    final partIds = {
      for (final item in items)
        if (item.kind == TicketItemKind.part && item.partId != null)
          item.partId!,
    };
    final categories = <int, String?>{};
    if (partIds.isNotEmpty) {
      final rows =
          await (select(this.parts)..where((p) => p.id.isIn(partIds))).get();
      for (final row in rows) {
        categories[row.id] = row.category;
      }
    }
    for (final item in items) {
      final line = item.quantity * item.unitPriceCents;
      subtotal += line;
      final isSupply = item.kind == TicketItemKind.part &&
          isShopSupplyCategory(categories[item.partId]);
      final isMerch =
          item.kind == TicketItemKind.custom && item.unitCostCents != null;
      if (isSupply || isMerch) continue;
      if (item.kind == TicketItemKind.part) {
        parts += line;
      } else {
        labour += line;
      }
    }
    return invoiceDiscountCentsFor(
      subtotalCents: subtotal,
      partsCents: parts,
      labourCents: labour,
      kind: ticket.invoiceDiscountKind,
      value: ticket.invoiceDiscountValue,
      partnerPartsPercent: ticket.partnerPartsPercent,
      partnerLabourPercent: ticket.partnerLabourPercent,
    );
  }

  Future<void> setInvoiceDiscount({
    required int ticketId,
    required InvoiceDiscountKind kind,
    required int value,
    int partnerPartsPercent = 0,
    int partnerLabourPercent = 0,
  }) async {
    if (kind == InvoiceDiscountKind.percentage && (value < 0 || value > 100)) {
      throw ArgumentError.value(value, 'value', 'must be between 0 and 100');
    }
    if (value < 0) {
      throw ArgumentError.value(value, 'value', 'must not be negative');
    }
    await (update(tickets)..where((ticket) => ticket.id.equals(ticketId)))
        .write(
      TicketsCompanion(
        invoiceDiscountKind: Value(kind),
        invoiceDiscountValue: Value(value),
        partnerPartsPercent: Value(partnerPartsPercent.clamp(0, 100)),
        partnerLabourPercent: Value(partnerLabourPercent.clamp(0, 100)),
      ),
    );
  }

  Future<void> removeRequiredPart({
    required int ticketId,
    required int ticketItemId,
  }) async {
    await (delete(ticketItems)
          ..where(
            (item) =>
                item.id.equals(ticketItemId) &
                item.ticketId.equals(ticketId) &
                item.kind.equals(TicketItemKind.part.index),
          ))
        .go();
  }

  /// Deletes a ticket and its dependent records while preserving shared
  /// customer records and the history of issued shop tags and part movements.
  Future<bool> deleteTicket(int ticketId) => transaction(() async {
        final ticket = await (select(tickets)
              ..where((t) => t.id.equals(ticketId)))
            .getSingleOrNull();
        if (ticket == null) return false;

        final reportIds = await (select(ticketReports)
              ..where((report) => report.ticketId.equals(ticketId)))
            .map((report) => report.id)
            .get();
        if (reportIds.isNotEmpty) {
          await (delete(reportCosmeticItems)
                ..where((item) => item.reportId.isIn(reportIds)))
              .go();
          await (delete(reportFindings)
                ..where((finding) => finding.reportId.isIn(reportIds)))
              .go();
          await (delete(technicalReportEntries)
                ..where((entry) => entry.reportId.isIn(reportIds)))
              .go();
          await (delete(clientReportEntries)
                ..where((entry) => entry.reportId.isIn(reportIds)))
              .go();
          await (delete(reportContactLog)
                ..where((log) => log.reportId.isIn(reportIds)))
              .go();
        }

        await (update(shopTags)..where((tag) => tag.ticketId.equals(ticketId)))
            .write(const ShopTagsCompanion(ticketId: Value(null)));
        await (update(partMovements)
              ..where((movement) => movement.ticketId.equals(ticketId)))
            .write(const PartMovementsCompanion(ticketId: Value(null)));
        await (delete(ticketItems)
              ..where((item) => item.ticketId.equals(ticketId)))
            .go();
        await (delete(ticketPhotos)
              ..where((photo) => photo.ticketId.equals(ticketId)))
            .go();
        await (delete(ticketPhotoSlots)
              ..where((slot) => slot.ticketId.equals(ticketId)))
            .go();
        await (delete(payments)
              ..where((payment) => payment.ticketId.equals(ticketId)))
            .go();
        await (delete(ticketReports)
              ..where((report) => report.ticketId.equals(ticketId)))
            .go();
        await (delete(tickets)..where((t) => t.id.equals(ticketId))).go();
        return true;
      });
}

/// What [AppDatabase.createTicket] hands back: enough to open the new ticket
/// and to print the shop tag.
class NewTicket {
  const NewTicket({
    required this.id,
    required this.number,
    required this.shopTag,
    required this.customerId,
    this.customerDeviceId,
  });

  final int id;
  final String number;
  final String shopTag;
  final int customerId;
  final int? customerDeviceId;
}
