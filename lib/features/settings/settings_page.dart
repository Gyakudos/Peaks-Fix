import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/database.dart';
import '../../data/taxes.dart';
import '../tickets/ticket_detail_page.dart';
import '../tickets/ticket_widgets.dart';
import 'device_catalog_section.dart';
import 'section_heading.dart';

const _staffJobs = ['Admin', 'Front Desk', 'Tech 3', 'Tech 2', 'Tech 1'];
const _invalidPayMessage =
    'Enter an hourly pay of \$0 or more, or leave it blank.';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, this.database});

  /// Supplied by tests; the app uses the shared database.
  final AppDatabase? database;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final AppDatabase _database = widget.database ?? AppDatabase.instance;
  late Future<List<_StaffMember>> _staffFuture = _readStaff(_database);

  Future<void> _refreshStaff() async {
    setState(() {
      _staffFuture = _readStaff(_database);
    });
  }

  Future<void> _addStaff() async {
    final staff = await showDialog<_StaffMember>(
      context: context,
      builder: (context) => const _AddStaffDialog(),
    );
    if (!mounted || staff == null) return;
    final roster = await _readStaff(_database);
    roster.add(staff);
    await _writeJsonSetting(
      _database,
      'staff_roster',
      roster.map((member) => member.toJson()).toList(),
    );
    await _refreshStaff();
  }

  Future<void> _setStaffActive(_StaffMember member, bool isActive) async {
    await _replaceStaff(member.copyWith(isActive: isActive));
  }

  Future<void> _editStaff(_StaffMember member) async {
    final updated = await showDialog<_StaffMember>(
      context: context,
      builder: (context) => _EditStaffDialog(member: member),
    );
    if (!mounted || updated == null) return;
    await _replaceStaff(updated);
  }

  Future<void> _replaceStaff(_StaffMember member) async {
    final roster = await _readStaff(_database);
    final index = roster.indexWhere((entry) => entry.id == member.id);
    if (index == -1) return;
    roster[index] = member;
    await _writeJsonSetting(
      _database,
      'staff_roster',
      roster.map((entry) => entry.toJson()).toList(),
    );
    await _refreshStaff();
  }

  void _openStaffHours(_StaffMember member) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => StaffHoursPage(
          staffId: member.id,
          staffName: member.name,
          database: _database,
        ),
      ),
    );
  }

  void _openStaffTickets(_StaffMember member) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => StaffTicketsPage(
          staffId: member.id,
          staffName: member.name,
          database: _database,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        children: [
          DeviceCatalogSection(database: _database),
          const Divider(height: 36),
          _TaxSettings(database: _database),
          const Divider(height: 36),
          _MarkupSettings(database: _database),
          const Divider(height: 36),
          SectionHeading(
            title: 'Staff',
            action: FilledButton.icon(
              onPressed: _addStaff,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Add staff'),
            ),
          ),
          FutureBuilder<List<_StaffMember>>(
            future: _staffFuture,
            builder: (context, snapshot) {
              final staff = snapshot.data ?? const <_StaffMember>[];
              if (staff.isEmpty) {
                return const ListTile(title: Text('No staff added yet.'));
              }
              return Column(
                children: staff
                    .map(
                      (member) => _StaffCard(
                        member: member,
                        onActiveChanged: (active) =>
                            _setStaffActive(member, active),
                        onEdit: () => _editStaff(member),
                        onHours: () => _openStaffHours(member),
                        onTickets: () => _openStaffTickets(member),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class StaffClockPage extends StatefulWidget {
  const StaffClockPage({super.key});

  @override
  State<StaffClockPage> createState() => _StaffClockPageState();
}

class _StaffClockPageState extends State<StaffClockPage> {
  final AppDatabase _database = AppDatabase.instance;
  late Future<_ClockData> _dataFuture = _load();

  Future<_ClockData> _load() async {
    final staff = await _readStaff(_database);
    final sessions = await _readSessions(_database);
    final clockedInIds = sessions
        .where((session) => session.clockOutAt == null)
        .map((session) => session.staffId)
        .toSet();
    return _ClockData(
      staff: staff
          .where(
              (member) => member.isActive || clockedInIds.contains(member.id))
          .toList(),
      sessions: sessions,
    );
  }

  void _refresh() {
    setState(() => _dataFuture = _load());
  }

  Future<void> _clockIn(_StaffMember member) async {
    final sessions = await _readSessions(_database);
    if (sessions.any((session) =>
        session.staffId == member.id && session.clockOutAt == null)) {
      return;
    }
    sessions.insert(
      0,
      _ClockSession(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        staffId: member.id,
        name: member.name,
        job: member.job,
        clockInAt: DateTime.now(),
      ),
    );
    await _writeJsonSetting(
      _database,
      'staff_clock_sessions',
      sessions.map((session) => session.toJson()).toList(),
    );
    _refresh();
  }

  Future<void> _clockOut(_ClockSession session) async {
    final sessions = await _readSessions(_database);
    final index = sessions.indexWhere((entry) => entry.id == session.id);
    if (index == -1) return;
    sessions[index] = session.copyWith(clockOutAt: DateTime.now());
    await _writeJsonSetting(
      _database,
      'staff_clock_sessions',
      sessions.map((entry) => entry.toJson()).toList(),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff login / time clock')),
      body: FutureBuilder<_ClockData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          final activeSessions = data.sessions
              .where((session) => session.clockOutAt == null)
              .toList();
          final recentSessions = data.sessions.take(8).toList();
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SectionHeading(title: 'Sign in'),
              if (data.staff.isEmpty)
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('No active staff are available.'),
                )
              else
                ...data.staff.map((member) {
                  final matchingSessions = activeSessions
                      .where((entry) => entry.staffId == member.id);
                  final session =
                      matchingSessions.isEmpty ? null : matchingSessions.first;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      child: Icon(Icons.person_outline),
                    ),
                    title: Text(member.name),
                    subtitle: Text(session == null
                        ? member.job
                        : '${member.job} · Since ${_formatTime(session.clockInAt)}'),
                    trailing: session == null
                        ? FilledButton(
                            onPressed: () => _clockIn(member),
                            child: const Text('Sign in'),
                          )
                        : OutlinedButton.icon(
                            onPressed: () => _clockOut(session),
                            icon: const Icon(Icons.logout),
                            label: const Text('Clock out'),
                          ),
                  );
                }),
              const Divider(height: 36),
              const SectionHeading(title: 'Recent shifts'),
              if (recentSessions.isEmpty)
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('No shifts recorded yet.'),
                )
              else
                ...recentSessions.map(
                  (session) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${session.name} · ${session.job}'),
                    subtitle: Text(
                      '${_formatDateTime(session.clockInAt)} – '
                      '${session.clockOutAt == null ? 'In progress' : _formatDateTime(session.clockOutAt!)}',
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _AddStaffDialog extends StatefulWidget {
  const _AddStaffDialog();

  @override
  State<_AddStaffDialog> createState() => _AddStaffDialogState();
}

class _AddStaffDialogState extends State<_AddStaffDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  String _job = _staffJobs.first;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add staff'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('staff-name-field'),
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _job,
              decoration: const InputDecoration(labelText: 'Staff job'),
              items: _staffJobs
                  .map((job) => DropdownMenuItem(value: job, child: Text(job)))
                  .toList(),
              onChanged: (job) {
                if (job != null) setState(() => _job = job);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('staff-rate-field'),
              controller: _rateController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Hourly pay',
                prefixText: '\$',
                suffixText: '/hr',
                helperText: 'Optional. Used to estimate tracked pay.',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
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
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('staff-add-save'),
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) {
              setState(() => _error = 'Enter a name.');
              return;
            }
            final rate = _parseHourlyRateCents(_rateController.text);
            if (rate == null) {
              setState(() => _error = _invalidPayMessage);
              return;
            }
            Navigator.pop(
              context,
              _StaffMember(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                name: name,
                job: _job,
                hourlyRateCents: rate,
              ),
            );
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _StaffCard extends StatelessWidget {
  const _StaffCard({
    required this.member,
    required this.onActiveChanged,
    required this.onEdit,
    required this.onHours,
    required this.onTickets,
  });

  final _StaffMember member;
  final ValueChanged<bool> onActiveChanged;
  final VoidCallback onEdit;
  final VoidCallback onHours;
  final VoidCallback onTickets;

  @override
  Widget build(BuildContext context) {
    final subtitle = member.isActive
        ? '${member.job} · ${member.rateLabel}'
        : '${member.job} · ${member.rateLabel} · Inactive';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.person_outline)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(subtitle),
                    ],
                  ),
                ),
                Switch(
                  value: member.isActive,
                  onChanged: onActiveChanged,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                TextButton.icon(
                  key: Key('staff-edit-${member.id}'),
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  key: Key('staff-hours-${member.id}'),
                  onPressed: onHours,
                  icon: const Icon(Icons.schedule_outlined),
                  label: const Text('Hours'),
                ),
                TextButton.icon(
                  key: Key('staff-tickets-${member.id}'),
                  onPressed: onTickets,
                  icon: const Icon(Icons.confirmation_number_outlined),
                  label: const Text('Tickets'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EditStaffDialog extends StatefulWidget {
  const _EditStaffDialog({required this.member});

  final _StaffMember member;

  @override
  State<_EditStaffDialog> createState() => _EditStaffDialogState();
}

class _EditStaffDialogState extends State<_EditStaffDialog> {
  late final TextEditingController _nameController =
      TextEditingController(text: widget.member.name);
  late final TextEditingController _rateController = TextEditingController(
    text: widget.member.hourlyRateCents <= 0
        ? ''
        : (widget.member.hourlyRateCents / 100).toStringAsFixed(2),
  );
  late String _job = widget.member.job;
  late bool _isActive = widget.member.isActive;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobs = <String>[
      widget.member.job,
      ..._staffJobs.where((job) => job != widget.member.job),
    ];
    return AlertDialog(
      title: const Text('Edit staff'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('staff-name-field'),
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _job,
              decoration: const InputDecoration(labelText: 'Staff job'),
              items: jobs
                  .map((job) => DropdownMenuItem(value: job, child: Text(job)))
                  .toList(),
              onChanged: (job) {
                if (job != null) setState(() => _job = job);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('staff-rate-field'),
              controller: _rateController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Hourly pay',
                prefixText: '\$',
                suffixText: '/hr',
                helperText: 'Optional. Used to estimate tracked pay.',
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active'),
              subtitle: const Text(
                'Inactive staff stay in ticket history but are hidden from sign-in.',
              ),
              value: _isActive,
              onChanged: (active) => setState(() => _isActive = active),
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
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('staff-edit-save'),
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) {
              setState(() => _error = 'Enter a name.');
              return;
            }
            final rate = _parseHourlyRateCents(_rateController.text);
            if (rate == null) {
              setState(() => _error = _invalidPayMessage);
              return;
            }
            Navigator.pop(
              context,
              widget.member.copyWith(
                name: name,
                job: _job,
                isActive: _isActive,
                hourlyRateCents: rate,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class StaffHoursPage extends StatefulWidget {
  const StaffHoursPage({
    super.key,
    required this.staffId,
    required this.staffName,
    this.database,
  });

  final String staffId;
  final String staffName;

  /// Supplied by tests; the app uses the shared database.
  final AppDatabase? database;

  @override
  State<StaffHoursPage> createState() => _StaffHoursPageState();
}

class _StaffHoursPageState extends State<StaffHoursPage> {
  late final AppDatabase _database = widget.database ?? AppDatabase.instance;
  late final Future<_StaffHoursData> _future = _load();

  Future<_StaffHoursData> _load() async {
    final roster = await _readStaff(_database);
    final sessions = await _readSessions(_database);
    _StaffMember? member;
    for (final entry in roster) {
      if (entry.id == widget.staffId) member = entry;
    }
    final shifts = sessions
        .where((session) => session.staffId == widget.staffId)
        .toList()
      ..sort((a, b) => b.clockInAt.compareTo(a.clockInAt));
    return _StaffHoursData(member: member, shifts: shifts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.staffName} · Hours')),
      body: FutureBuilder<_StaffHoursData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data;
          if (data == null || data.member == null) {
            return const Center(
              child: Text('This staff member no longer exists.'),
            );
          }
          final member = data.member!;
          final now = DateTime.now();
          final total = data.shifts.fold<Duration>(
            Duration.zero,
            (sum, shift) => sum + _shiftDuration(shift, now),
          );
          final weekStart = DateTime(now.year, now.month, now.day)
              .subtract(Duration(days: now.weekday - 1));
          final week = data.shifts
              .where((shift) => !shift.clockInAt.isBefore(weekStart))
              .fold<Duration>(
                Duration.zero,
                (sum, shift) => sum + _shiftDuration(shift, now),
              );
          final payCents = _estimatedPayCents(total, member.hourlyRateCents);
          final active =
              data.shifts.where((shift) => shift.clockOutAt == null).toList();
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StaffStatCard(
                    icon: Icons.schedule_outlined,
                    label: 'Total tracked',
                    value: _formatDuration(total),
                    note: '${data.shifts.length} shift'
                        '${data.shifts.length == 1 ? '' : 's'}',
                  ),
                  _StaffStatCard(
                    icon: Icons.date_range_outlined,
                    label: 'This week',
                    value: _formatDuration(week),
                  ),
                  _StaffStatCard(
                    icon: Icons.payments_outlined,
                    label: 'Estimated pay',
                    value: payCents == null
                        ? 'Set a rate'
                        : _formatMoney(payCents),
                    note: payCents == null
                        ? 'Add hourly pay from Edit.'
                        : '${member.rateLabel} · tracked time',
                  ),
                ],
              ),
              if (active.isNotEmpty) ...[
                const SizedBox(height: 12),
                Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: const Icon(Icons.punch_clock_outlined),
                    title: const Text('On the clock now'),
                    subtitle: Text(
                      'Since ${_formatDateTime(active.first.clockInAt)} · '
                      '${_formatDuration(_shiftDuration(active.first, now))}',
                    ),
                  ),
                ),
              ],
              const Divider(height: 36),
              const SectionHeading(title: 'Shift history'),
              if (data.shifts.isEmpty)
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('No shifts recorded yet.'),
                )
              else
                ...data.shifts.map((shift) {
                  final duration = _shiftDuration(shift, now);
                  final shiftPay =
                      _estimatedPayCents(duration, member.hourlyRateCents);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_formatDateTime(shift.clockInAt)),
                    subtitle: Text(
                      shift.clockOutAt == null
                          ? 'In progress · ${_formatDuration(duration)}'
                          : '${_formatTime(shift.clockOutAt!)} · '
                              '${_formatDuration(duration)}',
                    ),
                    trailing:
                        shiftPay == null ? null : Text(_formatMoney(shiftPay)),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

class StaffTicketsPage extends StatefulWidget {
  const StaffTicketsPage({
    super.key,
    required this.staffId,
    required this.staffName,
    this.database,
  });

  final String staffId;
  final String staffName;

  /// Supplied by tests; the app uses the shared database.
  final AppDatabase? database;

  @override
  State<StaffTicketsPage> createState() => _StaffTicketsPageState();
}

class _StaffTicketsPageState extends State<StaffTicketsPage> {
  late final AppDatabase _database = widget.database ?? AppDatabase.instance;
  late final Future<List<_StaffTicket>> _future =
      _readStaffTickets(_database, widget.staffId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.staffName} · Tickets')),
      body: FutureBuilder<List<_StaffTicket>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final tickets = snapshot.data ?? const <_StaffTicket>[];
          if (tickets.isEmpty) {
            return const Center(
              child: Text('No tickets are assigned to this staff member yet.'),
            );
          }
          final open = tickets.where((ticket) => ticket.status.isActive).length;
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text('$open open')),
                  Chip(label: Text('${tickets.length} total')),
                ],
              ),
              const SizedBox(height: 16),
              ...tickets.map(
                (ticket) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    key: Key('staff-ticket-${ticket.id}'),
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) =>
                            TicketDetailPage(ticketId: ticket.id),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${ticket.number} · ${ticket.deviceName}',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                              const SizedBox(width: 8),
                              TicketStatusChip(status: ticket.status),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(ticket.customerName),
                          const SizedBox(height: 2),
                          Text(
                            'Assigned: ${_reportKindsLabel(ticket.reports)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StaffStatCard extends StatelessWidget {
  const _StaffStatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.note,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 210,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(label, style: theme.textTheme.bodySmall),
              const SizedBox(height: 2),
              Text(value, style: theme.textTheme.titleLarge),
              if (note != null) ...[
                const SizedBox(height: 4),
                Text(note!, style: theme.textTheme.bodySmall),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TaxSettings extends StatefulWidget {
  const _TaxSettings({required this.database});

  final AppDatabase database;

  @override
  State<_TaxSettings> createState() => _TaxSettingsState();
}

class _TaxSettingsState extends State<_TaxSettings> {
  final _gstRateController = TextEditingController();
  final _pstRateController = TextEditingController();
  bool _gstEnabled = false;
  bool _pstEnabled = false;
  bool _loaded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _gstRateController.dispose();
    _pstRateController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final config = await widget.database.taxConfig();
    if (!mounted) return;
    setState(() {
      _gstEnabled = config.gstEnabled;
      _pstEnabled = config.pstEnabled;
      _gstRateController.text = _rateText(config.gstRateBp);
      _pstRateController.text = _rateText(config.pstRateBp);
      _loaded = true;
    });
  }

  Future<void> _save() async {
    final gst = _parseRate(_gstRateController.text);
    final pst = _parseRate(_pstRateController.text);
    if (gst == null || pst == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter tax rates from 0% to 50%.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.database.setTaxConfig(
        TaxConfig(
          gstEnabled: _gstEnabled,
          gstRateBp: gst,
          pstEnabled: _pstEnabled,
          pstRateBp: pst,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sales tax saved.')),
      );
      setState(() {});
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save sales tax: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  static String _rateText(int rateBp) {
    final whole = rateBp ~/ 100;
    final fraction = rateBp % 100;
    if (fraction == 0) return '$whole';
    if (fraction % 10 == 0) return '$whole.${fraction ~/ 10}';
    return '$whole.${fraction.toString().padLeft(2, '0')}';
  }

  static int? _parseRate(String input) {
    final value = double.tryParse(input.trim());
    if (value == null || !value.isFinite || value < 0 || value > 50) {
      return null;
    }
    return (value * 100).round();
  }

  Widget _taxCard({
    required String label,
    required String description,
    required Key switchKey,
    required Key rateKey,
    required bool enabled,
    required ValueChanged<bool> onChanged,
    required TextEditingController rateController,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            key: switchKey,
            value: enabled,
            onChanged: _saving ? null : onChanged,
            title: Text(label),
            subtitle: Text(description),
            secondary: const Icon(Icons.percent),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              key: rateKey,
              controller: rateController,
              enabled: !_saving,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: '$label rate',
                suffixText: '%',
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeading(title: 'Sales tax'),
        if (!_loaded)
          const LinearProgressIndicator()
        else ...[
          Text(
            'Invoices add the enabled taxes after discounts. GST defaults to '
            '5%; PST starts off at 7%.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          _taxCard(
            label: 'GST',
            description: 'Goods and services tax',
            switchKey: const Key('tax-gst-enabled'),
            rateKey: const Key('tax-gst-rate'),
            enabled: _gstEnabled,
            onChanged: (value) => setState(() => _gstEnabled = value),
            rateController: _gstRateController,
          ),
          const SizedBox(height: 8),
          _taxCard(
            label: 'PST',
            description: 'Provincial sales tax',
            switchKey: const Key('tax-pst-enabled'),
            rateKey: const Key('tax-pst-rate'),
            enabled: _pstEnabled,
            onChanged: (value) => setState(() => _pstEnabled = value),
            rateController: _pstRateController,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              key: const Key('tax-save'),
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save taxes'),
            ),
          ),
        ],
      ],
    );
  }
}

class _MarkupSettings extends StatefulWidget {
  const _MarkupSettings({required this.database});

  final AppDatabase database;

  @override
  State<_MarkupSettings> createState() => _MarkupSettingsState();
}

class _MarkupSettingsState extends State<_MarkupSettings> {
  final _partsMarkupController = TextEditingController();
  final _partsCostController = TextEditingController(text: '100.00');
  final _merchMarkupController = TextEditingController();
  final _merchCostController = TextEditingController(text: '100.00');
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _partsMarkupController.dispose();
    _partsCostController.dispose();
    _merchMarkupController.dispose();
    _merchCostController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final parts =
        await widget.database.markupPercent('parts_markup_percent', 35);
    final merch =
        await widget.database.markupPercent('merch_markup_percent', 45);
    if (!mounted) return;
    setState(() {
      _partsMarkupController.text = '$parts';
      _merchMarkupController.text = '$merch';
      _loaded = true;
    });
  }

  int? _priceCents(TextEditingController costController,
      TextEditingController markupController) {
    final cost = double.tryParse(costController.text.trim());
    final markup = int.tryParse(markupController.text.trim());
    if (cost == null ||
        !cost.isFinite ||
        cost < 0 ||
        markup == null ||
        markup < 0 ||
        markup > 500) {
      return null;
    }
    final costCents = (cost * 100).round();
    return (costCents * (100 + markup) + 50) ~/ 100;
  }

  Future<void> _save(String key, TextEditingController controller) async {
    final markup = int.tryParse(controller.text.trim());
    if (markup == null || markup < 0 || markup > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a markup from 0% to 500%.')),
      );
      return;
    }
    try {
      await widget.database.setMarkupPercent(key, markup);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Markup saved.')),
      );
      setState(() {});
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save markup: $error')),
      );
    }
  }

  Widget _calculator({
    required String title,
    required String keyPrefix,
    required String settingKey,
    required TextEditingController markupController,
    required TextEditingController costController,
  }) {
    final price = _priceCents(costController, markupController);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  child: TextField(
                    key: Key('$keyPrefix-markup'),
                    controller: markupController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Markup',
                      suffixText: '%',
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                SizedBox(
                  width: 170,
                  child: TextField(
                    key: Key('$keyPrefix-cost'),
                    controller: costController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Example cost',
                      prefixText: '\$',
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                FilledButton.icon(
                  key: Key('$keyPrefix-save'),
                  onPressed: () => _save(settingKey, markupController),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              price == null
                  ? 'Enter a valid cost and markup.'
                  : 'Suggested retail: \$${(price / 100).toStringAsFixed(2)}',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeading(title: 'Pricing markups'),
        if (!_loaded)
          const LinearProgressIndicator()
        else ...[
          _calculator(
            title: 'Parts',
            keyPrefix: 'parts',
            settingKey: 'parts_markup_percent',
            markupController: _partsMarkupController,
            costController: _partsCostController,
          ),
          const SizedBox(height: 8),
          _calculator(
            title: 'Merch',
            keyPrefix: 'merch',
            settingKey: 'merch_markup_percent',
            markupController: _merchMarkupController,
            costController: _merchCostController,
          ),
        ],
      ],
    );
  }
}

class _StaffMember {
  const _StaffMember({
    required this.id,
    required this.name,
    required this.job,
    this.isActive = true,
    this.hourlyRateCents = 0,
  });

  final String id;
  final String name;
  final String job;
  final bool isActive;
  final int hourlyRateCents;

  String get rateLabel => hourlyRateCents <= 0
      ? 'Pay not set'
      : '${_formatMoney(hourlyRateCents)}/hr';

  _StaffMember copyWith({
    String? name,
    String? job,
    bool? isActive,
    int? hourlyRateCents,
  }) =>
      _StaffMember(
        id: id,
        name: name ?? this.name,
        job: job ?? this.job,
        isActive: isActive ?? this.isActive,
        hourlyRateCents: hourlyRateCents ?? this.hourlyRateCents,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'job': job,
        'isActive': isActive,
        'hourlyRateCents': hourlyRateCents,
      };

  factory _StaffMember.fromJson(Map<String, dynamic> json) => _StaffMember(
        id: json['id'] as String,
        name: json['name'] as String,
        job: json['job'] as String,
        isActive: json['isActive'] as bool? ?? true,
        hourlyRateCents: (json['hourlyRateCents'] as num?)?.toInt() ?? 0,
      );
}

class _ClockSession {
  const _ClockSession({
    required this.id,
    required this.staffId,
    required this.name,
    required this.job,
    required this.clockInAt,
    this.clockOutAt,
  });

  final String id;
  final String staffId;
  final String name;
  final String job;
  final DateTime clockInAt;
  final DateTime? clockOutAt;

  _ClockSession copyWith({DateTime? clockOutAt}) => _ClockSession(
        id: id,
        staffId: staffId,
        name: name,
        job: job,
        clockInAt: clockInAt,
        clockOutAt: clockOutAt ?? this.clockOutAt,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'staffId': staffId,
        'name': name,
        'job': job,
        'clockInAt': clockInAt.toIso8601String(),
        'clockOutAt': clockOutAt?.toIso8601String(),
      };

  factory _ClockSession.fromJson(Map<String, dynamic> json) => _ClockSession(
        id: json['id'] as String,
        staffId: json['staffId'] as String,
        name: json['name'] as String,
        job: json['job'] as String,
        clockInAt: DateTime.parse(json['clockInAt'] as String),
        clockOutAt: json['clockOutAt'] == null
            ? null
            : DateTime.parse(json['clockOutAt'] as String),
      );
}

class _StaffHoursData {
  const _StaffHoursData({required this.member, required this.shifts});

  final _StaffMember? member;
  final List<_ClockSession> shifts;
}

class _StaffTicket {
  const _StaffTicket({
    required this.id,
    required this.number,
    required this.status,
    required this.customerName,
    required this.deviceName,
    required this.createdAt,
    required this.reports,
  });

  final int id;
  final String number;
  final TicketStatus status;
  final String customerName;
  final String deviceName;
  final DateTime createdAt;
  final Set<ReportKind> reports;
}

class _ClockData {
  const _ClockData({required this.staff, required this.sessions});

  final List<_StaffMember> staff;
  final List<_ClockSession> sessions;
}

Future<List<_StaffMember>> _readStaff(AppDatabase database) async {
  final row = await (database.select(database.settings)
        ..where((setting) => setting.key.equals('staff_roster')))
      .getSingleOrNull();
  if (row == null) return [];
  final items = jsonDecode(row.value) as List<dynamic>;
  return items
      .map((item) => _StaffMember.fromJson(item as Map<String, dynamic>))
      .toList();
}

Future<List<_ClockSession>> _readSessions(AppDatabase database) async {
  final row = await (database.select(database.settings)
        ..where((setting) => setting.key.equals('staff_clock_sessions')))
      .getSingleOrNull();
  if (row == null) return [];
  final items = jsonDecode(row.value) as List<dynamic>;
  return items
      .map((item) => _ClockSession.fromJson(item as Map<String, dynamic>))
      .toList();
}

Future<List<_StaffTicket>> _readStaffTickets(
  AppDatabase database,
  String staffId,
) async {
  final assignments = <int, Set<ReportKind>>{};
  final pattern = RegExp(r'^ticket_staff_(\d+)_(intake|technical|client)$');
  final rows = await (database.select(database.settings)
        ..where((setting) => setting.key.like('ticket_staff_%')))
      .get();
  for (final row in rows) {
    if (row.value != staffId) continue;
    final match = pattern.firstMatch(row.key);
    if (match == null) continue;
    final ticketId = int.tryParse(match.group(1)!);
    if (ticketId == null) continue;
    ReportKind? reportKind;
    for (final kind in ReportKind.values) {
      if (kind.name == match.group(2)) reportKind = kind;
    }
    if (reportKind == null) continue;
    assignments.putIfAbsent(ticketId, () => <ReportKind>{}).add(reportKind);
  }
  if (assignments.isEmpty) return const [];

  final query = database.select(database.tickets).join([
    drift.innerJoin(
      database.customers,
      database.customers.id.equalsExp(database.tickets.customerId),
    ),
    drift.leftOuterJoin(
      database.deviceModels,
      database.deviceModels.id.equalsExp(database.tickets.deviceModelId),
    ),
  ])
    ..where(database.tickets.id.isIn(assignments.keys));
  final ticketRows = await query.get();

  final tickets = [
    for (final row in ticketRows)
      _StaffTicket(
        id: row.readTable(database.tickets).id,
        number: row.readTable(database.tickets).number,
        status: row.readTable(database.tickets).status,
        customerName: row.readTable(database.customers).name,
        deviceName: row.readTableOrNull(database.deviceModels)?.name ??
            row.readTable(database.tickets).deviceName ??
            'Unlisted device',
        createdAt: row.readTable(database.tickets).createdAt,
        reports: assignments[row.readTable(database.tickets).id] ??
            const <ReportKind>{},
      ),
  ];
  tickets.sort((a, b) {
    if (a.status.isActive != b.status.isActive) {
      return a.status.isActive ? -1 : 1;
    }
    return b.createdAt.compareTo(a.createdAt);
  });
  return tickets;
}

Future<void> _writeJsonSetting(
  AppDatabase database,
  String key,
  Object value,
) async {
  await database.into(database.settings).insertOnConflictUpdate(
        SettingsCompanion.insert(key: key, value: jsonEncode(value)),
      );
}

int? _parseHourlyRateCents(String text) {
  final cleaned = text.trim().replaceAll('\$', '').replaceAll(',', '');
  if (cleaned.isEmpty) return 0;
  final value = double.tryParse(cleaned);
  if (value == null || !value.isFinite || value < 0 || value > 100000) {
    return null;
  }
  return (value * 100).round();
}

String _formatMoney(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

String _formatDuration(Duration duration) {
  if (duration.inSeconds < 60) return '${duration.inSeconds}s';
  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;
  if (hours == 0) return '${minutes}m';
  return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
}

Duration _shiftDuration(_ClockSession session, DateTime now) {
  final duration = (session.clockOutAt ?? now).difference(session.clockInAt);
  return duration.isNegative ? Duration.zero : duration;
}

int? _estimatedPayCents(Duration duration, int hourlyRateCents) {
  if (hourlyRateCents <= 0) return null;
  return (duration.inSeconds * hourlyRateCents / 3600).round();
}

String _reportKindLabel(ReportKind kind) => switch (kind) {
      ReportKind.intake => 'Intake',
      ReportKind.technical => 'Technical',
      ReportKind.client => 'Client',
    };

String _reportKindsLabel(Set<ReportKind> kinds) =>
    ReportKind.values.where(kinds.contains).map(_reportKindLabel).join(', ');

String _formatTime(DateTime dateTime) {
  final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = dateTime.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

String _formatDateTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  final date = '${local.month}/${local.day}/${local.year}';
  return '$date ${_formatTime(local)}';
}
