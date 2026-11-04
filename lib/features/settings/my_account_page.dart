import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/schedule.dart';
import '../../data/shop_scope.dart';
import '../../data/staff_credentials.dart';
import '../../shell/app_access.dart';

/// The Settings page for everyone but Admin: their own account and the jobs
/// booked to them.
class MyAccountPage extends StatefulWidget {
  const MyAccountPage({super.key, this.database});

  final AppDatabase? database;

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  String? _message;
  bool _isError = false;
  Future<List<ScheduledJob>>? _jobs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _jobs ??= ShopScope.of(context).loadScheduledJobs();
  }

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _show(String message, {required bool error}) => setState(() {
        _message = message;
        _isError = error;
      });

  Future<void> _changePassword(StaffAccount user) async {
    if (_new.text.length < StaffCredentials.minPasswordLength) {
      _show(
        'Use at least ${StaffCredentials.minPasswordLength} characters.',
        error: true,
      );
      return;
    }
    if (_new.text != _confirm.text) {
      _show('The new passwords do not match.', error: true);
      return;
    }
    final changed = await changeStaffPassword(
      widget.database ?? AppDatabase.instance,
      staffId: user.id,
      currentPassword: _current.text,
      newPassword: _new.text,
    );
    if (!mounted) return;
    if (changed) {
      _current.clear();
      _new.clear();
      _confirm.clear();
    }
    _show(
      changed ? 'Password changed.' : 'Current password is incorrect.',
      error: !changed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AppSessionScope.maybeOf(context)?.user;
    final localizations = MaterialLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        children: [
          Text('My account', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          if (user == null)
            const Text('Sign in to see your account and jobs.')
          else ...[
            Text('${user.name} · ${user.job} · ${user.username}'),
            const SizedBox(height: 16),
            SizedBox(
              width: 360,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    key: const Key('account-current-password'),
                    controller: _current,
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: 'Current password'),
                  ),
                  TextField(
                    key: const Key('account-new-password'),
                    controller: _new,
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: 'New password'),
                  ),
                  TextField(
                    key: const Key('account-confirm-password'),
                    controller: _confirm,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm new password',
                    ),
                  ),
                  if (_message != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _message!,
                        key: const Key('account-message'),
                        style: TextStyle(
                          color: _isError ? theme.colorScheme.error : null,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton(
                      key: const Key('account-change-password'),
                      onPressed: () => _changePassword(user),
                      child: const Text('Change password'),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Divider(height: 36),
          Text('My jobs', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          FutureBuilder<List<ScheduledJob>>(
            future: _jobs,
            builder: (context, snapshot) {
              final today = DateUtils.dateOnly(DateTime.now());
              final mine = [
                for (final job in snapshot.data ?? const <ScheduledJob>[])
                  if (user != null &&
                      job.techId == user.id &&
                      !job.date.isBefore(today))
                    job,
              ]..sort((a, b) => a.date.compareTo(b.date));
              if (mine.isEmpty) {
                return const Text('No upcoming jobs are scheduled to you.');
              }
              return Column(
                children: [
                  for (final job in mine)
                    ListTile(
                      key: Key('my-job-${job.id}'),
                      leading: const Icon(Icons.engineering),
                      title: Text('${job.ticketNumber} · ${job.customerName}'),
                      subtitle: Text(
                        [
                          localizations.formatMediumDate(job.date),
                          if (job.note.isNotEmpty) job.note,
                        ].join(' · '),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
