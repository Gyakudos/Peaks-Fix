import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import 'database.dart';
import 'ticket_due.dart';
import 'financials.dart';
import 'payments/payment_processor.dart';
import 'photo_store.dart';
import 'photo_templates.dart';
import 'taxes.dart';
import 'warranty.dart';

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
    this.dropOffAt,
    this.technicianStartAt,
    this.partsArriveAt,
    this.customerContactedAt,
    this.pickedUpAt,
    this.dueAt,
    this.shopTag,
    this.serial,
    this.serialMissing = false,
    this.deviceVariant,
    this.deviceSide,
    this.partnerName = '',
  });

  final int id;
  final String number;
  final TicketStatus status;
  final String customerName;
  final String device;
  final String complaint;
  final DateTime createdAt;
  final DateTime? dropOffAt;
  final DateTime? technicianStartAt;
  final DateTime? partsArriveAt;
  final DateTime? customerContactedAt;
  final DateTime? pickedUpAt;

  /// A due date the tech set by hand; null means the 14-day default applies.
  final DateTime? dueAt;

  /// The due date in effect: the tech's adjustment, else drop-off + 14 days.
  DateTime get dueDate => dueAt ?? defaultDueDate(dropOffAt ?? createdAt);
  final String? shopTag;
  final String? serial;
  final bool serialMissing;

  /// Model number / revision typed on the ticket, e.g. `PSP-3000`.
  final String? deviceVariant;

  /// `left` or `right` when the device is booked one half at a time, e.g. a
  /// single Joy-Con.
  final String? deviceSide;

  /// The partner this ticket came through; empty for walk-ins.
  final String partnerName;

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
    this.report2CompletedAt,
    this.report3CompletedAt,
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

  /// When the technical stage (Report 2) was marked complete.
  final DateTime? report2CompletedAt;

  /// When the client report (Report 3) was marked complete. Completing it also
  /// sends the ticket to Checkout.
  final DateTime? report3CompletedAt;
  final int estimateCents;
  final DateTime? dueAt;
  final DateTime? completedAt;
  final DateTime? pickedUpAt;

  TicketDetailEntry copyWith({
    TicketBoardEntry? summary,
    String? diagnosis,
    String? notes,
    String? intakeNotes,
    DateTime? report1CompletedAt,
    DateTime? report2CompletedAt,
    DateTime? report3CompletedAt,
    int? estimateCents,
    DateTime? dueAt,
    DateTime? completedAt,
    DateTime? pickedUpAt,
    bool clearReport1 = false,
    bool clearReport2 = false,
    bool clearReport3 = false,
  }) {
    return TicketDetailEntry(
      summary: summary ?? this.summary,
      diagnosis: diagnosis ?? this.diagnosis,
      notes: notes ?? this.notes,
      intakeNotes: intakeNotes ?? this.intakeNotes,
      report1CompletedAt:
          clearReport1 ? null : report1CompletedAt ?? this.report1CompletedAt,
      report2CompletedAt:
          clearReport2 ? null : report2CompletedAt ?? this.report2CompletedAt,
      report3CompletedAt:
          clearReport3 ? null : report3CompletedAt ?? this.report3CompletedAt,
      estimateCents: estimateCents ?? this.estimateCents,
      dueAt: dueAt ?? this.dueAt,
      completedAt: completedAt ?? this.completedAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
    );
  }

  TicketDates get dates => TicketDates(
        dropOffAt: summary.dropOffAt,
        technicianStartAt: summary.technicianStartAt,
        partsArriveAt: summary.partsArriveAt,
        customerContactedAt: summary.customerContactedAt,
        pickedUpAt: summary.pickedUpAt,
        dueAt: summary.dueAt,
      );
}

class TicketDates {
  const TicketDates({
    this.dropOffAt,
    this.technicianStartAt,
    this.partsArriveAt,
    this.customerContactedAt,
    this.pickedUpAt,
    this.dueAt,
  });

  final DateTime? dropOffAt;
  final DateTime? technicianStartAt;
  final DateTime? partsArriveAt;
  final DateTime? customerContactedAt;
  final DateTime? pickedUpAt;
  final DateTime? dueAt;
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
    this.warranty,
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

  /// The most recent warranty issued on a completed Report 3 for this device.
  final DeviceWarranty? warranty;
}

/// A device the intake form can pick, flattened from category → brand → model.
class DeviceOption {
  const DeviceOption({
    required this.modelId,
    required this.category,
    required this.modelName,
    required this.label,
    this.brand = '',
  });

