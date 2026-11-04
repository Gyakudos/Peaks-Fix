import 'package:flutter/material.dart';

import '../../data/tickets_repository.dart';

/// Lets Front Desk correct the on-hand quantity without editing anything
/// else about the part.
Future<void> showAdjustStockDialog(
  BuildContext context, {
  required TicketsRepository repository,
  required InventoryPart part,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _AdjustStockDialog(repository: repository, part: part),
  );
}

class _AdjustStockDialog extends StatefulWidget {
  const _AdjustStockDialog({required this.repository, required this.part});

  final TicketsRepository repository;
  final InventoryPart part;

  @override
  State<_AdjustStockDialog> createState() => _AdjustStockDialogState();
}

class _AdjustStockDialogState extends State<_AdjustStockDialog> {
  late final _quantity = TextEditingController(text: '${widget.part.stock}');
  String? _error;

  @override
  void dispose() {
    _quantity.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final stock = int.tryParse(_quantity.text.trim());
    if (stock == null || stock < 0) {
      setState(() => _error = 'Enter a quantity of 0 or more.');
      return;
    }
    final part = widget.part;
    await widget.repository.updateInventoryPart(
      partId: part.id,
      name: part.name,
      description: part.description,
      sku: part.sku,
      vendorId: part.vendorId,
      vendorSku: part.vendorSku,
      category: part.category,
      location: part.location,
      stock: stock,
      rawCostCents: part.rawCostCents,
      retailPriceCents: part.retailPriceCents,
      purchaseType: part.purchaseType,
      bulkQuantity: part.bulkQuantity,
      bulkTotalCents: part.bulkTotalCents,
      minimumStock: part.minimumStock,
      chargeShopSupply: part.chargeShopSupply,
      brand: part.brand,
      jobLevel: part.jobLevel,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Adjust ${widget.part.name}'),
      content: TextField(
        key: const Key('adjust-stock-quantity'),
        controller: _quantity,
        keyboardType: TextInputType.number,
        autofocus: true,
        decoration: InputDecoration(
          labelText: 'Quantity on hand',
          errorText: _error,
        ),
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('adjust-stock-save'),
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
