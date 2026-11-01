import 'package:flutter/material.dart';

import '../../data/ticket_due.dart';

Color dueColor(DueUrgency urgency, ColorScheme scheme) => switch (urgency) {
      DueUrgency.overdue => Colors.red.shade700,
      DueUrgency.urgent => Colors.orange.shade800,
      DueUrgency.soon => Colors.amber.shade700,
      DueUrgency.normal => scheme.onSurfaceVariant,
    };

String dueLabel(DateTime due, {DateTime? today}) {
  final days = daysUntilDue(due, today: today);
  if (days < 0) return '${-days} ${days == -1 ? 'day' : 'days'} overdue';
  if (days == 0) return 'Due today';
  return 'Due in $days ${days == 1 ? 'day' : 'days'}';
}

/// "Due Date" pill that turns yellow, orange and red as the date closes in.
class DueDateChip extends StatelessWidget {
  const DueDateChip({super.key, required this.due});

  final DateTime due;

  @override
  Widget build(BuildContext context) {
    final color = dueColor(dueUrgency(due), Theme.of(context).colorScheme);
    final date = MaterialLocalizations.of(context).formatMediumDate(due);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_outlined, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            'Due $date · ${dueLabel(due)}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
