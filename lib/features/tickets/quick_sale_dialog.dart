import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../payments/card_payment.dart';
import '../../data/tickets_repository.dart';

/// Rings up a direct sale (no device): pick items, take payment, and the sale
/// is recorded as a paid, closed ticket.
Future<void> showQuickSaleDialog(
  BuildContext context, {
  required TicketsRepository repository,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => QuickSaleDialog(repository: repository),
  );
}

class _SaleLine {
  _SaleLine({
    required this.description,
    required this.unitPriceCents,
    this.partId,
  });

  final String description;
  final int unitPriceCents;
  final int? partId;
  int quantity = 1;
}

class QuickSaleDialog extends StatefulWidget {
  const QuickSaleDialog({super.key, required this.repository});

  final TicketsRepository repository;

  @override
  State<QuickSaleDialog> createState() => _QuickSaleDialogState();
}

class _QuickSaleDialogState extends State<QuickSaleDialog> {
  final _customerController = TextEditingController();
  final _customNameController = TextEditingController();
  final _customPriceController = TextEditingController();
  final _lines = <_SaleLine>[];
  List<InventoryPart> _parts = const [];
  PaymentMethod _method = PaymentMethod.card;
  int _markupPercent = 35;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.repository.watchInventoryParts().first.then((parts) {
      if (mounted) setState(() => _parts = parts);
    }).catchError((_) {});
    widget.repository.getPartsMarkupPercent().then((value) {
      if (mounted) setState(() => _markupPercent = value);
    }).catchError((_) {});
  }

  bool _isTube(InventoryPart part) =>
      part.purchaseType == PartPurchaseType.tube;

  int _salePriceCents(InventoryPart part) => _isTube(part)
      ? (part.bulkTotalCents * (100 + _markupPercent) + 50) ~/ 100
      : part.retailPriceCents;

  @override
  void dispose() {
    _customerController.dispose();
    _customNameController.dispose();
    _customPriceController.dispose();
    super.dispose();
  }

  String _money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

  int get _subtotal => _lines.fold(
        0,
        (sum, line) => sum + line.quantity * line.unitPriceCents,
      );

  Iterable<InventoryPart> get _sellable => _parts.where(
        (part) => (part.category ?? '').trim().toLowerCase() != 'labour',
      );

  void _addPart(InventoryPart part) {
    setState(() {
      final existing =
          _lines.where((line) => line.partId == part.id).firstOrNull;
      if (existing != null) {
        existing.quantity++;
      } else {
        _lines.add(_SaleLine(
          description: _isTube(part) ? '${part.name} (full tube)' : part.name,
          unitPriceCents: _salePriceCents(part),
          partId: part.id,
        ));
      }
      _error = null;
    });
  }

  void _addCustom() {
    final name = _customNameController.text.trim();
    final price = double.tryParse(
      _customPriceController.text.trim().replaceAll('\$', ''),
    );
    if (name.isEmpty || price == null || !price.isFinite || price < 0) {
      setState(() => _error = 'Enter an item name and a valid price.');
      return;
    }
    setState(() {
      _lines.add(_SaleLine(
        description: name,
        unitPriceCents: (price * 100).round(),
      ));
      _customNameController.clear();
      _customPriceController.clear();
      _error = null;
    });
  }

  Future<void> _complete() async {
    if (_lines.isEmpty) {
      setState(() => _error = 'Add at least one item to the sale.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final processor = await widget.repository.paymentProcessor();
      if (!mounted) return;
      await widget.repository.createQuickSale(
        authorizePayment: (due) => authorizeCardPayment(
          context,
          processor: processor,
          method: _method,
          amountCents: due,
          reference: 'QuickSale${DateTime.now().millisecondsSinceEpoch}',
        ),
        customerName: _customerController.text,
        parts: [
          for (final line in _lines)
            if (line.partId != null)
              (partId: line.partId!, quantity: line.quantity),
        ],
        customLines: [
          for (final line in _lines)
            if (line.partId == null)
              (
                description: line.description,
                quantity: line.quantity,
                unitPriceCents: line.unitPriceCents,
              ),
        ],
        method: _method,
      );
      if (mounted) Navigator.of(context).pop();
    } on PaymentCancelledException {
      if (mounted) setState(() => _saving = false);
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not complete the sale: $error';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Quick Sale'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                key: const Key('quick-sale-customer'),
                controller: _customerController,
                decoration: const InputDecoration(
                  labelText: 'Customer (optional)',
                ),
              ),
              const SizedBox(height: 12),
              Autocomplete<InventoryPart>(
                key: const Key('quick-sale-item-search'),
                displayStringForOption: (part) => part.name,
                optionsBuilder: (value) {
                  final query = value.text.trim().toLowerCase();
                  if (query.isEmpty) {
                    return const Iterable<InventoryPart>.empty();
                  }
                  return _sellable.where((part) =>
                      part.name.toLowerCase().contains(query) ||
                      (part.sku ?? '').toLowerCase().contains(query));
                },
                onSelected: _addPart,
                fieldViewBuilder: (context, controller, focusNode, _) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Add inventory item',
                      hintText: 'Search by name or SKU',
                      prefixIcon: Icon(Icons.search),
                    ),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) => Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxHeight: 220, maxWidth: 460),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          for (final part in options)
                            ListTile(
                              dense: true,
                              title: Text(part.name),
                              subtitle: Text(
                                _isTube(part)
                                    ? '${part.sku ?? ''} · ${part.fullTubes} full tubes · sold whole'
                                    : '${part.sku ?? ''} · ${part.stock} in stock',
                              ),
                              trailing: Text(_money(_salePriceCents(part))),
                              onTap: () => onSelected(part),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      key: const Key('quick-sale-custom-name'),
                      controller: _customNameController,
                      decoration: const InputDecoration(
                        labelText: 'Other item',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      key: const Key('quick-sale-custom-price'),
                      controller: _customPriceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        prefixText: '\$',
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Add other item',
                    onPressed: _addCustom,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_lines.isEmpty)
                Text('No items yet.', style: theme.textTheme.bodySmall)
              else
                for (final line in _lines)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(line.description),
                    subtitle: Text(
                      '${line.quantity} × ${_money(line.unitPriceCents)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Fewer',
                          onPressed: line.quantity > 1
                              ? () => setState(() => line.quantity--)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('${line.quantity}'),
                        IconButton(
                          tooltip: 'More',
                          onPressed: () => setState(() => line.quantity++),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                        SizedBox(
                          width: 72,
                          child: Text(
                            _money(line.quantity * line.unitPriceCents),
                            textAlign: TextAlign.end,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Remove ${line.description}',
                          onPressed: () => setState(() => _lines.remove(line)),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
              const Divider(),
              Text(
                'Subtotal ${_money(_subtotal)} (tax added at payment)',
                key: const Key('quick-sale-subtotal'),
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<PaymentMethod>(
                key: const Key('quick-sale-method'),
                initialValue: _method,
                decoration: const InputDecoration(labelText: 'Payment method'),
                items: const [
                  DropdownMenuItem(
                      value: PaymentMethod.cash, child: Text('Cash')),
                  DropdownMenuItem(
                      value: PaymentMethod.card, child: Text('Card')),
                  DropdownMenuItem(
                      value: PaymentMethod.other, child: Text('Other')),
                  DropdownMenuItem(
                      value: PaymentMethod.eTransfer,
                      child: Text('E-transfer')),
                ],
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _method = value ?? _method),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(color: theme.colorScheme.error),
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
          key: const Key('quick-sale-complete'),
          onPressed: _saving ? null : _complete,
          child: const Text('Complete sale'),
        ),
      ],
    );
  }
}
