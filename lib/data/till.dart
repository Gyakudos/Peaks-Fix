import 'dart:convert';

import 'package:drift/drift.dart';

import 'database.dart';

/// A coin or bill the till is counted in.
class TillDenomination {
  const TillDenomination(this.label, this.cents, {this.isBill = false});

  final String label;
  final int cents;
  final bool isBill;
}

const tillCoins = [
  TillDenomination('Nickels (5¢)', 5),
  TillDenomination('Dimes (10¢)', 10),
  TillDenomination('Quarters (25¢)', 25),
  TillDenomination('Loonies (\$1)', 100),
  TillDenomination('Toonies (\$2)', 200),
];

const tillBills = [
  TillDenomination('\$5 bills', 500, isBill: true),
  TillDenomination('\$10 bills', 1000, isBill: true),
  TillDenomination('\$20 bills', 2000, isBill: true),
  TillDenomination('\$50 bills', 5000, isBill: true),
  TillDenomination('\$100 bills', 10000, isBill: true),
];

/// Total value of a count, keyed by denomination cents.
int tallyCents(Map<int, int> counts) =>
    counts.entries.fold(0, (sum, e) => sum + e.key * e.value);

String tillMoney(int cents) {
  final sign = cents < 0 ? '-' : '';
  return '$sign\$${(cents.abs() / 100).toStringAsFixed(2)}';
}

/// Money taken since the last close, net of refunds, by payment method.
class TillTakings {
  const TillTakings({
    this.cashCents = 0,
    this.cardCents = 0,
    this.eTransferCents = 0,
    this.otherCents = 0,
  });

  final int cashCents;
  final int cardCents;
  final int eTransferCents;
  final int otherCents;

  int get totalCents => cashCents + cardCents + eTransferCents + otherCents;

  Map<String, Object?> toJson() => {
        'cash': cashCents,
        'card': cardCents,
        'eTransfer': eTransferCents,
        'other': otherCents,
      };

  static TillTakings fromJson(Map<String, Object?> json) => TillTakings(
        cashCents: (json['cash'] as num?)?.toInt() ?? 0,
        cardCents: (json['card'] as num?)?.toInt() ?? 0,
        eTransferCents: (json['eTransfer'] as num?)?.toInt() ?? 0,
        otherCents: (json['other'] as num?)?.toInt() ?? 0,
      );
}

TillTakings summarizeTakings(Iterable<Payment> payments) {
  var cash = 0, card = 0, eTransfer = 0, other = 0;
  for (final payment in payments) {
    final amount = payment.kind == PaymentKind.refund
        ? -payment.amountCents
        : payment.amountCents;
    switch (payment.method) {
      case PaymentMethod.cash:
        cash += amount;
      case PaymentMethod.card:
        card += amount;
      case PaymentMethod.eTransfer:
        eTransfer += amount;
      case PaymentMethod.other:
        other += amount;
    }
  }
  return TillTakings(
    cashCents: cash,
    cardCents: card,
    eTransferCents: eTransfer,
    otherCents: other,
  );
}

enum TillEventType { open, close }

/// One "Open Day" or "Close Day" in the till log.
class TillEvent {
  const TillEvent({
    required this.type,
    required this.at,
    required this.by,
    required this.counts,
    required this.expectedCents,
    this.depositCents = 0,
    this.takings = const TillTakings(),
    this.note = '',
  });

  final TillEventType type;
  final DateTime at;
  final String by;
  final Map<int, int> counts;

  /// What the till should have held: last night's float (plus cash sales when
  /// closing).
  final int expectedCents;
  final int depositCents;
  final TillTakings takings;
  final String note;

  int get countedCents => tallyCents(counts);
  int get varianceCents => countedCents - expectedCents;

  /// Cash left in the till after this event.
  int get keptCents =>
      type == TillEventType.close ? countedCents - depositCents : countedCents;

  Map<String, Object?> toJson() => {
        'type': type.name,
        'at': at.toIso8601String(),
        'by': by,
        'counts': {for (final e in counts.entries) '${e.key}': e.value},
        'expected': expectedCents,
        'deposit': depositCents,
        'takings': takings.toJson(),
        'note': note,
      };

  static TillEvent fromJson(Map<String, Object?> json) => TillEvent(
        type: json['type'] == 'open' ? TillEventType.open : TillEventType.close,
        at: DateTime.parse(json['at'] as String),
        by: json['by'] as String? ?? '',
        counts: {
          for (final e in ((json['counts'] as Map?) ?? const {}).entries)
            int.parse('${e.key}'): (e.value as num).toInt(),
        },
        expectedCents: (json['expected'] as num?)?.toInt() ?? 0,
        depositCents: (json['deposit'] as num?)?.toInt() ?? 0,
        takings: TillTakings.fromJson(
          ((json['takings'] as Map?) ?? const {}).cast<String, Object?>(),
        ),
        note: json['note'] as String? ?? '',
      );
}

const _tillLogKey = 'till_log';

/// Newest first.
Future<List<TillEvent>> loadTillLog(AppDatabase database) async {
  try {
    final decoded = jsonDecode(await database.readSetting(_tillLogKey, '[]'));
    final events = [
      for (final item in decoded as List<dynamic>)
        TillEvent.fromJson((item as Map).cast<String, Object?>()),
    ];
    events.sort((a, b) => b.at.compareTo(a.at));
    return events;
  } catch (_) {
    return const [];
  }
}

Future<void> addTillEvent(AppDatabase database, TillEvent event) async {
  final log = await loadTillLog(database);
  await database.writeSetting(
    _tillLogKey,
    jsonEncode([
      for (final e in [event, ...log]) e.toJson()
    ]),
  );
}

/// Cash left in the till by the last close (or the last count at open).
int expectedOpeningCents(List<TillEvent> log) =>
    log.isEmpty ? 0 : log.first.keptCents;

/// Ends every shift that is still running, and returns how many were ended.
Future<int> clockOutAllStaff(AppDatabase database, {DateTime? at}) async {
  const key = 'staff_clock_sessions';
  final decoded = jsonDecode(await database.readSetting(key, '[]'));
  final stamp = (at ?? DateTime.now()).toIso8601String();
  var ended = 0;
  final sessions = [
    for (final item in decoded as List<dynamic>)
      if ((item as Map)['clockOutAt'] == null)
        {...item.cast<String, Object?>(), 'clockOutAt': stamp}
      else
        item,
  ];
  for (final item in decoded) {
    if ((item as Map)['clockOutAt'] == null) ended++;
  }
  if (ended > 0) await database.writeSetting(key, jsonEncode(sessions));
  return ended;
}

/// Payments recorded since the last close, or since midnight with no close.
Future<TillTakings> loadTakingsSinceClose(
  AppDatabase database,
  List<TillEvent> log, {
  DateTime? now,
}) async {
  final lastClose = log
      .where((e) => e.type == TillEventType.close)
      .map((e) => e.at)
      .fold<DateTime?>(null, (a, b) => a == null || b.isAfter(a) ? b : a);
  final current = now ?? DateTime.now();
  final since = lastClose ?? DateTime(current.year, current.month, current.day);
  final rows = await (database.select(database.payments)
        ..where((p) => p.at.isBiggerThanValue(since)))
      .get();
  return summarizeTakings(rows);
}
