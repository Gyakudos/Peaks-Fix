import 'dart:convert';

import 'package:flutter/material.dart';

import '../data/database.dart';
import '../data/staff_credentials.dart';

/// A staff member who can log in to the app.
class StaffAccount {
  const StaffAccount({
    required this.id,
    required this.name,
    required this.job,
    required this.username,
    required this.passwordSalt,
    required this.passwordHash,
  });

  final String id;
  final String name;
  final String job;
  final String username;
  final String passwordSalt;
  final String passwordHash;

  bool get isAdmin => job == AppAccess.adminJob;

  bool checkPassword(String password) =>
      StaffCredentials.verify(password, passwordSalt, passwordHash);
}

typedef StaffAccountLoader = Future<List<StaffAccount>> Function();

/// Reads the active staff with a username and password from the roster.
Future<List<StaffAccount>> loadStaffAccounts(AppDatabase database) async {
  final row = await (database.select(database.settings)
        ..where((setting) => setting.key.equals('staff_roster')))
      .getSingleOrNull();
  if (row == null) return const [];
  final accounts = <StaffAccount>[];
  for (final item in jsonDecode(row.value) as List<dynamic>) {
    final json = item as Map<String, dynamic>;
    final username = json['username'] as String? ?? '';
    final hash = json['passwordHash'] as String? ?? '';
    if (username.isEmpty || hash.isEmpty) continue;
    if (!(json['isActive'] as bool? ?? true)) continue;
    accounts.add(
      StaffAccount(
        id: json['id'] as String,
        name: json['name'] as String,
        job: json['job'] as String,
        username: username,
        passwordSalt: json['passwordSalt'] as String? ?? '',
        passwordHash: hash,
      ),
    );
  }
  return accounts;
}

/// What the signed-in job is allowed to do.
///
/// Admin can open everything and change every setting. Every other job gets
/// Tickets (including intake), Calendar, Inventory (view and add only) and
/// Staff Login.
class AppAccess {
  const AppAccess(this.job);

  const AppAccess.admin() : job = adminJob;

  static const String adminJob = 'Admin';
  static const Set<String> _limitedPages = {
    'Tickets',
    'Calendar',
    'Inventory',
    'Staff Login',
  };

  final String job;

  bool get isAdmin => job == adminJob;

  bool canOpen(String destinationLabel) =>
      isAdmin || _limitedPages.contains(destinationLabel);

  /// Editing or removing existing inventory is an admin task.
  bool get canChangeInventory => isAdmin;
}

/// Who is signed in. With no [user] the app is open (nobody has a login yet).
class AppSession extends ChangeNotifier {
  StaffAccount? _user;

  StaffAccount? get user => _user;

  AppAccess get access =>
      _user == null ? const AppAccess.admin() : AppAccess(_user!.job);

  void signIn(StaffAccount user) {
    _user = user;
    notifyListeners();
  }

  void signOut() {
    _user = null;
    notifyListeners();
  }
}

class AppSessionScope extends InheritedNotifier<AppSession> {
  const AppSessionScope({
    super.key,
    required AppSession session,
    required super.child,
  }) : super(notifier: session);

  static AppSession? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppSessionScope>()?.notifier;

  /// The access for this part of the tree; open (admin) with no session.
  static AppAccess accessOf(BuildContext context) =>
      maybeOf(context)?.access ?? const AppAccess.admin();
}

/// Shows a login screen until a staff member signs in.
///
/// The gate only applies once an active Admin has a username and password;
/// until then the app stays open so the shop cannot lock itself out.
class LoginGate extends StatefulWidget {
  const LoginGate({
    super.key,
    required this.session,
    required this.loadAccounts,
    required this.child,
  });

  final AppSession session;
  final StaffAccountLoader? loadAccounts;
  final Widget child;

  @override
  State<LoginGate> createState() => _LoginGateState();
}

class _LoginGateState extends State<LoginGate> {
  late Future<List<StaffAccount>> _accounts = _load();

  Future<List<StaffAccount>> _load() =>
      widget.loadAccounts?.call() ?? Future.value(const []);

  @override
  void initState() {
    super.initState();
    widget.session.addListener(_onSessionChanged);
  }

  @override
  void dispose() {
    widget.session.removeListener(_onSessionChanged);
    super.dispose();
  }

  /// Re-read the roster after sign-out so edits made meanwhile apply.
  void _onSessionChanged() {
    if (widget.session.user == null) {
      setState(() {
        _accounts = _load();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loadAccounts == null) return widget.child;
    return ListenableBuilder(
      listenable: widget.session,
      builder: (context, _) {
        if (widget.session.user != null) return widget.child;
        return FutureBuilder<List<StaffAccount>>(
          future: _accounts,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final accounts = snapshot.data!;
            if (!accounts.any((account) => account.isAdmin)) {
              return widget.child;
            }
            return _LoginScreen(
              accounts: accounts,
              onSignedIn: widget.session.signIn,
            );
          },
        );
      },
    );
  }
}

class _LoginScreen extends StatefulWidget {
  const _LoginScreen({required this.accounts, required this.onSignedIn});

  final List<StaffAccount> accounts;
  final ValueChanged<StaffAccount> onSignedIn;

  @override
  State<_LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<_LoginScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _username.text.trim().toLowerCase();
    for (final account in widget.accounts) {
      if (account.username.toLowerCase() == name &&
          account.checkPassword(_password.text)) {
        widget.onSignedIn(account);
        return;
      }
    }
    setState(() => _error = 'Wrong username or password.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Peaks Fix',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                TextField(
                  key: const Key('login-username'),
                  controller: _username,
                  autofocus: true,
                  autocorrect: false,
                  decoration: const InputDecoration(labelText: 'Username'),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('login-password'),
                  controller: _password,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: _error,
                  ),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('login-submit'),
                  onPressed: _submit,
                  child: const Text('Log in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
