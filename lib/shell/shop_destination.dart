import 'package:flutter/material.dart';

import '../features/calendar/calendar_page.dart';
import '../features/checkout/checkout_page.dart';
import '../features/customers/customers_page.dart';
import '../features/financial/financial_page.dart';
import '../features/merch/merch_page.dart';
import '../features/parts/parts_page.dart';
import '../features/settings/settings_page.dart';
import '../features/tickets/tickets_page.dart';

/// A live figure shown on a destination's icon.
enum ShopBadge { checkout, closed, profit }

/// One top-level tab in the shop shell.
///
/// The same list drives both the desktop rail and the mobile bottom bar, so
/// there is only one place to add, remove or reorder a tab.
class ShopDestination {
  const ShopDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.page,
    this.badge,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget page;

  /// The live figure to overlay on the icon, if any.
  final ShopBadge? badge;

  static const List<ShopDestination> all = <ShopDestination>[
    ShopDestination(
      label: 'Tickets',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      page: TicketsPage(),
    ),
    ShopDestination(
      label: 'Closed Tickets',
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
      page: TicketsPage(closedOnly: true),
      badge: ShopBadge.closed,
    ),
    ShopDestination(
      label: 'Checkout',
      icon: Icons.point_of_sale_outlined,
      selectedIcon: Icons.point_of_sale,
      page: CheckoutPage(),
      badge: ShopBadge.checkout,
    ),
    ShopDestination(
      label: 'Calendar',
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month,
      page: CalendarPage(),
    ),
    ShopDestination(
      label: 'Customers',
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      page: CustomersPage(),
    ),
    ShopDestination(
      label: 'Merch',
      icon: Icons.storefront_outlined,
      selectedIcon: Icons.storefront,
      page: MerchPage(),
    ),
    ShopDestination(
      label: 'Parts',
      icon: Icons.memory_outlined,
      selectedIcon: Icons.memory,
      page: PartsPage(),
    ),
    ShopDestination(
      label: 'Financial',
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights,
      page: FinancialPage(),
      badge: ShopBadge.profit,
    ),
    ShopDestination(
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      page: SettingsPage(),
    ),
  ];
}
