import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import 'database.dart';

/// One closed ticket and the money it brought in.
///
/// Revenue is the invoice total after discounts. Cost is the recorded part and
/// merchandise cost on the bill, so labour does not count against gross profit;
/// staff pay is tracked separately from the time clock.
///
/// Parts and merchandise are also tracked on their own. Their revenue figures
/// are net of a proportional share of any invoice discount, so
/// [partsRevenueCents] + [merchRevenueCents] + [servicesRevenueCents] always
/// equals [revenueCents].
class FinancialTicket {
  const FinancialTicket({
    required this.ticketId,
    required this.number,
    required this.customerName,
    required this.device,
    required this.closedAt,
    required this.revenueCents,
    required this.costCents,
    this.gstCents = 0,
    this.pstCents = 0,
    this.partsRevenueCents = 0,
    this.partsCostCents = 0,
    this.partsQuantity = 0,
    this.merchRevenueCents = 0,
    this.merchCostCents = 0,
    this.merchQuantity = 0,
  });

  final int ticketId;
  final String number;
  final String customerName;
  final String device;
  final DateTime closedAt;
  final int revenueCents;
  final int costCents;

  /// Sales tax snapshotted when the ticket closed. Revenue is pre-tax.
  final int gstCents;
  final int pstCents;

  /// Inventory parts: revenue after their share of the discount, recorded cost
  /// and how many units left the shelf.
  final int partsRevenueCents;
  final int partsCostCents;
  final int partsQuantity;

  /// Checkout merchandise: the same fields, tracked separately from parts.
  final int merchRevenueCents;
  final int merchCostCents;
  final int merchQuantity;

  int get taxCents => gstCents + pstCents;

  int get profitCents => revenueCents - costCents;

  int get partsProfitCents => partsRevenueCents - partsCostCents;

  int get merchProfitCents => merchRevenueCents - merchCostCents;

  /// Services and labour, which carry no recorded cost.
  int get servicesRevenueCents =>
      revenueCents - partsRevenueCents - merchRevenueCents;

  /// Gross margin as a fraction, e.g. `0.42` for 42%.
  double get margin =>
      revenueCents <= 0 ? 0 : profitCents / revenueCents.toDouble();

  double get partsMargin => partsRevenueCents <= 0
      ? 0
      : partsProfitCents / partsRevenueCents.toDouble();

  double get merchMargin => merchRevenueCents <= 0
      ? 0
      : merchProfitCents / merchRevenueCents.toDouble();
}

/// One clock-in / clock-out pair from the staff time clock.
class FinancialShift {
  const FinancialShift({required this.start, this.end});

  final DateTime start;
  final DateTime? end;

  bool get isActive => end == null;

  /// Time worked between [from] and [to], clipped to the shift.
  Duration durationIn(DateTime? from, DateTime to) {
    final windowStart = from == null || start.isAfter(from) ? start : from;
    final finish = end ?? to;
    final windowEnd = finish.isAfter(to) ? to : finish;
    if (!windowEnd.isAfter(windowStart)) return Duration.zero;
    return windowEnd.difference(windowStart);
  }
}

/// A roster member plus every shift recorded under that id.
class FinancialStaff {
  const FinancialStaff({
    required this.id,
    required this.name,
    required this.job,
    required this.isActive,
    required this.hourlyRateCents,
    required this.shifts,
  });

  final String id;
  final String name;
  final String job;
  final bool isActive;
  final int hourlyRateCents;
  final List<FinancialShift> shifts;

  bool get isClockedIn => shifts.any((shift) => shift.isActive);

  Duration trackedIn(DateTime? from, DateTime to) => shifts.fold(
        Duration.zero,
        (total, shift) => total + shift.durationIn(from, to),
      );

  /// Tracked time × hourly pay, rounded to the nearest cent. `null` when the
  /// roster entry has no rate yet.
  int? payCentsFor(Duration duration) {
    if (hourlyRateCents <= 0) return null;
    return (duration.inSeconds * hourlyRateCents / 3600).round();
  }
}

