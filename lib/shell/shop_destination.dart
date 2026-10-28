import 'package:flutter/material.dart';

import '../features/calendar/calendar_page.dart';
import '../features/customers/customers_page.dart';
import '../features/financial/financial_page.dart';
import '../features/inventory/inventory_page.dart';
import '../features/invoicing/invoicing_page.dart';
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
      label: 'Invoicing',
      icon: Icons.point_of_sale_outlined,
      selectedIcon: Icons.point_of_sale,
      page: InvoicingPage(),
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
      label: 'Inventory',
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
      page: InventoryPage(),
    ),
    ShopDestination(
      label: 'Financial',
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights,
      page: FinancialPage(),
      badge: ShopBadge.profit,
    ),
    ShopDestination(
      label: 'Staff Login',
      icon: Icons.punch_clock_outlined,
      selectedIcon: Icons.punch_clock,
      page: StaffClockPage(),
    ),
    ShopDestination(
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      page: SettingsPage(),
    ),
  ];
}
