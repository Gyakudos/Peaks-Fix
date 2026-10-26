import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/shop_scope.dart';
import '../../data/tickets_repository.dart';
import 'ticket_widgets.dart';

/// One job: identity, fault, status and the three report stages.
class TicketDetailPage extends StatelessWidget {
  const TicketDetailPage({super.key, required this.ticketId});

  final int ticketId;

  @override
  Widget build(BuildContext context) {
    final repository = ShopScope.of(context);

    return StreamBuilder<TicketDetailEntry?>(
      stream: repository.watchTicket(ticketId),
      builder: (context, snapshot) {
        final entry = snapshot.data;
        if (snapshot.hasError) {
          return _shell(
            context,
            title: 'Ticket',
            child: const _Missing(
              message: 'This ticket could not be loaded from the database.',
            ),
          );
        }
        if (entry == null) {
          return _shell(
            context,
            title: 'Ticket',
            child: snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : const _Missing(message: 'This ticket no longer exists.'),
          );
        }

        return _shell(
          context,
          title: entry.summary.number,
          child: _TicketBody(entry: entry),
        );
      },
    );
  }

  Widget _shell(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: child,
    );
  }
}

class _TicketBody extends StatelessWidget {
  const _TicketBody({required this.entry});

  final TicketDetailEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = entry.summary;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          children: [
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                summary.device,
                                style: theme.textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                summary.customerName,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TicketStatusChip(status: summary.status),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 24,
                      runSpacing: 12,
                      children: [
                        _Meta(
                          label: 'Shop tag',
                          value: summary.shopTag ?? 'not issued',
                          emphasise: true,
                        ),
                        _Meta(
                          label:
                              summary.serialMissing ? 'Shop serial' : 'Serial',
                          value: summary.serial ??
                              (summary.serialMissing
                                  ? 'not present'
                                  : 'not recorded'),
                        ),
                        if (summary.deviceVariant != null)
                          _Meta(
                            label: 'Model number',
                            value: summary.deviceVariant!,
                          ),
                        if (deviceSideLabel(summary.deviceSide).isNotEmpty)
                          _Meta(
                            label: 'Side',
                            value: deviceSideLabel(summary.deviceSide),
                          ),
                        _Meta(
                          label: 'Opened',
                          value: shortDate(summary.createdAt),
                        ),
                      ],
                    ),
                    if (summary.shopTag != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        'Sticker on the outside and inside of the device. '
                        'Match this tag before releasing the unit.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _StatusCard(ticketId: summary.id, status: summary.status),
            const SizedBox(height: 16),
            _TextCard(
              title: 'Reported fault',
              body: summary.complaint,
            ),
            if (entry.diagnosis != null && entry.diagnosis!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _TextCard(title: 'Diagnosis', body: entry.diagnosis!),
            ],
            if (entry.notes != null && entry.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _TextCard(title: 'Notes', body: entry.notes!),
            ],
            const SizedBox(height: 16),
            _ReportsCard(ticketId: summary.id),
          ],
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({
    required this.label,
    required this.value,
    this.emphasise = false,
  });

  final String label;
  final String value;
  final bool emphasise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            letterSpacing: 0.8,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: emphasise ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: emphasise ? 0.6 : 0,
          ),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.ticketId, required this.status});

  final int ticketId;
  final TicketStatus status;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TicketStatus>(
              initialValue: status,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                for (final option in TicketStatus.values)
                  DropdownMenuItem(value: option, child: Text(option.label)),
              ],
              onChanged: (next) async {
                if (next == null || next == status) return;
                await ShopScope.of(context).updateStatus(ticketId, next);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Moved to ${next.label}')),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Nothing is blocked: change this whenever the job actually '
              'moves.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextCard extends StatelessWidget {
  const _TextCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(body,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.45)),
          ],
        ),
      ),
    );
  }
}

class _ReportsCard extends StatelessWidget {
  const _ReportsCard({required this.ticketId});

  final int ticketId;

  static const _stages = <(String, String)>[
    ('Technical', 'Findings, parts and contact log · made while diagnosing'),
    ('Client report', 'Auto-filled summary · sent at completion'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repository = ShopScope.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
        child: StreamBuilder<PhotoChecklist>(
          stream: repository.watchPhotoChecklist(ticketId),
          builder: (context, snapshot) {
            final checklist = snapshot.data;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reports',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'The three stages of this job. Editors are next; nothing is '
                  'required to move the ticket.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                ExpansionTile(
                  key: const Key('report1-checklist'),
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.fromLTRB(40, 0, 8, 12),
                  leading: Icon(
                    Icons.checklist_rtl_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Row(
                    children: [
                      Expanded(child: Text('Intake / cosmetic')),
                      Chip(
                        label: Text('Not started'),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  subtitle: Text(_intakeSummary(checklist)),
                  children: [
                    if (checklist == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: LinearProgressIndicator(),
                      )
                    else if (checklist.isEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'This job was booked before device-specific '
                          'checklists existed, so it has no photo slots.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    else
                      for (final slot in checklist.slots)
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 12,
                            child: Text(
                              '${slot.sortOrder}',
                              style: theme.textTheme.labelMedium,
                            ),
                          ),
                          title: Text(slot.label),
                          subtitle: slot.hint == null ? null : Text(slot.hint!),
                          trailing: Text(
                            slot.captured ? 'saved' : 'not captured',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: slot.captured
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                  ],
                ),
                const Divider(height: 1),
                for (final (title, subtitle) in _stages)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.description_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(title),
                    subtitle: Text(subtitle),
                    trailing: const Chip(
                      label: Text('Not started'),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _intakeSummary(PhotoChecklist? checklist) {
    if (checklist == null) return 'Checklist · made at intake';
    if (checklist.isEmpty) {
      return 'Checklist + photos · made at intake';
    }
    final family = checklist.templateName ?? checklist.templateKey;
    return 'Checklist + ${checklist.slots.length} photos'
        '${family == null ? '' : ' · $family'}';
  }
}

class _Missing extends StatelessWidget {
  const _Missing({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyLarge,
        textAlign: TextAlign.center,
      ),
    );
  }
}