/// Headline money for the rail badge and the Financial header.
///
/// All figures are for closed tickets and tracked shifts. [staffPayCents] only
/// includes roster members with an hourly rate, so the net estimate is a
/// conservative figure until pay is filled in.
class FinancialSummary {
  const FinancialSummary({
    required this.revenueCents,
    required this.costCents,
    required this.staffPayCents,
    required this.tracked,
    required this.ticketCount,
    this.gstCents = 0,
    this.pstCents = 0,
    this.partsRevenueCents = 0,
    this.partsCostCents = 0,
    this.partsQuantity = 0,
    this.merchRevenueCents = 0,
    this.merchCostCents = 0,
    this.merchQuantity = 0,
  });

  final int revenueCents;
  final int costCents;
  final int staffPayCents;
  final Duration tracked;
  final int ticketCount;
  final int gstCents;
  final int pstCents;

  final int partsRevenueCents;
  final int partsCostCents;
  final int partsQuantity;
  final int merchRevenueCents;
  final int merchCostCents;
  final int merchQuantity;

  int get taxCents => gstCents + pstCents;

  int get grossProfitCents => revenueCents - costCents;

  int get netEstimateCents => grossProfitCents - staffPayCents;

  int get partsProfitCents => partsRevenueCents - partsCostCents;

  int get merchProfitCents => merchRevenueCents - merchCostCents;

  /// Services and labour, which carry no recorded cost.
  int get servicesRevenueCents =>
      revenueCents - partsRevenueCents - merchRevenueCents;

  double get partsMargin => partsRevenueCents <= 0
      ? 0
      : partsProfitCents / partsRevenueCents.toDouble();

  double get merchMargin => merchRevenueCents <= 0
      ? 0
      : merchProfitCents / merchRevenueCents.toDouble();
}

/// Reporting window for the Financial tab.
enum FinancialPeriod { allTime, thisMonth, last30Days, thisYear }

extension FinancialPeriodInfo on FinancialPeriod {
  String get label => switch (this) {
        FinancialPeriod.allTime => 'All time',
        FinancialPeriod.thisMonth => 'This month',
        FinancialPeriod.last30Days => 'Last 30 days',
        FinancialPeriod.thisYear => 'This year',
      };

  /// First instant included in the period, or `null` for all time.
  DateTime? startFrom(DateTime now) => switch (this) {
        FinancialPeriod.allTime => null,
        FinancialPeriod.thisMonth => DateTime(now.year, now.month),
        FinancialPeriod.last30Days => now.subtract(const Duration(days: 30)),
        FinancialPeriod.thisYear => DateTime(now.year),
      };

  bool contains(DateTime date, DateTime now) {
    final start = startFrom(now);
    return start == null || !date.isBefore(start);
  }
}

