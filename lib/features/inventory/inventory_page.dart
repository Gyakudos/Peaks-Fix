import 'package:flutter/material.dart';

import 'labour_tab.dart';
import 'merch_tab.dart';
import 'parts_tab.dart';
import 'shop_supplies_tab.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Parts'),
                selected: _selected == 0,
                onSelected: (_) => setState(() => _selected = 0),
              ),
              ChoiceChip(
                label: const Text('Merch'),
                selected: _selected == 1,
                onSelected: (_) => setState(() => _selected = 1),
              ),
              ChoiceChip(
                label: const Text('Shop'),
                selected: _selected == 2,
                onSelected: (_) => setState(() => _selected = 2),
              ),
              ChoiceChip(
                label: const Text('Labour'),
                selected: _selected == 3,
                onSelected: (_) => setState(() => _selected = 3),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: switch (_selected) {
            0 => const PartsTab(),
            1 => const MerchTab(),
            2 => const ShopSuppliesTab(),
            3 => const LabourTab(),
            _ => const PartsTab(),
          },
        ),
      ],
    );
  }
}
