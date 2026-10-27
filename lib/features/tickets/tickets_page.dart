import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/shop_scope.dart';
import '../../data/tickets_repository.dart';
import '../repairs/new_repair_page.dart';
import 'ticket_detail_page.dart';
import 'ticket_widgets.dart';

/// The default screen: every job in the shop, grouped by workflow stage.
class TicketsPage extends StatelessWidget {
  const TicketsPage({super.key, this.closedOnly = false});

  final bool closedOnly;

  static const double _maxContentWidth = 980;

  @override
  Widget build(BuildContext context) {
    final repository = ShopScope.of(context);

    return StreamBuilder<List<TicketBoardEntry>>(
      stream: repository.watchBoard(),
      builder: (context, snapshot) {
        final allTickets = snapshot.data ?? const <TicketBoardEntry>[];
        final tickets = allTickets
            .where((ticket) => closedOnly
                ? ticket.status == TicketStatus.closed
                : ticket.status != TicketStatus.closed)
            .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(count: tickets.length, closedOnly: closedOnly),
            Expanded(
              child: switch (snapshot) {
                AsyncSnapshot(hasError: true) => const _Message(
                    icon: Icons.storage_outlined,
                    title: 'The board could not be loaded',
                    body:
                        'The local database is unavailable. Restart the app; if '
                        'it keeps happening, check the database file.',
                  ),
                AsyncSnapshot(hasData: false) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                _ when tickets.isEmpty => _Message(
                    icon: Icons.assignment_outlined,
                    title: closedOnly ? 'No closed tickets' : 'No jobs yet',
                    body: closedOnly
                        ? 'Closed tickets will appear here.'
                        : 'Start with New repair. The device, its serial (or shop '
                            'tag) and the customer go on one ticket.',
                  ),
                _ => _Board(
                    tickets: tickets,
                    repository: repository,
                    closedOnly: closedOnly,
                  ),
              },
            ),
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count, required this.closedOnly});

  final int count;
  final bool closedOnly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: TicketsPage._maxContentWidth,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    closedOnly
                        ? Icons.inventory_2_outlined
                        : Icons.receipt_long_outlined,
                    size: 26,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    closedOnly ? 'Closed Tickets' : 'Tickets',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (count > 0)
                    Chip(
                      label: Text('$count'),
                      visualDensity: VisualDensity.compact,
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                ],
              ),
              if (!closedOnly)
                FilledButton.icon(
                  onPressed: () => openNewRepair(context),
                  icon: const Icon(Icons.add),
                  label: const Text('New repair'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Board extends StatelessWidget {
  const _Board({
    required this.tickets,
    required this.repository,
    required this.closedOnly,
  });

  final List<TicketBoardEntry> tickets;
  final TicketsRepository repository;
  final bool closedOnly;

  @override
  Widget build(BuildContext context) {
    if (closedOnly) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: TicketsPage._maxContentWidth,
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            children: [
              _Group(
                label: 'Closed',
                tickets: tickets,
                repository: repository,
              ),
            ],
          ),
        ),
      );
    }
    final active = tickets.where((t) => t.status.isActive).toList();
    final finished = tickets.where((t) => !t.status.isActive).toList();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: TicketsPage._maxContentWidth,
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            _Group(
              label: 'In the shop',
              tickets: active,
              repository: repository,
            ),
            if (finished.isNotEmpty) ...[
              const SizedBox(height: 12),
              _Group(
                label: 'Finished',
                tickets: finished,
                repository: repository,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({
    required this.label,
    required this.tickets,
    required this.repository,
  });

  final String label;
  final List<TicketBoardEntry> tickets;
  final TicketsRepository repository;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
          child: Text(
            '$label · ${tickets.length}',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (tickets.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text(
              'Nothing here right now.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        for (final ticket in tickets)
          _TicketCard(ticket: ticket, repository: repository),
      ],
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket, required this.repository});

  final TicketBoardEntry ticket;
  final TicketsRepository repository;

  Future<void> _deleteTicket(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete ticket?'),
        content: Text(
          'Delete ${ticket.number} and its reports, payment records, and '
          'attached photos? Customer records and issued shop-tag history '
          'will be kept. This cannot be undone.',
        ),
        actions: [
          TextButton(
            key: Key('cancel-delete-ticket-${ticket.id}'),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: Key('confirm-delete-ticket-${ticket.id}'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete ticket'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await repository.deleteTicket(ticket.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${ticket.number} deleted')),
      );
    } on TicketPhotoCleanupException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${ticket.number} was deleted, but its photos could not be '
            'removed: $error',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete ${ticket.number}: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => TicketDetailPage(ticketId: ticket.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          ticket.number,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                        TicketStatusChip(status: ticket.status),
                      ],
                    ),
                  ),
                  Text(
                    ageLabel(ticket.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                  if (ticket.status == TicketStatus.closed)
                    IconButton(
                      key: Key('reopen-ticket-${ticket.id}'),
                      tooltip: 'Reopen ${ticket.number}',
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.lock_open),
                      onPressed: () => showReopenTicketDialog(
                        context,
                        ticketId: ticket.id,
                        ticketNumber: ticket.number,
                      ),
                    ),
                  IconButton(
                    key: Key('delete-ticket-${ticket.id}'),
                    tooltip: 'Delete ${ticket.number}',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteTicket(context),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                ticket.deviceWithVariant,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                [
                  ticket.customerName,
                  if (ticket.shopTag != null) ticket.shopTag!,
                  ticket.serial ?? (ticket.serialMissing ? 'no serial' : ''),
                ].where((part) => part.isNotEmpty).join(' · '),
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
              const SizedBox(height: 6),
              Text(
                ticket.complaint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                body,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens the intake form. Kept here so the header, the empty state and any
/// future shortcut all use one call site.
Future<void> openNewRepair(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const NewRepairPage()),
  );
}
