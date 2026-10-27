/// Shop-wide warranty fallbacks and the Report 3 warranty block.
///
/// The shop default lives in Settings (`warranty_days` / `warranty_terms`), and
/// each device category can override the length. A ticket's Report 3 copies the
/// effective length and terms onto the report when it is completed, so later
/// changes to the catalog or shop defaults never rewrite an issued warranty.
class WarrantyConfig {
  const WarrantyConfig._();

  static const int defaultDays = 90;
  static const int maxDays = 3650;
  static const String daysKey = 'warranty_days';
  static const String termsKey = 'warranty_terms';

  static const String defaultTerms =
      'Covers the work and parts listed on this report for the period '
      'shown. Excludes accidental or liquid damage, tampering or '
      'repairs by anyone else, normal wear, software or account '
      'problems, and data loss. The shop tag must still be on the '
      'device.';

  static String daysLabel(int days) => '$days ${days == 1 ? 'day' : 'days'}';

  /// Expiry as a date, so a printed report reads "until 12 Jan 2027" rather
  /// than only "90 days".
  static DateTime expiryFor(DateTime startAt, int days) =>
      DateTime(startAt.year, startAt.month, startAt.day + days);

  /// Returns [days] when it is a usable warranty length.
  static int requireDays(int days) {
    if (days < 1 || days > maxDays) {
      throw ArgumentError.value(
        days,
        'days',
        'Warranty period must be between 1 and $maxDays days.',
      );
    }
    return days;
  }
}

/// A warranty issued with a completed repair, e.g. for a saved customer device.
class DeviceWarranty {
  const DeviceWarranty({
    required this.startAt,
    required this.days,
    this.terms,
  });

  final DateTime startAt;
  final int days;
  final String? terms;

  DateTime get expiresAt => WarrantyConfig.expiryFor(startAt, days);

  bool isActiveAt(DateTime time) => !time.isAfter(expiresAt);
}

/// The Report 3 warranty block, with the device-category/shop defaults already
/// resolved when the report has not frozen its own values yet.
class ClientReportWarranty {
  const ClientReportWarranty({
    required this.defaultDays,
    required this.defaultTerms,
    this.days,
    this.terms,
    this.startAt,
    this.categoryName,
  });

  final int defaultDays;
  final String defaultTerms;

  /// Frozen length once Report 3 is completed; otherwise null means "use the
  /// category or shop default".
  final int? days;
  final String? terms;

  /// Stamped when Report 3 is completed, cleared again if it is reopened.
  final DateTime? startAt;

  /// Device category that supplied [defaultDays], when the ticket has one.
  final String? categoryName;

  int get effectiveDays => days ?? defaultDays;

  String get effectiveTerms {
    final value = terms?.trim();
    return value == null || value.isEmpty ? defaultTerms : value;
  }

  DateTime? get expiresAt => startAt == null
      ? null
      : WarrantyConfig.expiryFor(startAt!, effectiveDays);

  bool get isRecorded => startAt != null;

  String? get defaultLabel {
    final category = categoryName;
    return category == null
        ? 'Shop default: ${WarrantyConfig.daysLabel(defaultDays)}'
        : '$category default: ${WarrantyConfig.daysLabel(defaultDays)}';
  }
}
