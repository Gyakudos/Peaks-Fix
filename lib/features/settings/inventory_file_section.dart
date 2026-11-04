import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/inventory_file.dart';
import 'section_heading.dart';

/// Admin tools to move the shop's inventory between installs as one file.
class InventoryFileSettings extends StatefulWidget {
  const InventoryFileSettings({super.key, required this.database});

  final AppDatabase database;

  @override
  State<InventoryFileSettings> createState() => _InventoryFileSettingsState();
}

class _InventoryFileSettingsState extends State<InventoryFileSettings> {
  bool _includeStock = false;
  String? _message;
  bool _busy = false;

  static const _types = [
    XTypeGroup(label: 'Peaks Fix inventory', extensions: ['json']),
  ];

  Future<void> _run(Future<String?> Function() action) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final message = await action();
      if (mounted && message != null) setState(() => _message = message);
    } catch (error) {
      if (mounted) setState(() => _message = 'Failed: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _export() async {
    final location = await getSaveLocation(
      suggestedName: 'inventory.json',
      acceptedTypeGroups: _types,
    );
    if (location == null) return null;
    final json = await exportInventory(
      widget.database,
      includeStock: _includeStock,
    );
    await File(location.path).writeAsString(json);
    return 'Inventory saved to ${location.path}';
  }

  Future<String?> _import() async {
    final file = await openFile(acceptedTypeGroups: _types);
    if (file == null || !mounted) return null;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import inventory?'),
        content: Text(
          'Items in ${file.name} are matched to yours by SKU. Matches are '
          'updated and the rest are added. Nothing is deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('inventory-import-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Import'),
          ),
        ],
      ),
    );
    if (confirmed != true) return null;
    final result = await importInventory(
      widget.database,
      await file.readAsString(),
    );
    return 'Imported: $result.';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(title: 'Inventory file'),
        const Text(
          'Export Parts, Labour, Shop Supplies and Merch to a file, or import '
          'one from another shop. Importing merges by SKU and never deletes.',
        ),
        CheckboxListTile(
          key: const Key('inventory-file-include-stock'),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: _includeStock,
          onChanged: (value) => setState(() => _includeStock = value ?? false),
          title: const Text('Include quantities on hand'),
        ),
        Wrap(
          spacing: 12,
          children: [
            OutlinedButton.icon(
              key: const Key('inventory-export'),
              onPressed: _busy ? null : () => _run(_export),
              icon: const Icon(Icons.file_upload_outlined),
              label: const Text('Export inventory'),
            ),
            OutlinedButton.icon(
              key: const Key('inventory-import'),
              onPressed: _busy ? null : () => _run(_import),
              icon: const Icon(Icons.file_download_outlined),
              label: const Text('Import inventory'),
            ),
          ],
        ),
        if (_message != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_message!, key: const Key('inventory-file-message')),
          ),
      ],
    );
  }
}
