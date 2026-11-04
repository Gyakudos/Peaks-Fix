import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/print_documents.dart';
import 'section_heading.dart';

/// The shop's own warranty disclaimer, printed on the Warranty page.
class WarrantyDisclaimerSettings extends StatefulWidget {
  const WarrantyDisclaimerSettings({super.key, required this.database});

  final AppDatabase database;

  @override
  State<WarrantyDisclaimerSettings> createState() =>
      _WarrantyDisclaimerSettingsState();
}

class _WarrantyDisclaimerSettingsState
    extends State<WarrantyDisclaimerSettings> {
  final _controller = TextEditingController();
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    widget.database.readSetting(warrantyDisclaimerKey, '').then((value) {
      if (mounted) _controller.text = value;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await widget.database.writeSetting(
      warrantyDisclaimerKey,
      _controller.text.trim(),
    );
    if (mounted) setState(() => _saved = true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(title: 'Warranty disclaimer'),
        const Text('Printed on every Warranty page. Leave empty to omit it.'),
        const SizedBox(height: 8),
        TextField(
          key: const Key('warranty-disclaimer'),
          controller: _controller,
          minLines: 4,
          maxLines: 12,
          onChanged: (_) => setState(() => _saved = false),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Warranty disclaimer',
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            FilledButton(
              key: const Key('warranty-disclaimer-save'),
              onPressed: _save,
              child: const Text('Save disclaimer'),
            ),
            if (_saved)
              const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Text('Saved'),
              ),
          ],
        ),
      ],
    );
  }
}
