import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/database.dart';
import '../payments/card_payment.dart';
import '../../data/shop_scope.dart';

/// Colour used for a status everywhere it appears, so the board and the ticket
/// page agree.
Color ticketStatusColor(BuildContext context, TicketStatus status) {
  final scheme = Theme.of(context).colorScheme;
  return switch (status) {
    TicketStatus.received => scheme.primary,
    TicketStatus.diagnosing => const Color(0xFF1E88E5),
    TicketStatus.awaitingApproval => const Color(0xFFF9A825),
    TicketStatus.awaitingParts => const Color(0xFFEF6C00),
    TicketStatus.inRepair => const Color(0xFF00897B),
    TicketStatus.testing => const Color(0xFF8E24AA),
    TicketStatus.ready => const Color(0xFF2E7D32),
    TicketStatus.pickedUp => const Color(0xFF546E7A),
    TicketStatus.closed => const Color(0xFF6D4C41),
    TicketStatus.cancelled => scheme.error,
    TicketStatus.quote => const Color(0xFF5E35B1),
  };
}

class TicketStatusChip extends StatelessWidget {
  const TicketStatusChip({super.key, required this.status});

  final TicketStatus status;

  @override
  Widget build(BuildContext context) {
    final color = ticketStatusColor(context, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(90)),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

/// `2h ago`, `3d ago`, then a plain date for anything older than a week.
String ageLabel(DateTime time, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final diff = reference.difference(time);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return shortDate(time);
}

String shortDate(DateTime time) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${time.day} ${months[time.month - 1]} ${time.year}';
}

/// Reopens a closed ticket so warranty work can be booked against the same job.
///
/// Reports, invoice lines and payments stay on the ticket; only the workflow
/// status changes. The shop chooses where the job re-enters the board.
Future<void> showReopenTicketDialog(
  BuildContext context, {
  required int ticketId,
  required String ticketNumber,
}) async {
  final repository = ShopScope.of(context);
  final status = await showDialog<TicketStatus>(
    context: context,
    builder: (_) => _ReopenTicketDialog(ticketNumber: ticketNumber),
  );
  if (status == null || !context.mounted) return;

  try {
    await repository.updateStatus(ticketId, status);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$ticketNumber reopened as ${status.label}'),
      ),
    );
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not reopen $ticketNumber: $error')),
    );
  }
}

/// Refunds money on a closed ticket, up to what the customer paid.
Future<void> showRefundTicketDialog(
  BuildContext context, {
  required int ticketId,
  required String ticketNumber,
}) async {
  final repository = ShopScope.of(context);
  final entries = await repository.watchTicketPayments(ticketId).first;
  final paid = entries.fold<int>(
    0,
    (sum, entry) =>
        sum +
        (entry.kind == PaymentKind.refund
            ? -entry.amountCents
            : entry.amountCents),
  );
  if (!context.mounted) return;
  if (paid <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$ticketNumber has nothing left to refund.')),
    );
    return;
  }
  final result = await showDialog<({int amountCents, PaymentMethod method})>(
    context: context,
    builder: (_) =>
        _RefundTicketDialog(ticketNumber: ticketNumber, paidCents: paid),
  );
  if (result == null || !context.mounted) return;

  try {
    final processor = await repository.paymentProcessor();
    if (!context.mounted) return;
    final approved = await authorizeCardPayment(
      context,
      processor: processor,
      method: result.method,
      amountCents: result.amountCents,
      reference: ticketNumber,
      refund: true,
    );
    if (!approved || !context.mounted) return;
    await repository.recordTicketRefund(
      ticketId: ticketId,
      amountCents: result.amountCents,
      method: result.method,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Refunded \$${(result.amountCents / 100).toStringAsFixed(2)} '
          'on $ticketNumber',
        ),
      ),
    );
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not refund $ticketNumber: $error')),
    );
  }
}

class _RefundTicketDialog extends StatefulWidget {
  const _RefundTicketDialog({
    required this.ticketNumber,
    required this.paidCents,
  });

  final String ticketNumber;
  final int paidCents;

  @override
  State<_RefundTicketDialog> createState() => _RefundTicketDialogState();
}

class _RefundTicketDialogState extends State<_RefundTicketDialog> {
  late final _amountController = TextEditingController(
    text: (widget.paidCents / 100).toStringAsFixed(2),
  );
  PaymentMethod _method = PaymentMethod.card;
  String? _error;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Refund ${widget.ticketNumber}'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paid so far: \$${(widget.paidCents / 100).toStringAsFixed(2)}',
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('refund-amount'),
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                labelText: 'Refund amount',
                prefixText: '\$',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<PaymentMethod>(
              key: const Key('refund-method'),
              initialValue: _method,
              decoration: const InputDecoration(
                labelText: 'Refunded via',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final method in PaymentMethod.values)
                  DropdownMenuItem(
                    value: method,
                    child: Text(method.label),
                  ),
              ],
              onChanged: (next) {
                if (next != null) setState(() => _method = next);
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          key: const Key('confirm-refund'),
          onPressed: () {
            final amount = double.tryParse(_amountController.text.trim());
            final cents = amount == null ? 0 : (amount * 100).round();
            if (cents < 1 || cents > widget.paidCents) {
              setState(
                () => _error = 'Enter an amount up to the amount paid.',
              );
              return;
            }
            Navigator.of(context).pop((amountCents: cents, method: _method));
          },
          icon: const Icon(Icons.currency_exchange),
          label: const Text('Refund'),
        ),
      ],
    );
  }
}

class _ReopenTicketDialog extends StatefulWidget {
  const _ReopenTicketDialog({required this.ticketNumber});

  final String ticketNumber;

  @override
  State<_ReopenTicketDialog> createState() => _ReopenTicketDialogState();
}

class _ReopenTicketDialogState extends State<_ReopenTicketDialog> {
  TicketStatus _status = TicketStatus.inRepair;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Reopen ${widget.ticketNumber}?'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Use this for warranty work or a repair that came back. Reports, '
              'invoice lines and payments stay on the ticket.',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TicketStatus>(
              key: const Key('reopen-status-field'),
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Return to the board as',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final option in TicketStatus.values)
                  if (option.isActive)
                    DropdownMenuItem(
                      value: option,
                      child: Text(option.label),
                    ),
              ],
              onChanged: (next) {
                if (next != null) setState(() => _status = next);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('cancel-reopen-ticket'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          key: const Key('confirm-reopen-ticket'),
          onPressed: () => Navigator.of(context).pop(_status),
          icon: const Icon(Icons.lock_open),
          label: const Text('Reopen ticket'),
        ),
      ],
    );
  }
}
