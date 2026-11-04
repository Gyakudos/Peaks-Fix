import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/print_documents.dart';
import 'section_heading.dart';

/// Where a PDF copy of every printed or emailed document is kept.
class DocumentsFolderSettings extends StatefulWidget {
  const DocumentsFolderSettings({super.key, required this.database});

  final AppDatabase database;

  @override
  State<DocumentsFolderSettings> createState() =>
      _DocumentsFolderSettingsState();
}

class _DocumentsFolderSettingsState extends State<DocumentsFolderSettings> {
  String _folder = '';

  @override
  void initState() {
    super.initState();
    documentsFolder(widget.database).then((value) {
      if (mounted) setState(() => _folder = value);
    });
  }

  Future<void> _choose() async {
    final path = await getDirectoryPath();
    if (path == null) return;
    await widget.database.writeSetting(documentsFolderKey, path);
    if (mounted) setState(() => _folder = path);
  }

  Future<void> _open() async {
    if (_folder.isEmpty) return;
    await Directory(_folder).create(recursive: true);
    await Process.run('explorer', [_folder]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(title: 'Saved documents'),
        const Text(
          'A PDF copy of every invoice, report and warranty you print or '
          'email is saved here, in a folder for each ticket.',
        ),
        const SizedBox(height: 8),
        SelectableText(_folder, key: const Key('documents-folder')),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton.icon(
              key: const Key('documents-folder-choose'),
              onPressed: _choose,
              icon: const Icon(Icons.folder_outlined),
              label: const Text('Change folder'),
            ),
            OutlinedButton.icon(
              key: const Key('documents-folder-open'),
              onPressed: _open,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open folder'),
            ),
          ],
        ),
      ],
    );
  }
}
