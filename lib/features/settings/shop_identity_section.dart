import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../data/database.dart';
import '../../data/print_documents.dart';
import 'section_heading.dart';

/// The shop's name (Shop ID) and logo, printed at the top right of every
/// printed or emailed document.
class ShopIdentitySettings extends StatefulWidget {
  const ShopIdentitySettings({super.key, required this.database});

  final AppDatabase database;

  @override
  State<ShopIdentitySettings> createState() => _ShopIdentitySettingsState();
}

class _ShopIdentitySettingsState extends State<ShopIdentitySettings> {
  final _name = TextEditingController();
  String _logoPath = '';
  String? _message;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final name = await widget.database.readSetting('shop_name', '');
    final logo = await widget.database.readSetting(shopLogoKey, '');
    if (!mounted) return;
    setState(() {
      _name.text = name;
      _logoPath = logo;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _message = 'Enter the shop name.');
      return;
    }
    await widget.database.writeSetting('shop_name', name);
    if (mounted) setState(() => _message = 'Shop ID saved.');
  }

  Future<void> _chooseLogo() async {
    try {
      final file = await openFile(
        acceptedTypeGroups: const [
          XTypeGroup(label: 'Images', extensions: ['jpg', 'jpeg', 'png']),
        ],
      );
      if (file == null) return;
      if (await file.length() > 5 * 1024 * 1024) {
        throw const FormatException('Choose a logo smaller than 5 MB.');
      }
      final support = await getApplicationSupportDirectory();
      final folder = Directory(p.join(support.path, 'shop_logo'));
      await folder.create(recursive: true);
      final target = p.join(
        folder.path,
        'logo_${DateTime.now().millisecondsSinceEpoch}'
        '${p.extension(file.name)}',
      );
      await File(target).writeAsBytes(await file.readAsBytes());
      await widget.database.writeSetting(shopLogoKey, target);
      if (mounted) {
        setState(() {
          _logoPath = target;
          _message = 'Logo saved.';
        });
      }
    } catch (error) {
      if (mounted) setState(() => _message = 'Could not add that logo: $error');
    }
  }

  Future<void> _removeLogo() async {
    await widget.database.writeSetting(shopLogoKey, '');
    if (mounted) setState(() => _logoPath = '');
  }

  @override
  Widget build(BuildContext context) {
    final logoFile = _logoPath.isEmpty ? null : File(_logoPath);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(title: 'Shop ID and logo'),
        const Text(
          'Shown at the top right of invoices, reports and warranties when '
          'printed or emailed.',
        ),
        const SizedBox(height: 8),
        TextField(
          key: const Key('shop-name'),
          controller: _name,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Shop ID (shop name)',
          ),
          onSubmitted: (_) => _saveName(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            FilledButton(
              key: const Key('shop-name-save'),
              onPressed: _saveName,
              child: const Text('Save shop ID'),
            ),
            const SizedBox(width: 16),
            if (logoFile != null && logoFile.existsSync())
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Image.file(logoFile, height: 56),
              ),
            OutlinedButton.icon(
              key: const Key('shop-logo-choose'),
              onPressed: _chooseLogo,
              icon: const Icon(Icons.image_outlined),
              label: Text(_logoPath.isEmpty ? 'Add logo' : 'Change logo'),
            ),
            if (_logoPath.isNotEmpty)
              IconButton(
                key: const Key('shop-logo-remove'),
                tooltip: 'Remove logo',
                onPressed: _removeLogo,
                icon: const Icon(Icons.delete_outline),
              ),
          ],
        ),
        if (_message != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_message!, key: const Key('shop-identity-message')),
          ),
      ],
    );
  }
}
