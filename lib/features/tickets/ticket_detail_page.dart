import 'dart:async';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../data/database.dart';
import '../../data/shop_scope.dart';
import '../../data/tickets_repository.dart';
import '../capture/phone_capture_dialog.dart';
import 'ticket_dates_panel.dart';
import 'technical_report_editor.dart';
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
          key: const Key('ticket-detail-scroll'),
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
                              if (summary.partnerName.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Chip(
                                    key: const Key('ticket-partner'),
                                    avatar: const Icon(
                                      Icons.business_center,
                                      size: 16,
                                    ),
                                    label: Text(
                                      'Partner: ${summary.partnerName}',
                                    ),
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
                    if (summary.partnerName.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _PartnerPricing(ticketId: summary.id),
                    ],
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
            _StatusCard(
              ticketId: summary.id,
              ticketNumber: summary.number,
              status: summary.status,
            ),
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
            _ReportsCard(
              ticketId: summary.id,
              ticketNumber: summary.number,
              customerName: summary.customerName,
              device: summary.deviceWithVariant,
              intakeNotes: entry.intakeNotes,
              report1CompletedAt: entry.report1CompletedAt,
              report2CompletedAt: entry.report2CompletedAt,
              report3CompletedAt: entry.report3CompletedAt,
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketStaffAssignment extends StatefulWidget {
  const _TicketStaffAssignment({
    required this.ticketId,
    required this.reportKind,
    required this.label,
  });

  final int ticketId;
  final ReportKind reportKind;
  final String label;

  @override
  State<_TicketStaffAssignment> createState() => _TicketStaffAssignmentState();
}

class _TicketStaffAssignmentState extends State<_TicketStaffAssignment> {
  bool _saving = false;

  Future<void> _save(String? staffId) async {
    setState(() => _saving = true);
    try {
      await ShopScope.of(context).setReportStaffAssignment(
        ticketId: widget.ticketId,
        reportKind: widget.reportKind,
        staffId: staffId,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not assign staff: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = ShopScope.of(context);
    return StreamBuilder<List<StaffMemberEntry>>(
      stream: repository.watchClockedInStaff(),
      builder: (context, activeSnapshot) => StreamBuilder<StaffMemberEntry?>(
        stream: repository.watchReportStaffAssignment(
          widget.ticketId,
          widget.reportKind,
        ),
        builder: (context, assignmentSnapshot) {
          final assigned = assignmentSnapshot.data;
          final activeStaff = activeSnapshot.data ?? const [];
          final options = [
            ...activeStaff,
            if (assigned != null &&
                !activeStaff.any((staff) => staff.id == assigned.id))
              assigned,
          ];
          final assignedIsClockedIn = assigned != null &&
              activeStaff.any((staff) => staff.id == assigned.id);

          return Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    key: ValueKey(
                      'report-staff-${widget.reportKind.name}-${widget.ticketId}',
                    ),
                    initialValue: assigned?.id ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Staff',
                      helperText:
                          'Only active staff who are currently signed in can be assigned.',
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('Unassigned'),
                      ),
                      for (final staff in options)
                        DropdownMenuItem(
                          value: staff.id,
                          enabled:
                              assigned?.id != staff.id || assignedIsClockedIn,
                          child: Text(
                            assigned?.id == staff.id && !assignedIsClockedIn
                                ? '${staff.name} · off shift'
                                : '${staff.name} · ${staff.job}',
                          ),
                        ),
                    ],
                    onChanged: _saving ? null : _save,
                  ),
                  if (!activeSnapshot.hasData &&
                      !assignmentSnapshot.hasData) ...[
                    const SizedBox(height: 8),
                    const LinearProgressIndicator(),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ReportSubtitle extends StatelessWidget {
  const _ReportSubtitle({
    required this.ticketId,
    required this.reportKind,
    required this.fallbackText,
  });

  final int ticketId;
  final ReportKind reportKind;
  final String fallbackText;

  @override
  Widget build(BuildContext context) {
    final repository = ShopScope.of(context);
    return StreamBuilder<StaffMemberEntry?>(
      stream: repository.watchReportStaffAssignment(ticketId, reportKind),
      builder: (context, snapshot) {
        final staff = snapshot.data;
        return Text(
          staff == null ? fallbackText : '$fallbackText · ${staff.name}',
        );
      },
    );
  }
}

class _ReportSection extends StatefulWidget {
  const _ReportSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.status,
    required this.child,
    required this.expandKey,
    this.startKey,
    this.locked = false,
  });

  final String title;
  final Widget subtitle;
  final IconData icon;
  final String status;
  final Widget child;
  final Key expandKey;
  final Key? startKey;
  final bool locked;

  @override
  State<_ReportSection> createState() => _ReportSectionState();
}

class _ReportSectionState extends State<_ReportSection> {
  bool _expanded = false;

  void _toggle() => setState(() => _expanded = !_expanded);

  void _open() => setState(() => _expanded = true);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            widget.icon,
            color: widget.locked
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.primary,
          ),
          title: Text(widget.title),
          subtitle: widget.subtitle,
          onTap: _toggle,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Chip(
                avatar: widget.locked ? const Icon(Icons.lock, size: 14) : null,
                label: Text(widget.status),
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                key: widget.expandKey,
                tooltip: _expanded
                    ? 'Collapse ${widget.title}'
                    : 'Expand ${widget.title}',
                onPressed: _toggle,
                icon: AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: const Icon(Icons.expand_more),
                ),
              ),
            ],
          ),
        ),
        if (widget.startKey != null && !_expanded)
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 8, bottom: 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                key: widget.startKey,
                onPressed: widget.locked ? null : _open,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start'),
              ),
            ),
          ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _expanded
              ? SizedBox(width: double.infinity, child: widget.child)
              : const SizedBox(width: double.infinity, height: 0),
        ),
      ],
    );
  }
}

