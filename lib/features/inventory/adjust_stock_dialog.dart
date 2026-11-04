import 'package:flutter/material.dart';

import '../../data/tickets_repository.dart';

/// Lets Front Desk correct the on-hand quantity without editing anything
/// else about the item. [onSave] stores the new quantity.
Future<void> showAdjustStockDialog(
  BuildContext context, {
  required String name,
  required int stock,
  required Future<void> Function(int stock) onSave,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) =>
        _AdjustStockDialog(name: name, stock: stock, onSave: onSave),
  );
}

/// Saves a new quantity for a part or shop supply, keeping all other fields.
Future<void> saveInventoryPartStock(
  TicketsRepository repository,
  InventoryPart part,
  int stock,
) =>
    repository.updateInventoryPart(
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

/// Saves a new quantity for a merch item, keeping all other fields.
Future<void> saveMerchItemStock(
  TicketsRepository repository,
  InventoryMerchItem item,
  int stock,
) =>
    repository.updateMerchItem(
      itemId: item.id,
      name: item.name,
      description: item.description,
      sku: item.sku,
      category: item.category,
      location: item.location,
      stock: stock,
      costCents: item.costCents,
      priceCents: item.priceCents,
    );

class _AdjustStockDialog extends StatefulWidget {
  const _AdjustStockDialog({
    required this.name,
    required this.stock,
    required this.onSave,
  });

  final String name;
  final int stock;
  final Future<void> Function(int stock) onSave;

  @override
  State<_AdjustStockDialog> createState() => _AdjustStockDialogState();
}

class _AdjustStockDialogState extends State<_AdjustStockDialog> {
  late final _quantity = TextEditingController(text: '${widget.stock}');
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
    await widget.onSave(stock);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Adjust ${widget.name}'),
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
