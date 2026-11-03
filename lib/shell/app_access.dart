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

/// Creates the shop's first Admin login and returns it.
typedef AdminCreator = Future<StaffAccount> Function(
  String name,
  String username,
  String password,
);

/// Adds an Admin to the staff roster with a salted password hash.
Future<StaffAccount> createFirstAdmin(
  AppDatabase database, {
  required String name,
  required String username,
  required String password,
}) async {
  final row = await (database.select(database.settings)
        ..where((setting) => setting.key.equals('staff_roster')))
      .getSingleOrNull();
  final roster = row == null
      ? <dynamic>[]
      : List<dynamic>.of(jsonDecode(row.value) as List<dynamic>);
  final salt = StaffCredentials.newSalt();
  final hash = StaffCredentials.hash(password, salt);
  final id = DateTime.now().microsecondsSinceEpoch.toString();
  roster.add({
    'id': id,
    'name': name,
    'job': AppAccess.adminJob,
    'isActive': true,
    'hourlyRateCents': 0,
    'phone': '',
    'email': '',
    'address': '',
    'username': username,
    'passwordSalt': salt,
    'passwordHash': hash,
  });
  await database.writeSetting('staff_roster', jsonEncode(roster));
  return StaffAccount(
    id: id,
    name: name,
    job: AppAccess.adminJob,
    username: username,
    passwordSalt: salt,
    passwordHash: hash,
  );
}

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
    this.createAdmin,
    required this.child,
  });

  final AppSession session;
  final StaffAccountLoader? loadAccounts;

  /// When set, a shop with no Admin login must create one before using the
  /// app. When null the app stays open until an Admin exists.
  final AdminCreator? createAdmin;
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
              final create = widget.createAdmin;
              if (create == null) return widget.child;
              return _AdminSetupScreen(
                createAdmin: create,
                onCreated: widget.session.signIn,
              );
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

/// First-run screen: the shop owner creates the Admin login.
class _AdminSetupScreen extends StatefulWidget {
  const _AdminSetupScreen({required this.createAdmin, required this.onCreated});

  final AdminCreator createAdmin;
  final ValueChanged<StaffAccount> onCreated;

  @override
  State<_AdminSetupScreen> createState() => _AdminSetupScreenState();
}

class _AdminSetupScreenState extends State<_AdminSetupScreen> {
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    final username = _username.text.trim();
    String? problem;
    if (name.isEmpty || username.isEmpty) {
      problem = 'Enter your name and a username.';
    } else if (_password.text.length < StaffCredentials.minPasswordLength) {
      problem = 'Password must be at least '
          '${StaffCredentials.minPasswordLength} characters.';
    } else if (_password.text != _confirm.text) {
      problem = 'The passwords do not match.';
    }
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final account = await widget.createAdmin(name, username, _password.text);
      widget.onCreated(account);
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not create the login: $error';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome to Peaks Fix',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create the Admin login for this shop. Staff logins are '
                  'added later in Settings. Keep this password safe: it '
                  'cannot be recovered.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  key: const Key('setup-name'),
                  controller: _name,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Your name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('setup-username'),
                  controller: _username,
                  autocorrect: false,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('setup-password'),
                  controller: _password,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('setup-confirm'),
                  controller: _confirm,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: 'Confirm password',
                    errorText: _error,
                    errorMaxLines: 3,
                  ),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('setup-submit'),
                  onPressed: _saving ? null : _submit,
                  child: const Text('Create Admin login'),
                ),
              ],
            ),
          ),
        ),
      ),
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
