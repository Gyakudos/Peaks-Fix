import 'package:flutter/widgets.dart';

import 'tickets_repository.dart';

/// Gives every screen access to the shop's data layer without threading
/// constructor arguments through the navigation shell.
///
/// It sits above the navigator (see `app.dart`), so pushed routes such as the
/// intake form and a ticket page can read it too.
class ShopScope extends InheritedWidget {
  const ShopScope({super.key, required this.tickets, required super.child});

  final TicketsRepository tickets;

  static TicketsRepository of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ShopScope>();
    assert(scope != null, 'No ShopScope above this widget.');
    return scope!.tickets;
  }

  @override
  bool updateShouldNotify(ShopScope oldWidget) => oldWidget.tickets != tickets;
}
