import 'package:flutter/material.dart';

import 'app.dart';
import 'data/database.dart';
import 'data/shop_network.dart';
import 'shell/app_access.dart';

/// The host's listener, kept for the life of the app.
ShopHost? activeHost;

/// What went wrong starting the host listener, shown in Cloud Settings.
String? hostStartError;

/// Picks the database for this run: local, shared as a host, or a host's.
/// Returns an error message when a client could not reach its host.
Future<String?> openConfiguredDatabase(NetworkSettings settings) async {
  switch (settings.mode) {
    case NetworkMode.standalone:
      await AppDatabase.instance.ensureSeeded();
      return null;
    case NetworkMode.host:
      final opened = await openHostDatabase();
      AppDatabase.instance = opened.database;
      await AppDatabase.instance.ensureSeeded();
      try {
        activeHost = await ShopHost.start(
          server: opened.server,
          port: settings.port,
          key: settings.key,
          schemaVersion: AppDatabase.currentSchemaVersion,
        );
      } catch (error) {
        hostStartError = 'Could not share on port ${settings.port}: $error';
      }
      return null;
    case NetworkMode.client:
      try {
        AppDatabase.instance = await connectToHost(settings);
        return null;
      } on HostConnectionException catch (error) {
        return error.message;
      }
  }
}

void runShop() => runApp(
      VolaFixApp(loadAccounts: () => loadStaffAccounts(AppDatabase.instance)),
    );

/// Shown when a client PC can't reach its host.
class HostUnavailableApp extends StatelessWidget {
  const HostUnavailableApp({
    super.key,
    required this.message,
    required this.onRetry,
    required this.onUseLocal,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onUseLocal;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Can\'t reach the shop host',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(message, key: const Key('host-unavailable-message')),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  children: [
                    FilledButton(
                      key: const Key('host-retry'),
                      onPressed: onRetry,
                      child: const Text('Try again'),
                    ),
                    OutlinedButton(
                      key: const Key('host-use-local'),
                      onPressed: onUseLocal,
                      child: const Text('Use this PC on its own'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
