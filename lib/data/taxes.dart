/// One sales tax collected on an invoice.
class TaxLine {
  const TaxLine({
    required this.label,
    required this.rateBp,
    required this.amountCents,
  });

  final String label;

  /// Rate in basis points: `500` is 5.00%, `725` is 7.25%.
  final int rateBp;
  final int amountCents;

  String get rateLabel => formatTaxRate(rateBp);
}

/// GST/PST setup for invoices, stored in the local settings table.
///
/// Rates are kept in basis points (hundredths of a percent) so 7.25% is an
/// exact integer. Missing settings mean both taxes are off; the first-run seed
/// turns GST on at 5% and leaves PST off at 7%.
class TaxConfig {
  const TaxConfig({
    this.gstEnabled = false,
    this.gstRateBp = defaultGstRateBp,
    this.pstEnabled = false,
    this.pstRateBp = defaultPstRateBp,
  });

  static const int defaultGstRateBp = 500;
  static const int defaultPstRateBp = 700;
  static const int maxRateBp = 5000;

  static const String gstEnabledKey = 'tax_gst_enabled';
  static const String gstRateKey = 'tax_gst_rate_bp';
  static const String pstEnabledKey = 'tax_pst_enabled';
  static const String pstRateKey = 'tax_pst_rate_bp';

  static const List<String> settingKeys = [
    gstEnabledKey,
    gstRateKey,
    pstEnabledKey,
    pstRateKey,
  ];

  final bool gstEnabled;
  final int gstRateBp;
  final bool pstEnabled;
  final int pstRateBp;

  bool get isEnabled => gstEnabled || pstEnabled;

  TaxConfig copyWith({
    bool? gstEnabled,
    int? gstRateBp,
    bool? pstEnabled,
    int? pstRateBp,
  }) =>
      TaxConfig(
        gstEnabled: gstEnabled ?? this.gstEnabled,
        gstRateBp: gstRateBp ?? this.gstRateBp,
        pstEnabled: pstEnabled ?? this.pstEnabled,
        pstRateBp: pstRateBp ?? this.pstRateBp,
      );

  /// The taxes to add to [taxableCents], in invoice display order.
  List<TaxLine> linesFor(int taxableCents) => [
        if (gstEnabled)
          TaxLine(
            label: 'GST',
            rateBp: gstRateBp,
            amountCents: taxCents(taxableCents, gstRateBp),
          ),
        if (pstEnabled)
          TaxLine(
            label: 'PST',
            rateBp: pstRateBp,
            amountCents: taxCents(taxableCents, pstRateBp),
          ),
      ];

  int taxCentsFor(int taxableCents) => linesFor(taxableCents).fold(
        0,
        (total, line) => total + line.amountCents,
      );

  int gstCentsFor(int taxableCents) =>
      gstEnabled ? taxCents(taxableCents, gstRateBp) : 0;

  int pstCentsFor(int taxableCents) =>
      pstEnabled ? taxCents(taxableCents, pstRateBp) : 0;

  factory TaxConfig.fromSettings(Map<String, String> values) => TaxConfig(
        gstEnabled: _readBool(values[gstEnabledKey]),
        gstRateBp: _readRate(values[gstRateKey], defaultGstRateBp),
        pstEnabled: _readBool(values[pstEnabledKey]),
        pstRateBp: _readRate(values[pstRateKey], defaultPstRateBp),
      );

  Map<String, String> toSettings() => {
        gstEnabledKey: gstEnabled ? 'true' : 'false',
        gstRateKey: '$gstRateBp',
        pstEnabledKey: pstEnabled ? 'true' : 'false',
        pstRateKey: '$pstRateBp',
      };

  /// Sales tax on [cents], rounded to the nearest cent.
  static int taxCents(int cents, int rateBp) {
    if (cents <= 0 || rateBp <= 0) return 0;
    return (cents * rateBp + 5000) ~/ 10000;
  }

  static bool _readBool(String? value) =>
      value == 'true' || value == '1' || value == 'yes';

  static int _readRate(String? value, int fallback) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null) return fallback;
    return parsed.clamp(0, maxRateBp).toInt();
  }
}

/// `5%`, `7.25%`, `7.05%` — no trailing zeros beyond the needed precision.
String formatTaxRate(int rateBp) {
  final whole = rateBp ~/ 100;
  final fraction = rateBp % 100;
  if (fraction == 0) return '$whole%';
  return '$whole.${fraction.toString().padLeft(2, '0')}%';
}