/// Closed-ticket money and staff hours for the Financial tab.
extension FinancialQueries on AppDatabase {
  Stream<List<FinancialTicket>> watchFinancialTickets() {
    final query = select(tickets).join([
      innerJoin(
        customers,
        customers.id.equalsExp(tickets.customerId),
      ),
      leftOuterJoin(
        deviceModels,
        deviceModels.id.equalsExp(tickets.deviceModelId),
      ),
      leftOuterJoin(
        ticketItems,
        ticketItems.ticketId.equalsExp(tickets.id),
      ),
    ])
      ..where(tickets.status.equalsValue(TicketStatus.closed))
      ..orderBy([
        OrderingTerm.desc(tickets.completedAt),
        OrderingTerm.desc(tickets.id),
      ]);

    return query.watch().map((rows) {
      final byTicket = <int, _TicketAccumulator>{};
      for (final row in rows) {
        final ticket = row.readTable(tickets);
        final accumulator = byTicket.putIfAbsent(
          ticket.id,
          () => _TicketAccumulator(
            ticket: ticket,
            customerName: row.readTable(customers).name,
            device: row.readTableOrNull(deviceModels)?.name ??
                ticket.deviceName ??
                'Unlisted device',
          ),
        );
        final item = row.readTableOrNull(ticketItems);
        if (item == null) continue;
        final lineTotalCents = item.quantity * item.unitPriceCents;
        final lineCostCents = item.quantity * (item.unitCostCents ?? 0);
        accumulator.subtotalCents += lineTotalCents;
        accumulator.costCents += lineCostCents;
        if (item.kind == TicketItemKind.part) {
          accumulator.partsSubtotalCents += lineTotalCents;
          accumulator.partsCostCents += lineCostCents;
          accumulator.partsQuantity += item.quantity;
        } else if (item.kind == TicketItemKind.custom &&
            item.unitCostCents != null) {
          // Checkout merchandise is a custom line with a recorded cost;
          // labour lines are custom with no cost.
          accumulator.merchSubtotalCents += lineTotalCents;
          accumulator.merchCostCents += lineCostCents;
          accumulator.merchQuantity += item.quantity;
        }
      }

      final result = [
        for (final accumulator in byTicket.values)
          () {
            final discount = _discountCents(
              subtotalCents: accumulator.subtotalCents,
              kind: accumulator.ticket.invoiceDiscountKind,
              value: accumulator.ticket.invoiceDiscountValue,
            );
            final split = splitDiscountedRevenue(
              partsSubtotalCents: accumulator.partsSubtotalCents,
              merchSubtotalCents: accumulator.merchSubtotalCents,
              servicesSubtotalCents: accumulator.subtotalCents -
                  accumulator.partsSubtotalCents -
                  accumulator.merchSubtotalCents,
              discountCents: discount,
            );
            return FinancialTicket(
              ticketId: accumulator.ticket.id,
              number: accumulator.ticket.number,
              customerName: accumulator.customerName,
              device: accumulator.device,
              closedAt: accumulator.ticket.completedAt ??
                  accumulator.ticket.pickedUpAt ??
                  accumulator.ticket.updatedAt,
              revenueCents: accumulator.subtotalCents - discount,
              costCents: accumulator.costCents,
              gstCents: accumulator.ticket.gstCents,
              pstCents: accumulator.ticket.pstCents,
              partsRevenueCents: split.partsCents,
              partsCostCents: accumulator.partsCostCents,
              partsQuantity: accumulator.partsQuantity,
              merchRevenueCents: split.merchCents,
              merchCostCents: accumulator.merchCostCents,
              merchQuantity: accumulator.merchQuantity,
            );
          }(),
      ]..sort((a, b) => b.closedAt.compareTo(a.closedAt));
      return result;
    });
  }

  Stream<List<FinancialStaff>> watchFinancialStaff() {
    final query = select(settings)
      ..where(
        (row) => row.key.isIn(const ['staff_roster', 'staff_clock_sessions']),
      );
    return query.watch().map((rows) {
      final values = {for (final row in rows) row.key: row.value};
      return buildFinancialStaff(
        rosterJson: values['staff_roster'],
        sessionsJson: values['staff_clock_sessions'],
      );
    });
  }

  /// Revenue, cost and staff pay for every closed ticket.
  ///
  /// The two source queries update independently, so this waits for both and
  /// re-emits whenever either changes.
  Stream<FinancialSummary> watchFinancialSummary() {
    late StreamController<FinancialSummary> controller;
    StreamSubscription<List<FinancialTicket>>? ticketSubscription;
    StreamSubscription<List<FinancialStaff>>? staffSubscription;
    List<FinancialTicket>? tickets;
    List<FinancialStaff>? staff;

    void emit() {
      if (tickets == null || staff == null) return;
      controller.add(
        summarizeFinancials(tickets: tickets!, staff: staff!),
      );
    }

    controller = StreamController<FinancialSummary>(
      onListen: () {
        ticketSubscription = watchFinancialTickets().listen((value) {
          tickets = value;
          emit();
        });
        staffSubscription = watchFinancialStaff().listen((value) {
          staff = value;
          emit();
        });
      },
      onCancel: () async {
        await ticketSubscription?.cancel();
        await staffSubscription?.cancel();
      },
    );
    return controller.stream;
  }
}

