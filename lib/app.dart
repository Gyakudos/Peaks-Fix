import 'package:flutter/material.dart';

import 'data/database.dart';
import 'data/shop_scope.dart';
import 'data/tickets_repository.dart';
import 'shell/app_access.dart';
import 'shell/shop_shell.dart';
import 'window/window_chrome.dart';
import 'window/window_title_bar.dart';

class VolaFixApp extends StatefulWidget {
  const VolaFixApp({
    super.key,
    this.tickets,
    this.loadAccounts,
    this.createAdmin,
  });

  /// Creates the first Admin on a new install. Null skips the setup screen.
  final AdminCreator? createAdmin;

  /// Injected by tests; production uses the SQLite-backed repository.
  final TicketsRepository? tickets;

  /// Staff logins to check at start-up. Null leaves the app open (tests).
  final StaffAccountLoader? loadAccounts;

  /// Built once, not per rebuild: the board stream is cached inside.
  static final TicketsRepository _defaultRepository = DriftTicketsRepository(
    AppDatabase.instance,
  );

  @override
  State<VolaFixApp> createState() => _VolaFixAppState();
}

class _VolaFixAppState extends State<VolaFixApp> {
  final AppSession _session = AppSession();

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = widget.tickets ?? VolaFixApp._defaultRepository;

    return MaterialApp(
      title: 'Peaks Fix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      // The window is frameless on Windows, so the title bar is drawn by
      // Flutter. Keeping it here — above the navigator — means pushed routes
      // such as the intake form can never cover the minimise/maximise/close
      // buttons. The shop scope sits here for the same reason: pushed routes
      // need it.
      builder: (context, child) {
        final content = WindowChrome.isSupported
            ? Column(
                children: [
                  const Material(child: WindowTitleBar()),
                  Expanded(child: child ?? const SizedBox.shrink()),
                ],
              )
            : child ?? const SizedBox.shrink();
        return ShopScope(
          tickets: repository,
          child: AppSessionScope(session: _session, child: content),
        );
      },
      home: LoginGate(
        session: _session,
        loadAccounts: widget.loadAccounts,
        createAdmin: widget.createAdmin,
        child: const ShopShell(),
      ),
    );
  }
}
