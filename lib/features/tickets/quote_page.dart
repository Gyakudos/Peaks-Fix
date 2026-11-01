import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/partners.dart';
import '../../data/shop_scope.dart';
import '../../data/ticket_due.dart';
import '../../data/tickets_repository.dart';
import '../repairs/new_repair_page.dart';
import 'invoice_editor.dart';
import 'required_parts_dialog.dart';
import 'ticket_widgets.dart';

/// Asks for an optional customer name, opens a quote and shows it.
Future<void> startQuote(BuildContext context, {Partner? partner}) async {
  final repository = ShopScope.of(context);
  final partners = partner != null
      ? <Partner>[partner]
      : await loadPartners(AppDatabase.instance);
  if (!context.mounted) return;
  final controller = TextEditingController(text: partner?.name);
  Partner? chosen = partner;
  final name = await showDialog<String>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (_, setDialogState) => AlertDialog(
        title: const Text('New quote'),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (partners.isNotEmpty) ...[
                DropdownButtonFormField<Partner?>(
                  key: const Key('quote-partner'),
                  initialValue: chosen,
                  decoration: const InputDecoration(labelText: 'Partner'),
                  items: [
                    const DropdownMenuItem<Partner?>(
                      value: null,
                      child: Text('No partner'),
                    ),
                    for (final item in partners)
                      DropdownMenuItem<Partner?>(
                        value: item,
                        child: Text(
                          item.hasDiscount
                              ? '${item.name} (${item.discountLabel})'
                              : item.name,
                        ),
                      ),
                  ],
                  onChanged: (value) => setDialogState(() {
                    chosen = value;
                    if (value != null) controller.text = value.name;
                  }),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                key: const Key('quote-customer-field'),
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Customer (optional)',
                  helperText: 'Quotes are removed after $quoteLifetimeDays '
                      'days unless intake is done.',
                ),
                onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('quote-create'),
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Open quote'),
          ),
        ],
      ),
    ),
  );
  controller.dispose();
  if (name == null || !context.mounted) return;
  final created = await repository.createQuote(customerName: name);
  if (chosen != null && chosen!.hasDiscount) {
    await repository.setInvoiceDiscount(
      ticketId: created.id,
      kind: InvoiceDiscountKind.none,
      value: 0,
      partnerPartsPercent: chosen!.partsDiscountPercent,
      partnerLabourPercent: chosen!.labourDiscountPercent,
    );
  }
  if (!context.mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => QuoteScreen(ticketId: created.id),
    ),
  );
}

/// Opens an existing quote.
class QuoteScreen extends StatelessWidget {
  const QuoteScreen({super.key, required this.ticketId});

  final int ticketId;

  @override
  Widget build(BuildContext context) {
    final repository = ShopScope.of(context);
    return StreamBuilder<TicketDetailEntry?>(
      stream: repository.watchTicket(ticketId),
      builder: (context, snapshot) {
        final entry = snapshot.data;
        return Scaffold(
          appBar: AppBar(title: Text(entry?.summary.number ?? 'Quote')),
          body: entry == null
              ? const Center(child: Text('This quote no longer exists.'))
              : QuoteBody(entry: entry),
        );
      },
    );
  }
}

class QuoteBody extends StatelessWidget {
  const QuoteBody({super.key, required this.entry});

  final TicketDetailEntry entry;

  String _money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

  Future<void> _delete(BuildContext context) async {
    final repository = ShopScope.of(context);
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this quote?'),
        content: Text('${entry.summary.number} and its lines will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep'),
          ),
          FilledButton(
            key: const Key('quote-delete-confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await repository.deleteTicket(entry.summary.id);
    navigator.pop();
  }

  void _startIntake(BuildContext context) {
    final name = entry.summary.customerName;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => NewRepairPage(
          quoteTicketId: entry.summary.id,
          customerName: name == quoteCustomerName ? null : name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repository = ShopScope.of(context);
    final summary = entry.summary;
    final expires = quoteExpiryDate(summary.createdAt);
    final daysLeft = daysUntilDue(expires);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          children: [
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            summary.customerName == quoteCustomerName
                                ? 'Quote'
                                : summary.customerName,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TicketStatusChip(status: summary.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Opened ${shortDate(summary.createdAt)} · removed '
                      '${shortDate(expires)} (${daysLeft <= 0 ? 'today' : 'in $daysLeft days'}) '
                      'if intake is not done.',
                      key: const Key('quote-expiry'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton.icon(
                  key: const Key('quote-add-parts'),
                  onPressed: () => showRequiredPartsDialog(
                    context,
                    repository: repository,
                    ticketId: summary.id,
                  ),
                  icon: const Icon(Icons.memory_outlined),
                  label: const Text('Add parts'),
                ),
                OutlinedButton.icon(
                  key: const Key('quote-open-invoice'),
                  onPressed: () => showInvoiceDialog(
                    context,
                    repository: repository,
                    ticketId: summary.id,
                    ticketNumber: summary.number,
                    customerName: summary.customerName,
                    device: 'Quote',
                  ),
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: const Text('Labour, discount & invoice'),
                ),
                FilledButton.icon(
                  key: const Key('quote-start-intake'),
                  onPressed: () => _startIntake(context),
                  icon: const Icon(Icons.assignment_add),
                  label: const Text('Start intake'),
                ),
                TextButton.icon(
                  key: const Key('quote-delete'),
                  onPressed: () => _delete(context),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete quote'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<InvoiceDraft?>(
              stream: repository.watchInvoice(summary.id),
              builder: (context, snapshot) {
                final draft = snapshot.data;
                final lines = draft?.lines ?? const <InvoiceLine>[];
                return Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quote lines',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (lines.isEmpty)
                          const Text('Nothing added yet.')
                        else
                          for (final line in lines)
                            ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(line.description),
                              subtitle: Text(
                                '${line.quantity} × ${_money(line.unitPriceCents)}',
                              ),
                              trailing: Text(
                                line.isShopSupply
                                    ? 'Included'
                                    : _money(line.lineTotalCents),
                              ),
                            ),
                        if (draft != null && lines.isNotEmpty) ...[
                          const Divider(),
                          if (draft.discountCents > 0) ...[
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Full price ${_money(draft.subtotalCents)}',
                                key: const Key('quote-full-price'),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Discount -${_money(draft.discountCents)} → '
                                'Partner price ${_money(draft.taxableCents)}',
                                key: const Key('quote-partner-price'),
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Total with tax ${_money(draft.totalCents)}',
                              key: const Key('quote-total'),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
