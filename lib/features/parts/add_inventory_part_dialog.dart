import 'dart:async';

import 'package:flutter/material.dart';

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
  final _skuController = TextEditingController();
  final _categoryController = TextEditingController();
  final _locationController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  final _rawCostController = TextEditingController(text: '0.00');
  final _retailCostController = TextEditingController(text: '0.00');
  String? _error;
  bool _saving = false;
  int _markupPercent = 35;

  @override
  void initState() {
    super.initState();
    unawaited(_loadMarkup());
    final part = widget.part;
    if (part == null) return;
    _nameController.text = part.name;
    _skuController.text = part.sku ?? '';
    _categoryController.text = part.category ?? '';
    _locationController.text = part.location ?? '';
    _stockController.text = '${part.stock}';
    _rawCostController.text = (part.rawCostCents / 100).toStringAsFixed(2);
    _retailCostController.text =
        (part.retailPriceCents / 100).toStringAsFixed(2);
  }

  Future<void> _loadMarkup() async {
    try {
      final markup = await widget.repository.getPartsMarkupPercent();
      if (!mounted) return;
      setState(() => _markupPercent = markup);
      if (widget.part == null) _updateRetailCost(_rawCostController.text);
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    _stockController.dispose();
    _rawCostController.dispose();
    _retailCostController.dispose();
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

  Future<void> _save() async {
    final startingStock = int.tryParse(_stockController.text.trim());
    final rawCostCents = _moneyCents(_rawCostController.text);
    final retailCostCents = _moneyCents(_retailCostController.text);
    if (_nameController.text.trim().isEmpty ||
        startingStock == null ||
        startingStock < 0 ||
        rawCostCents == null ||
        retailCostCents == null) {
      setState(() => _error =
          'Enter a part name, valid stock quantity, and non-negative costs.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final part = widget.part;
      if (part == null) {
        await widget.repository.createInventoryPart(
          name: _nameController.text,
          sku: _skuController.text,
          category: _categoryController.text,
          location: _locationController.text,
          startingStock: startingStock,
          rawCostCents: rawCostCents,
          retailPriceCents: retailCostCents,
        );
      } else {
        await widget.repository.updateInventoryPart(
          partId: part.id,
          name: _nameController.text,
          sku: _skuController.text,
          category: _categoryController.text,
          location: _locationController.text,
          stock: startingStock,
          rawCostCents: rawCostCents,
          retailPriceCents: retailCostCents,
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
                key: const Key('inventory-part-sku'),
                controller: _skuController,
                decoration: const InputDecoration(labelText: 'SKU (optional)'),
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
              TextField(
                key: const Key('inventory-part-stock'),
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText:
                      widget.part == null ? 'Starting stock' : 'Stock quantity',
                ),
              ),
              TextField(
                key: const Key('inventory-part-raw-cost'),
                controller: _rawCostController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: _updateRetailCost,
                decoration: const InputDecoration(
                  labelText: 'Raw Parts Cost',
                  prefixText: '\$',
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
