import 'package:flutter/material.dart';

import '../../shell/section_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionPage(
      icon: Icons.settings_outlined,
      title: 'Settings',
      summary: 'Shop configuration, including the device catalog. Categories, '
          'brands and models live here because a device is recorded on the '
          'ticket \u2014 there is no separate device list to keep in sync.',
      planned: [
        'Shop info, currency and tax',
        'Ticket numbering',
        'Device categories: Consoles, Handheld PCs',
        'Add more categories later (phones, laptops, controllers)',
        'Brands \u2192 models per category',
        'Service templates and default prices',
        'Backup / export',
      ],
    );
  }
}
