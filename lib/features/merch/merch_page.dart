import 'package:flutter/material.dart';

import '../../shell/section_page.dart';

class MerchPage extends StatelessWidget {
  const MerchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionPage(
      icon: Icons.storefront_outlined,
      title: 'Merch',
      summary:
          'Retail: shirts, accessories and anything else you sell over the '
          'counter. Separately tracked from repair parts so both stock counts '
          'and revenue stay accurate.',
      planned: [
        'Products with variants (size / color)',
        'SKU and barcode per variant',
        'Quick sell from the product list',
        'Cart checkout for multi-item sales',
        'Cash / card / other',
        'Stock decremented on every sale',
        'Today\u2019s sales and low-stock warnings',
        'Optional link to a customer',
      ],
    );
  }
}
