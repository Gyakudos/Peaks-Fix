import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vola_fix/app.dart';
import 'package:vola_fix/data/database.dart';
import 'package:vola_fix/data/financials.dart';
import 'package:vola_fix/data/part_skus.dart';
import 'package:vola_fix/data/payments/payment_processor.dart';
import 'package:vola_fix/data/photo_templates.dart';
import 'package:vola_fix/data/shop_scope.dart';
import 'package:vola_fix/data/tickets_repository.dart';
import 'package:vola_fix/data/warranty.dart';
import 'package:vola_fix/features/checkout/checkout_page.dart';
import 'package:vola_fix/features/tickets/required_parts_dialog.dart';
import 'package:vola_fix/features/tickets/ticket_detail_page.dart';
import 'package:vola_fix/features/tickets/tickets_page.dart';

/// Stands in for SQLite so these tests never open a database file.
class FakeTicketsRepository implements TicketsRepository {
  FakeTicketsRepository({List<DeviceOption>? catalog})
      : catalog = catalog ?? _defaultCatalog;

  static const _defaultCatalog = <DeviceOption>[
    DeviceOption(
      modelId: 1,
      category: 'Consoles',
      brand: 'Sony',
      modelName: 'PlayStation 5',
      label: 'Sony PlayStation 5',
    ),
    DeviceOption(
      modelId: 2,
      category: 'Handheld PCs',
      brand: 'Valve',
      modelName: 'Steam Deck OLED',
      label: 'Valve Steam Deck OLED',
    ),
    DeviceOption(
      modelId: 3,
      category: 'Portable Consoles',
      brand: 'Nintendo',
      modelName: '3DS',
      label: 'Nintendo 3DS',
    ),
    DeviceOption(
      modelId: 4,
      category: 'Controllers',
      modelName: 'Joy-Con (pair)',
      label: 'Nintendo Joy-Con (pair)',
    ),
    DeviceOption(
      modelId: 5,
      category: 'Controllers',
      modelName: 'Joy-Con (single)',
      label: 'Nintendo Joy-Con (single)',
    ),
    DeviceOption(
      modelId: 6,
      category: 'Vacuum',
      brand: 'Dyson',
      modelName: 'V8',
      label: 'Dyson V8',
    ),
  ];

  final List<DeviceOption> catalog;
  final List<CreateCall> creations = <CreateCall>[];
  final List<({int ticketId, String notes})> intakeNoteWrites =
      <({int ticketId, String notes})>[];
  final List<({int ticketId, bool completed})> report1Writes =
      <({int ticketId, bool completed})>[];
  final List<({int ticketId, bool completed})> report2Writes =
      <({int ticketId, bool completed})>[];
  final List<({int ticketId, bool completed})> report3Writes =
      <({int ticketId, bool completed})>[];

  final StreamController<List<TicketBoardEntry>> _boardUpdates =
      StreamController<List<TicketBoardEntry>>.broadcast();
  final StreamController<List<CustomerRecord>> _customerUpdates =
      StreamController<List<CustomerRecord>>.broadcast();
  final StreamController<List<RequiredPart>> _requiredPartUpdates =
      StreamController<List<RequiredPart>>.broadcast();
  final StreamController<List<InventoryPart>> _inventoryUpdates =
      StreamController<List<InventoryPart>>.broadcast();
  final StreamController<List<InventoryMerchItem>> _merchUpdates =
      StreamController<List<InventoryMerchItem>>.broadcast();
  final StreamController<TicketDetailEntry?> _detailUpdates =
      StreamController<TicketDetailEntry?>.broadcast();
  final Map<int, StreamController<InvoiceDraft?>> _invoiceUpdates = {};
  final Map<int, StreamController<List<PaymentEntry>>> _paymentUpdates = {};
  final StreamController<PhotoChecklist> _checklistUpdates =
      StreamController<PhotoChecklist>.broadcast();
  final StreamController<List<TechnicalReportBlock>> _technicalUpdates =
      StreamController<List<TechnicalReportBlock>>.broadcast();
  final List<TechnicalReportBlock> technicalEntries = [];
  final List<TicketBoardEntry> boardTickets = [];
  final List<InventoryPart> inventoryParts = [];
  final List<InventoryMerchItem> merchItems = [];
  final List<RequiredPart> requiredParts = [];
  final List<CustomerRecord> customers = [];
  final List<StaffMemberEntry> staffRoster = [];
  final List<StaffMemberEntry> clockedInStaff = [];
  final Map<(int, ReportKind), String?> reportStaffAssignments = {};
  final Map<int, InvoiceDraft> invoices = {};
  final Map<int, List<PaymentEntry>> ticketPayments = {};
  int partsMarkupPercent = 35;
  int merchMarkupPercent = 45;
  final Map<int, List<CustomerDeviceEntry>> customerDevices = {};
  final Map<int, ClientReportWarranty> clientWarranties = {};
  final Map<int, StreamController<ClientReportWarranty>> _warrantyUpdates = {};

  TicketDetailEntry? _detail;
  PhotoChecklist _checklist = const PhotoChecklist(
    templateKey: null,
    templateName: null,
    slots: [],
  );
  int _nextTechnicalEntryId = 1;
  PhotoChecklist get currentChecklist => _checklist;

  @override
  Stream<List<CustomerRecord>> watchCustomers() async* {
    yield List.unmodifiable(customers);
    yield* _customerUpdates.stream;
  }

  @override
  Future<List<CustomerRecord>> findCustomersByContact(
      String phoneOrEmail) async {
    final input = phoneOrEmail.trim().toLowerCase();
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    return customers
        .where(
          (customer) =>
              (customer.email ?? '').toLowerCase().contains(input) ||
              (digits.isNotEmpty &&
                  (customer.phone ?? '')
                      .replaceAll(RegExp(r'[^0-9]'), '')
                      .contains(digits)),
        )
        .toList();
  }

  @override
  Future<List<CustomerRecord>> searchCustomersByName(String query) async {
    final input = query.trim().toLowerCase();
    if (input.isEmpty) return [];
    return customers
        .where((customer) => customer.name.toLowerCase().contains(input))
        .take(8)
        .toList();
  }

  @override
  Future<int> saveCustomer({
    int? customerId,
    required String name,
    required String phone,
    required String email,
    required String notes,
  }) async {
    final id = customerId ?? (customers.isEmpty ? 1 : customers.last.id + 1);
    final record = CustomerRecord(
      id: id,
      name: name.trim(),
      phone: phone.trim().isEmpty ? null : phone.trim(),
      email: email.trim().isEmpty ? null : email.trim(),
      notes: notes.trim().isEmpty ? null : notes.trim(),
      updatedAt: DateTime(2026, 1, 1),
    );
    final index = customers.indexWhere((customer) => customer.id == id);
    if (index == -1) {
      customers.add(record);
    } else {
      customers[index] = record;
    }
    _customerUpdates.add(List.unmodifiable(customers));
    return id;
  }

  @override
  Stream<List<CustomerDeviceEntry>> watchCustomerDevices(int customerId) =>
      Stream.value(List.unmodifiable(customerDevices[customerId] ?? const []));

  @override
  Stream<List<TicketBoardEntry>> watchCustomerTickets(int customerId) =>
      Stream.value(List.unmodifiable(boardTickets));

  @override
  Stream<List<TicketBoardEntry>> watchBoard() async* {
    yield List.unmodifiable(boardTickets);
    yield* _boardUpdates.stream;
  }

  @override
  Stream<FinancialSummary> watchFinancialSummary() async* {
    FinancialSummary current() {
      var revenue = 0;
      var count = 0;
      for (final ticket in boardTickets) {
        if (ticket.status != TicketStatus.closed) continue;
        count++;
        revenue += invoices[ticket.id]?.totalCents ?? 0;
      }
      return FinancialSummary(
        revenueCents: revenue,
        costCents: 0,
        staffPayCents: 0,
        tracked: Duration.zero,
        ticketCount: count,
      );
    }

    yield current();
    yield* _boardUpdates.stream.map((_) => current());
  }

  @override
  Future<void> deleteTicket(int ticketId) async {
    boardTickets.removeWhere((ticket) => ticket.id == ticketId);
    _boardUpdates.add(List.unmodifiable(boardTickets));
  }

  @override
  Stream<List<InventoryPart>> watchInventoryParts() async* {
    yield _inventorySnapshot();
    yield* _inventoryUpdates.stream.map((_) => _inventorySnapshot());
  }

  /// Stands in for the SQLite join: committed is the quantity on parts already
  /// billed to a ticket.
  List<InventoryPart> _inventorySnapshot() => [
        for (final part in inventoryParts)
          InventoryPart(
            id: part.id,
            name: part.name,
            description: part.description,
            stock: part.stock,
            minimumStock: part.minimumStock,
            rawCostCents: part.rawCostCents,
            retailPriceCents: part.retailPriceCents,
            sku: part.sku,
            vendorId: part.vendorId,
            vendorSku: part.vendorSku,
            category: part.category,
            location: part.location,
            purchaseType: part.purchaseType,
            bulkQuantity: part.bulkQuantity,
            bulkTotalCents: part.bulkTotalCents,
            committedQuantity: requiredParts
                .where((item) => item.partId == part.id)
                .fold<int>(0, (sum, item) => sum + item.quantity),
          ),
      ];

  @override
  Stream<List<RequiredPart>> watchRequiredParts(int ticketId) async* {
    yield List.unmodifiable(requiredParts);
    yield* _requiredPartUpdates.stream;
  }

