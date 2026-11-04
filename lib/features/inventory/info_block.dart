import 'package:flutter/material.dart';

/// A coloured box that makes one inventory detail stand out.
class InfoBlock extends StatelessWidget {
  const InfoBlock({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        border: Border.all(color: color.withValues(alpha: .6), width: 1.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
            TextSpan(
              text: value,
              style: TextStyle(color: color, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}

/// The SKU, vendor, vendor SKU and cost boxes for one inventory row. A box
/// with nothing in it (no SKU, vendor, vendor SKU or a $0.00 amount) is left
/// out. Keys are `<keyPrefix>-sku-<id>`, `-vendor-`, `-vendor-sku-`,
/// `-raw-cost-` and `-retail-cost-`.
class InventoryInfoBlocks extends StatelessWidget {
  const InventoryInfoBlocks({
    super.key,
    required this.keyPrefix,
    required this.id,
    this.sku,
    this.vendor,
    this.vendorSku,
    required this.costLabel,
    required this.costCents,
    required this.retailLabel,
    required this.retailCents,
  });

  final String keyPrefix;
  final int id;
  final String? sku;
  final String? vendor;
  final String? vendorSku;
  final String costLabel;
  final int costCents;
  final String retailLabel;
  final int retailCents;

  static bool _has(String? value) => value != null && value.trim().isNotEmpty;

  static String _money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        if (_has(sku))
          InfoBlock(
            key: Key('$keyPrefix-sku-$id'),
            label: 'SKU',
            value: sku!.trim(),
            color: const Color(0xFF1565C0),
          ),
        if (_has(vendor))
          InfoBlock(
            key: Key('$keyPrefix-vendor-$id'),
            label: 'Vendor',
            value: vendor!.trim(),
            color: const Color(0xFF6A1B9A),
          ),
        if (_has(vendorSku))
          InfoBlock(
            key: Key('$keyPrefix-vendor-sku-$id'),
            label: 'Vendor SKU',
            value: vendorSku!.trim(),
            color: const Color(0xFF00838F),
          ),
        if (costCents > 0)
          InfoBlock(
            key: Key('$keyPrefix-raw-cost-$id'),
            label: costLabel,
            value: _money(costCents),
            color: const Color(0xFFE65100),
          ),
        if (retailCents > 0)
          InfoBlock(
            key: Key('$keyPrefix-retail-cost-$id'),
            label: retailLabel,
            value: _money(retailCents),
            color: const Color(0xFF2E7D32),
          ),
      ],
    );
  }
}