/// Full price beside the partner price, before tax.
class _PartnerPricing extends StatelessWidget {
  const _PartnerPricing({required this.ticketId});

  final int ticketId;

  String _money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<InvoiceDraft?>(
      stream: ShopScope.of(context).watchInvoice(ticketId),
      builder: (context, snapshot) {
        final draft = snapshot.data;
        if (draft == null || draft.subtotalCents == 0) {
          return const SizedBox.shrink();
        }
        return Wrap(
          key: const Key('ticket-partner-pricing'),
          spacing: 24,
          runSpacing: 12,
          children: [
            _Meta(label: 'Full price', value: _money(draft.subtotalCents)),
            if (draft.discountCents > 0)
              _Meta(
                label: draft.discountKind == InvoiceDiscountKind.percentage
                    ? 'Partner discount (${draft.discountValue}%)'
                    : 'Partner discount',
                value: '-${_money(draft.discountCents)}',
              ),
            _Meta(
              label: 'Partner price',
              value: _money(draft.taxableCents),
              emphasise: true,
            ),
          ],
        );
      },
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
  const _StatusCard({
    required this.ticketId,
    required this.ticketNumber,
    required this.status,
  });

  final int ticketId;
  final String ticketNumber;
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
                  if (option != TicketStatus.quote &&
                      (option != TicketStatus.closed ||
                          status == TicketStatus.closed))
                    DropdownMenuItem(
                      value: option,
                      enabled: option != TicketStatus.closed,
                      child: Text(option.label),
                    ),
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
            if (status == TicketStatus.closed) ...[
              OutlinedButton.icon(
                key: Key('reopen-ticket-detail-$ticketId'),
                onPressed: () => showReopenTicketDialog(
                  context,
                  ticketId: ticketId,
                  ticketNumber: ticketNumber,
                ),
                icon: const Icon(Icons.lock_open),
                label: const Text('Reopen ticket'),
              ),
              const SizedBox(height: 8),
              Text(
                'Reopen a closed ticket for warranty work. Reports, invoice '
                'lines and payments are kept.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ] else
              Text(
                'Close ready tickets from Checkout after final payment.',
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
  const _ReportsCard({
    required this.ticketId,
    required this.ticketNumber,
    required this.customerName,
    required this.device,
    required this.intakeNotes,
    required this.report1CompletedAt,
    required this.report2CompletedAt,
    required this.report3CompletedAt,
  });

  final int ticketId;
  final String ticketNumber;
  final String customerName;
  final String device;
  final String? intakeNotes;
  final DateTime? report1CompletedAt;
  final DateTime? report2CompletedAt;
  final DateTime? report3CompletedAt;

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
                  'Drafts save automatically. No report is required to move '
                  'the ticket.',
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
                  title: Row(
                    children: [
                      const Expanded(child: Text('Intake / cosmetic')),
                      Chip(
                        label: Text(
                          report1CompletedAt == null
                              ? _progressLabel(checklist)
                              : 'Completed',
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  subtitle: _ReportSubtitle(
                    ticketId: ticketId,
                    reportKind: ReportKind.intake,
                    fallbackText: _intakeSummary(checklist),
                  ),
                  children: [
                    _TicketStaffAssignment(
                      ticketId: ticketId,
                      reportKind: ReportKind.intake,
                      label: 'Checked in by',
                    ),
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
                      ),
                    TicketDatesPanel(
                      ticketId: ticketId,
                      title: 'Report 1 dates',
                    ),
                    if (checklist != null && checklist.slots.isNotEmpty) ...[
                      if (defaultTargetPlatform == TargetPlatform.windows)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 6),
                            child: FilledButton.tonalIcon(
                              key: const Key('capture-with-phone'),
                              onPressed: () => showPhoneCaptureDialog(
                                context,
                                repository: repository,
                                ticketId: ticketId,
                                ticketNumber: ticketNumber,
                                device: device,
                                checklist: checklist,
                              ),
                              icon: const Icon(Icons.qr_code_2, size: 20),
                              label: const Text('Capture with phone'),
                            ),
                          ),
                        ),
                      for (final slot
                          in checklist.slots.where((slot) => slot.required))
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
                          trailing: _SlotTrailing(
                            slot: slot,
                            onTap: () => _showFullPhoto(context, slot),
                          ),
                        ),
                    ],
                    if (checklist != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Optional Photos',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          OutlinedButton.icon(
                            key: const Key('add-optional-photo'),
                            onPressed: () => _addOptionalPhoto(
                              context,
                              repository,
                              ticketId,
                            ),
                            icon: const Icon(Icons.add_a_photo_outlined),
                            label: const Text('Add Optional Photos'),
                          ),
                        ],
                      ),
                      for (final slot
                          in checklist.slots.where((slot) => !slot.required))
                        ListTile(
                          key: Key('optional-photo-${slot.sortOrder}'),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.photo_outlined),
                          title: Text(slot.label),
                          subtitle:
                              Text(slot.hint ?? 'Optional reference photo'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!slot.captured)
                                IconButton(
                                  key: Key(
                                    'attach-optional-photo-${slot.sortOrder}',
                                  ),
                                  tooltip: 'Attach ${slot.label}',
                                  onPressed: () => _attachOptionalPhoto(
                                    context,
                                    repository,
                                    ticketId,
                                    slot.sortOrder,
                                  ),
                                  icon: const Icon(Icons.upload_file_outlined),
                                ),
                              _SlotTrailing(
                                slot: slot,
                                onTap: () => _showFullPhoto(context, slot),
                              ),
                            ],
                          ),
                        ),
                    ],
                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    _IntakeNotesField(
                      ticketId: ticketId,
                      repository: repository,
                      initialNotes: intakeNotes,
                    ),
                    _ReportOneFooter(
                      ticketId: ticketId,
                      checklist: checklist,
                      completedAt: report1CompletedAt,
                      repository: repository,
                    ),
                  ],
                ),
                const Divider(height: 1),
                _ReportSection(
                  key: const Key('report2-row'),
                  title: 'Technical',
                  subtitle: _ReportSubtitle(
                    ticketId: ticketId,
                    reportKind: ReportKind.technical,
                    fallbackText: report1CompletedAt == null
                        ? 'Complete report 1 to unlock'
                        : 'Bench notes and photos · internal',
                  ),
                  icon: report1CompletedAt == null
                      ? Icons.lock_outline
                      : Icons.description_outlined,
                  status: report1CompletedAt == null
                      ? 'Locked'
                      : report2CompletedAt == null
                          ? 'Draft'
                          : 'Completed',
                  locked: report1CompletedAt == null,
                  expandKey: const Key('report2-expand'),
                  startKey: const Key('report2-start'),
                  child: report1CompletedAt == null
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(40, 8, 8, 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 18,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Complete Report 1 above to unlock the '
                                  'technical bench log. Your notes and photos '
                                  'will be added here.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            _TicketStaffAssignment(
                              ticketId: ticketId,
                              reportKind: ReportKind.technical,
                              label: 'Diagnosis / repair by',
                            ),
                            TicketDatesPanel(
                              ticketId: ticketId,
                              title: 'Technical report dates',
                            ),
                            TechnicalReportEditor(
                              ticketId: ticketId,
                              ticketNumber: ticketNumber,
                              device: device,
                              repository: repository,
                            ),
                            _ReportCompletionFooter(
                              completedAt: report2CompletedAt,
                              title: 'Report 2 complete',
                              completeLabel: 'Complete report 2',
                              completedHint: 'Technical stage done',
                              pendingHint: 'Mark the bench work done when the '
                                  'diagnosis and estimate are finished.',
                              completeKey: const Key('complete-report2'),
                              reopenKey: const Key('reopen-report2'),
                              confirmReopenKey:
                                  const Key('confirm-reopen-report2'),
                              onSetCompleted: (completed) => repository
                                  .setReport2Completed(ticketId, completed),
                              snackbarText: 'Technical stage marked complete.',
                            ),
                          ],
                        ),
                ),
                const Divider(height: 1),
                _ReportSection(
                  key: const Key('report3-row'),
                  title: 'Client report',
                  subtitle: _ReportSubtitle(
                    ticketId: ticketId,
                    reportKind: ReportKind.client,
                    fallbackText: 'Editable draft · review before sharing',
                  ),
                  icon: Icons.description_outlined,
                  status: report3CompletedAt == null ? 'Draft' : 'Completed',
                  expandKey: const Key('report3-expand'),
                  startKey: const Key('report3-start'),
                  child: Column(
                    children: [
                      _TicketStaffAssignment(
                        ticketId: ticketId,
                        reportKind: ReportKind.client,
                        label: 'Completed by',
                      ),
                      TicketDatesPanel(
                        ticketId: ticketId,
                        title: 'Client report dates',
                      ),
                      ClientReportDraftEditor(
                        ticketId: ticketId,
                        ticketNumber: ticketNumber,
                        customerName: customerName,
                        device: device,
                        repository: repository,
                      ),
                      _ReportCompletionFooter(
                        completedAt: report3CompletedAt,
                        title: 'Report 3 complete',
                        completeLabel: 'Complete report 3',
                        completedHint: 'Client report done · sent to checkout',
                        pendingHint: 'Completing the client report sends the '
                            'ticket to Checkout.',
                        completeKey: const Key('complete-report3'),
                        reopenKey: const Key('reopen-report3'),
                        confirmReopenKey: const Key('confirm-reopen-report3'),
                        onSetCompleted: (completed) =>
                            repository.setReport3Completed(ticketId, completed),
                        snackbarText:
                            'Client report complete. Sent to checkout.',
                        confirmComplete: const _CompleteConfirmation(
                          title: 'Send to checkout?',
                          body: 'The ticket moves to Checkout so payment and '
                              'pickup can be handled. The report stays editable.',
                          confirmLabel: 'Send to checkout',
                          confirmKey: Key('confirm-complete-report3'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _progressLabel(PhotoChecklist? checklist) {
    if (checklist == null || checklist.slots.isEmpty) return 'Not started';
    final required = checklist.slots.where((slot) => slot.required).toList();
    final captured = required.where((slot) => slot.captured).length;
    if (required.isEmpty) return 'Optional photos';
    if (captured == 0) return 'Not started';
    if (captured >= required.length) return 'Photos done';
    return '$captured/${required.length}';
  }

  String _intakeSummary(PhotoChecklist? checklist) {
    if (checklist == null) return 'Checklist · made at intake';
    if (checklist.isEmpty) {
      return 'Checklist + photos · made at intake';
    }
    final required = checklist.slots.where((slot) => slot.required).length;
    final captured =
        checklist.slots.where((slot) => slot.required && slot.captured).length;
    final family = checklist.templateName ?? checklist.templateKey;
    return '$captured of $required required photos'
        '${family == null ? '' : ' · $family'}';
  }

  Future<void> _addOptionalPhoto(
    BuildContext context,
    TicketsRepository repository,
    int ticketId,
  ) async {
    final label = await showDialog<String>(
      context: context,
      builder: (dialogContext) => const _OptionalPhotoDialog(),
    );
    if (label == null || !context.mounted) return;
    try {
      await repository.addOptionalPhotoSlot(ticketId: ticketId, label: label);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not add optional photo: $error')),
      );
    }
  }

  Future<void> _attachOptionalPhoto(
    BuildContext context,
    TicketsRepository repository,
    int ticketId,
    int sortOrder,
  ) async {
    try {
      final file = await openFile(
        acceptedTypeGroups: const [
          XTypeGroup(
            label: 'Images',
            extensions: ['jpg', 'jpeg', 'png', 'webp'],
          ),
        ],
      );
      if (file == null) return;
      if (await file.length() > 12 * 1024 * 1024) {
        throw const FormatException('Choose a photo smaller than 12 MB.');
      }
      await repository.savePhotoSlot(
        ticketId: ticketId,
        sortOrder: sortOrder,
        bytes: await file.readAsBytes(),
        extension: p.extension(file.name).replaceFirst('.', ''),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not attach optional photo: $error')),
      );
    }
  }
}

class _OptionalPhotoDialog extends StatefulWidget {
  const _OptionalPhotoDialog();

  @override
  State<_OptionalPhotoDialog> createState() => _OptionalPhotoDialogState();
}

class _OptionalPhotoDialogState extends State<_OptionalPhotoDialog> {
  final _labelController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _save() {
    final label = _labelController.text.trim();
    if (label.isEmpty) {
      setState(() => _error = 'Enter a label for this photo.');
      return;
    }
    if (label.length > 80) {
      setState(() => _error = 'Keep the label to 80 characters or fewer.');
      return;
    }
    Navigator.of(context).pop(label);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add optional photo'),
      content: SizedBox(
        width: 360,
        child: TextField(
          key: const Key('optional-photo-label'),
          controller: _labelController,
          autofocus: true,
          maxLength: 80,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: 'Photo label',
            hintText: 'e.g. Damage close-up',
            errorText: _error,
          ),
          onSubmitted: (_) => _save(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('optional-photo-save'),
          onPressed: _save,
          child: const Text('Add photo'),
        ),
      ],
    );
  }
}

/// Complete / reopen control at the bottom of Report 1.
///
/// Completion needs every required photo, so the button stays disabled until
/// the checklist is done. Legacy jobs with no photo template can be completed
/// straight away; notes are optional.
class _ReportOneFooter extends StatelessWidget {
  const _ReportOneFooter({
    required this.ticketId,
    required this.checklist,
    required this.completedAt,
    required this.repository,
  });

  final int ticketId;
  final PhotoChecklist? checklist;
  final DateTime? completedAt;
  final TicketsRepository repository;

  bool get _canComplete =>
      checklist != null && (checklist!.isEmpty || checklist!.isComplete);

  int get _missingCount => checklist == null
      ? 0
      : checklist!.slots
          .where((slot) => slot.required && !slot.captured)
          .length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (completedAt != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 6),
        child: Row(
          children: [
            Icon(Icons.task_alt, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report 1 complete',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${_dateTimeLabel(completedAt!)} · report 2 unlocked',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              key: const Key('reopen-report1'),
              onPressed: () => _confirmReopen(context),
              child: const Text('Reopen'),
            ),
          ],
        ),
      );
    }

    final String hint;
    if (checklist == null) {
      hint = 'Loading the photo checklist…';
    } else if (checklist!.isEmpty) {
      hint = 'This job has no photo checklist, so it can be completed now.';
    } else if (_canComplete) {
      hint = 'This unlocks report 2.';
    } else {
      hint = _missingCount == 1
          ? '1 photo still needed.'
          : '$_missingCount photos still needed.';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FilledButton.icon(
            key: const Key('complete-report1'),
            onPressed: _canComplete
                ? () => repository.setReport1Completed(ticketId, true)
                : null,
            icon: const Icon(Icons.task_alt, size: 18),
            label: const Text('Complete report 1'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 9),
              child: Text(
                hint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReopen(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reopen report 1?'),
        content: const Text(
          'Report 2 locks again until report 1 is completed. Photos and notes '
          'are kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirm-reopen-report1'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reopen'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await repository.setReport1Completed(ticketId, false);
    }
  }
}

/// Optional confirmation shown before a report is marked complete.
class _CompleteConfirmation {
  const _CompleteConfirmation({
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.confirmKey,
  });

  final String title;
  final String body;
  final String confirmLabel;
  final Key confirmKey;
}

/// Complete / reopen control at the bottom of Reports 2 and 3.
///
/// Unlike Report 1 these reports have no required content, so the button is
/// always available. The timestamp is the only record of completion; the
/// report stays editable and can be reopened.
class _ReportCompletionFooter extends StatefulWidget {
  const _ReportCompletionFooter({
    required this.completedAt,
    required this.title,
    required this.completeLabel,
    required this.completedHint,
    required this.pendingHint,
    required this.completeKey,
    required this.reopenKey,
    required this.confirmReopenKey,
    required this.onSetCompleted,
    required this.snackbarText,
    this.confirmComplete,
  });

  final DateTime? completedAt;
  final String title;
  final String completeLabel;
  final String completedHint;
  final String pendingHint;
  final Key completeKey;
  final Key reopenKey;
  final Key confirmReopenKey;
  final Future<void> Function(bool completed) onSetCompleted;
  final String snackbarText;
  final _CompleteConfirmation? confirmComplete;

  @override
  State<_ReportCompletionFooter> createState() =>
      _ReportCompletionFooterState();
}

class _ReportCompletionFooterState extends State<_ReportCompletionFooter> {
  bool _busy = false;

  Future<void> _complete() async {
    final confirmation = widget.confirmComplete;
    if (confirmation != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(confirmation.title),
          content: Text(confirmation.body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              key: confirmation.confirmKey,
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmation.confirmLabel),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }
    await _setCompleted(true);
  }

  Future<void> _reopen() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reopen report?'),
        content: const Text(
          'The content is kept and the report stays editable.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: widget.confirmReopenKey,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reopen'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await _setCompleted(false);
  }

  Future<void> _setCompleted(bool completed) async {
    setState(() => _busy = true);
    try {
      await widget.onSetCompleted(completed);
      if (!mounted) return;
      if (completed) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(widget.snackbarText)));
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update the report: $error')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedAt = widget.completedAt;

    if (completedAt != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 6),
        child: Row(
          children: [
            Icon(Icons.task_alt, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${_dateTimeLabel(completedAt)} · ${widget.completedHint}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              key: widget.reopenKey,
              onPressed: _busy ? null : _reopen,
              child: const Text('Reopen'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FilledButton.icon(
            key: widget.completeKey,
            onPressed: _busy ? null : _complete,
            icon: const Icon(Icons.task_alt, size: 18),
            label: Text(widget.completeLabel),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 9),
              child: Text(
                widget.pendingHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _dateTimeLabel(DateTime time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '${shortDate(time)} at $hour:$minute';
}

class _IntakeNotesField extends StatefulWidget {
  const _IntakeNotesField({
    required this.ticketId,
    required this.repository,
    required this.initialNotes,
  });

  final int ticketId;
  final TicketsRepository repository;
  final String? initialNotes;

  @override
  State<_IntakeNotesField> createState() => _IntakeNotesFieldState();
}

class _IntakeNotesFieldState extends State<_IntakeNotesField> {
  late final TextEditingController _controller;
  late final FocusNode _focus;
  Timer? _timer;
  late String _savedText;
  bool _dirty = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _savedText = widget.initialNotes ?? '';
    _controller = TextEditingController(text: _savedText);
    _controller.addListener(_onChanged);
    _focus = FocusNode()..addListener(_onFocus);
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_dirty) {
      // Leaving the ticket mid-sentence still keeps the note.
      unawaited(
        widget.repository.saveIntakeNotes(widget.ticketId, _controller.text),
      );
    }
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onFocus() {
    if (!_focus.hasFocus && _dirty) _save();
  }

  void _onChanged() {
    final dirty = _controller.text != _savedText;
    setState(() {
      _dirty = dirty;
      _error = null;
    });
    _timer?.cancel();
    if (!dirty) return;
    _timer = Timer(const Duration(milliseconds: 800), _save);
  }

  Future<void> _save() async {
    _timer?.cancel();
    if (!_dirty || _saving) return;
    final text = _controller.text;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.repository.saveIntakeNotes(widget.ticketId, text);
      if (!mounted) return;
      setState(() {
        _saving = false;
        _savedText = text;
        _dirty = _controller.text != text;
      });
      if (_dirty) {
        _timer = Timer(const Duration(milliseconds: 800), _save);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Not saved. Keep typing to retry.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12, right: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: const Key('intake-notes'),
            controller: _controller,
            focusNode: _focus,
            minLines: 3,
            maxLines: 8,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Condition notes',
              hintText: 'Scratches, cracks, stickers, missing parts — anything '
                  'the photos do not show.',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 6),
          _status(theme),
        ],
      ),
    );
  }

  Widget _status(ThemeData theme) {
    final style = theme.textTheme.bodySmall;
    if (_error != null) {
      return Row(
        children: [
          Icon(Icons.error_outline, size: 15, color: theme.colorScheme.error),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              _error!,
              style: style?.copyWith(color: theme.colorScheme.error),
            ),
          ),
        ],
      );
    }
    if (_saving) {
      return Row(
        children: [
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 7),
          Text(
            'Saving…',
            style: style?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      );
    }
    if (_dirty) {
      return Text(
        'Not saved yet',
        style: style?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      );
    }
    if (_savedText.trim().isNotEmpty) {
      return Row(
        children: [
          Icon(Icons.check_circle_outline,
              size: 15, color: theme.colorScheme.primary),
          const SizedBox(width: 5),
          Text(
            'Saved to this ticket',
            style: style?.copyWith(color: theme.colorScheme.primary),
          ),
        ],
      );
    }
    return Text(
      'Saves automatically',
      style: style?.copyWith(color: theme.colorScheme.onSurfaceVariant),
    );
  }
}

class _SlotTrailing extends StatelessWidget {
  const _SlotTrailing({required this.slot, required this.onTap});

  final TicketPhotoSlotEntry slot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final path = slot.photoPath;
    if (path == null) {
      return Text(
        'not captured',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Tooltip(
      message: 'View photo',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(path),
            width: 52,
            height: 52,
            fit: BoxFit.cover,
            cacheWidth: 104,
            errorBuilder: (_, __, ___) => Container(
              width: 52,
              height: 52,
              color: theme.colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.broken_image_outlined,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void _showFullPhoto(BuildContext context, TicketPhotoSlotEntry slot) {
  final path = slot.photoPath;
  if (path == null) return;
  showDialog<void>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      return Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 900,
            maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(slot.label),
                subtitle: slot.hint == null ? null : Text(slot.hint!),
                trailing: IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ),
              Flexible(
                child: ColoredBox(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: InteractiveViewer(
                    maxScale: 4,
                    child: Image.file(
                      File(path),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Padding(
                        padding: EdgeInsets.all(40),
                        child: Icon(Icons.broken_image_outlined, size: 48),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
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
