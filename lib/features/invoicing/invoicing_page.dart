import 'package:flutter/material.dart';

import '../checkout/checkout_page.dart';
import '../tickets/tickets_page.dart';

/// Checkout and closed tickets in one place.
class InvoicingPage extends StatelessWidget {
  const InvoicingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: 'Checkout'),
              Tab(text: 'Closed Tickets'),
            ],
          ),
          Expanded(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                CheckoutPage(),
                TicketsPage(closedOnly: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
