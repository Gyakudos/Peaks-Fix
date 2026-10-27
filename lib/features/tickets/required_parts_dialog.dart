import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/tickets_repository.dart';
import '../parts/add_inventory_part_dialog.dart';

/// Label shown in the Parts Invoice picker.
///
/// The menu's filter matches this text, so it contains both the SKU and the
/// part name.
String partPickerLabel(InventoryPart part) {
  final sku = part.sku?.trim();
  return [
    if (sku != null && sku.isNotEmpty) sku,
    part.name,
    'stock ${part.stock}',
  ].join(' · ');
}

/// Whether [part] matches the text typed into the Parts Invoice picker.
bool partMatchesQuery(InventoryPart part, String query) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) return true;
  return [
    part.sku ?? '',
    part.name,
    part.description ?? '',
  ].any((value) => value.toLowerCase().contains(needle));
}

Future<void> showRequiredPartsDialog(
  BuildContext context, {
  required TicketsRepository repository,
  required int ticketId,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => RequiredPartsDialog(
      repository: repository,
      ticketId: ticketId,
    ),
  );
}

class RequiredPartsDialog extends StatefulWidget {
  const RequiredPartsDialog({
    super.key,
    required this.repository,
    required this.ticketId,
  });

  final TicketsRepository repository;
  final int ticketId;

  @override
  State<RequiredPartsDialog> createState() => _RequiredPartsDialogState();
}

class _RequiredPartsDialogState extends State<RequiredPartsDialog> {
  final _quantityController = TextEditingController(text: '1');
  int? _selectedPartId;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _addPart() async {
    final partId = _selectedPartId;
    final quantity = int.tryParse(_quantityController.text.trim());
    if (partId == null || quantity == null || quantity < 1) {
      setState(
          () => _error = 'Select a part and enter a quantity of 1 or more.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.repository.addRequiredPart(
        ticketId: widget.ticketId,
        partId: partId,
        quantity: quantity,
      );
      _quantityController.text = '1';
    } catch (error) {
      if (mounted) setState(() => _error = 'Could not add the part: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _removePart(RequiredPart part) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.repository.removeRequiredPart(
        ticketId: widget.ticketId,
        ticketItemId: part.ticketItemId,
      );
    } catch (error) {
      if (mounted) setState(() => _error = 'Could not remove the part: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: StreamBuilder<List<InventoryPart>>(
            stream: widget.repository.watchInventoryParts(),
            builder: (context, inventorySnapshot) {
              if (inventorySnapshot.hasError) {
                return const _PartsError(
                  message: 'Could not load parts inventory.',
                );
              }
              final inventory = inventorySnapshot.data ?? const [];
              if (_selectedPartId != null &&
                  !inventory.any((part) => part.id == _selectedPartId)) {
                _selectedPartId = null;
              }
              return StreamBuilder<List<RequiredPart>>(
                stream: widget.repository.watchRequiredParts(widget.ticketId),
                builder: (context, requiredSnapshot) {
                  if (requiredSnapshot.hasError) {
                    return const _PartsError(
                      message: 'Could not load parts for this invoice.',
                    );
                  }
                  final requiredParts = requiredSnapshot.data ?? const [];
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Parts Invoice',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Close',
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      Text(
                        'Add parts from inventory. Stock is unchanged until '
                        'parts are consumed.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      if (inventory.isEmpty) ...[
                        const Text(
                          'No inventory parts yet. Add a part to make it '
                          'available for this ticket.',
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          key: const Key('required-parts-create-inventory'),
                          onPressed: _busy
                              ? null
                              : () => showAddInventoryPartDialog(
                                    context,
                                    repository: widget.repository,
                                  ),
                          icon: const Icon(Icons.add),
                          label: const Text('Add inventory part'),
                        ),
                      ] else ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: DropdownMenu<int>(
                                key: const Key('required-parts-picker'),
                                width: double.infinity,
                                initialSelection: _selectedPartId,
                                label: const Text('Search by SKU or part name'),
                                hintText: 'Type a SKU or part name',
                                leadingIcon: const Icon(Icons.search),
                                enableFilter: true,
                                requestFocusOnTap: true,
                                filterCallback: (entries, filter) => [
                                  for (final entry in entries)
                                    if (partMatchesQuery(
                                      inventory.firstWhere(
                                        (part) => part.id == entry.value,
                                      ),
                                      filter,
                                    ))
                                      entry,
                                ],
                                dropdownMenuEntries: [
                                  for (final part in inventory)
                                    DropdownMenuEntry(
                                      value: part.id,
                                      label: partPickerLabel(part),
                                    ),
                                ],
                                onSelected: _busy
                                    ? null
                                    : (value) =>
                                        setState(() => _selectedPartId = value),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 92,
                              child: TextField(
                                key: const Key('required-parts-quantity'),
                                controller: _quantityController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Qty',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: IconButton.filledTonal(
                                key: const Key('required-parts-add'),
                                tooltip: 'Add to required list',
                                onPressed: _busy ? null : _addPart,
                                icon: const Icon(Icons.add),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Flexible(
                          child: requiredParts.isEmpty
                              ? const Center(
                                  child: Text('No parts on this invoice yet.'),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: requiredParts.length,
                                  itemBuilder: (context, index) {
                                    final part = requiredParts[index];
                                    return ListTile(
                                      key: Key(
                                        'required-part-${part.ticketItemId}',
                                      ),
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(part.name),
                                      subtitle: Text(
                                        '${part.description == null || part.description!.trim().isEmpty ? '' : '${part.description!.trim()} · '}'
                                        'Qty ${part.quantity} · stock '
                                        '${part.stock}'
                                        ' · Raw ${_money(part.rawCostCents)}'
                                        ' · Retail '
                                        '${_money(part.retailPriceCents)}'
                                        '${part.location == null ? '' : ' · Location ${part.location}'}'
                                        '${part.sku == null ? '' : ' · SKU ${part.sku}'}',
                                      ),
                                      trailing: IconButton(
                                        tooltip: 'Remove ${part.name}',
                                        onPressed: _busy
                                            ? null
                                            : () => _removePart(part),
                                        icon: const Icon(Icons.delete_outline),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Done'),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  String _money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';
}

class _PartsError extends StatelessWidget {
  const _PartsError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
}