  @override
  Future<String> nextPartSku() async =>
      PartSku.next(inventoryParts.map((part) => part.sku));

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
  }) async {
    final cleanSku = sku?.trim();
    final id = inventoryParts.length + 1;
    inventoryParts.add(
      InventoryPart(
        id: id,
        jobLevel: jobLevel,
        name: name,
        description: description,
        sku: cleanSku == null || cleanSku.isEmpty
            ? PartSku.next(inventoryParts.map((part) => part.sku))
            : cleanSku,
        vendorId: vendorId,
        vendorSku: vendorSku,
        category: category,
        location: location,
        stock: startingStock,
        minimumStock: minimumStock,
        rawCostCents: rawCostCents,
        retailPriceCents: retailPriceCents,
        purchaseType: purchaseType,
        bulkQuantity: bulkQuantity,
        bulkTotalCents: bulkTotalCents,
        chargeShopSupply: chargeShopSupply,
      ),
    );
    _inventoryUpdates.add(List.unmodifiable(inventoryParts));
    return id;
  }

  final Map<int, List<LabourIncludedPart>> labourIncluded = {};

  @override
  Stream<Map<int, List<LabourIncludedPart>>> watchLabourIncludedParts() async* {
    yield Map.of(labourIncluded);
  }

  @override
  Future<void> setLabourIncludedParts(
    int labourId,
    List<LabourIncludedPart> included,
  ) async {
    labourIncluded[labourId] = included;
  }

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
  }) async {
    final index = inventoryParts.indexWhere((part) => part.id == partId);
    if (index == -1) throw StateError('Inventory part not found.');
    final existing = inventoryParts[index];
    final cleanSku = sku?.trim();
    inventoryParts[index] = InventoryPart(
      id: partId,
      jobLevel: jobLevel,
      name: name,
      description: description,
      sku: cleanSku == null || cleanSku.isEmpty
          ? existing.sku ?? PartSku.next(inventoryParts.map((part) => part.sku))
          : cleanSku,
      vendorId: vendorId,
      vendorSku: vendorSku,
      category: category,
      location: location,
      stock: stock,
      minimumStock: minimumStock,
      rawCostCents: rawCostCents,
      retailPriceCents: retailPriceCents,
      purchaseType: purchaseType,
      bulkQuantity: bulkQuantity,
      bulkTotalCents: bulkTotalCents,
      chargeShopSupply: chargeShopSupply,
    );
    _inventoryUpdates.add(List.unmodifiable(inventoryParts));
  }

  @override
  Future<void> removeInventoryPart(int partId) async {
    inventoryParts.removeWhere((part) => part.id == partId);
    _inventoryUpdates.add(List.unmodifiable(inventoryParts));
  }

  @override
  Stream<List<InventoryMerchItem>> watchMerchItems() async* {
    yield List.unmodifiable(merchItems);
    yield* _merchUpdates.stream;
  }

  @override
  Future<String> nextMerchSku() async =>
      PartSku.next(merchItems.map((item) => item.sku));

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
    final cleanSku = sku?.trim();
    merchItems.add(
      InventoryMerchItem(
        id: merchItems.isEmpty ? 1 : merchItems.last.id + 1,
        name: name,
        description: description,
        sku: cleanSku == null || cleanSku.isEmpty
            ? PartSku.next(merchItems.map((item) => item.sku))
            : cleanSku,
        category: category,
        location: location,
        stock: startingStock,
        costCents: costCents,
        priceCents: priceCents,
      ),
    );
    _merchUpdates.add(List.unmodifiable(merchItems));
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
  }) async {
    final index = merchItems.indexWhere((item) => item.id == itemId);
    if (index == -1) throw StateError('Merchandise item not found.');
    final existing = merchItems[index];
    final cleanSku = sku?.trim();
    merchItems[index] = InventoryMerchItem(
      id: itemId,
      name: name,
      description: description,
      sku: cleanSku == null || cleanSku.isEmpty
          ? existing.sku ?? PartSku.next(merchItems.map((item) => item.sku))
          : cleanSku,
      category: category,
      location: location,
      stock: stock,
      costCents: costCents,
      priceCents: priceCents,
    );
    _merchUpdates.add(List.unmodifiable(merchItems));
  }

  @override
  Future<void> removeMerchItem(int itemId) async {
    merchItems.removeWhere((item) => item.id == itemId);
    _merchUpdates.add(List.unmodifiable(merchItems));
  }

  @override
  Future<void> addRequiredPart({
    required int ticketId,
    required int partId,
    required int quantity,
  }) async {
    final part = inventoryParts.singleWhere((item) => item.id == partId);
    final index = requiredParts.indexWhere((item) => item.partId == partId);
    if (index == -1) {
      requiredParts.add(
        RequiredPart(
          ticketItemId: requiredParts.length + 1,
          partId: part.id,
          name: part.name,
          description: part.description,
          quantity: quantity,
          stock: part.stock,
          rawCostCents: part.rawCostCents,
          retailPriceCents: part.retailPriceCents,
          sku: part.sku,
          location: part.location,
        ),
      );
      _requiredPartUpdates.add(List.unmodifiable(requiredParts));
    } else {
      final existing = requiredParts[index];
      requiredParts[index] = RequiredPart(
        ticketItemId: existing.ticketItemId,
        partId: existing.partId,
        name: existing.name,
        description: existing.description,
        quantity: existing.quantity + quantity,
        stock: existing.stock,
        rawCostCents: existing.rawCostCents,
        retailPriceCents: existing.retailPriceCents,
        sku: existing.sku,
        location: existing.location,
      );
      _requiredPartUpdates.add(List.unmodifiable(requiredParts));
    }
  }

  @override
  Future<void> removeRequiredPart({
    required int ticketId,
    required int ticketItemId,
  }) async {
    requiredParts.removeWhere((part) => part.ticketItemId == ticketItemId);
    _requiredPartUpdates.add(List.unmodifiable(requiredParts));
  }

  @override
  Stream<InvoiceDraft?> watchInvoice(int ticketId) async* {
    yield invoices[ticketId] ??
        const InvoiceDraft(
          discountKind: InvoiceDiscountKind.none,
          discountValue: 0,
          lines: [],
        );
    yield* (_invoiceUpdates[ticketId] ??=
            StreamController<InvoiceDraft?>.broadcast())
        .stream;
  }

  @override
  Stream<List<PaymentEntry>> watchTicketPayments(int ticketId) async* {
    yield List.unmodifiable(ticketPayments[ticketId] ?? const []);
    yield* (_paymentUpdates[ticketId] ??=
            StreamController<List<PaymentEntry>>.broadcast())
        .stream;
  }

  @override
  Future<void> addCheckoutMerchLine({
    required int ticketId,
    required String description,
    required int quantity,
    required int unitCostCents,
    required int unitPriceCents,
  }) async {
    final invoice = invoices[ticketId] ??
        const InvoiceDraft(
          discountKind: InvoiceDiscountKind.none,
          discountValue: 0,
          lines: [],
        );
    invoices[ticketId] = InvoiceDraft(
      discountKind: invoice.discountKind,
      discountValue: invoice.discountValue,
      lines: [
        ...invoice.lines,
        InvoiceLine(
          ticketItemId: invoice.lines.length + 1,
          kind: TicketItemKind.custom,
          description: description,
          quantity: quantity,
          unitPriceCents: unitPriceCents,
          isMerch: true,
        ),
      ],
    );
    _invoiceUpdates[ticketId]?.add(invoices[ticketId]!);
  }

  @override
  Future<void> recordTicketPayment({
    required int ticketId,
    required int amountCents,
    required PaymentMethod method,
  }) async {
    final entry = PaymentEntry(
      id: (ticketPayments[ticketId]?.length ?? 0) + 1,
      at: DateTime(2026),
      amountCents: amountCents,
      method: method,
      kind: PaymentKind.balance,
    );
    final payments = ticketPayments.putIfAbsent(ticketId, () => []);
    payments.add(entry);
    _paymentUpdates[ticketId]?.add(List.unmodifiable(payments));
  }

  @override
  Future<void> setSupplyLineCharged(int ticketItemId, bool charged) async {}

  @override
  Future<NewTicket> createQuote({String? customerName}) async =>
      throw UnimplementedError();

  @override
  Future<void> purgeExpiredQuotes() async {}

  @override
  Future<void> adoptQuote({
    required int quoteId,
    required int ticketId,
  }) async {}

  @override
  Future<int> createQuickSale({
    String? customerName,
    required List<({int partId, int quantity})> parts,
    required List<({String description, int quantity, int unitPriceCents})>
        customLines,
    required PaymentMethod method,
    Future<bool> Function(int dueCents)? authorizePayment,
  }) async =>
      0;

  @override
  Future<PaymentProcessor> paymentProcessor() async => const ManualProcessor();

  @override
  Future<void> recordTicketRefund({
    required int ticketId,
    required int amountCents,
    required PaymentMethod method,
  }) async {
    final entry = PaymentEntry(
      id: (ticketPayments[ticketId]?.length ?? 0) + 1,
      at: DateTime.now(),
      amountCents: amountCents,
      method: method,
      kind: PaymentKind.refund,
    );
    ticketPayments.putIfAbsent(ticketId, () => []).add(entry);
  }

  @override
  Future<void> recordTicketDeposit({
    required int ticketId,
    required int amountCents,
    required PaymentMethod method,
  }) async {
    final entry = PaymentEntry(
      id: (ticketPayments[ticketId]?.length ?? 0) + 1,
      at: DateTime.now(),
      amountCents: amountCents,
      method: method,
      kind: PaymentKind.deposit,
    );
    ticketPayments.putIfAbsent(ticketId, () => []).add(entry);
  }

  @override
  Future<void> closeTicketAfterPayment(int ticketId) async {
    final invoice = invoices[ticketId] ??
        const InvoiceDraft(
          discountKind: InvoiceDiscountKind.none,
          discountValue: 0,
          lines: [],
        );
    final paid = (ticketPayments[ticketId] ?? const <PaymentEntry>[])
        .fold<int>(0, (sum, payment) => sum + payment.amountCents);
    if (paid < invoice.totalCents) {
      throw StateError('The invoice must be paid before closing this ticket.');
    }
    await updateStatus(ticketId, TicketStatus.closed);
  }

  @override
  Future<int> getPartsMarkupPercent() async => partsMarkupPercent;

  @override
  Future<int> getMerchMarkupPercent() async => merchMarkupPercent;

  @override
  Future<void> savePartsMarkupPercent(int percent) async {
    partsMarkupPercent = percent;
  }

  @override
  Future<void> saveMerchMarkupPercent(int percent) async {
    merchMarkupPercent = percent;
  }

  @override
  Future<void> addInvoiceLaborLine({
    required int ticketId,
    required String description,
    required int quantity,
    required int unitPriceCents,
  }) async {}

  @override
  Future<void> removeInvoiceLaborLine({
    required int ticketId,
    required int ticketItemId,
  }) async {}

  @override
  Future<void> setInvoiceDiscount({
    required int ticketId,
    required InvoiceDiscountKind kind,
    required int value,
    int partnerPartsPercent = 0,
    int partnerLabourPercent = 0,
  }) async {}

  @override
  Stream<TicketDetailEntry?> watchTicket(int ticketId) async* {
    yield _detail;
    yield* _detailUpdates.stream;
  }

  @override
  Stream<List<StaffMemberEntry>> watchClockedInStaff() =>
      Stream.value(List.unmodifiable(clockedInStaff));

  @override
  Stream<StaffMemberEntry?> watchReportStaffAssignment(
    int ticketId,
    ReportKind reportKind,
  ) {
    final staffId = reportStaffAssignments[(ticketId, reportKind)];
    for (final staff in staffRoster) {
      if (staff.id == staffId) return Stream.value(staff);
    }
    return Stream.value(null);
  }

  @override
  Future<void> setReportStaffAssignment({
    required int ticketId,
    required ReportKind reportKind,
    required String? staffId,
  }) async {
    if (staffId != null &&
        !clockedInStaff.any((staff) => staff.id == staffId)) {
      throw StateError('Staff must be active and clocked in to be assigned.');
    }
    reportStaffAssignments[(ticketId, reportKind)] = staffId;
  }

  @override
  Stream<PhotoChecklist> watchPhotoChecklist(int ticketId) async* {
    yield _checklist;
    yield* _checklistUpdates.stream;
  }

  @override
  Future<void> addOptionalPhotoSlot({
    required int ticketId,
    required String label,
  }) async {
    final sortOrder = _checklist.slots.isEmpty
        ? 1
        : _checklist.slots
                .map((slot) => slot.sortOrder)
                .reduce((left, right) => left > right ? left : right) +
            1;
    _checklist = PhotoChecklist(
      templateKey: _checklist.templateKey,
      templateName: _checklist.templateName,
      slots: [
        ..._checklist.slots,
        TicketPhotoSlotEntry(
          sortOrder: sortOrder,
          label: label,
          hint: 'Optional reference photo',
          required: false,
        ),
      ],
    );
    _checklistUpdates.add(_checklist);
  }

  /// Pretends the phone has filled every Report 1 slot.
  void markAllPhotosCaptured() {
    _checklist = PhotoChecklist(
      templateKey: _checklist.templateKey,
      templateName: _checklist.templateName,
      slots: [
        for (final slot in _checklist.slots)
          TicketPhotoSlotEntry(
            sortOrder: slot.sortOrder,
            label: slot.label,
            hint: slot.hint,
            required: slot.required,
            photoPath: 'ticket-7-slot-${slot.sortOrder}.jpg',
          ),
      ],
    );
    _checklistUpdates.add(_checklist);
  }

  @override
  Future<void> setReport1Completed(int ticketId, bool completed) async {
    report1Writes.add((ticketId: ticketId, completed: completed));
    final detail = _detail;
    if (detail == null) return;
    _detail = detail.copyWith(
      report1CompletedAt: completed ? DateTime(2026, 2, 3, 10, 15) : null,
      clearReport1: !completed,
    );
    _detailUpdates.add(_detail);
  }

  @override
  Future<void> setReport2Completed(int ticketId, bool completed) async {
    report2Writes.add((ticketId: ticketId, completed: completed));
    final detail = _detail;
    if (detail == null) return;
    _detail = detail.copyWith(
      report2CompletedAt: completed ? DateTime(2026, 2, 3, 11, 30) : null,
      clearReport2: !completed,
    );
    _detailUpdates.add(_detail);
  }

  @override
  Future<void> setReport3Completed(int ticketId, bool completed) async {
    report3Writes.add((ticketId: ticketId, completed: completed));
    final completedAt = DateTime(2026, 2, 3, 12, 45);
    _setWarrantyStarted(ticketId, completed ? completedAt : null);
    final detail = _detail;
    if (detail == null) return;
    _detail = detail.copyWith(
      report3CompletedAt: completed ? completedAt : null,
      clearReport3: !completed,
    );
    _detailUpdates.add(_detail);
    if (completed) {
      await updateStatus(ticketId, TicketStatus.ready);
    }
  }

  ClientReportWarranty _warrantyFor(int ticketId) =>
      clientWarranties[ticketId] ??
      const ClientReportWarranty(
        defaultDays: WarrantyConfig.defaultDays,
        defaultTerms: WarrantyConfig.defaultTerms,
      );

  void _setWarrantyStarted(int ticketId, DateTime? startAt) {
    final current = _warrantyFor(ticketId);
    final updated = ClientReportWarranty(
      defaultDays: current.defaultDays,
      defaultTerms: current.defaultTerms,
      days: current.days,
      terms: current.terms,
      startAt: startAt,
      categoryName: current.categoryName,
    );
    clientWarranties[ticketId] = updated;
    _warrantyUpdates[ticketId]?.add(updated);
  }

  @override
  Stream<ClientReportWarranty> watchClientReportWarranty(int ticketId) async* {
    yield _warrantyFor(ticketId);
    yield* _warrantyUpdates
        .putIfAbsent(
          ticketId,
          () => StreamController<ClientReportWarranty>.broadcast(),
        )
        .stream;
  }

  @override
  Future<void> saveClientReportWarranty({
    required int ticketId,
    int? days,
    String? terms,
  }) async {
    final current = _warrantyFor(ticketId);
    final updated = ClientReportWarranty(
      defaultDays: current.defaultDays,
      defaultTerms: current.defaultTerms,
      days: days ?? current.days,
      terms: terms ?? current.terms,
      startAt: current.startAt,
      categoryName: current.categoryName,
    );
    clientWarranties[ticketId] = updated;
    _warrantyUpdates[ticketId]?.add(updated);
  }

  @override
  Future<void> ensureTechnicalReports(int ticketId) async {}

  @override
  Stream<List<TechnicalReportBlock>> watchTechnicalEntries(
      int ticketId) async* {
    yield List.unmodifiable(technicalEntries);
    yield* _technicalUpdates.stream;
  }

  @override
  Stream<List<ClientReportBlock>> watchClientReportEntries(int ticketId) =>
      Stream.value(const []);

  @override
  Future<void> addTechnicalNote(int ticketId) async {
    technicalEntries.add(
      TechnicalReportBlock(
        id: _nextTechnicalEntryId++,
        sortOrder: technicalEntries.length,
        kind: TechnicalEntryKind.note,
      ),
    );
    _technicalUpdates.add(List.unmodifiable(technicalEntries));
  }

  @override
  Future<String> addTechnicalPhoto({
    required int ticketId,
    required Uint8List bytes,
    required String extension,
    int? parentEntryId,
  }) async =>
      'technical-photo.jpg';

  @override
  Future<void> updateTechnicalEntry({
    required int ticketId,
    required int entryId,
    required TechnicalEntryKind kind,
    String? text,
    String? caption,
  }) async {}

  @override
  Future<void> deleteTechnicalEntry(int ticketId, int entryId) async {}

  @override
  Future<void> updateClientReportEntry({
    required int entryId,
    required TechnicalEntryKind kind,
    String? text,
    String? caption,
    bool? included,
  }) async {}

  @override
  Future<List<DeviceOption>> deviceCatalog() async => catalog;

  @override
  Future<List<String>> deviceCategories() async => {
        for (final option in catalog) option.category,
        'General Electronics',
      }.toList();

  @override
  Future<String> nextShopSerial() async => 'PFS-123456789';

  @override
  Future<String> savePhotoSlot({
    required int ticketId,
    required int sortOrder,
    required Uint8List bytes,
    required String extension,
  }) async =>
      'ticket-$ticketId-slot-$sortOrder.$extension';

  @override
  Future<void> saveIntakeNotes(int ticketId, String notes) async {
    intakeNoteWrites.add((ticketId: ticketId, notes: notes));
  }

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
  }) async {
    creations.add(
      CreateCall(
        customerId: customerId,
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
        dates: dates,
        complaint: complaint,
      ),
    );

    const result = NewTicket(
      id: 7,
      number: 'PF-000001',
      shopTag: 'G-123456789',
      customerId: 1,
    );

    _detail = TicketDetailEntry(
      summary: TicketBoardEntry(
        id: result.id,
        number: result.number,
        status: TicketStatus.received,
        customerName: customerName,
        device: deviceName ?? 'Sony PlayStation 5',
        complaint: complaint,
        createdAt: DateTime(2026, 1, 2, 9, 30),
        dropOffAt: dates?.dropOffAt ?? DateTime(2026, 1, 2),
        technicianStartAt: dates?.technicianStartAt,
        partsArriveAt: dates?.partsArriveAt,
        customerContactedAt: dates?.customerContactedAt,
        pickedUpAt: dates?.pickedUpAt,
        shopTag: result.shopTag,
        serial: serial,
        serialMissing: serialMissing,
        deviceVariant: deviceVariant,
        deviceSide: deviceSide,
      ),
    );
    boardTickets.add(_detail!.summary);
    _boardUpdates.add(List.unmodifiable(boardTickets));

    final seed = photoTemplateSeed(photoTemplateKey);
    _checklist = PhotoChecklist(
      templateKey: seed?.key,
      templateName:
          photoTemplateKey == 'general_electronics' ? deviceName : seed?.name,
      slots: [
        if (seed != null)
          for (var index = 0; index < seed.slots.length; index++)
            TicketPhotoSlotEntry(
              sortOrder: index + 1,
              label: seed.slots[index].label,
              hint: seed.slots[index].hint,
            ),
      ],
    );

    return result;
  }

  @override
  Future<void> updateStatus(int ticketId, TicketStatus status) async {
    final ticket = boardTickets.singleWhere((entry) => entry.id == ticketId);
    final updated = TicketBoardEntry(
      id: ticket.id,
      number: ticket.number,
      status: status,
      customerName: ticket.customerName,
      device: ticket.device,
      complaint: ticket.complaint,
      createdAt: ticket.createdAt,
      dropOffAt: ticket.dropOffAt,
      technicianStartAt: ticket.technicianStartAt,
      partsArriveAt: ticket.partsArriveAt,
      customerContactedAt: ticket.customerContactedAt,
      pickedUpAt:
          status == TicketStatus.closed ? DateTime(2026) : ticket.pickedUpAt,
      shopTag: ticket.shopTag,
      serial: ticket.serial,
      serialMissing: ticket.serialMissing,
      deviceVariant: ticket.deviceVariant,
      deviceSide: ticket.deviceSide,
    );
    boardTickets[boardTickets.indexOf(ticket)] = updated;
    _boardUpdates.add(List.unmodifiable(boardTickets));
    final detail = _detail;
    if (detail != null) {
      _detail = detail.copyWith(summary: updated);
      _detailUpdates.add(_detail);
    }
  }

  @override
  Future<void> updateTicketDates(int ticketId, TicketDates dates) async {
    final ticket = boardTickets.singleWhere((entry) => entry.id == ticketId);
    final updated = TicketBoardEntry(
      id: ticket.id,
      number: ticket.number,
      status: ticket.status,
      customerName: ticket.customerName,
      device: ticket.device,
      complaint: ticket.complaint,
      createdAt: ticket.createdAt,
      dropOffAt: dates.dropOffAt,
      technicianStartAt: dates.technicianStartAt,
      partsArriveAt: dates.partsArriveAt,
      customerContactedAt: dates.customerContactedAt,
      pickedUpAt: dates.pickedUpAt,
      shopTag: ticket.shopTag,
      serial: ticket.serial,
      serialMissing: ticket.serialMissing,
      deviceVariant: ticket.deviceVariant,
      deviceSide: ticket.deviceSide,
    );
    boardTickets[boardTickets.indexOf(ticket)] = updated;
    final detail = _detail;
    if (detail != null) {
      _detail = TicketDetailEntry(summary: updated);
      _detailUpdates.add(_detail);
    }
    _boardUpdates.add(List.unmodifiable(boardTickets));
  }
}

