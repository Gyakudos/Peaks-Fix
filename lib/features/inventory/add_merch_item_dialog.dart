import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/part_skus.dart';
import '../../data/tickets_repository.dart';

Future<void> showAddMerchItemDialog(
  BuildContext context, {
  required TicketsRepository repository,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => AddMerchItemDialog(repository: repository),
  );
}

Future<void> showEditMerchItemDialog(
  BuildContext context, {
  required TicketsRepository repository,
  required InventoryMerchItem item,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => AddMerchItemDialog(
      repository: repository,
      item: item,
    ),
  );
}

class AddMerchItemDialog extends StatefulWidget {
  const AddMerchItemDialog({
    super.key,
    required this.repository,
    this.item,
  });

  final TicketsRepository repository;
  final InventoryMerchItem? item;

  @override
  State<AddMerchItemDialog> createState() => _AddMerchItemDialogState();
}

class _AddMerchItemDialogState extends State<AddMerchItemDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skuController = TextEditingController();
  final _categoryController = TextEditingController();
  final _locationController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  final _costController = TextEditingController(text: '0.00');
  final _priceController = TextEditingController(text: '0.00');
  String? _error;
  bool _saving = false;
  int _markupPercent = 45;

  @override
  void initState() {
    super.initState();
    unawaited(_loadMarkup());
    final item = widget.item;
    if (item == null) {
      unawaited(_loadSuggestedSku());
      return;
    }
    _nameController.text = item.name;
    _descriptionController.text = item.description ?? '';
    _skuController.text = item.sku ?? '';
    _categoryController.text = item.category ?? '';
    _locationController.text = item.location ?? '';
    _stockController.text = '${item.stock}';
    _costController.text = (item.costCents / 100).toStringAsFixed(2);
    _priceController.text = (item.priceCents / 100).toStringAsFixed(2);
  }

  Future<void> _loadMarkup() async {
    try {
      final markup = await widget.repository.getMerchMarkupPercent();
      if (!mounted) return;
      setState(() => _markupPercent = markup);
      if (widget.item == null) _updatePrice(_costController.text);
    } catch (_) {}
  }

  /// Shows the code that will be assigned when the item is saved, so the shop
  /// can write it on the tag or shelf before saving.
  Future<void> _loadSuggestedSku() async {
    try {
      final sku = await widget.repository.nextMerchSku();
      if (!mounted || _skuController.text.trim().isNotEmpty) return;
      setState(() => _skuController.text = sku);
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _skuController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    _stockController.dispose();
    _costController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  int? _moneyCents(String text) {
    final normalized = text.trim().replaceAll(',', '').replaceAll('\$', '');
    final amount = double.tryParse(normalized);
    if (amount == null || !amount.isFinite || amount < 0) return null;
    return (amount * 100).round();
  }

  void _updatePrice(String costText) {
    final cents = _moneyCents(costText);
    if (cents == null) return;
    final priceCents = (cents * (100 + _markupPercent) + 50) ~/ 100;
    final text = (priceCents / 100).toStringAsFixed(2);
    _priceController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  Future<void> _save() async {
    final stock = int.tryParse(_stockController.text.trim());
    final costCents = _moneyCents(_costController.text);
    final priceCents = _moneyCents(_priceController.text);
    final sku = _skuController.text.trim();
    if (_nameController.text.trim().isEmpty ||
        stock == null ||
        stock < 0 ||
        costCents == null ||
        priceCents == null) {
      setState(() => _error =
          'Enter an item name, valid stock quantity, and non-negative costs.');
      return;
    }
    if (widget.item == null && sku.isNotEmpty && !PartSku.isValid(sku)) {
      setState(
          () => _error = 'Use the 000-000 SKU format, for example 001-003.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final item = widget.item;
      if (item == null) {
        await widget.repository.createMerchItem(
          name: _nameController.text,
          description: _descriptionController.text,
          sku: sku,
          category: _categoryController.text,
          location: _locationController.text,
          startingStock: stock,
          costCents: costCents,
          priceCents: priceCents,
        );
      } else {
        await widget.repository.updateMerchItem(
          itemId: item.id,
          name: _nameController.text,
          description: _descriptionController.text,
          sku: sku,
          category: _categoryController.text,
          location: _locationController.text,
          stock: stock,
          costCents: costCents,
          priceCents: priceCents,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Could not save this merchandise: $error');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.item == null ? 'Add merchandise' : 'Edit merchandise',
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('merch-item-name'),
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Item name',
                  hintText: 'e.g. Peaks Fix T-shirt',
                ),
              ),
              TextField(
                key: const Key('merch-item-description'),
                controller: _descriptionController,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'e.g. Black cotton shirt, front logo',
                ),
              ),
              TextField(
                key: const Key('merch-item-sku'),
                controller: _skuController,
                decoration: const InputDecoration(
                  labelText: 'SKU',
                  hintText: '001-001',
                  helperText:
                      'Shop format 000-000. Leave blank to auto-assign.',
                ),
              ),
              TextField(
                key: const Key('merch-item-category'),
                controller: _categoryController,
                decoration:
                    const InputDecoration(labelText: 'Category (optional)'),
              ),
              TextField(
                key: const Key('merch-item-location'),
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location (optional)',
                  hintText: 'e.g. Shelf B2',
                ),
              ),
              TextField(
                key: const Key('merch-item-stock'),
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText:
                      widget.item == null ? 'Starting stock' : 'Stock quantity',
                ),
              ),
              TextField(
                key: const Key('merch-item-cost'),
                controller: _costController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: _updatePrice,
                decoration: const InputDecoration(
                  labelText: 'Cost per item',
                  prefixText: '\$',
                ),
              ),
              TextField(
                key: const Key('merch-item-price'),
                controller: _priceController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Retail price',
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
          key: const Key('merch-item-save'),
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.item == null ? 'Add item' : 'Save changes'),
        ),
      ],
    );
  }
}