/// Adds up closed-ticket money and tracked staff pay for [now].
///
/// Pass [now] in tests; production uses the current clock so an in-progress
/// shift counts up to this moment.
FinancialSummary summarizeFinancials({
  required List<FinancialTicket> tickets,
  required List<FinancialStaff> staff,
  DateTime? now,
}) {
  final cutoff = now ?? DateTime.now();
  final revenue =
      tickets.fold<int>(0, (sum, ticket) => sum + ticket.revenueCents);
  final cost = tickets.fold<int>(0, (sum, ticket) => sum + ticket.costCents);
  final gst = tickets.fold<int>(0, (sum, ticket) => sum + ticket.gstCents);
  final pst = tickets.fold<int>(0, (sum, ticket) => sum + ticket.pstCents);
  final partsRevenue =
      tickets.fold<int>(0, (sum, ticket) => sum + ticket.partsRevenueCents);
  final partsCost =
      tickets.fold<int>(0, (sum, ticket) => sum + ticket.partsCostCents);
  final partsQuantity =
      tickets.fold<int>(0, (sum, ticket) => sum + ticket.partsQuantity);
  final merchRevenue =
      tickets.fold<int>(0, (sum, ticket) => sum + ticket.merchRevenueCents);
  final merchCost =
      tickets.fold<int>(0, (sum, ticket) => sum + ticket.merchCostCents);
  final merchQuantity =
      tickets.fold<int>(0, (sum, ticket) => sum + ticket.merchQuantity);
  var tracked = Duration.zero;
  var staffPay = 0;
  for (final member in staff) {
    final duration = member.trackedIn(null, cutoff);
    tracked += duration;
    staffPay += member.payCentsFor(duration) ?? 0;
  }
  return FinancialSummary(
    revenueCents: revenue,
    costCents: cost,
    staffPayCents: staffPay,
    tracked: tracked,
    ticketCount: tickets.length,
    gstCents: gst,
    pstCents: pst,
    partsRevenueCents: partsRevenue,
    partsCostCents: partsCost,
    partsQuantity: partsQuantity,
    merchRevenueCents: merchRevenue,
    merchCostCents: merchCost,
    merchQuantity: merchQuantity,
  );
}

/// Applies an invoice discount across parts, merchandise and services in
/// proportion to their subtotals and returns the net revenue for each.
///
/// Cents are allocated with the largest subtotal first, so the three results
/// add up to exactly `subtotal − discount` with no lost or invented cent.
({int partsCents, int merchCents, int servicesCents}) splitDiscountedRevenue({
  required int partsSubtotalCents,
  required int merchSubtotalCents,
  required int servicesSubtotalCents,
  required int discountCents,
}) {
  final subtotals = [
    partsSubtotalCents,
    merchSubtotalCents,
    servicesSubtotalCents,
  ];
  final total = subtotals.fold<int>(0, (sum, value) => sum + value);
  if (total <= 0) {
    return (partsCents: 0, merchCents: 0, servicesCents: 0);
  }
  final cappedDiscount = discountCents.clamp(0, total).toInt();
  final cuts = [
    for (final subtotal in subtotals) (cappedDiscount * subtotal) ~/ total,
  ];
  var remainder = cappedDiscount - cuts.fold<int>(0, (sum, cut) => sum + cut);
  final order = [0, 1, 2]..sort((a, b) => subtotals[b].compareTo(subtotals[a]));
  var index = 0;
  while (remainder > 0) {
    final bucket = order[index % order.length];
    if (cuts[bucket] < subtotals[bucket]) {
      cuts[bucket]++;
      remainder--;
    }
    index++;
    if (index > 1000) break;
  }
  return (
    partsCents: partsSubtotalCents - cuts[0],
    merchCents: merchSubtotalCents - cuts[1],
    servicesCents: servicesSubtotalCents - cuts[2],
  );
}