class CreateCall {
  const CreateCall({
    this.customerId,
    this.customerDeviceId,
    required this.customerName,
    required this.customerEmail,
    required this.complaint,
    this.customerPhone,
    this.deviceModelId,
    this.deviceName,
    this.deviceVariant,
    this.deviceSide,
    this.serial,
    this.serialMissing = false,
    this.photoTemplateKey,
    this.dates,
  });

  final String customerName;
  final int? customerId;
  final int? customerDeviceId;
  final String? customerPhone;
  final String customerEmail;
  final int? deviceModelId;
  final String? deviceName;
  final String? deviceVariant;
  final String? deviceSide;
  final String? serial;
  final bool serialMissing;
  final String? photoTemplateKey;
  final TicketDates? dates;
  final String complaint;
}

Future<void> _openIntake(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(FilledButton, 'New repair'));
  await tester.pumpAndSettle();
}

Future<void> _selectDevice(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.byKey(const Key('intake-category')),
    250,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(find.byKey(const Key('intake-category')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Consoles').last);
  await tester.pumpAndSettle();

  await tester.scrollUntilVisible(
    find.byKey(const Key('intake-brand')),
    250,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(find.byKey(const Key('intake-brand')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Sony').last);
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    find.byKey(const Key('intake-model')),
    250,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(find.byKey(const Key('intake-model')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Sony PlayStation 5').last);
  await tester.pumpAndSettle();
}

Future<void> _selectPortableDevice(
  WidgetTester tester,
  String label,
) async {
  await tester.tap(find.byKey(const Key('intake-category')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Portable Consoles').last);
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('intake-brand')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label.split(' ').first).last);
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('intake-model')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

Future<void> _selectController(WidgetTester tester, String label) async {
  await tester.tap(find.byKey(const Key('intake-category')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Controllers').last);
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('intake-model')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

Future<void> _fillCustomer(WidgetTester tester) async {
  await tester.enterText(
    find.byKey(const Key('intake-customer')),
    'Ana Ribeiro',
  );
  await tester.enterText(find.byKey(const Key('intake-phone')), '555 0102');
  await tester.enterText(
    find.byKey(const Key('intake-email')),
    'ana@example.com',
  );
  await tester.enterText(
    find.byKey(const Key('intake-complaint')),
    'Lid hinge cracked',
  );
}

void main() {
  testWidgets('parts area edits inventory details and recalculates retail',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await repository.createInventoryPart(
      name: 'USB-C charging port',
      description: 'Charging board for Switch',
      sku: 'PORT-1',
      vendorId: 'PartsPro',
      vendorSku: 'TYPE-C-16PIN',
      category: 'Ports',
      location: 'Shelf A1',
      startingStock: 4,
      rawCostCents: 1000,
      retailPriceCents: 1350,
    );
    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await tester.tap(find.text('Inventory'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Parts').last);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Edit'), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(
            find.byKey(const Key('edit-inventory-part-1')),
          )
          .style!
          .foregroundColor!
          .resolve({}),
      const Color(0xFF0D47A1),
    );
    expect(
        find.descendant(
          of: find.byKey(const Key('edit-inventory-part-1')),
          matching: find.byIcon(Icons.build),
        ),
        findsOneWidget);
    await tester.tap(find.byKey(const Key('edit-inventory-part-1')));
    await tester.pumpAndSettle();
    expect(find.text('Edit inventory part'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('inventory-part-name')))
          .controller!
          .text,
      'USB-C charging port',
    );
    expect(
      tester
          .widget<TextField>(
            find.byKey(const Key('inventory-part-description')),
          )
          .controller!
          .text,
      'Charging board for Switch',
    );
    expect(
      tester
          .widget<TextField>(
            find.byKey(const Key('inventory-part-vendor-id')),
          )
          .controller!
          .text,
      'PartsPro',
    );
    expect(
      tester
          .widget<TextField>(
            find.byKey(const Key('inventory-part-vendor-sku')),
          )
          .controller!
          .text,
      'TYPE-C-16PIN',
    );

    await tester.enterText(
      find.byKey(const Key('inventory-part-name')),
      'USB-C replacement port',
    );
    await tester.enterText(
      find.byKey(const Key('inventory-part-description')),
      '24-pin replacement board',
    );
    await tester.enterText(
      find.byKey(const Key('inventory-part-vendor-id')),
      'Mouser',
    );
    await tester.enterText(
      find.byKey(const Key('inventory-part-vendor-sku')),
      'USB-C-24PIN',
    );
    await tester.enterText(
      find.byKey(const Key('inventory-part-stock')),
      '6',
    );
    await tester.enterText(
      find.byKey(const Key('inventory-part-location')),
      'Bin B4',
    );
    await tester.enterText(
      find.byKey(const Key('inventory-part-raw-cost')),
      '20.00',
    );
    expect(
      tester
          .widget<TextField>(
            find.byKey(const Key('inventory-part-retail-cost')),
          )
          .controller!
          .text,
      '27.00',
    );
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    final edited = repository.inventoryParts.single;
    expect(edited.name, 'USB-C replacement port');
    expect(edited.description, '24-pin replacement board');
    expect(edited.vendorId, 'Mouser');
    expect(edited.vendorSku, 'USB-C-24PIN');
    expect(edited.stock, 6);
    expect(edited.location, 'Bin B4');
    expect(edited.rawCostCents, 2000);
    expect(edited.retailPriceCents, 2700);
  });

  testWidgets('parts area calculates cost per item for a bulk purchase',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await repository.createInventoryPart(
      name: 'USB-C charging port',
      startingStock: 10,
      rawCostCents: 1000,
      retailPriceCents: 1350,
    );
    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await tester.tap(find.text('Inventory'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Parts').last);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    await tester.tap(find.byKey(const Key('edit-inventory-part-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('inventory-part-purchase-type')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bulk purchase').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('inventory-part-bulk-quantity')),
      '10',
    );
    await tester.enterText(
      find.byKey(const Key('inventory-part-bulk-total')),
      '50.00',
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Cost per item: \$5.00'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<TextField>(
            find.byKey(const Key('inventory-part-raw-cost')),
          )
          .controller!
          .text,
      '5.00',
    );
    expect(
      tester
          .widget<TextField>(
            find.byKey(const Key('inventory-part-retail-cost')),
          )
          .controller!
          .text,
      '6.75',
    );

    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    final edited = repository.inventoryParts.single;
    expect(edited.purchaseType, PartPurchaseType.bulk);
    expect(edited.bulkQuantity, 10);
    expect(edited.bulkTotalCents, 5000);
    expect(edited.rawCostCents, 500);
    expect(edited.retailPriceCents, 675);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('parts area asks before removing inventory part',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await repository.createInventoryPart(
      name: 'USB-C charging port',
      startingStock: 2,
    );
    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await tester.tap(find.text('Inventory'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Parts').last);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    await tester.tap(find.byKey(const Key('delete-inventory-part-1')));
    await tester.pumpAndSettle();
    expect(find.text('Remove part from inventory?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('cancel-remove-inventory-part-1')));
    await tester.pumpAndSettle();
    expect(repository.inventoryParts, hasLength(1));

    await tester.tap(find.byKey(const Key('delete-inventory-part-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-remove-inventory-part-1')));
    await tester.pumpAndSettle();

    expect(repository.inventoryParts, isEmpty);
    expect(find.textContaining('USB-C charging port removed from inventory'),
        findsOneWidget);
  });

  testWidgets('parts area shows how many are committed to open tickets',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await repository.createInventoryPart(
      name: 'USB-C charging port',
      startingStock: 4,
    );
    await repository.addRequiredPart(ticketId: 7, partId: 1, quantity: 2);

    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await tester.tap(find.text('Inventory'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Parts').last);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Inventory 4'), findsOneWidget);
    expect(find.byKey(const Key('part-inventory-1')), findsOneWidget);
    expect(find.byKey(const Key('part-stock-min-1')), findsOneWidget);
    expect(find.text('Stock Min 0'), findsOneWidget);
    expect(find.byKey(const Key('part-committed-1')), findsOneWidget);
    expect(find.text('Committed 2'), findsOneWidget);
  });

  testWidgets('merch area adds and edits stock, SKU and prices',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await tester.tap(find.text('Inventory'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Merch'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.textContaining('No merchandise'), findsOneWidget);
    await tester.tap(find.byKey(const Key('merch-add-item')));
    await tester.pumpAndSettle();
    expect(find.text('Add merchandise'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('merch-item-sku')))
          .controller!
          .text,
      '001-001',
    );

    await tester.enterText(
      find.byKey(const Key('merch-item-name')),
      'Peaks Fix T-shirt',
    );
    await tester.enterText(
      find.byKey(const Key('merch-item-description')),
      'Black cotton shirt',
    );
    await tester.enterText(
      find.byKey(const Key('merch-item-category')),
      'Apparel',
    );
    await tester.enterText(
      find.byKey(const Key('merch-item-location')),
      'Shelf A2',
    );
    await tester.enterText(find.byKey(const Key('merch-item-stock')), '12');
    await tester.enterText(find.byKey(const Key('merch-item-cost')), '10.00');
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('merch-item-price')))
          .controller!
          .text,
      '14.50',
    );
    await tester.tap(find.byKey(const Key('merch-item-save')));
    await tester.pumpAndSettle();

    final added = repository.merchItems.single;
    expect(added.name, 'Peaks Fix T-shirt');
    expect(added.description, 'Black cotton shirt');
    expect(added.category, 'Apparel');
    expect(added.location, 'Shelf A2');
    expect(added.sku, '001-001');
    expect(added.stock, 12);
    expect(added.costCents, 1000);
    expect(added.priceCents, 1450);
    expect(find.text('Stock 12'), findsOneWidget);
    expect(find.byKey(const Key('edit-merch-item-1')), findsOneWidget);

    await tester.tap(find.byKey(const Key('edit-merch-item-1')));
    await tester.pumpAndSettle();
    expect(find.text('Edit merchandise'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('merch-item-name')))
          .controller!
          .text,
      'Peaks Fix T-shirt',
    );
    await tester.enterText(
      find.byKey(const Key('merch-item-name')),
      'Peaks Fix hoodie',
    );
    await tester.enterText(find.byKey(const Key('merch-item-stock')), '8');
    await tester.enterText(find.byKey(const Key('merch-item-cost')), '20.00');
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('merch-item-price')))
          .controller!
          .text,
      '29.00',
    );
    await tester.tap(find.byKey(const Key('merch-item-save')));
    await tester.pumpAndSettle();

    final edited = repository.merchItems.single;
    expect(edited.name, 'Peaks Fix hoodie');
    expect(edited.stock, 8);
    expect(edited.costCents, 2000);
    expect(edited.priceCents, 2900);
    expect(find.text('Stock 8'), findsOneWidget);
  });

  testWidgets('merch area asks before removing an item',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await repository.createMerchItem(
      name: 'Logo sticker',
      startingStock: 30,
      costCents: 100,
      priceCents: 300,
    );
    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await tester.tap(find.text('Inventory'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Merch'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    await tester.tap(find.byKey(const Key('delete-merch-item-1')));
    await tester.pumpAndSettle();
    expect(find.text('Remove item from merchandise?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('cancel-remove-merch-item-1')));
    await tester.pumpAndSettle();
    expect(repository.merchItems, hasLength(1));

    await tester.tap(find.byKey(const Key('delete-merch-item-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-remove-merch-item-1')));
    await tester.pumpAndSettle();

    expect(repository.merchItems, isEmpty);
    expect(
      find.textContaining('Logo sticker removed from merchandise'),
      findsOneWidget,
    );
  });

  testWidgets('ticket delete requires confirmation and removes the ticket',
      (WidgetTester tester) async {
    final repository = FakeTicketsRepository();
    await repository.createTicket(
      customerName: 'Test Customer',
      customerPhone: '555-0100',
      customerEmail: 'test@example.com',
      deviceName: 'Test console',
      complaint: 'Does not power on',
    );
    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await tester.pumpAndSettle();

    expect(find.text('PF-000001'), findsOneWidget);
    await tester.tap(find.byKey(const Key('delete-ticket-7')));
    await tester.pumpAndSettle();
    expect(find.text('Delete ticket?'), findsOneWidget);
    expect(find.text('PF-000001'), findsOneWidget);

    await tester.tap(find.byKey(const Key('cancel-delete-ticket-7')));
    await tester.pumpAndSettle();
    expect(find.text('PF-000001'), findsOneWidget);

    await tester.tap(find.byKey(const Key('delete-ticket-7')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-delete-ticket-7')));
    await tester.pumpAndSettle();

    expect(find.text('PF-000001'), findsNothing);
    expect(find.text('PF-000001 deleted'), findsOneWidget);
  });

  testWidgets('ticket staff selector offers signed-in staff only',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await repository.createTicket(
      customerName: 'Test Customer',
      customerPhone: '555-0100',
      customerEmail: 'test@example.com',
      deviceName: 'Test console',
      complaint: 'Does not power on',
    );
    const clockedInTech = StaffMemberEntry(
      id: 'tech-1',
      name: 'Alex Tech',
      job: 'Tech 2',
      isActive: true,
    );
    const offShiftTech = StaffMemberEntry(
      id: 'tech-2',
      name: 'Sam Tech',
      job: 'Tech 1',
      isActive: true,
    );
    repository.staffRoster.addAll([clockedInTech, offShiftTech]);
    repository.clockedInStaff.add(clockedInTech);

    await tester.pumpWidget(
      MaterialApp(
        home: ShopScope(
          tickets: repository,
          child: const TicketDetailPage(ticketId: 7),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final ticketScroll = find.descendant(
      of: find.byKey(const Key('ticket-detail-scroll')),
      matching: find.byType(Scrollable).first,
    );
    final intakeReport = find.byKey(const Key('report1-checklist'));
    await tester.scrollUntilVisible(
      intakeReport,
      200,
      scrollable: ticketScroll,
    );
    await tester.tap(intakeReport);
    await tester.pumpAndSettle();
    final selector = find.byKey(const Key('report-staff-intake-7'));
    await tester.scrollUntilVisible(selector, 200, scrollable: ticketScroll);
    await tester.tap(selector);
    await tester.pumpAndSettle();
    expect(find.text('Alex Tech · Tech 2'), findsOneWidget);
    expect(find.text('Sam Tech · Tech 1'), findsNothing);

    await tester.tap(find.text('Alex Tech · Tech 2'));
    await tester.pumpAndSettle();
    expect(repository.reportStaffAssignments[(7, ReportKind.intake)], 'tech-1');
  });

  testWidgets('app builds with all eight tabs', (WidgetTester tester) async {
    await tester.pumpWidget(VolaFixApp(tickets: FakeTicketsRepository()));

    expect(find.text('Peaks Fix'), findsWidgets);
    expect(find.text('Tickets'), findsWidgets);
    expect(find.text('Invoicing'), findsWidgets);
    expect(find.text('Calendar'), findsWidgets);
    expect(find.text('Customers'), findsWidgets);
    expect(find.text('Inventory'), findsWidgets);
    expect(find.text('Financial'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
    expect(find.byKey(const Key('nav-badge-checkout')), findsOneWidget);
    expect(find.byKey(const Key('nav-badge-financial')), findsOneWidget);
  });

  testWidgets('checkout adds merchandise, takes payment, and closes ticket',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await repository.createTicket(
      customerName: 'Checkout Customer',
      customerPhone: '555-0100',
      customerEmail: 'checkout@example.com',
      deviceName: 'Repair console',
      complaint: 'Broken HDMI port',
    );
    repository.invoices[7] = const InvoiceDraft(
      discountKind: InvoiceDiscountKind.none,
      discountValue: 0,
      lines: [
        InvoiceLine(
          ticketItemId: 1,
          kind: TicketItemKind.custom,
          description: 'Repair labor',
          quantity: 1,
          unitPriceCents: 2500,
        ),
      ],
    );
    await repository.updateStatus(7, TicketStatus.ready);

    await tester.pumpWidget(
      MaterialApp(
        home: ShopScope(
          tickets: repository,
          child: const Scaffold(body: CheckoutPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Balance due \$25.00'), findsOneWidget);

    await tester.tap(find.byKey(const Key('checkout-open-7')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('checkout-add-merch')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('checkout-merch-name')),
      'Shop T-shirt',
    );
    await tester.enterText(
      find.byKey(const Key('checkout-merch-cost')),
      '20.00',
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('45% markup: \$29.00'), findsOneWidget);
    await tester.tap(find.byKey(const Key('checkout-merch-add')));
    await tester.pumpAndSettle();
    expect(find.text('Shop T-shirt'), findsOneWidget);
    expect(find.textContaining('Balance due \$54.00'), findsOneWidget);

    await tester.tap(find.byKey(const Key('checkout-record-payment')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('checkout-payment-save')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Balance due \$0.00'), findsOneWidget);

    await tester.tap(find.byKey(const Key('checkout-close-7')));
    await tester.pumpAndSettle();
    expect(repository.boardTickets.single.status, TicketStatus.closed);
    expect(find.text('No tickets are ready for checkout.'), findsOneWidget);
  });

  testWidgets('closed tickets are shown in their own tab',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await repository.createTicket(
      customerName: 'Closed Customer',
      customerPhone: '555-0100',
      customerEmail: 'closed@example.com',
      deviceName: 'Repaired console',
      complaint: 'Fixed HDMI port',
    );
    await repository.updateStatus(7, TicketStatus.ready);
    await repository.closeTicketAfterPayment(7);

    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await tester.pumpAndSettle();
    expect(find.text('PF-000001'), findsNothing);

    await tester.tap(find.text('Invoicing').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Closed Tickets').first);
    await tester.pumpAndSettle();
    expect(find.text('PF-000001'), findsOneWidget);
  });

  testWidgets('closed ticket reopens for warranty work',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    repository.boardTickets.add(
      TicketBoardEntry(
        id: 9,
        number: 'PF-000009',
        status: TicketStatus.closed,
        customerName: 'Warranty Customer',
        device: 'Handheld console',
        complaint: 'Warranty return',
        createdAt: DateTime(2026, 10, 1),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ShopScope(
          tickets: repository,
          child: const Scaffold(body: TicketsPage(closedOnly: true)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('PF-000009'), findsOneWidget);

    await tester.tap(find.byKey(const Key('reopen-ticket-9')));
    await tester.pumpAndSettle();
    expect(find.text('Reopen PF-000009?'), findsOneWidget);
    expect(
      find.textContaining('Reports, invoice lines and payments stay'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('confirm-reopen-ticket')));
    await tester.pumpAndSettle();

    expect(repository.boardTickets.single.status, TicketStatus.inRepair);
    expect(find.text('No closed tickets'), findsOneWidget);
    expect(find.textContaining('reopened as In repair'), findsOneWidget);
  });

  testWidgets('calendar shows all ticket workflow dates and opens tickets',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    final today = DateTime.now();
    final date = DateTime(today.year, today.month, today.day);
    await repository.createTicket(
      customerName: 'Calendar Customer',
      customerPhone: '555-0123',
      customerEmail: 'calendar@example.com',
      deviceName: 'Test console',
      complaint: 'Calendar test',
      dates: TicketDates(
        dropOffAt: date,
        technicianStartAt: date,
        partsArriveAt: date,
        customerContactedAt: date,
        pickedUpAt: date,
      ),
    );

    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await tester.tap(find.text('Calendar').last);
    await tester.pumpAndSettle();

    for (final label in [
      'Drop Off',
      'Technician Start',
      'Parts Arrive',
      'Customer Contacted',
      'Date of Pick Up',
    ]) {
      expect(find.textContaining(label), findsOneWidget);
    }
    await tester.tap(find.byKey(const Key('calendar-event-7-Drop Off')));
    await tester.pumpAndSettle();
    expect(find.text('Calendar test'), findsOneWidget);
  });

  testWidgets('wide layout uses a rail and switches tabs',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(VolaFixApp(tickets: FakeTicketsRepository()));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(find.text('Inventory'));
    await tester.pumpAndSettle();

    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.selectedIndex, 4);
  });

  testWidgets('narrow layout uses the bottom bar', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(VolaFixApp(tickets: FakeTicketsRepository()));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('customers page saves and edits customer profiles',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await tester.tap(find.text('Customers').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('customer-add')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('customer-name')),
      'Morgan Lee',
    );
    await tester.enterText(
      find.byKey(const Key('customer-phone')),
      '555-0110',
    );
    await tester.enterText(
      find.byKey(const Key('customer-email')),
      'morgan@example.com',
    );
    await tester.tap(find.byKey(const Key('customer-save')));
    await tester.pumpAndSettle();
    expect(find.text('Morgan Lee'), findsOneWidget);

    await tester.tap(find.byKey(const Key('customer-edit-1')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('customer-name')),
      'Morgan Lee-Smith',
    );
    await tester.tap(find.byKey(const Key('customer-save')));
    await tester.pumpAndSettle();
    expect(find.text('Morgan Lee-Smith'), findsOneWidget);
  });

  testWidgets('customer devices show their warranty coverage',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await repository.saveCustomer(
      name: 'Warranty Customer',
      phone: '555-0120',
      email: 'warranty@example.com',
      notes: '',
    );
    repository.customerDevices[1] = [
      CustomerDeviceEntry(
        id: 42,
        label: 'Sony PlayStation 5',
        serial: 'XKW-WARRANTY',
        serialMissing: false,
        modelId: 1,
        category: 'Consoles',
        modelName: 'PlayStation 5',
        warranty: DeviceWarranty(
          startAt: DateTime.now().subtract(const Duration(days: 10)),
          days: 90,
        ),
      ),
    ];

    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await tester.tap(find.text('Customers').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('customer-1')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('customer-device-warranty-42')),
      findsOneWidget,
    );
    expect(find.textContaining('Warranty until'), findsOneWidget);
    expect(find.textContaining('90 days'), findsOneWidget);
  });

  testWidgets('intake opens from the Tickets page',
      (WidgetTester tester) async {
    await tester.pumpWidget(VolaFixApp(tickets: FakeTicketsRepository()));
    await _openIntake(tester);

    expect(find.text('New repair'), findsWidgets);
    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('No serial number sticker'), findsOneWidget);
  });

  testWidgets('General Electronics uses the standard custom device fields',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(VolaFixApp(tickets: FakeTicketsRepository()));
    await _openIntake(tester);

    await tester.tap(find.byKey(const Key('intake-category')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('General Electronics').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('intake-model')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Other / not listed').last);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('intake-device-other')), findsOneWidget);
    expect(find.byKey(const Key('intake-device-variant')), findsOneWidget);
    expect(find.byKey(const Key('intake-serial')), findsOneWidget);
    expect(find.byKey(const Key('intake-complaint')), findsOneWidget);
  });

  testWidgets('a missing sticker swaps in a generated shop serial',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(VolaFixApp(tickets: FakeTicketsRepository()));
    await _openIntake(tester);

    final field = find.byKey(const Key('intake-serial'));
    expect(tester.widget<TextField>(field).enabled, isTrue);

    await tester.enterText(field, 'XKW1000123');
    await tester.ensureVisible(find.text('No serial number sticker'));
    await tester.tap(find.text('No serial number sticker'));
    await tester.pumpAndSettle();

    final disabled = tester.widget<TextField>(field);
    expect(disabled.enabled, isFalse);
    expect(disabled.controller!.text, 'PFS-123456789');
    expect(
      find.textContaining('Shop serial PFS-000000000 replaces'),
      findsOneWidget,
    );

    await tester.tap(find.text('No serial number sticker'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(field).enabled, isTrue);
    expect(tester.widget<TextField>(field).controller!.text, isEmpty);
    expect(
      find.textContaining('Shop serial PFS-000000000 replaces'),
      findsNothing,
    );
  });

  testWidgets('intake refuses to save without a customer name',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await _openIntake(tester);

    await tester.scrollUntilVisible(
      find.byKey(const Key('intake-save')),
      250,
      scrollable: find.descendant(
        of: find.byKey(const Key('intake-form-scroll')),
        matching: find.byType(Scrollable).first,
      ),
    );
    await tester.ensureVisible(find.byKey(const Key('intake-save')));
    await tester.tap(find.byKey(const Key('intake-save')));
    await tester.pumpAndSettle();

    expect(find.text('Enter the customer name.'), findsOneWidget);
    expect(repository.creations, isEmpty);
  });

  testWidgets('intake requires a phone number', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await _openIntake(tester);

    await tester.enterText(
      find.byKey(const Key('intake-customer')),
      'Ana Ribeiro',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('intake-save')),
      250,
      scrollable: find.descendant(
        of: find.byKey(const Key('intake-form-scroll')),
        matching: find.byType(Scrollable).first,
      ),
    );
    await tester.ensureVisible(find.byKey(const Key('intake-save')));
    await tester.tap(find.byKey(const Key('intake-save')));
    await tester.pumpAndSettle();

    expect(find.text('Enter the customer phone number.'), findsOneWidget);
    expect(repository.creations, isEmpty);
  });

  testWidgets('intake requires an email address', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await _openIntake(tester);

    await tester.enterText(
      find.byKey(const Key('intake-customer')),
      'Ana Ribeiro',
    );
    await tester.enterText(find.byKey(const Key('intake-phone')), '555 0102');
    await tester.scrollUntilVisible(
      find.byKey(const Key('intake-save')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('intake-save')));
    await tester.pumpAndSettle();

    expect(find.text('Enter the customer email address.'), findsOneWidget);
    expect(repository.creations, isEmpty);
  });

  testWidgets('intake rejects a malformed email', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await _openIntake(tester);

    await tester.enterText(
      find.byKey(const Key('intake-customer')),
      'Ana Ribeiro',
    );
    await tester.enterText(find.byKey(const Key('intake-phone')), '555 0102');
    await tester.enterText(
      find.byKey(const Key('intake-email')),
      'ana(at)example.com',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('intake-save')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('intake-save')));
    await tester.pumpAndSettle();

    expect(
        find.text('That email address does not look right.'), findsOneWidget);
    expect(repository.creations, isEmpty);
  });

  testWidgets('intake creates a ticket and opens it',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await _openIntake(tester);

    await tester.enterText(
      find.byKey(const Key('intake-customer')),
      'Ana Ribeiro',
    );
    await tester.enterText(find.byKey(const Key('intake-phone')), '555 0102');
    await tester.enterText(
      find.byKey(const Key('intake-email')),
      'ana@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('intake-serial')),
      'XKW1000123',
    );
    await tester.enterText(
      find.byKey(const Key('intake-complaint')),
      'No HDMI output',
    );
    await _selectDevice(tester);
    expect(find.byKey(const Key('date-picker-Drop Off')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('intake-save')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('intake-save')));
    await tester.pumpAndSettle();

    expect(repository.creations, hasLength(1));
    final created = repository.creations.single;
    expect(created.customerName, 'Ana Ribeiro');
    expect(created.customerPhone, '555 0102');
    expect(created.customerEmail, 'ana@example.com');
    expect(created.deviceModelId, 1);
    expect(created.serial, 'XKW1000123');
    expect(created.serialMissing, isFalse);
    expect(created.complaint, 'No HDMI output');
    final intakeDate = DateTime.now();
    expect(
      created.dates?.dropOffAt,
      DateTime(intakeDate.year, intakeDate.month, intakeDate.day),
    );
    expect(created.dates?.technicianStartAt, isNull);

    // The intake route is replaced by the new ticket.
    expect(find.text('PF-000001'), findsWidgets);
    expect(find.text('No HDMI output'), findsOneWidget);
    expect(find.text('G-123456789'), findsWidgets);
    expect(find.byType(NavigationRail), findsOneWidget);

    await tester.tap(find.text('Customers'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byKey(const Key('customer-search')), findsOneWidget);
  });

  testWidgets('intake reuses a customer and saved device by phone or email',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await repository.saveCustomer(
      name: 'Returning Customer',
      phone: '(555) 0102',
      email: 'returning@example.com',
      notes: '',
    );
    repository.customerDevices[1] = const [
      CustomerDeviceEntry(
        id: 42,
        label: 'Sony PlayStation 5',
        serial: 'XKW1000123',
        serialMissing: false,
        modelId: 1,
        category: 'Consoles',
        modelName: 'PlayStation 5',
      ),
    ];
    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await _openIntake(tester);
    await tester.enterText(
      find.byKey(const Key('intake-phone')),
      '555 0102',
    );
    await tester.enterText(
      find.byKey(const Key('intake-email')),
      'returning@example.com',
    );
    await tester.tap(find.byKey(const Key('intake-find-customer')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('intake-customer-result-1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      tester
          .widget<TextField>(find.byKey(const Key('intake-customer')))
          .controller!
          .text,
      'Returning Customer',
    );
    await tester.tap(find.byKey(const Key('intake-saved-device')));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Sony PlayStation 5').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('intake-complaint')),
      'Intermittent HDMI',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('intake-save')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('intake-save')));
    await tester.pumpAndSettle();

    expect(repository.creations, hasLength(1));
    expect(repository.creations.single.customerId, 1);
    expect(repository.creations.single.customerDeviceId, 42);
    expect(repository.creations.single.deviceModelId, 1);
    expect(repository.creations.single.serial, 'XKW1000123');
  });

  testWidgets('customer name suggestions select and load a returning customer',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await repository.saveCustomer(
      name: 'Morgan Lee-Smith',
      phone: '555-0123',
      email: 'morgan@example.com',
      notes: '',
    );
    repository.customerDevices[1] = const [
      CustomerDeviceEntry(
        id: 73,
        label: 'Sony PlayStation 5',
        serial: 'XKW-73',
        serialMissing: false,
        modelId: 1,
        category: 'Consoles',
        modelName: 'PlayStation 5',
      ),
    ];

    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await _openIntake(tester);
    await tester.enterText(
      find.byKey(const Key('intake-customer')),
      'lee-sm',
    );
    await tester.pumpAndSettle();

    final suggestion = find.byKey(const Key('intake-customer-suggestion-1'));
    expect(suggestion, findsOneWidget);
    expect(find.text('555-0123 · morgan@example.com'), findsOneWidget);
    await tester.tap(suggestion);
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<TextField>(find.byKey(const Key('intake-customer')))
          .controller!
          .text,
      'Morgan Lee-Smith',
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('intake-phone')))
          .controller!
          .text,
      '555-0123',
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('intake-email')))
          .controller!
          .text,
      'morgan@example.com',
    );
    expect(find.text('Existing customer selected'), findsOneWidget);

    await tester.tap(find.byKey(const Key('intake-saved-device')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Sony PlayStation 5'), findsWidgets);
  });

  testWidgets('intake records a model number below the model',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await _openIntake(tester);

    await tester.enterText(
      find.byKey(const Key('intake-customer')),
      'Ana Ribeiro',
    );
    await tester.enterText(find.byKey(const Key('intake-phone')), '555 0102');
    await tester.enterText(
      find.byKey(const Key('intake-email')),
      'ana@example.com',
    );
    await _selectDevice(tester);
    await tester.enterText(
      find.byKey(const Key('intake-device-variant')),
      'PSP-3000',
    );
    await tester.enterText(
      find.byKey(const Key('intake-serial')),
      'XKW1000123',
    );
    await tester.enterText(
      find.byKey(const Key('intake-complaint')),
      'Screen flicker',
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('intake-save')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('intake-save')));
    await tester.pumpAndSettle();

    expect(repository.creations, hasLength(1));
    expect(repository.creations.single.deviceVariant, 'PSP-3000');
    expect(find.text('MODEL NUMBER'), findsOneWidget);
    expect(find.text('PSP-3000'), findsWidgets);
  });

  testWidgets('intake saves a device with no serial sticker',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await _openIntake(tester);

    await tester.enterText(
      find.byKey(const Key('intake-customer')),
      'Ana Ribeiro',
    );
    await tester.enterText(find.byKey(const Key('intake-phone')), '555 0102');
    await tester.enterText(
      find.byKey(const Key('intake-email')),
      'ana@example.com',
    );
    await _selectDevice(tester);
    await tester.enterText(
      find.byKey(const Key('intake-complaint')),
      'Will not power on',
    );
    await tester.ensureVisible(find.text('No serial number sticker'));
    await tester.tap(find.text('No serial number sticker'));
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const Key('intake-form-scroll')),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('intake-save')));
    await tester.pumpAndSettle();

    expect(repository.creations, hasLength(1));
    final created = repository.creations.single;
    expect(created.serial, 'PFS-123456789');
    expect(created.serialMissing, isTrue);
    expect(find.text('SHOP SERIAL'), findsOneWidget);
    expect(find.text('PFS-123456789'), findsWidgets);
  });

  testWidgets('a single Joy-Con asks which side it is', (tester) async {
    tester.view.physicalSize = const Size(1400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await _openIntake(tester);
    await _fillCustomer(tester);

    // A pair is one device: no side to choose.
    await _selectController(tester, 'Nintendo Joy-Con (pair)');
    expect(find.byKey(const Key('intake-side')), findsNothing);

    await _selectController(tester, 'Nintendo Joy-Con (single)');
    expect(find.byKey(const Key('intake-side')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('intake-serial')),
      'XKW1000123',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('intake-save')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('intake-save')));
    await tester.pumpAndSettle();

    expect(
      find.text('Choose which side this Joy-Con is: left or right.'),
      findsOneWidget,
    );
    expect(repository.creations, isEmpty);

    await tester.tap(find.byKey(const Key('intake-side')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Left (L)').last);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('intake-save')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('intake-save')));
    await tester.pumpAndSettle();

    expect(repository.creations, hasLength(1));
    expect(repository.creations.single.deviceSide, 'left');
    expect(find.text('SIDE'), findsOneWidget);
    expect(find.text('Left'), findsWidgets);
  });

  testWidgets('intake previews the 3DS photo checklist',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(VolaFixApp(tickets: FakeTicketsRepository()));
    await _openIntake(tester);
    await _selectPortableDevice(tester, 'Nintendo 3DS');

    expect(find.text('Report 1 · 5 photos'), findsOneWidget);
    expect(find.text('Hinged handheld (3DS / DS)'), findsOneWidget);

    await tester.tap(find.text('Report 1 · 5 photos'));
    await tester.pumpAndSettle();

    for (final label in const [
      'Top screen (closed)',
      'Back (closed)',
      'Charger port',
      'Open (both screens)',
      'Serial label',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('ticket report 1 keeps the 3DS shot list',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await _openIntake(tester);

    await _fillCustomer(tester);
    await _selectPortableDevice(tester, 'Nintendo 3DS');
    await tester.enterText(
      find.byKey(const Key('intake-serial')),
      'CW123456789',
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('intake-save')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('intake-save')));
    await tester.pumpAndSettle();

    expect(repository.creations, hasLength(1));
    expect(repository.creations.single.photoTemplateKey, 'hinged');

    await tester.scrollUntilVisible(
      find.text('Intake / cosmetic'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Intake / cosmetic'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('0 of 5 required photos · Hinged handheld'),
      findsOneWidget,
    );
    expect(find.text('Top screen (closed)'), findsOneWidget);
    expect(find.text('Open (both screens)'), findsOneWidget);
    expect(find.text('not captured'), findsNWidgets(5));
    // The phone link belongs to the shop PC, not the phone app.
    expect(find.byKey(const Key('capture-with-phone')), findsNothing);
  });

  testWidgets('report 1 supports labeled optional photos',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await _open3dsReport1(tester, repository);
    expect(find.byKey(const Key('add-optional-photo')), findsOneWidget);
    await tester.tap(find.byKey(const Key('add-optional-photo')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('optional-photo-label')),
      'Cracked shell close-up',
    );
    await tester.tap(find.byKey(const Key('optional-photo-save')));
    await tester.pumpAndSettle();

    expect(find.text('Cracked shell close-up'), findsOneWidget);
    expect(
      find.textContaining('0 of 5 required photos · Hinged handheld'),
      findsOneWidget,
    );
    expect(
      repository.currentChecklist.slots.where((slot) => slot.required),
      hasLength(5),
    );
    expect(repository.currentChecklist.slots.last.required, isFalse);
  });

  testWidgets('the shop PC offers phone capture for report 1',
      (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    tester.view.physicalSize = const Size(1400, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await _openIntake(tester);

    await _fillCustomer(tester);
    await _selectPortableDevice(tester, 'Nintendo 3DS');
    await tester.enterText(
      find.byKey(const Key('intake-serial')),
      'CW123456789',
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('intake-save')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('intake-save')));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Intake / cosmetic'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Intake / cosmetic'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('capture-with-phone')), findsOneWidget);
    expect(find.text('Capture with phone'), findsOneWidget);

    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('General Electronics uses its device name and phone capture',
      (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    tester.view.physicalSize = const Size(1400, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await _openIntake(tester);
    await _fillCustomer(tester);

    await tester.tap(find.byKey(const Key('intake-category')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('General Electronics').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('intake-model')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Other / not listed').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('intake-device-other')),
      'Ninja Grill',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('intake-checklist')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Ninja Grill'), findsWidgets);
    expect(find.text('Home console'), findsNothing);
    expect(
      find.byKey(const Key('intake-import-photos-qr')),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(const Key('intake-serial')),
      'NG-12345',
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('intake-save')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('intake-save')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Intake / cosmetic'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Intake / cosmetic'));
    await tester.pumpAndSettle();
    debugDefaultTargetPlatformOverride = null;

    expect(
      find.textContaining('0 of 4 required photos · Ninja Grill'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('capture-with-phone')), findsOneWidget);
  });

  testWidgets('Vacuum offers phone capture for its required photos',
      (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    tester.view.physicalSize = const Size(1400, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await _openIntake(tester);
    await _fillCustomer(tester);

    await tester.tap(find.byKey(const Key('intake-category')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vacuum').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('intake-brand')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dyson').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('intake-model')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dyson V8').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('intake-checklist')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.byKey(const Key('intake-import-photos-qr')),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(const Key('intake-serial')),
      'VAC-12345',
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('intake-save')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('intake-save')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Intake / cosmetic'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Intake / cosmetic'));
    await tester.pumpAndSettle();
    debugDefaultTargetPlatformOverride = null;

    expect(
      find.textContaining('0 of 3 required photos · Vacuum'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('capture-with-phone')), findsOneWidget);
  });

  testWidgets('report 1 saves condition notes automatically',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await _openIntake(tester);

    await _fillCustomer(tester);
    await _selectPortableDevice(tester, 'Nintendo 3DS');
    await tester.enterText(
      find.byKey(const Key('intake-serial')),
      'CW123456789',
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('intake-save')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('intake-save')));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Intake / cosmetic'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Intake / cosmetic'));
    await tester.pumpAndSettle();

    final notes = find.byKey(const Key('intake-notes'));
    await tester.scrollUntilVisible(
      notes,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(
      notes,
      'Scratch across the top shell. Worn serial sticker.',
    );
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(repository.intakeNoteWrites, hasLength(1));
    expect(
      repository.intakeNoteWrites.single.notes,
      'Scratch across the top shell. Worn serial sticker.',
    );
    expect(find.text('Saved to this ticket'), findsOneWidget);
  });

  testWidgets('report 1 completes and unlocks report 2',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await _open3dsReport1(tester, repository);

    final complete = find.byKey(const Key('complete-report1'));
    await tester.scrollUntilVisible(
      complete,
      250,
      scrollable: find.byType(Scrollable).first,
    );

    // No photos yet: the button is visible but disabled.
    expect(tester.widget<FilledButton>(complete).onPressed, isNull);
    expect(find.text('5 photos still needed.'), findsOneWidget);
    expect(repository.report1Writes, isEmpty);

    repository.markAllPhotosCaptured();
    await tester.pumpAndSettle();

    expect(tester.widget<FilledButton>(complete).onPressed, isNotNull);
    expect(find.text('This unlocks report 2.'), findsOneWidget);

    await tester.tap(complete);
    await tester.pumpAndSettle();

    expect(repository.report1Writes, hasLength(1));
    expect(repository.report1Writes.single.completed, isTrue);
    expect(find.text('Report 1 complete'), findsOneWidget);
    expect(find.byKey(const Key('reopen-report1')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('report2-row')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('report2-row')),
        matching: find.text('Draft'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('report2-row')),
        matching: find.text('Locked'),
      ),
      findsNothing,
    );
    // Report 3 is unaffected.
    expect(
      find.descendant(
        of: find.byKey(const Key('report3-row')),
        matching: find.text('Draft'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('report 2 stays locked until report 1 is complete',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await _open3dsReport1(tester, repository);

    await tester.scrollUntilVisible(
      find.byKey(const Key('report2-row')),
      250,
      scrollable: find.byType(Scrollable).first,
    );

    expect(
      find.descendant(
        of: find.byKey(const Key('report2-row')),
        matching: find.text('Locked'),
      ),
      findsOneWidget,
    );
    expect(find.text('Complete report 1 to unlock'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('report2-start')))
          .onPressed,
      isNull,
    );
    await tester.tap(find.byKey(const Key('report2-expand')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Complete Report 1 above to unlock the technical'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('technical-add-note')), findsNothing);
  });

  testWidgets('client report Start button opens the editable draft',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 2800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    repository.clientWarranties[7] = const ClientReportWarranty(
      defaultDays: 120,
      defaultTerms: WarrantyConfig.defaultTerms,
      categoryName: 'Consoles',
    );
    await _open3dsReport1(tester, repository);
    final report3 = find.byKey(const Key('report3-row'));
    await tester.scrollUntilVisible(
      report3,
      250,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Editable client draft'), findsNothing);
    await tester.tap(find.byKey(const Key('report3-start')));
    await tester.pumpAndSettle();

    expect(find.text('Editable client draft'), findsOneWidget);
    expect(
        find.text(
          'The draft will fill as you add technical notes and photos.',
        ),
        findsOneWidget);

    final warrantyPanel = find.byKey(const Key('client-warranty-coverage'));
    await tester.scrollUntilVisible(
      warrantyPanel,
      250,
      scrollable: find.descendant(
        of: find.byKey(const Key('ticket-detail-scroll')),
        matching: find.byType(Scrollable).first,
      ),
    );
    expect(warrantyPanel, findsOneWidget);
    expect(
      find.text('Consoles default: 120 days. Change it per category in '
          'Settings › Device catalog.'),
      findsOneWidget,
    );
    final daysField = find.byKey(const Key('client-warranty-days'));
    expect(
      tester.widget<TextField>(daysField).controller!.text,
      '120',
    );
    await tester.enterText(daysField, '30');
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
    expect(repository.clientWarranties[7]!.days, 30);

    await tester.scrollUntilVisible(
      find.byKey(const Key('client-report-open-invoice')),
      250,
      scrollable: find.descendant(
        of: find.byKey(const Key('ticket-detail-scroll')),
        matching: find.byType(Scrollable).first,
      ),
    );
    await tester.ensureVisible(
      find.byKey(const Key('client-report-open-invoice')),
    );
    await tester.tap(find.byKey(const Key('client-report-open-invoice')));
    await tester.pumpAndSettle();
    expect(find.text('Invoice · PF-000001'), findsOneWidget);
    expect(find.textContaining('No invoice lines yet.'), findsOneWidget);
  });

  testWidgets('report 2 supports a bench note after report 1 is complete',
      (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    tester.view.physicalSize = const Size(1400, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await _open3dsReport1(tester, repository);
    repository.markAllPhotosCaptured();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    final ticketScroll = find.descendant(
      of: find.byKey(const Key('ticket-detail-scroll')),
      matching: find.byType(Scrollable).first,
    );

    final complete = find.byKey(const Key('complete-report1'));
    await tester.scrollUntilVisible(
      complete,
      250,
      scrollable: ticketScroll,
    );
    await tester.tap(complete);
    await tester.pumpAndSettle();

    final report2Start = find.byKey(const Key('report2-start'));
    await tester.scrollUntilVisible(
      report2Start,
      250,
      scrollable: ticketScroll,
    );
    await tester.tap(report2Start);
    await tester.pumpAndSettle();

    final addNote = find.byKey(const Key('technical-add-note'));
    expect(addNote, findsOneWidget);
    expect(
      find.byKey(const Key('technical-capture-with-phone')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('report2-expand')));
    await tester.pumpAndSettle();
    expect(addNote, findsNothing);
    await tester.tap(find.byKey(const Key('report2-expand')));
    await tester.pumpAndSettle();
    expect(addNote, findsOneWidget);
    await tester.scrollUntilVisible(
      addNote,
      250,
      scrollable: ticketScroll,
    );
    await tester.ensureVisible(addNote);
    await tester.tap(addNote);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('technical-note-field-1')), findsOneWidget);
    expect(
      find.byKey(const Key('technical-note-capture-with-phone-1')),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('technical-required-parts')),
      250,
      scrollable: ticketScroll,
    );
    await tester.ensureVisible(
      find.byKey(const Key('technical-required-parts')),
    );
    await tester.tap(find.byKey(const Key('technical-required-parts')));
    await tester.pumpAndSettle();
    expect(find.textContaining('No inventory parts yet.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('required-parts-create-inventory')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('inventory-part-sku')))
          .controller!
          .text,
      '001-001',
    );
    await tester.enterText(
      find.byKey(const Key('inventory-part-name')),
      'USB-C charging port',
    );
    await tester.enterText(
      find.byKey(const Key('inventory-part-stock')),
      '4',
    );
    await tester.enterText(
      find.byKey(const Key('inventory-part-raw-cost')),
      '10.00',
    );
    expect(
      tester
          .widget<TextField>(
            find.byKey(const Key('inventory-part-retail-cost')),
          )
          .controller!
          .text,
      '13.50',
    );
    await tester.tap(find.text('Add part'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('required-parts-picker')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.text('001-001 · USB-C charging port · stock 4').last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('required-parts-add')));
    await tester.pumpAndSettle();
    expect(find.text('USB-C charging port'), findsOneWidget);
    expect(repository.requiredParts.single.quantity, 1);
    expect(repository.inventoryParts.single.stock, 4);
    expect(repository.inventoryParts.single.sku, '001-001');
    expect(repository.inventoryParts.single.rawCostCents, 1000);
    expect(repository.inventoryParts.single.retailPriceCents, 1350);
    expect(find.textContaining('Qty 1 · stock 4'), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('parts invoice picker filters by SKU or part name',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await repository.createInventoryPart(
      name: 'USB-C charging port',
      description: 'Charging board for Switch',
      startingStock: 4,
      rawCostCents: 1000,
      retailPriceCents: 1350,
    );
    await repository.createInventoryPart(
      name: 'Speaker module',
      startingStock: 2,
      rawCostCents: 500,
      retailPriceCents: 700,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RequiredPartsDialog(repository: repository, ticketId: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Parts Invoice'), findsOneWidget);

    final dropdown = tester.widget<DropdownMenu<int>>(
      find.byKey(const Key('required-parts-picker')),
    );
    expect(dropdown.enableFilter, isTrue);

    final entries = dropdown.dropdownMenuEntries;
    expect(entries.map((entry) => entry.label), [
      '001-001 · USB-C charging port · stock 4',
      '001-002 · Speaker module · stock 2',
    ]);

    List<String> filtered(String query) =>
        dropdown.filterCallback!(entries, query)
            .map((entry) => entry.label)
            .toList();

    expect(filtered('001-002'), ['001-002 · Speaker module · stock 2']);
    expect(filtered('charging'), ['001-001 · USB-C charging port · stock 4']);
    expect(filtered('switch'), ['001-001 · USB-C charging port · stock 4']);
    expect(filtered(''), hasLength(2));
  });

  testWidgets('reopening report 1 locks report 2 again',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await _open3dsReport1(tester, repository);
    repository.markAllPhotosCaptured();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('complete-report1')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('complete-report1')));
    await tester.pumpAndSettle();
    expect(repository.report1Writes.single.completed, isTrue);

    await tester.scrollUntilVisible(
      find.byKey(const Key('reopen-report1')),
      -250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('reopen-report1')));
    await tester.pumpAndSettle();

    expect(find.text('Reopen report 1?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm-reopen-report1')));
    await tester.pumpAndSettle();

    expect(repository.report1Writes, hasLength(2));
    expect(repository.report1Writes.last.completed, isFalse);
    expect(find.byKey(const Key('complete-report1')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('report2-row')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('report2-row')),
        matching: find.text('Locked'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('report 2 completes and reopens without touching report 3',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await _open3dsReport1(tester, repository);
    repository.markAllPhotosCaptured();
    await tester.pumpAndSettle();
    final ticketScroll = find.descendant(
      of: find.byKey(const Key('ticket-detail-scroll')),
      matching: find.byType(Scrollable).first,
    );

    final complete1 = find.byKey(const Key('complete-report1'));
    await tester.scrollUntilVisible(
      complete1,
      250,
      scrollable: ticketScroll,
    );
    await tester.tap(complete1);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('report2-start')),
      250,
      scrollable: ticketScroll,
    );
    await tester.tap(find.byKey(const Key('report2-start')));
    await tester.pumpAndSettle();

    final complete2 = find.byKey(const Key('complete-report2'));
    await tester.scrollUntilVisible(
      complete2,
      250,
      scrollable: ticketScroll,
    );
    await tester.tap(complete2);
    await tester.pumpAndSettle();

    expect(repository.report2Writes, hasLength(1));
    expect(repository.report2Writes.single.completed, isTrue);
    expect(repository.report3Writes, isEmpty);
    expect(find.text('Report 2 complete'), findsOneWidget);
    expect(
      find.textContaining('Technical stage done'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('report2-row')),
      -250,
      scrollable: ticketScroll,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('report2-row')),
        matching: find.text('Completed'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('report3-row')),
        matching: find.text('Draft'),
      ),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('reopen-report2')),
      250,
      scrollable: ticketScroll,
    );
    await tester.tap(find.byKey(const Key('reopen-report2')));
    await tester.pumpAndSettle();
    expect(find.text('Reopen report?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm-reopen-report2')));
    await tester.pumpAndSettle();

    expect(repository.report2Writes, hasLength(2));
    expect(repository.report2Writes.last.completed, isFalse);
    expect(find.byKey(const Key('complete-report2')), findsOneWidget);
  });

  testWidgets('report 3 completion sends the ticket to checkout',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await _open3dsReport1(tester, repository);
    final ticketScroll = find.descendant(
      of: find.byKey(const Key('ticket-detail-scroll')),
      matching: find.byType(Scrollable).first,
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('report3-start')),
      250,
      scrollable: ticketScroll,
    );
    await tester.tap(find.byKey(const Key('report3-start')));
    await tester.pumpAndSettle();

    final complete3 = find.byKey(const Key('complete-report3'));
    await tester.scrollUntilVisible(
      complete3,
      250,
      scrollable: ticketScroll,
    );
    await tester.tap(complete3);
    await tester.pumpAndSettle();
    expect(find.text('Send to checkout?'), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirm-complete-report3')));
    await tester.pumpAndSettle();

    expect(repository.report3Writes, hasLength(1));
    expect(repository.report3Writes.single.completed, isTrue);
    expect(repository.boardTickets.single.status, TicketStatus.ready);
    expect(find.text('Report 3 complete'), findsOneWidget);
    expect(find.textContaining('sent to checkout'), findsWidgets);

    await tester.pumpWidget(
      MaterialApp(
        home: ShopScope(
          tickets: repository,
          child: const Scaffold(body: CheckoutPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('checkout-open-7')), findsOneWidget);
  });
}

/// Books a 3DS job and opens its Report 1 checklist.
Future<void> _open3dsReport1(
  WidgetTester tester,
  FakeTicketsRepository repository,
) async {
  await tester.pumpWidget(VolaFixApp(tickets: repository));
  await _openIntake(tester);

  await _fillCustomer(tester);
  await _selectPortableDevice(tester, 'Nintendo 3DS');
  await tester.enterText(
    find.byKey(const Key('intake-serial')),
    'CW123456789',
  );

  await tester.scrollUntilVisible(
    find.byKey(const Key('intake-save')),
    250,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(find.byKey(const Key('intake-save')));
  await tester.pumpAndSettle();

  await tester.scrollUntilVisible(
    find.text('Intake / cosmetic'),
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(find.text('Intake / cosmetic'));
  await tester.pumpAndSettle();
}
