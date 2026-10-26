import 'package:flutter/material.dart';

import '../../shell/section_page.dart';

class PartsPage extends StatelessWidget {
  const PartsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionPage(
      icon: Icons.memory_outlined,
      title: 'Parts',
      summary:
          'Components used in repairs \u2014 HDMI ports, batteries, screens, '
          'thermal paste. Consumed from a ticket, so the stock you see here is '
          'what is actually on the shelf.',
      planned: [
        'Stock, cost and price',
        'Reorder levels and low-stock warnings',
        'Consumed from a ticket',
        'Stock movements and adjustments',
        'Supplier field',
      ],
    );
  }
}