  final int modelId;
  final String category;
  final String brand;

  /// The bare catalog name, e.g. `3DS`, used to pick the photo checklist.
  final String modelName;

  /// e.g. `Nintendo 3DS`.
  final String label;
}

class StaffMemberEntry {
  const StaffMemberEntry({
    required this.id,
    required this.name,
    required this.job,
    required this.isActive,
  });

  final String id;
  final String name;
  final String job;
  final bool isActive;

  factory StaffMemberEntry.fromJson(Map<String, dynamic> json) =>
      StaffMemberEntry(
        id: json['id'] as String,
        name: json['name'] as String,
        job: json['job'] as String,
        isActive: json['isActive'] as bool? ?? true,
      );
}

/// Technician levels for labour; Tech 1 is the highest and Admin counts as one.
const List<int> jobLevels = [1, 2, 3];

String jobLevelLabel(int level) => 'Tech $level';

class InventoryPart {
  const InventoryPart({
    required this.id,
    required this.name,
    required this.stock,
    int? inventory,
    int? minimumStock,
    this.description,
    this.rawCostCents = 0,
    this.retailPriceCents = 0,
    this.sku,
    this.vendorId,
    this.vendorSku,
    this.brand,
    this.jobLevel,
    this.category,
    this.location,
    this.purchaseType = PartPurchaseType.single,
    this.bulkQuantity = 1,
    this.bulkTotalCents = 0,
    this.committedQuantity = 0,
    this.chargeShopSupply = false,
    int? reorderLevel,
  }) : minimumStock = minimumStock ?? reorderLevel ?? 0;

  /// The manufacturer or brand, e.g. "Anker".
  final String? brand;

  /// Labour only: technician level needed, 1 (Tech 1) to 3 (Tech 3).
  final int? jobLevel;

  /// Shop supplies only: bills [retailPriceCents] per use on the invoice.
  final bool chargeShopSupply;

  /// Whole tubes on hand when this part is a [PartPurchaseType.tube].
  int get fullTubes => purchaseType == PartPurchaseType.tube && bulkQuantity > 0
      ? stock ~/ bulkQuantity
      : 0;

  /// Uses left in the opened tube.
  int get usesInOpenTube =>
      purchaseType == PartPurchaseType.tube && bulkQuantity > 0
          ? stock % bulkQuantity
          : 0;

  final int id;
  final String name;
  final String? description;

  /// Current on-hand inventory. This is deducted when a ticket is closed.
  final int stock;
  int get inventory => stock;
  int get inventoryValue => stock;

  /// Minimum stock level (shown as "Stock" on the parts page).
  final int minimumStock;
  int get reorderLevel => minimumStock;

  final int rawCostCents;
  final int retailPriceCents;
  final String? sku;
  final String? vendorId;
  final String? vendorSku;
  final String? category;
  final String? location;
  final PartPurchaseType purchaseType;
  final int bulkQuantity;
  final int bulkTotalCents;

  /// How many of this part are still needed by tickets that are open. Closing
  /// a ticket takes its parts out of inventory and stops counting them here, so
  /// this is the quantity already spoken for by jobs in the shop.
  final int committedQuantity;
}

/// A retail item on the Merch page: something sold over the counter rather
/// than fitted to a repair ticket.
class InventoryMerchItem {
  const InventoryMerchItem({
    required this.id,
    required this.name,
    required this.stock,
    this.description,
    this.costCents = 0,
    this.priceCents = 0,
    this.sku,
    this.category,
    this.location,
  });

  final int id;
  final String name;
  final String? description;
  final int stock;
  final int costCents;
  final int priceCents;
  final String? sku;
  final String? category;
  final String? location;

  int get profitCents => priceCents - costCents;
}

class RequiredPart {
  const RequiredPart({
    required this.ticketItemId,
    required this.partId,
    required this.name,
    required this.quantity,
    required this.stock,
    this.description,
    this.rawCostCents = 0,
    this.retailPriceCents = 0,
    this.sku,
    this.location,
  });

  final int ticketItemId;
  final int partId;
  final String name;
  final String? description;
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
    this.isMerch = false,
    this.isShopSupply = false,
  });

  final int ticketItemId;
  final TicketItemKind kind;
  final String description;
  final int quantity;
  final int unitPriceCents;
  final bool isMerch;

  /// A shop supply used on the repair: listed on the invoice, never billed.
  final bool isShopSupply;

  int get lineTotalCents => quantity * unitPriceCents;
}

