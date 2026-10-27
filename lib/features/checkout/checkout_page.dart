import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/database.dart';
import '../../data/shop_scope.dart';
import '../../data/tickets_repository.dart';
import '../tickets/invoice_editor.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = ShopScope.of(context);
    return StreamBuilder<List<TicketBoardEntry>>(
      stream: repository.watchBoard(),
      builder: (context, snapshot) {
        final ready = (snapshot.data ?? const <TicketBoardEntry>[])
            .where((ticket) => ticket.status == TicketStatus.ready)
            .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Checkout',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  if (ready.isNotEmpty) Chip(label: Text('${ready.length}')),
                ],
              ),
            ),
            Expanded(
              child: snapshot.hasError
                  ? const Center(
                      child: Text('Could not load checkout tickets.'))
                  : !snapshot.hasData
                      ? const Center(child: CircularProgressIndicator())
                      : ready.isEmpty
                          ? const Center(
                              child: Text('No tickets are ready for checkout.'),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                              itemCount: ready.length,
                              itemBuilder: (context, index) => _CheckoutTicket(
                                ticket: ready[index],
                                repository: repository,
                              ),
                            ),
            ),
          ],
        );
      },
    );
  }
}

class _CheckoutTicket extends StatelessWidget {
  const _CheckoutTicket({required this.ticket, required this.repository});

