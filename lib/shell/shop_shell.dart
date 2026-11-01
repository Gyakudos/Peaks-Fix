import 'package:flutter/material.dart';

import '../data/database.dart';
import '../data/financials.dart';
import '../data/shop_scope.dart';
import '../data/tickets_repository.dart';
import '../window/window_chrome.dart';
import 'app_access.dart';
import 'shop_destination.dart';

/// Root of the app: a navigation rail on wide windows, a bottom bar when the
/// window is narrow (or on Android).
///
/// The Windows title bar is *not* part of this widget; it lives above the
/// navigator in [VolaFixApp] so that pushed routes (such as the intake form)
/// cannot cover the window buttons.
class ShopShell extends StatefulWidget {
  const ShopShell({super.key});

  @override
  State<ShopShell> createState() => _ShopShellState();
}

class _ShopShellState extends State<ShopShell> {
  /// Below this width the rail is replaced by the bottom bar.
  static const double _railBreakpoint = 900;

  int _selected = 0;

  TicketsRepository? _repository;
  Stream<List<TicketBoardEntry>>? _boardStream;
  Stream<FinancialSummary>? _summaryStream;

  /// Keep one subscription per repository so switching tabs does not restart
  /// the board or rebuild the financial totals.
  void _bindStreams(TicketsRepository repository) {
    if (identical(_repository, repository)) return;
    _repository = repository;
    _boardStream = repository.watchBoard();
    _summaryStream = repository.watchFinancialSummary();
    repository.purgeExpiredQuotes().catchError((Object _) {});
  }

  @override
  Widget build(BuildContext context) {
    _bindStreams(ShopScope.of(context));

    return StreamBuilder<List<TicketBoardEntry>>(
      stream: _boardStream,
      builder: (context, boardSnapshot) {
        final board = boardSnapshot.data ?? const <TicketBoardEntry>[];
        final checkoutCount =
            board.where((ticket) => ticket.status == TicketStatus.ready).length;
        final closedCount = board
            .where((ticket) => ticket.status == TicketStatus.closed)
            .length;
        return StreamBuilder<FinancialSummary>(
          stream: _summaryStream,
          builder: (context, summarySnapshot) => _buildShell(
            context,
            checkoutCount: checkoutCount,
            closedCount: closedCount,
            profitCents: summarySnapshot.data?.netEstimateCents ?? 0,
          ),
        );
      },
    );
  }

  Widget _buildShell(
    BuildContext context, {
    required int checkoutCount,
    required int closedCount,
    required int profitCents,
  }) {
    final session = AppSessionScope.maybeOf(context);
    final access = session?.access ?? const AppAccess.admin();
    final destinations = [
      for (final destination in ShopDestination.all)
        if (access.canOpen(destination.label)) destination,
    ];
    final selected = _selected.clamp(0, destinations.length - 1);
    final signedInUser = session?.user;

    Widget iconFor(ShopDestination destination, {required bool selected}) {
      final icon = Icon(
        selected ? destination.selectedIcon : destination.icon,
      );
      return switch (destination.badge) {
        ShopBadge.checkout => Badge.count(
            key: const Key('nav-badge-checkout'),
            count: checkoutCount,
            isLabelVisible: checkoutCount > 0,
            child: icon,
          ),
        ShopBadge.closed => Badge.count(
            key: const Key('nav-badge-closed'),
            count: closedCount,
            isLabelVisible: closedCount > 0,
            child: icon,
          ),
        ShopBadge.profit => Badge(
            key: const Key('nav-badge-financial'),
            isLabelVisible: profitCents != 0,
            backgroundColor: profitCents < 0
                ? Theme.of(context).colorScheme.error
                : const Color(0xFF2E7D32),
            textColor: Colors.white,
            label: Text(_compactMoney(profitCents)),
            child: icon,
          ),
        null => icon,
      };
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= _railBreakpoint;

        Widget? signOutButton({required bool compact}) {
          if (signedInUser == null) return null;
          final label = '${signedInUser.name} · ${signedInUser.job}';
          return compact
              ? TextButton.icon(
                  key: const Key('sign-out'),
                  onPressed: session!.signOut,
                  icon: const Icon(Icons.logout),
                  label: Text('Log out $label'),
                )
              : Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Tooltip(
                    message: label,
                    child: IconButton(
                      key: const Key('sign-out'),
                      onPressed: session!.signOut,
                      icon: const Icon(Icons.logout),
                    ),
                  ),
                );
        }

        return Scaffold(
          // Android has no native window chrome to show the app name; a
          // narrow signed-in window needs somewhere for the log out button.
          appBar: !WindowChrome.isSupported
              ? AppBar(
                  title: const Text('Peaks Fix'),
                  actions: [
                    if (signedInUser != null) signOutButton(compact: true)!,
                  ],
                )
              : (!wide && signedInUser != null)
                  ? AppBar(
                      title: const Text('Peaks Fix'),
                      actions: [signOutButton(compact: true)!],
                    )
                  : null,
          body: Stack(children: [
            Positioned.fill(
                child: Row(
              children: [
                if (wide) ...[
                  NavigationRail(
                    selectedIndex: selected,
                    onDestinationSelected: (index) =>
                        setState(() => _selected = index),
                    labelType: NavigationRailLabelType.all,
                    minWidth: 84,
                    trailing: Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: signOutButton(compact: false),
                      ),
                    ),
                    destinations: [
                      for (final destination in destinations)
                        NavigationRailDestination(
                          icon: iconFor(destination, selected: false),
                          selectedIcon: iconFor(destination, selected: true),
                          label: Text(destination.label),
                        ),
                    ],
                  ),
                  const VerticalDivider(width: 1, thickness: 1),
                ],
                Expanded(
                  child: Navigator(
                    key: ValueKey(selected),
                    onGenerateRoute: (_) => MaterialPageRoute<void>(
                      builder: (_) => destinations[selected].page,
                    ),
                  ),
                ),
              ],
            )),
            Positioned(
              right: 8,
              bottom: 4,
              child: IgnorePointer(
                child: Text(
                  'Build $appBuildVersion',
                  key: const Key('build-version'),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ),
            ),
          ]),
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: selected,
                  onDestinationSelected: (index) =>
                      setState(() => _selected = index),
                  destinations: [
                    for (final destination in destinations)
                      NavigationDestination(
                        icon: iconFor(destination, selected: false),
                        selectedIcon: iconFor(destination, selected: true),
                        label: destination.label,
                      ),
                  ],
                ),
        );
      },
    );
  }
}

/// Shown bottom-right of the main window; matches the GitHub release tag.
const String appBuildVersion = '0.45.01.11.26';

/// Short money label for a badge, e.g. `$140`, `-$84`, `$1.2k`.
String _compactMoney(int cents) {
  final dollars = cents / 100;
  final sign = dollars < 0 ? '-' : '';
  final abs = dollars.abs();
  if (abs >= 1000) {
    final thousands = abs / 1000;
    return '$sign\$${thousands.toStringAsFixed(thousands >= 10 ? 0 : 1)}k';
  }
  return '$sign\$${abs.round()}';
}