class PaymentEntry {
  const PaymentEntry({
    required this.id,
    required this.at,
    required this.amountCents,
    required this.method,
    required this.kind,
  });

  final int id;
  final DateTime at;
  final int amountCents;
  final PaymentMethod method;
  final PaymentKind kind;
}

class InvoiceDraft {
  const InvoiceDraft({
    required this.discountKind,
    required this.discountValue,
    required this.lines,
    this.taxes = const TaxConfig(),
    this.partnerPartsPercent = 0,
    this.partnerLabourPercent = 0,
  });

  final InvoiceDiscountKind discountKind;
  final int discountValue;
  final List<InvoiceLine> lines;
  final TaxConfig taxes;
  final int partnerPartsPercent;
  final int partnerLabourPercent;

  int get subtotalCents =>
      lines.fold(0, (total, line) => total + line.lineTotalCents);

  int get partsCents => lines
      .where((l) => l.kind == TicketItemKind.part && !l.isShopSupply)
      .fold(0, (total, line) => total + line.lineTotalCents);

  int get labourCents => lines
      .where(
        (l) => l.kind != TicketItemKind.part && !l.isMerch && !l.isShopSupply,
      )
      .fold(0, (total, line) => total + line.lineTotalCents);

  /// Discount from the partner's parts and labour percentages alone.
  int get partnerDiscountCents =>
      (partsCents * partnerPartsPercent + 50) ~/ 100 +
      (labourCents * partnerLabourPercent + 50) ~/ 100;

  int get discountCents => invoiceDiscountCentsFor(
        subtotalCents: subtotalCents,
        partsCents: partsCents,
        labourCents: labourCents,
        kind: discountKind,
        value: discountValue,
        partnerPartsPercent: partnerPartsPercent,
        partnerLabourPercent: partnerLabourPercent,
      );

  /// Amount sales tax is calculated on: the bill after discounts.
  int get taxableCents => subtotalCents - discountCents;

  List<TaxLine> get taxLines => taxes.linesFor(taxableCents);

  int get taxCents => taxes.taxCentsFor(taxableCents);

  int get totalCents => taxableCents + taxCents;
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

  Future<List<CustomerRecord>> searchCustomersByName(String query);

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

  /// All-time closed-ticket revenue, cost and staff pay for the rail badge.
  Stream<FinancialSummary> watchFinancialSummary();

  Future<void> deleteTicket(int ticketId);

  Stream<List<InventoryPart>> watchInventoryParts();

  /// The next auto-assigned `NNN-NNN` shop SKU.
  Future<String> nextPartSku();

