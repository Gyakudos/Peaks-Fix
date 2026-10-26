import 'package:flutter/material.dart';

import '../../data/database.dart';

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
