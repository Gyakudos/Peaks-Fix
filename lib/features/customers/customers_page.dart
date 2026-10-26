import 'package:flutter/material.dart';

import '../../shell/section_page.dart';

class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionPage(
      icon: Icons.people_outline,
      title: 'Customers',
      summary:
          'The people behind the repairs. One record per customer, linked to '
          'every device they have brought in and every job you have done for '
          'them.',
      planned: [
        'Name, phone, email, notes',
        'Devices owned',
        'Repair history',
        'Merch purchases',
        'Search and quick-add',
      ],
    );
  }
}