  Stream<List<RequiredPart>> watchRequiredParts(int ticketId);

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
    String? brand,
    int? jobLevel,
  });

  /// Parts that come with each labour item, keyed by the labour part id.
  Stream<Map<int, List<LabourIncludedPart>>> watchLabourIncludedParts();

  Future<void> setLabourIncludedParts(
    int labourId,
    List<LabourIncludedPart> included,
  );

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
    String? brand,
    int? jobLevel,
  });

  Future<void> removeInventoryPart(int partId);

  Stream<List<InventoryMerchItem>> watchMerchItems();

  /// The next auto-assigned `NNN-NNN` merchandise SKU.
  Future<String> nextMerchSku();

  Future<void> createMerchItem({
    required String name,
    String? description,
    String? sku,
    String? category,
    String? location,
    required int startingStock,
    int costCents = 0,
    int priceCents = 0,
  });

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
  });

  Future<void> removeMerchItem(int itemId);

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

  Stream<List<PaymentEntry>> watchTicketPayments(int ticketId);

  Future<void> addCheckoutMerchLine({
    required int ticketId,
    required String description,
    required int quantity,
    required int unitCostCents,
    required int unitPriceCents,
  });

  Future<void> recordTicketPayment({
    required int ticketId,
    required int amountCents,
    required PaymentMethod method,
  });

  Future<void> closeTicketAfterPayment(int ticketId);

  Future<void> recordTicketRefund({
    required int ticketId,
    required int amountCents,
    required PaymentMethod method,
  });

  Future<void> recordTicketDeposit({
    required int ticketId,
    required int amountCents,
    required PaymentMethod method,
  });

  Future<void> setSupplyLineCharged(int ticketItemId, bool charged);

  /// Opens a quote ticket (no intake) for building up an invoice.
  Future<NewTicket> createQuote({String? customerName});

  /// Deletes quotes that never reached intake within [quoteLifetimeDays].
  Future<void> purgeExpiredQuotes();

  /// Moves a quote's invoice lines to [ticketId] and removes the quote.
  Future<void> adoptQuote({required int quoteId, required int ticketId});

  Future<int> createQuickSale({
    String? customerName,
    required List<({int partId, int quantity})> parts,
    required List<({String description, int quantity, int unitPriceCents})>
        customLines,
    required PaymentMethod method,
    Future<bool> Function(int dueCents)? authorizePayment,
  });

  Future<PaymentProcessor> paymentProcessor();

  Future<int> getPartsMarkupPercent();

  Future<int> getMerchMarkupPercent();

  Future<void> savePartsMarkupPercent(int percent);

  Future<void> saveMerchMarkupPercent(int percent);

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
    int partnerPartsPercent,
    int partnerLabourPercent,
  });

  Stream<TicketDetailEntry?> watchTicket(int ticketId);

  Stream<List<StaffMemberEntry>> watchClockedInStaff();

  Stream<StaffMemberEntry?> watchReportStaffAssignment(
    int ticketId,
    ReportKind reportKind,
  );

  Future<void> setReportStaffAssignment({
    required int ticketId,
    required ReportKind reportKind,
    required String? staffId,
  });

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

  /// Marks the technical stage (Report 2) complete or reopens it.
  Future<void> setReport2Completed(int ticketId, bool completed);

  /// Marks the client report (Report 3) complete or reopens it. Completing it
  /// sends the ticket to Checkout and freezes the warranty coverage.
  Future<void> setReport3Completed(int ticketId, bool completed);

  /// Report 3 warranty coverage, with category/shop defaults resolved.
  Stream<ClientReportWarranty> watchClientReportWarranty(int ticketId);

  /// Saves the per-ticket warranty length and/or terms.
  Future<void> saveClientReportWarranty({
    required int ticketId,
    int? days,
    String? terms,
  });

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
    TicketDates? dates,
    String partnerName = '',
    required String complaint,
  });

  Future<void> updateStatus(int ticketId, TicketStatus status);

  Future<void> updateTicketDates(int ticketId, TicketDates dates);
}

class TicketPhotoCleanupException implements Exception {
  const TicketPhotoCleanupException(this.cause);

  final Object cause;

  @override
  String toString() => cause.toString();
}

