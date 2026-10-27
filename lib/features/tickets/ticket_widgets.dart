import 'package:flutter/material.dart';

import '../../data/database.dart';
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
