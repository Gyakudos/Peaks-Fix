import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';

import '../../data/database.dart';

const _staffJobs = ['Admin', 'Front Desk', 'Tech 3', 'Tech 2', 'Tech 1'];

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AppDatabase _database = AppDatabase.instance;
  late Future<List<_StaffMember>> _staffFuture = _readStaff(_database);

  Future<void> _refreshStaff() async {
    setState(() => _staffFuture = _readStaff(_database));
  }

  Future<void> _addCategory() async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => const _NameDialog(
        title: 'Add device category',
        label: 'Category name',
      ),
    );
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty) return;
    try {
      final categories = await _database.select(_database.deviceCategories).get();
      final nextOrder = categories.fold<int>(
        0,
        (maxOrder, category) =>
            category.sortOrder >= maxOrder ? category.sortOrder + 1 : maxOrder,
      );
      await _database.into(_database.deviceCategories).insert(
            DeviceCategoriesCompanion.insert(
              name: trimmed,
              sortOrder: drift.Value(nextOrder),
            ),
          );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('That category already exists.')),
        );
      }
    }
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
    final roster = await _readStaff(_database);
    final index = roster.indexWhere((entry) => entry.id == member.id);
    if (index == -1) return;
    roster[index] = member.copyWith(isActive: isActive);
    await _writeJsonSetting(
      _database,
      'staff_roster',
      roster.map((entry) => entry.toJson()).toList(),
    );
    await _refreshStaff();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        children: [
          _SectionHeading(
            title: 'Device categories',
            action: FilledButton.icon(
              onPressed: _addCategory,
              icon: const Icon(Icons.add),
              label: const Text('Add category'),
            ),
          ),
          StreamBuilder<List<DeviceCategory>>(
            stream: (_database.select(_database.deviceCategories)
                  ..orderBy([
                    (category) => drift.OrderingTerm.asc(category.sortOrder),
                    (category) => drift.OrderingTerm.asc(category.name),
                  ]))
                .watch(),
            builder: (context, snapshot) {
              final categories = snapshot.data ?? const <DeviceCategory>[];
              if (categories.isEmpty) {
                return const ListTile(title: Text('No device categories yet.'));
              }
              return Column(
                children: categories
                    .map(
                      (category) => SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(category.name),
                        subtitle: Text(category.isActive ? 'Active' : 'Hidden'),
                        value: category.isActive,
                        onChanged: (active) => _database
                            .update(_database.deviceCategories)
                            .replace(category.copyWith(isActive: active)),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const Divider(height: 36),
          _SectionHeading(
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
                      (member) => SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(member.name),
                        subtitle: Text(member.job),
                        value: member.isActive,
                        onChanged: (active) => _setStaffActive(member, active),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const Divider(height: 36),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.punch_clock_outlined),
            title: const Text('Staff login / time clock'),
            subtitle: const Text('Sign in to start a shift or clock out.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const StaffClockPage(),
              ),
            ),
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
          .where((member) => member.isActive || clockedInIds.contains(member.id))
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
              const _SectionHeading(title: 'Sign in'),
              if (data.staff.isEmpty)
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('No active staff are available.'),
                )
              else
                ...data.staff.map((member) {
                  final matchingSessions = activeSessions
                    .where((entry) => entry.staffId == member.id);
                  final session = matchingSessions.isEmpty
                    ? null
                    : matchingSessions.first;
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
              const _SectionHeading(title: 'Recent shifts'),
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
  String _job = _staffJobs.first;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add staff'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _job,
            decoration: const InputDecoration(labelText: 'Staff job'),
            items: _staffJobs
                .map((job) => DropdownMenuItem(value: job, child: Text(job)))
                .toList(),
            onChanged: (job) {
              if (job != null) setState(() => _job = job);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;
            Navigator.pop(
              context,
              _StaffMember(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                name: name,
                job: _job,
              ),
            );
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.title, required this.label});

  final String title;
  final String label;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.title),
        content: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(labelText: widget.label),
          onSubmitted: (_) => Navigator.pop(context, _controller.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _controller.text),
            child: const Text('Add'),
          ),
        ],
      );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (action != null) action!,
          ],
        ),
      );
}

class _StaffMember {
  const _StaffMember({
    required this.id,
    required this.name,
    required this.job,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String job;
  final bool isActive;

  _StaffMember copyWith({bool? isActive}) => _StaffMember(
        id: id,
        name: name,
        job: job,
        isActive: isActive ?? this.isActive,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'job': job,
        'isActive': isActive,
      };

  factory _StaffMember.fromJson(Map<String, dynamic> json) => _StaffMember(
        id: json['id'] as String,
        name: json['name'] as String,
        job: json['job'] as String,
        isActive: json['isActive'] as bool? ?? true,
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

Future<void> _writeJsonSetting(
  AppDatabase database,
  String key,
  Object value,
) async {
  await database.into(database.settings).insertOnConflictUpdate(
        SettingsCompanion.insert(key: key, value: jsonEncode(value)),
      );
}

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