String _reportStaffSettingKey(int ticketId, ReportKind reportKind) =>
    'ticket_staff_${ticketId}_${reportKind.name}';

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
  Future<List<CustomerRecord>> searchCustomersByName(String query) async {
    final input = query.trim().toLowerCase();
    if (input.isEmpty) return [];
    final rows = await (_db.select(_db.customers)
          ..where((customer) => customer.name.lower().like('%$input%'))
          ..orderBy([(customer) => OrderingTerm.asc(customer.name)])
          ..limit(8))
        .get();
    return [for (final row in rows) _customer(row)];
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
      leftOuterJoin(
        _db.tickets,
        _db.tickets.customerDeviceId.equalsExp(_db.customerDevices.id),
      ),
      leftOuterJoin(
        _db.ticketReports,
        _db.ticketReports.ticketId.equalsExp(_db.tickets.id) &
            _db.ticketReports.kind.equals(ReportKind.client.index) &
            _db.ticketReports.warrantyStartAt.isNotNull(),
      ),
    ])
      ..where(_db.customerDevices.customerId.equals(customerId))
      ..orderBy([OrderingTerm.asc(_db.customerDevices.id)]);
    return query.watch().map((rows) {
      final devices = <int,
          (CustomerDevice, DeviceModel?, DeviceBrand?, DeviceCategory?)>{};
      final warranties = <int, ({DeviceWarranty warranty, int reportId})>{};
      for (final row in rows) {
        final device = row.readTable(_db.customerDevices);
        final report = row.readTableOrNull(_db.ticketReports);
        final startAt = report?.warrantyStartAt;
        if (report != null && startAt != null) {
          final current = warranties[device.id];
          if (current == null ||
              startAt.isAfter(current.warranty.startAt) ||
              (startAt == current.warranty.startAt &&
                  report.id > current.reportId)) {
            warranties[device.id] = (
              warranty: DeviceWarranty(
                startAt: startAt,
                days: report.warrantyDays ?? WarrantyConfig.defaultDays,
                terms: report.warrantyTerms,
              ),
              reportId: report.id,
            );
          }
        }
        devices.putIfAbsent(
          device.id,
          () => (
            device,
            row.readTableOrNull(_db.deviceModels),
            row.readTableOrNull(_db.deviceBrands),
            row.readTableOrNull(_db.deviceCategories),
          ),
        );
      }
      return [
        for (final source in devices.values)
          _customerDevice(
            source.$1,
            source.$2,
            source.$3,
            source.$4,
            warranty: warranties[source.$1.id]?.warranty,
          ),
      ];
    });
  }

  @override
  Stream<List<TicketBoardEntry>> watchCustomerTickets(int customerId) =>
      (_ticketQuery()..where(_db.tickets.customerId.equals(customerId)))
          .watch()
          .map((rows) => [for (final row in rows) _readBoardRow(row)]);

  @override
  Stream<List<TicketBoardEntry>> watchBoard() => _board;

  @override
  Stream<FinancialSummary> watchFinancialSummary() =>
      _db.watchFinancialSummary();

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
  Stream<List<InventoryPart>> watchInventoryParts() {
    final query = _db.select(_db.parts).join([
      leftOuterJoin(
        _db.ticketItems,
        _db.ticketItems.partId.equalsExp(_db.parts.id) &
            _db.ticketItems.kind.equals(TicketItemKind.part.index),
      ),
      leftOuterJoin(
        _db.tickets,
        _db.tickets.id.equalsExp(_db.ticketItems.ticketId),
      ),
    ])
      ..where(_db.parts.isActive.equals(true))
      ..orderBy([
        OrderingTerm.asc(_db.parts.name),
        OrderingTerm.asc(_db.parts.id),
      ]);

    return query.watch().map((rows) {
      // Parts on closed or cancelled tickets are no longer spoken for, so they
      // release their quantity back to the shelf.
      final committed = <int, int>{};
      for (final row in rows) {
        final item = row.readTableOrNull(_db.ticketItems);
        final ticket = row.readTableOrNull(_db.tickets);
        if (item == null || ticket == null) continue;
        if (ticket.status == TicketStatus.closed ||
            ticket.status == TicketStatus.cancelled ||
            ticket.status == TicketStatus.quote) {
          continue;
        }
        final partId = item.partId;
        if (partId == null) continue;
        // Parts a reopened warranty job already took out of stock stay
        // consumed, so only the outstanding quantity is still spoken for.
        final outstanding = item.quantity - item.consumedQuantity;
        if (outstanding <= 0) continue;
        committed.update(
          partId,
          (quantity) => quantity + outstanding,
          ifAbsent: () => outstanding,
        );
      }

      final seen = <int>{};
      return [
        for (final row in rows)
          if (seen.add(row.readTable(_db.parts).id))
            _inventoryPart(
              row.readTable(_db.parts),
              committed[row.readTable(_db.parts).id] ?? 0,
            ),
      ];
    });
  }

  InventoryPart _inventoryPart(Part part, int committedQuantity) =>
      InventoryPart(
        id: part.id,
        name: part.name,
        description: part.description,
        stock: part.stock,
        minimumStock: part.reorderLevel,
        rawCostCents: part.costCents,
        retailPriceCents: part.priceCents,
        sku: part.sku,
        vendorId: part.vendorId,
        vendorSku: part.vendorSku,
        brand: part.brand,
        jobLevel: part.jobLevel,
        category: part.category,
        location: part.location,
        purchaseType: part.purchaseType,
        bulkQuantity: part.bulkQuantity,
        bulkTotalCents: part.bulkTotalCents,
        committedQuantity: committedQuantity,
        chargeShopSupply: part.chargeShopSupply,
      );

  @override
  Stream<List<InventoryMerchItem>> watchMerchItems() =>
      (_db.select(_db.merchProducts)
            ..where((item) => item.isActive.equals(true))
            ..orderBy([(item) => OrderingTerm.asc(item.name)]))
          .watch()
          .map(
            (rows) => [
              for (final item in rows)
                InventoryMerchItem(
                  id: item.id,
                  name: item.name,
                  description: item.description,
                  stock: item.stock,
                  costCents: item.costCents,
                  priceCents: item.priceCents,
                  sku: item.sku,
                  category: item.category,
                  location: item.location,
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
                description: row.readTable(_db.parts).description,
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

    late StreamController<InvoiceDraft?> controller;
    StreamSubscription<List<TypedResult>>? invoiceSubscription;
    StreamSubscription<TaxConfig>? taxSubscription;
    List<TypedResult>? rows;
    TaxConfig? taxes;

    void emit() {
      final currentRows = rows;
      final currentTaxes = taxes;
      if (currentRows == null || currentTaxes == null) return;
      if (currentRows.isEmpty) {
        controller.add(null);
        return;
      }
      final ticket = currentRows.first.readTable(_db.tickets);
      controller.add(
        InvoiceDraft(
          discountKind: ticket.invoiceDiscountKind,
          discountValue: ticket.invoiceDiscountValue,
          partnerPartsPercent: ticket.partnerPartsPercent,
          partnerLabourPercent: ticket.partnerLabourPercent,
          taxes: currentTaxes,
          lines: [
            for (final row in currentRows)
              if (row.readTableOrNull(_db.ticketItems) case final item?)
                InvoiceLine(
                  ticketItemId: item.id,
                  kind: item.kind,
                  description: item.description,
                  quantity: item.quantity,
                  unitPriceCents: item.unitPriceCents,
                  isMerch: item.kind == TicketItemKind.custom &&
                      item.unitCostCents != null,
                  isShopSupply: item.kind == TicketItemKind.part &&
                      isShopSupplyCategory(
                        row.readTableOrNull(_db.parts)?.category,
                      ),
                ),
          ],
        ),
      );
    }

    controller = StreamController<InvoiceDraft?>(
      onListen: () {
        invoiceSubscription = query.watch().listen((value) {
          rows = value;
          emit();
        });
        taxSubscription = _db.watchTaxConfig().listen((value) {
          taxes = value;
          emit();
        });
      },
      onCancel: () async {
        await invoiceSubscription?.cancel();
        await taxSubscription?.cancel();
      },
    );
    return controller.stream;
  }

  @override
  Stream<List<PaymentEntry>> watchTicketPayments(int ticketId) =>
      _db.watchTicketPayments(ticketId).map(
            (rows) => [
              for (final payment in rows)
                PaymentEntry(
                  id: payment.id,
                  at: payment.at,
                  amountCents: payment.amountCents,
                  method: payment.method,
                  kind: payment.kind,
                ),
            ],
          );

  @override
  Future<void> addCheckoutMerchLine({
    required int ticketId,
    required String description,
    required int quantity,
    required int unitCostCents,
    required int unitPriceCents,
  }) =>
      _db.addCheckoutMerchLine(
        ticketId: ticketId,
        description: description,
        quantity: quantity,
        unitCostCents: unitCostCents,
        unitPriceCents: unitPriceCents,
      );

  @override
  Future<void> recordTicketPayment({
    required int ticketId,
    required int amountCents,
    required PaymentMethod method,
  }) =>
      _db.recordTicketPayment(
        ticketId: ticketId,
        amountCents: amountCents,
        method: method,
      );

  @override
  Future<void> closeTicketAfterPayment(int ticketId) =>
      _db.closeTicketAfterPayment(ticketId);

  @override
  Future<void> recordTicketRefund({
    required int ticketId,
    required int amountCents,
    required PaymentMethod method,
  }) =>
      _db.recordTicketRefund(
        ticketId: ticketId,
        amountCents: amountCents,
        method: method,
      );

  @override
  Future<void> recordTicketDeposit({
    required int ticketId,
    required int amountCents,
    required PaymentMethod method,
  }) =>
      _db.recordTicketDeposit(
        ticketId: ticketId,
        amountCents: amountCents,
        method: method,
      );

  @override
  Future<void> setSupplyLineCharged(int ticketItemId, bool charged) =>
      _db.setSupplyLineCharged(ticketItemId, charged);

  @override
  Future<NewTicket> createQuote({String? customerName}) =>
      _db.createQuote(customerName: customerName);

  @override
  Future<void> purgeExpiredQuotes() async {
    for (final id in await _db.expiredQuoteIds()) {
      await deleteTicket(id);
    }
  }

  @override
  Future<void> adoptQuote({required int quoteId, required int ticketId}) =>
      _db.adoptQuote(quoteId: quoteId, ticketId: ticketId);

  @override
  Future<int> createQuickSale({
    String? customerName,
    required List<({int partId, int quantity})> parts,
    required List<({String description, int quantity, int unitPriceCents})>
        customLines,
    required PaymentMethod method,
    Future<bool> Function(int dueCents)? authorizePayment,
  }) =>
      _db.createQuickSale(
        customerName: customerName,
        parts: parts,
        customLines: customLines,
        method: method,
        authorizePayment: authorizePayment,
      );

  @override
  Future<PaymentProcessor> paymentProcessor() async =>
      PaymentProcessors.adapterFor(
        await ProcessorConfigStore(_db).load(),
        log: ProcessorTransactionLog(_db),
      );

  @override
  Future<int> getPartsMarkupPercent() =>
      _db.markupPercent('parts_markup_percent', 35);

  @override
  Future<int> getMerchMarkupPercent() =>
      _db.markupPercent('merch_markup_percent', 45);

  @override
  Future<void> savePartsMarkupPercent(int percent) =>
      _db.setMarkupPercent('parts_markup_percent', percent);

  @override
  Future<void> saveMerchMarkupPercent(int percent) =>
      _db.setMarkupPercent('merch_markup_percent', percent);

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
    int partnerPartsPercent = 0,
    int partnerLabourPercent = 0,
  }) =>
      _db.setInvoiceDiscount(
        ticketId: ticketId,
        kind: kind,
        value: value,
        partnerPartsPercent: partnerPartsPercent,
        partnerLabourPercent: partnerLabourPercent,
      );

  @override
  Future<String> nextPartSku() => _db.nextPartSku();

  @override
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
    String? brand,
    int? jobLevel,
  }) =>
      _db.createInventoryPart(
        brand: brand,
        jobLevel: jobLevel,
        name: name,
        description: description,
        sku: sku,
        vendorId: vendorId,
        vendorSku: vendorSku,
        category: category,
        location: location,
        startingStock: startingStock,
        rawCostCents: rawCostCents,
        retailPriceCents: retailPriceCents,
        purchaseType: purchaseType,
        bulkQuantity: bulkQuantity,
        bulkTotalCents: bulkTotalCents,
        minimumStock: minimumStock,
        chargeShopSupply: chargeShopSupply,
      );

  @override
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
    String? brand,
    int? jobLevel,
  }) =>
      _db.updateInventoryPart(
        brand: brand,
        jobLevel: jobLevel,
        partId: partId,
        name: name,
        description: description,
        sku: sku,
        vendorId: vendorId,
        vendorSku: vendorSku,
        category: category,
        location: location,
        stock: stock,
        rawCostCents: rawCostCents,
        retailPriceCents: retailPriceCents,
        purchaseType: purchaseType,
        bulkQuantity: bulkQuantity,
        bulkTotalCents: bulkTotalCents,
        minimumStock: minimumStock,
        chargeShopSupply: chargeShopSupply,
      );

  @override
  Stream<Map<int, List<LabourIncludedPart>>> watchLabourIncludedParts() =>
      _db.watchLabourIncludedParts();

  @override
  Future<void> setLabourIncludedParts(
    int labourId,
    List<LabourIncludedPart> included,
  ) =>
      _db.setLabourIncludedParts(labourId, included);

  @override
  Future<void> removeInventoryPart(int partId) =>
      _db.removeInventoryPart(partId);

  @override
  Future<String> nextMerchSku() => _db.nextMerchSku();

  @override
  Future<void> createMerchItem({
    required String name,
    String? description,
    String? sku,
    String? category,
    String? location,
    required int startingStock,
    int costCents = 0,
    int priceCents = 0,
  }) async {
    await _db.createMerchItem(
      name: name,
      description: description,
      sku: sku,
      category: category,
      location: location,
      startingStock: startingStock,
      costCents: costCents,
      priceCents: priceCents,
    );
  }

  @override
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
  }) =>
      _db.updateMerchItem(
        itemId: itemId,
        name: name,
        description: description,
        sku: sku,
        category: category,
        location: location,
        stock: stock,
        costCents: costCents,
        priceCents: priceCents,
      );

  @override
  Future<void> removeMerchItem(int itemId) => _db.removeMerchItem(itemId);

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
  Stream<List<StaffMemberEntry>> watchClockedInStaff() {
    final query = _db.select(_db.settings)
      ..where((setting) => setting.key.isIn([
            'staff_roster',
            'staff_clock_sessions',
          ]));
    return query.watch().map((rows) {
      final values = {for (final row in rows) row.key: row.value};
      final roster = (jsonDecode(values['staff_roster'] ?? '[]')
              as List<dynamic>)
          .map(
              (item) => StaffMemberEntry.fromJson(item as Map<String, dynamic>))
          .toList();
      final clockedInIds =
          (jsonDecode(values['staff_clock_sessions'] ?? '[]') as List<dynamic>)
              .map((item) => item as Map<String, dynamic>)
              .where((session) => session['clockOutAt'] == null)
              .map((session) => session['staffId'] as String)
              .toSet();
      return roster
          .where((staff) => staff.isActive && clockedInIds.contains(staff.id))
          .toList()
        ..sort((first, second) => first.name.compareTo(second.name));
    });
  }

  @override
  Stream<StaffMemberEntry?> watchReportStaffAssignment(
    int ticketId,
    ReportKind reportKind,
  ) {
    final assignmentKey = _reportStaffSettingKey(ticketId, reportKind);
    final query = _db.select(_db.settings)
      ..where((setting) => setting.key.isIn([
            'staff_roster',
            assignmentKey,
          ]));
    return query.watch().map((rows) {
      final values = {for (final row in rows) row.key: row.value};
      final staffId = values[assignmentKey];
      if (staffId == null || staffId.isEmpty) return null;
      final roster =
          (jsonDecode(values['staff_roster'] ?? '[]') as List<dynamic>).map(
              (item) =>
                  StaffMemberEntry.fromJson(item as Map<String, dynamic>));
      for (final staff in roster) {
        if (staff.id == staffId) return staff;
      }
      return null;
    });
  }

  @override
  Future<void> setReportStaffAssignment({
    required int ticketId,
    required ReportKind reportKind,
    required String? staffId,
  }) async {
    if (staffId != null) {
      final available = await watchClockedInStaff().first;
      if (!available.any((staff) => staff.id == staffId)) {
        throw StateError('Staff must be active and clocked in to be assigned.');
      }
    }
    await _db.into(_db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: _reportStaffSettingKey(ticketId, reportKind),
            value: staffId ?? '',
          ),
        );
  }

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
        report2CompletedAt: row.readTable(_db.tickets).report2CompletedAt,
        report3CompletedAt: row.readTable(_db.tickets).report3CompletedAt,
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
          ..where(_db.deviceModels.isActive.equals(true) &
              _db.deviceBrands.isActive.equals(true))
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
          brand: row.readTable(_db.deviceBrands).name,
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
  Future<void> setReport2Completed(int ticketId, bool completed) =>
      _db.setReport2Completed(ticketId, completed);

  @override
  Future<void> setReport3Completed(int ticketId, bool completed) =>
      _db.setReport3Completed(ticketId, completed);

  @override
  Stream<ClientReportWarranty> watchClientReportWarranty(int ticketId) =>
      _db.watchClientReportWarranty(ticketId);

  @override
  Future<void> saveClientReportWarranty({
    required int ticketId,
    int? days,
    String? terms,
  }) =>
      _db.saveClientReportWarranty(
        ticketId: ticketId,
        days: days,
        terms: terms,
      );

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
    TicketDates? dates,
    String partnerName = '',
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
      dropOffAt: dates?.dropOffAt,
      technicianStartAt: dates?.technicianStartAt,
      partsArriveAt: dates?.partsArriveAt,
      customerContactedAt: dates?.customerContactedAt,
      pickedUpAt: dates?.pickedUpAt,
      partnerName: partnerName,
      complaint: complaint,
    );
  }

  @override
  Future<void> updateStatus(int ticketId, TicketStatus status) =>
      _db.setTicketStatus(ticketId, status);

  @override
  Future<void> updateTicketDates(int ticketId, TicketDates dates) =>
      _db.setTicketDates(
        ticketId: ticketId,
        dropOffAt: dates.dropOffAt,
        technicianStartAt: dates.technicianStartAt,
        partsArriveAt: dates.partsArriveAt,
        customerContactedAt: dates.customerContactedAt,
        pickedUpAt: dates.pickedUpAt,
        dueAt: dates.dueAt,
      );

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
      dropOffAt: ticket.dropOffAt ?? ticket.createdAt,
      technicianStartAt: ticket.technicianStartAt,
      partsArriveAt: ticket.partsArriveAt,
      customerContactedAt: ticket.customerContactedAt,
      pickedUpAt: ticket.pickedUpAt,
      dueAt: ticket.dueAt,
      shopTag: ticket.shopTag,
      serial: ticket.serial,
      serialMissing: ticket.serialMissing,
      deviceVariant: ticket.deviceVariant,
      deviceSide: ticket.deviceSide,
      partnerName: ticket.partnerName,
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
    DeviceCategory? category, {
    DeviceWarranty? warranty,
  }) {
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
      warranty: warranty,
    );
  }
}
