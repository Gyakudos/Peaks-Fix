import 'package:flutter/material.dart';

import 'data/database.dart';
import 'data/shop_scope.dart';
import 'data/tickets_repository.dart';
import 'shell/shop_shell.dart';
import 'window/window_chrome.dart';
import 'window/window_title_bar.dart';

class VolaFixApp extends StatelessWidget {
  const VolaFixApp({super.key, this.tickets});

  /// Injected by tests; production uses the SQLite-backed repository.
  final TicketsRepository? tickets;

  /// Built once, not per rebuild: the board stream is cached inside.
  static final TicketsRepository _defaultRepository = DriftTicketsRepository(
    AppDatabase.instance,
  );

  @override
  Widget build(BuildContext context) {
    final repository = tickets ?? _defaultRepository;

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
        return ShopScope(tickets: repository, child: content);
      },
      home: const ShopShell(),
    );
  }
}
