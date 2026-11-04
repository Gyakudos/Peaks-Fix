import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../data/database.dart';
import '../../data/print_documents.dart';
import 'section_heading.dart';

/// Picks the printer used by Print on tickets. Network printers show up here
/// once they are added in Windows.
class PrinterSettings extends StatefulWidget {
  const PrinterSettings({super.key, required this.database});

  final AppDatabase database;

  @override
  State<PrinterSettings> createState() => _PrinterSettingsState();
}

class _PrinterSettingsState extends State<PrinterSettings> {
  List<Printer> _printers = const [];
  String _selectedUrl = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final url = await widget.database.readSetting(printerUrlKey, '');
      final printers = await Printing.listPrinters();
      if (!mounted) return;
      setState(() {
        _printers = printers;
        _selectedUrl = printers.any((p) => p.url == url) ? url : '';
      });
    } catch (error) {
      if (mounted) setState(() => _error = 'Could not list printers: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _select(String url) async {
    final name =
        _printers.where((p) => p.url == url).map((p) => p.name).firstOrNull;
    await widget.database.writeSetting(printerUrlKey, url);
    await widget.database.writeSetting(printerNameKey, name ?? '');
    if (mounted) setState(() => _selectedUrl = url);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(
          title: 'Printer',
          action: IconButton(
            key: const Key('printer-refresh'),
            tooltip: 'Refresh printers',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ),
        const Text(
          'Printers added in Windows, including network printers, appear here. '
          'Printing from a ticket goes straight to this printer.',
        ),
        const SizedBox(height: 8),
        if (_loading)
          const Text('Looking for printers...')
        else if (_error != null)
          Text(_error!)
        else
          DropdownButtonFormField<String>(
            key: const Key('printer-select'),
            initialValue: _selectedUrl,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Printer',
            ),
            items: [
              const DropdownMenuItem(
                value: '',
                child: Text('Ask every time'),
              ),
              for (final printer in _printers)
                DropdownMenuItem(
                  value: printer.url,
                  child: Text(
                    printer.isDefault
                        ? '${printer.name} (Windows default)'
                        : printer.name,
                  ),
                ),
            ],
            onChanged: (value) => _select(value ?? ''),
          ),
      ],
    );
  }
}