  final TicketBoardEntry ticket;
  final TicketsRepository repository;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${ticket.number} · ${ticket.customerName}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(ticket.deviceWithVariant),
                  const SizedBox(height: 8),
                  StreamBuilder<InvoiceDraft?>(
                    stream: repository.watchInvoice(ticket.id),
                    builder: (context, invoiceSnapshot) =>
                        StreamBuilder<List<PaymentEntry>>(
                      stream: repository.watchTicketPayments(ticket.id),
                      builder: (context, paymentSnapshot) {
                        final invoice = invoiceSnapshot.data;
                        final paid = _netPaid(paymentSnapshot.data ?? const []);
                        final due = invoice == null
                            ? null
                            : (invoice.totalCents - paid)
                                .clamp(0, invoice.totalCents)
                                .toInt();
                        return Text(
                          due == null
                              ? 'Loading balance…'
                              : 'Balance due ${_money(due)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              key: Key('checkout-open-${ticket.id}'),
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => _CheckoutDialog(
                  ticket: ticket,
                  repository: repository,
                ),
              ),
              icon: const Icon(Icons.point_of_sale),
              label: const Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutDialog extends StatefulWidget {
  const _CheckoutDialog({required this.ticket, required this.repository});

  final TicketBoardEntry ticket;
  final TicketsRepository repository;

  @override
  State<_CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<_CheckoutDialog> {
  bool _busy = false;
  String? _error;

  Future<void> _openInvoice() => showInvoiceDialog(
        context,
        repository: widget.repository,
        ticketId: widget.ticket.id,
        ticketNumber: widget.ticket.number,
        customerName: widget.ticket.customerName,
        device: widget.ticket.deviceWithVariant,
      );

  Future<void> _addMerch() async {
    final values = await showDialog<
        ({String description, int quantity, int costCents, int priceCents})>(
      context: context,
      builder: (_) => _AddMerchDialog(repository: widget.repository),
    );
    if (values == null || !mounted) return;
    await _run(() => widget.repository.addCheckoutMerchLine(
          ticketId: widget.ticket.id,
          description: values.description,
          quantity: values.quantity,
          unitCostCents: values.costCents,
          unitPriceCents: values.priceCents,
        ));
  }

  Future<void> _recordPayment(int amountDue) async {
    final payment = await showDialog<({int amountCents, PaymentMethod method})>(
      context: context,
      builder: (_) => _PaymentDialog(amountDueCents: amountDue),
    );
    if (payment == null || !mounted) return;
    await _run(() => widget.repository.recordTicketPayment(
          ticketId: widget.ticket.id,
          amountCents: payment.amountCents,
          method: payment.method,
        ));
  }

  Future<void> _closeTicket() async {
    await _run(
        () => widget.repository.closeTicketAfterPayment(widget.ticket.id));
    if (_error == null && mounted) Navigator.of(context).pop();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
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
            stream: widget.repository.watchInvoice(widget.ticket.id),
            builder: (context, invoiceSnapshot) =>
                StreamBuilder<List<PaymentEntry>>(
              stream: widget.repository.watchTicketPayments(widget.ticket.id),
              builder: (context, paymentSnapshot) {
                final invoice = invoiceSnapshot.data;
                if (invoice == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                final payments = paymentSnapshot.data ?? const <PaymentEntry>[];
                final paid = _netPaid(payments);
                final due = (invoice.totalCents - paid)
                    .clamp(0, invoice.totalCents)
                    .toInt();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Checkout · ${widget.ticket.number}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close checkout',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    Text(
                        '${widget.ticket.customerName} · ${widget.ticket.deviceWithVariant}'),
                    const SizedBox(height: 12),
                    Expanded(
                      child: invoice.lines.isEmpty
                          ? const Center(child: Text('No bill lines yet.'))
                          : ListView(
                              children: [
                                for (final line in invoice.lines)
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(line.description),
                                    subtitle: Text(
                                      '${line.isMerch ? 'Merchandise' : _kindLabel(line.kind)} · '
                                      '${line.quantity} × ${_money(line.unitPriceCents)}',
                                    ),
                                    trailing: Text(_money(line.lineTotalCents)),
                                  ),
                              ],
                            ),
                    ),
                    if (_error != null) ...[
                      Text(
                        _error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          key: const Key('checkout-edit-invoice'),
                          onPressed: _busy ? null : _openInvoice,
                          icon: const Icon(Icons.edit_note),
                          label: const Text('Edit bill'),
                        ),
                        OutlinedButton.icon(
                          key: const Key('checkout-add-merch'),
                          onPressed: _busy ? null : _addMerch,
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Add merchandise'),
                        ),
                        OutlinedButton.icon(
                          key: const Key('checkout-record-payment'),
                          onPressed: _busy || due == 0
                              ? null
                              : () => _recordPayment(due),
                          icon: const Icon(Icons.payments_outlined),
                          label: const Text('Record payment'),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _TotalRow(
                        label: 'Invoice total', cents: invoice.totalCents),
                    _TotalRow(label: 'Paid', cents: paid),
                    _TotalRow(
                        label: 'Balance due', cents: due, emphasize: true),
                    if (payments.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Payments: ${payments.map((payment) => '${_money(payment.amountCents)} ${_paymentMethodLabel(payment.method)}').join(' · ')}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      key: Key('checkout-close-${widget.ticket.id}'),
                      onPressed: _busy || due > 0 ? null : _closeTicket,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Close ticket'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AddMerchDialog extends StatefulWidget {
  const _AddMerchDialog({required this.repository});

  final TicketsRepository repository;

  @override
  State<_AddMerchDialog> createState() => _AddMerchDialogState();
}

class _AddMerchDialogState extends State<_AddMerchDialog> {
  final _nameController = TextEditingController();
  final _costController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  int _markupPercent = 45;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadMarkup();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadMarkup() async {
    final markup = await widget.repository.getMerchMarkupPercent();
    if (!mounted) return;
    setState(() {
      _markupPercent = markup;
      _loaded = true;
    });
  }

  int? _costCents() {
    final cost = double.tryParse(_costController.text.trim());
    if (cost == null || !cost.isFinite || cost < 0) return null;
    return (cost * 100).round();
  }

  int? _priceCents() {
    final cost = _costCents();
    if (cost == null) return null;
    return (cost * (100 + _markupPercent) + 50) ~/ 100;
  }

  @override
  Widget build(BuildContext context) {
    final price = _priceCents();
    return AlertDialog(
      title: const Text('Add merchandise to bill'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('checkout-merch-name'),
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Merchandise'),
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              key: const Key('checkout-merch-cost'),
              controller: _costController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
              ],
              decoration: const InputDecoration(
                labelText: 'Unit cost',
                prefixText: '\$',
              ),
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              key: const Key('checkout-merch-quantity'),
              controller: _quantityController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Quantity'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Text(
              !_loaded
                  ? 'Loading merch markup…'
                  : price == null
                      ? 'Enter a unit cost to calculate retail.'
                      : 'Retail with $_markupPercent% markup: ${_money(price)} each',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('checkout-merch-add'),
          onPressed: !_loaded ||
                  price == null ||
                  _nameController.text.trim().isEmpty ||
                  (int.tryParse(_quantityController.text) ?? 0) < 1
              ? null
              : () => Navigator.of(context).pop((
                    description: _nameController.text.trim(),
                    quantity: int.parse(_quantityController.text),
                    costCents: _costCents()!,
                    priceCents: price,
                  )),
          child: const Text('Add to bill'),
        ),
      ],
    );
  }
}

class _PaymentDialog extends StatefulWidget {
  const _PaymentDialog({required this.amountDueCents});

  final int amountDueCents;

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  late final _amountController = TextEditingController(
    text: (widget.amountDueCents / 100).toStringAsFixed(2),
  );
  PaymentMethod _method = PaymentMethod.card;
  String? _error;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  int? _amountCents() {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || !amount.isFinite || amount <= 0) return null;
    return (amount * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Record payment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('checkout-payment-amount'),
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
            ],
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: '\$',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<PaymentMethod>(
            initialValue: _method,
            decoration: const InputDecoration(labelText: 'Payment method'),
            items: PaymentMethod.values
                .map((method) => DropdownMenuItem(
                      value: method,
                      child: Text(_paymentMethodLabel(method)),
                    ))
                .toList(),
            onChanged: (method) {
              if (method != null) setState(() => _method = method);
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('checkout-payment-save'),
          onPressed: () {
            final amount = _amountCents();
            if (amount == null || amount > widget.amountDueCents) {
              setState(() => _error = 'Enter an amount up to the balance due.');
              return;
            }
            Navigator.of(context).pop((amountCents: amount, method: _method));
          },
          child: const Text('Save payment'),
        ),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow(
      {required this.label, required this.cents, this.emphasize = false});

  final String label;
  final int cents;
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
          Text(_money(cents), style: style),
        ],
      ),
    );
  }
}

int _netPaid(List<PaymentEntry> payments) => payments.fold<int>(
      0,
      (total, payment) =>
          total +
          (payment.kind == PaymentKind.refund
              ? -payment.amountCents
              : payment.amountCents),
    );

String _kindLabel(TicketItemKind kind) => switch (kind) {
      TicketItemKind.service => 'Service',
      TicketItemKind.part => 'Part',
      TicketItemKind.custom => 'Labor/service',
    };

String _paymentMethodLabel(PaymentMethod method) => switch (method) {
      PaymentMethod.cash => 'Cash',
      PaymentMethod.card => 'Card',
      PaymentMethod.other => 'Other',
    };

String _money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';
