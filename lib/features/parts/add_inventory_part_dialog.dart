import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/part_skus.dart';
import '../../data/tickets_repository.dart';

Future<void> showAddInventoryPartDialog(
  BuildContext context, {
  required TicketsRepository repository,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => AddInventoryPartDialog(repository: repository),
  );
}

Future<void> showEditInventoryPartDialog(
  BuildContext context, {
  required TicketsRepository repository,
  required InventoryPart part,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => AddInventoryPartDialog(
      repository: repository,
      part: part,
    ),
  );
}

class AddInventoryPartDialog extends StatefulWidget {
  const AddInventoryPartDialog({
    super.key,
    required this.repository,
    this.part,
  });

  final TicketsRepository repository;
  final InventoryPart? part;

  @override
  State<AddInventoryPartDialog> createState() => _AddInventoryPartDialogState();
}

class _AddInventoryPartDialogState extends State<AddInventoryPartDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skuController = TextEditingController();
  // _vendorIdController no longer used
  final _vendorSkuController = TextEditingController();
  final _categoryController = TextEditingController();
  final _locationController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  final _rawCostController = TextEditingController(text: '0.00');
  final _retailCostController = TextEditingController(text: '0.00');
  final _bulkQuantityController = TextEditingController(text: '1');
  final _bulkTotalController = TextEditingController(text: '0.00');
  final _minimumStockController = TextEditingController(text: '0');
  String? _error;
  bool _saving = false;
  int _markupPercent = 35;
  PartPurchaseType _purchaseType = PartPurchaseType.single;

  @override
  void initState() {
    super.initState();
    unawaited(_loadMarkup());
    final part = widget.part;
    if (part == null) {
      unawaited(_loadSuggestedSku());
      return;
    }
    _nameController.text = part.name;
    _descriptionController.text = part.description ?? '';
    _skuController.text = part.sku ?? '';
    _vendorSkuController.text = part.vendorSku ?? '';
    _categoryController.text = part.category ?? '';
    _locationController.text = part.location ?? '';
    _stockController.text = '${part.inventoryValue}';
    _minimumStockController.text = '${part.reorderLevel}';
    _rawCostController.text = (part.rawCostCents / 100).toStringAsFixed(2);
    _retailCostController.text =
        (part.retailPriceCents / 100).toStringAsFixed(2);
    _purchaseType = part.purchaseType;
    _bulkQuantityController.text = '${part.bulkQuantity}';
    _bulkTotalController.text = (part.bulkTotalCents / 100).toStringAsFixed(2);
  }

  Future<void> _loadMarkup() async {
    try {
      final markup = await widget.repository.getPartsMarkupPercent();
      if (!mounted) return;
      setState(() => _markupPercent = markup);
      if (widget.part == null) _updateRetailCost(_rawCostController.text);
    } catch (_) {}
  }

  /// Shows the code that will be assigned when the part is saved, so the shop
  /// can write it on the bin before saving.
  Future<void> _loadSuggestedSku() async {
    try {
      final sku = await widget.repository.nextPartSku();
      if (!mounted || _skuController.text.trim().isNotEmpty) return;
      setState(() => _skuController.text = sku);
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _skuController.dispose();
    _vendorSkuController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    _stockController.dispose();
    _minimumStockController.dispose();
    _rawCostController.dispose();
    _retailCostController.dispose();
    _bulkQuantityController.dispose();
    _bulkTotalController.dispose();
    super.dispose();
  }

  int? _moneyCents(String text) {
    final normalized = text.trim().replaceAll(',', '').replaceAll('\$', '');
    final amount = double.tryParse(normalized);
    if (amount == null || !amount.isFinite || amount < 0) return null;
    return (amount * 100).round();
  }

  void _updateRetailCost(String rawCost) {
    final cents = _moneyCents(rawCost);
    if (cents == null) return;
    final retailCents = (cents * (100 + _markupPercent) + 50) ~/ 100;
    _retailCostController.value = TextEditingValue(
      text: (retailCents / 100).toStringAsFixed(2),
      selection: TextSelection.collapsed(
        offset: (retailCents / 100).toStringAsFixed(2).length,
      ),
    );
  }

  String _money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

  int? _bulkUnitCents() {
    final quantity = int.tryParse(_bulkQuantityController.text.trim());
    final total = _moneyCents(_bulkTotalController.text);
    if (quantity == null || quantity < 1 || total == null) return null;
    return (total / quantity).round();
  }

  void _recalculateBulkUnitCost() {
    final unit = _bulkUnitCents();
    if (unit == null) return;
    final text = (unit / 100).toStringAsFixed(2);
    _rawCostController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _updateRetailCost(text);
  }

  void _changePurchaseType(PartPurchaseType? type) {
    if (type == null) return;
    setState(() {
      _purchaseType = type;
      if (type == PartPurchaseType.bulk) {
        if (int.tryParse(_bulkQuantityController.text.trim()) == null) {
          _bulkQuantityController.text = '1';
        }
        // Start the lot total at the per-item cost the user already entered.
        _bulkTotalController.text = _rawCostController.text;
        _recalculateBulkUnitCost();
      }
    });
  }

  String _bulkCalculationLabel() {
    final quantity = int.tryParse(_bulkQuantityController.text.trim());
    final total = _moneyCents(_bulkTotalController.text);
    final unit = _bulkUnitCents();
    if (quantity == null || quantity < 1 || total == null || unit == null) {
      return 'Enter a quantity and total purchase cost.';
    }
    return 'Cost per item: ${_money(unit)} '
        '(${_money(total)} ÷ $quantity)';
  }

  Future<void> _save() async {
    final startingStock = int.tryParse(_stockController.text.trim());
    final minimumStock = int.tryParse(_minimumStockController.text.trim()) ?? 0;
    final rawCostCents = _moneyCents(_rawCostController.text);
    final retailCostCents = _moneyCents(_retailCostController.text);
    final isBulk = _purchaseType == PartPurchaseType.bulk;
    final bulkQuantity = int.tryParse(_bulkQuantityController.text.trim());
    final bulkTotalCents = _moneyCents(_bulkTotalController.text);
    final sku = _skuController.text.trim();
    if (_nameController.text.trim().isEmpty ||
        startingStock == null ||
        startingStock < 0 ||
        minimumStock < 0 ||
        rawCostCents == null ||
        retailCostCents == null ||
        (isBulk &&
            (bulkQuantity == null ||
                bulkQuantity < 1 ||
                bulkTotalCents == null))) {
      setState(() => _error =
          'Enter a part name, valid inventory and stock quantities, and non-negative costs.');
      return;
    }
    if (widget.part == null && sku.isNotEmpty && !PartSku.isValid(sku)) {
      setState(
          () => _error = 'Use the 000-000 SKU format, for example 001-003.');
      return;
    }
    final unitCostCents =
        isBulk ? (bulkTotalCents! / bulkQuantity!).round() : rawCostCents;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final part = widget.part;
      if (part == null) {
        await widget.repository.createInventoryPart(
          name: _nameController.text,
          description: _descriptionController.text,
          sku: sku,
          vendorId: null,
          vendorSku: _vendorSkuController.text,
          category: _categoryController.text,
          location: _locationController.text,
          startingStock: startingStock,
          rawCostCents: unitCostCents,
          retailPriceCents: retailCostCents,
          purchaseType: _purchaseType,
          bulkQuantity: isBulk ? bulkQuantity! : 1,
          bulkTotalCents: isBulk ? bulkTotalCents! : 0,
          minimumStock: minimumStock,
        );
      } else {
        await widget.repository.updateInventoryPart(
          partId: part.id,
          name: _nameController.text,
          description: _descriptionController.text,
          sku: sku,
          vendorId: null,
          vendorSku: _vendorSkuController.text,
          category: _categoryController.text,
          location: _locationController.text,
          stock: startingStock,
          rawCostCents: unitCostCents,
          retailPriceCents: retailCostCents,
          purchaseType: _purchaseType,
          bulkQuantity: isBulk ? bulkQuantity! : 1,
          bulkTotalCents: isBulk ? bulkTotalCents! : 0,
          minimumStock: minimumStock,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) setState(() => _error = 'Could not add this part: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.part == null ? 'Add inventory part' : 'Edit inventory part',
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('inventory-part-name'),
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Part name',
                  hintText: 'e.g. USB-C charging port',
                ),
              ),
              TextField(
                key: const Key('inventory-part-description'),
                controller: _descriptionController,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'e.g. Charging port board for Nintendo Switch',
                ),
              ),
              TextField(
                key: const Key('inventory-part-sku'),
                controller: _skuController,
                decoration: const InputDecoration(
                  labelText: 'SKU',
                  hintText: '001-001',
                  helperText:
                      'Shop format 000-000. Leave blank to auto-assign.',
                ),
              ),
              TextField(
                key: const Key('inventory-part-vendor-sku'),
                controller: _vendorSkuController,
                decoration: const InputDecoration(
                  labelText: 'Vendor SKU (optional)',
                  hintText: 'The exact SKU you order',
                ),
              ),
              TextField(
                key: const Key('inventory-part-category'),
                controller: _categoryController,
                decoration:
                    const InputDecoration(labelText: 'Category (optional)'),
              ),
              TextField(
                key: const Key('inventory-part-location'),
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location (optional)',
                  hintText: 'e.g. Bin A3',
                ),
              ),
              DropdownButtonFormField<PartPurchaseType>(
                key: const Key('inventory-part-purchase-type'),
                initialValue: _purchaseType,
                decoration: const InputDecoration(labelText: 'Purchase type'),
                items: PartPurchaseType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      ),
                    )
                    .toList(),
                onChanged: _saving ? null : _changePurchaseType,
              ),
              if (_purchaseType == PartPurchaseType.bulk) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('inventory-part-bulk-quantity'),
                        controller: _bulkQuantityController,
                        enabled: !_saving,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(_recalculateBulkUnitCost),
                        decoration: const InputDecoration(
                          labelText: 'Quantity purchased',
                          hintText: 'e.g. 10',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        key: const Key('inventory-part-bulk-total'),
                        controller: _bulkTotalController,
                        enabled: !_saving,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) => setState(_recalculateBulkUnitCost),
                        decoration: const InputDecoration(
                          labelText: 'Total purchase cost',
                          prefixText: '\$',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _bulkCalculationLabel(),
                    key: const Key('inventory-part-bulk-calculation'),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
              TextField(
                key: const Key('inventory-part-stock'),
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Inventory',
                  helperText: 'On-hand quantity.',
                ),
              ),
              TextField(
                key: const Key('inventory-part-min-stock'),
                controller: _minimumStockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Minimum stock',
                  helperText: 'Minimum stock level for reordering.',
                ),
              ),
              TextField(
                key: const Key('inventory-part-raw-cost'),
                controller: _rawCostController,
                readOnly: _purchaseType == PartPurchaseType.bulk,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: _purchaseType == PartPurchaseType.bulk
                    ? null
                    : _updateRetailCost,
                decoration: InputDecoration(
                  labelText: _purchaseType == PartPurchaseType.bulk
                      ? 'Cost per item'
                      : 'Raw Parts Cost',
                  prefixText: '\$',
                  helperText: _purchaseType == PartPurchaseType.bulk
                      ? 'Calculated from total purchase cost ÷ quantity.'
                      : null,
                ),
              ),
              TextField(
                key: const Key('inventory-part-retail-cost'),
                controller: _retailCostController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Retail Parts Cost',
                  prefixText: '\$',
                  helperText: 'Calculated with $_markupPercent% markup.',
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.part == null ? 'Add part' : 'Save changes'),
        ),
      ],
    );
  }
}
