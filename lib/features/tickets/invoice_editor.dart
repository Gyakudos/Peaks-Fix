import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/database.dart';
import '../../data/tickets_repository.dart';

Future<void> showInvoiceDialog(
  BuildContext context, {
  required TicketsRepository repository,
  required int ticketId,
  required String ticketNumber,
  required String customerName,
  required String device,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _InvoiceDialog(
      repository: repository,
      ticketId: ticketId,
      ticketNumber: ticketNumber,
      customerName: customerName,
      device: device,
    ),
  );
}

class _InvoiceDialog extends StatefulWidget {
  const _InvoiceDialog({
    required this.repository,
    required this.ticketId,
    required this.ticketNumber,
    required this.customerName,
    required this.device,
  });

  final TicketsRepository repository;
  final int ticketId;
  final String ticketNumber;
  final String customerName;
  final String device;

  @override
  State<_InvoiceDialog> createState() => _InvoiceDialogState();
}

class _InvoiceDialogState extends State<_InvoiceDialog> {
  final _discountController = TextEditingController();
  InvoiceDiscountKind _discountKind = InvoiceDiscountKind.none;
  bool _discountInitialized = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _addLaborLine() async {
    final descriptionController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final priceController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final values =
        await showDialog<({String description, int quantity, int priceCents})>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add labor or service'),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  key: const Key('invoice-labor-description'),
                  controller: descriptionController,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a description.'
                      : null,
                ),
                TextFormField(
                  key: const Key('invoice-labor-quantity'),
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  validator: (value) {
                    final quantity = int.tryParse(value ?? '');
                    return quantity == null || quantity < 1
                        ? 'Enter a quantity of 1 or more.'
                        : null;
                  },
                ),
                TextFormField(
                  key: const Key('invoice-labor-price'),
                  controller: priceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Price per unit',
                    prefixText: '\$',
                  ),
                  validator: (value) => _parseMoney(value ?? '') == null
                      ? 'Enter a valid amount.'
                      : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('invoice-labor-save'),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.of(dialogContext).pop((
                description: descriptionController.text.trim(),
                quantity: int.parse(quantityController.text.trim()),
                priceCents: _parseMoney(priceController.text)!,
              ));
            },
            child: const Text('Add line'),
          ),
        ],
      ),
    );
    descriptionController.dispose();
    quantityController.dispose();
    priceController.dispose();
    if (values == null || !mounted) return;

    await _run(() => widget.repository.addInvoiceLaborLine(
          ticketId: widget.ticketId,
          description: values.description,
          quantity: values.quantity,
          unitPriceCents: values.priceCents,
        ));
  }

  Future<void> _applyDiscount() async {
    final input = _discountController.text.trim();
    final value = switch (_discountKind) {
      InvoiceDiscountKind.none => 0,
      InvoiceDiscountKind.percentage => int.tryParse(input),
      InvoiceDiscountKind.fixed => _parseMoney(input),
    };
    if (value == null ||
        value < 0 ||
        (_discountKind == InvoiceDiscountKind.percentage && value > 100)) {
      setState(
        () => _error = _discountKind == InvoiceDiscountKind.percentage
            ? 'Enter a percentage from 0 to 100.'
            : 'Enter a valid non-negative discount.',
      );
      return;
    }
    await _run(() => widget.repository.setInvoiceDiscount(
          ticketId: widget.ticketId,
          kind: _discountKind,
          value: value,
        ));
  }

  Future<void> _removeLine(InvoiceLine line) async {
    await _run(() => widget.repository.removeInvoiceLaborLine(
          ticketId: widget.ticketId,
          ticketItemId: line.ticketItemId,
        ));
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (error) {
      if (mounted) setState(() => _error = 'Could not update invoice: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 760),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: StreamBuilder<InvoiceDraft?>(
            stream: widget.repository.watchInvoice(widget.ticketId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const _InvoiceError(
                  message: 'Could not load this ticket invoice.',
                );
              }
              final invoice = snapshot.data;
              if (invoice != null && !_discountInitialized) {
                _discountKind = invoice.discountKind;
                _discountController.text = switch (invoice.discountKind) {
                  InvoiceDiscountKind.none => '',
                  InvoiceDiscountKind.percentage =>
                    invoice.discountValue.toString(),
                  InvoiceDiscountKind.fixed =>
                    (invoice.discountValue / 100).toStringAsFixed(2),
                };
                _discountInitialized = true;
              }
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (invoice == null) {
                return const _InvoiceError(
                  message: 'This ticket is no longer available.',
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Invoice · ${widget.ticketNumber}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close invoice',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  Text(
                    'Prepared for ${widget.customerName} · ${widget.device}\n'
                    'Required Parts are priced at their saved retail price. '
                    'Add labor or service charges below.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  if (_error != null) ...[
                    _InvoiceError(message: _error!),
                    const SizedBox(height: 8),
                  ],
                  Expanded(
                    child: invoice.lines.isEmpty
                        ? const Center(
                            child: Text(
                              'No invoice lines yet. Add Required Parts in '
                              'Technical or add a labor/service charge.',
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView(
                            children: [
                              for (final line in invoice.lines)
                                ListTile(
                                  key: Key(
                                    'invoice-line-${line.ticketItemId}',
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(line.description),
                                  subtitle: Text(
                                    '${line.isMerch ? 'Merchandise' : _kindLabel(line.kind)} · '
                                    '${line.quantity} × '
                                    '${_money(line.unitPriceCents)}',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(_money(line.lineTotalCents)),
                                      if (line.kind == TicketItemKind.custom)
                                        IconButton(
                                          tooltip: 'Remove ${line.description}',
                                          onPressed: _busy
                                              ? null
                                              : () => _removeLine(line),
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      key: const Key('invoice-add-labor'),
                      onPressed: _busy ? null : _addLaborLine,
                      icon: const Icon(Icons.add),
                      label: const Text('Add labor/service'),
                    ),
                  ),
                  const Divider(),
                  Row(
                    children: [
                      const Expanded(child: Text('Discount')),
                      SizedBox(
                        width: 150,
                        child: DropdownButtonFormField<InvoiceDiscountKind>(
                          key: const Key('invoice-discount-kind'),
                          initialValue: _discountKind,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            isDense: true,
                            labelText: 'Type',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: InvoiceDiscountKind.none,
                              child: Text('None'),
                            ),
                            DropdownMenuItem(
                              value: InvoiceDiscountKind.percentage,
                              child: Text('Percent'),
                            ),
                            DropdownMenuItem(
                              value: InvoiceDiscountKind.fixed,
                              child: Text('Fixed'),
                            ),
                          ],
                          onChanged: _busy
                              ? null
                              : (value) => setState(() {
                                    _discountKind =
                                        value ?? InvoiceDiscountKind.none;
                                    _error = null;
                                  }),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 130,
                        child: TextField(
                          key: const Key('invoice-discount-value'),
                          controller: _discountController,
                          enabled: !_busy &&
                              _discountKind != InvoiceDiscountKind.none,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            if (_discountKind == InvoiceDiscountKind.percentage)
                              FilteringTextInputFormatter.digitsOnly
                            else
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ),
                          ],
                          decoration: InputDecoration(
                            isDense: true,
                            labelText:
                                _discountKind == InvoiceDiscountKind.fixed
                                    ? 'Amount'
                                    : 'Value',
                            prefixText:
                                _discountKind == InvoiceDiscountKind.fixed
                                    ? '\$'
                                    : null,
                            suffixText:
                                _discountKind == InvoiceDiscountKind.percentage
                                    ? '%'
                                    : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        key: const Key('invoice-apply-discount'),
                        tooltip: 'Apply discount',
                        onPressed: _busy ? null : _applyDiscount,
                        icon: const Icon(Icons.check),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _TotalRow(
                    label: 'Subtotal',
                    value: _money(invoice.subtotalCents),
                  ),
                  _TotalRow(
                    label: 'Discount',
                    value: '-${_money(invoice.discountCents)}',
                  ),
                  for (final line in invoice.taxLines)
                    _TotalRow(
                      label: '${line.label} (${line.rateLabel})',
                      value: _money(line.amountCents),
                    ),
                  _TotalRow(
                    label: 'Total',
                    value: _money(invoice.totalCents),
                    emphasize: true,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    invoice.taxes.isEnabled
                        ? 'GST/PST is calculated on the discounted subtotal.'
                        : 'Sales tax is turned off in Settings.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _kindLabel(TicketItemKind kind) {
    switch (kind) {
      case TicketItemKind.service:
        return 'Service';
      case TicketItemKind.part:
        return 'Part';
      case TicketItemKind.custom:
        return 'Labor/service';
    }
  }

  static int? _parseMoney(String input) {
    final value = double.tryParse(input);
    if (value == null || !value.isFinite || value < 0) return null;
    return (value * 100).round();
  }

  static String _money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final style = emphasize
        ? Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w700)
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _InvoiceError extends StatelessWidget {
  const _InvoiceError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
}