class _TicketAccumulator {
  _TicketAccumulator({
    required this.ticket,
    required this.customerName,
    required this.device,
  });

  final Ticket ticket;
  final String customerName;
  final String device;
  int subtotalCents = 0;
  int costCents = 0;
  int partsSubtotalCents = 0;
  int partsCostCents = 0;
  int partsQuantity = 0;
  int merchSubtotalCents = 0;
  int merchCostCents = 0;
  int merchQuantity = 0;
}

class _StaffAccumulator {
  _StaffAccumulator({
    required this.id,
    required this.name,
    required this.job,
    required this.isActive,
    required this.hourlyRateCents,
  });

  final String id;
  final String name;
  final String job;
  final bool isActive;
  final int hourlyRateCents;
  final List<FinancialShift> shifts = [];
}

/// Reads the roster and time-clock JSON kept in `settings`.
///
/// Missing or malformed entries are skipped rather than crashing the tab; a
/// roster written before pay tracking simply has a zero rate.
List<FinancialStaff> buildFinancialStaff({
  String? rosterJson,
  String? sessionsJson,
}) {
  final byId = <String, _StaffAccumulator>{};

  for (final entry in _decodeList(rosterJson)) {
    final id = entry['id'];
    if (id is! String || id.isEmpty) continue;
    byId[id] = _StaffAccumulator(
      id: id,
      name: entry['name'] as String? ?? 'Staff',
      job: entry['job'] as String? ?? '',
      isActive: entry['isActive'] as bool? ?? true,
      hourlyRateCents: (entry['hourlyRateCents'] as num?)?.toInt() ?? 0,
    );
  }

  for (final entry in _decodeList(sessionsJson)) {
    final staffId = entry['staffId'];
    final clockIn = entry['clockInAt'];
    if (staffId is! String || clockIn is! String) continue;
    final start = DateTime.tryParse(clockIn);
    if (start == null) continue;
    final rawClockOut = entry['clockOutAt'];
    final end = rawClockOut is String ? DateTime.tryParse(rawClockOut) : null;
    final accumulator = byId.putIfAbsent(
      staffId,
      () => _StaffAccumulator(
        id: staffId,
        name: entry['name'] as String? ?? 'Staff',
        job: entry['job'] as String? ?? '',
        isActive: false,
        hourlyRateCents: 0,
      ),
    );
    accumulator.shifts.add(FinancialShift(start: start, end: end));
  }

  return [
    for (final accumulator in byId.values)
      FinancialStaff(
        id: accumulator.id,
        name: accumulator.name,
        job: accumulator.job,
        isActive: accumulator.isActive,
        hourlyRateCents: accumulator.hourlyRateCents,
        shifts: List.unmodifiable(accumulator.shifts),
      ),
  ];
}

List<Map<String, dynamic>> _decodeList(String? json) {
  if (json == null || json.isEmpty) return const [];
  try {
    final decoded = jsonDecode(json);
    if (decoded is! List) return const [];
    return [
      for (final entry in decoded)
        if (entry is Map<String, dynamic>) entry,
    ];
  } on FormatException {
    return const [];
  }
}

int _discountCents({
  required int subtotalCents,
  required InvoiceDiscountKind kind,
  required int value,
}) =>
    switch (kind) {
      InvoiceDiscountKind.none => 0,
      InvoiceDiscountKind.percentage => (subtotalCents * value + 50) ~/ 100,
      InvoiceDiscountKind.fixed =>
        value > subtotalCents ? subtotalCents : value,
    };
