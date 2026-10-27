/// Helpers for the shop's `NNN-NNN` inventory part SKU format.
///
/// Generated SKUs count up from `001-001` so they are easy to read out over the
/// counter. SKUs the shop entered by hand are never rewritten, even when they
/// do not follow the format.
class PartSku {
  PartSku._();

  /// The first SKU handed out when the inventory has no formatted SKUs yet.
  static const int firstSequence = 1001; // 001-001

  static final RegExp _pattern = RegExp(r'^(\d{3})-(\d{3})$');

  /// Whether [value] is exactly `NNN-NNN`.
  static bool isValid(String? value) => parse(value) != null;

  /// Returns the sequence encoded in [value], or null when it is not
  /// `NNN-NNN`.
  static int? parse(String? value) {
    if (value == null) return null;
    final match = _pattern.firstMatch(value.trim());
    if (match == null) return null;
    return int.parse(match.group(1)!) * 1000 + int.parse(match.group(2)!);
  }

  /// Formats [sequence] as `NNN-NNN`.
  static String format(int sequence) {
    if (sequence < 0 || sequence > 999999) {
      throw ArgumentError.value(
        sequence,
        'sequence',
        'must be between 0 and 999999',
      );
    }
    final first = (sequence ~/ 1000).toString().padLeft(3, '0');
    final second = (sequence % 1000).toString().padLeft(3, '0');
    return '$first-$second';
  }

  /// The highest sequence among [skus], or 0 when none follow the format.
  static int highestSequence(Iterable<String?> skus) {
    var highest = 0;
    for (final sku in skus) {
      final sequence = parse(sku);
      if (sequence != null && sequence > highest) highest = sequence;
    }
    return highest;
  }

  /// The next free SKU after every formatted value in [skus].
  ///
  /// Starts at `001-001`, then `001-002` … `001-999`, `002-000`, and so on.
  static String next(Iterable<String?> skus) {
    final highest = highestSequence(skus);
    final sequence = highest < firstSequence ? firstSequence : highest + 1;
    return format(sequence);
  }
}
