import 'package:flutter/material.dart';

import '../window/window_chrome.dart';
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

  @override
  Widget build(BuildContext context) {
    const destinations = ShopDestination.all;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= _railBreakpoint;

        return Scaffold(
          // Android has no native window chrome to show the app name.
          appBar: WindowChrome.isSupported
              ? null
              : AppBar(title: const Text('Peaks Fix')),
          body: Row(
            children: [
              if (wide) ...[
                NavigationRail(
                  selectedIndex: _selected,
                  onDestinationSelected: (index) =>
                      setState(() => _selected = index),
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final destination in destinations)
                      NavigationRailDestination(
                        icon: Icon(destination.icon),
                        selectedIcon: Icon(destination.selectedIcon),
                        label: Text(destination.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1, thickness: 1),
              ],
              Expanded(
                child: Navigator(
                  key: ValueKey(_selected),
                  onGenerateRoute: (_) => MaterialPageRoute<void>(
                    builder: (_) => destinations[_selected].page,
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: _selected,
                  onDestinationSelected: (index) =>
                      setState(() => _selected = index),
                  destinations: [
                    for (final destination in destinations)
                      NavigationDestination(
                        icon: Icon(destination.icon),
                        selectedIcon: Icon(destination.selectedIcon),
                        label: destination.label,
                      ),
                  ],
                ),
        );
      },
    );
  }
}
