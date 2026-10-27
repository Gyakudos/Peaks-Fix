import 'dart:async';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../data/database.dart';
import '../../data/tickets_repository.dart';
import '../capture/phone_capture_dialog.dart';
import 'invoice_editor.dart';
import 'required_parts_dialog.dart';

class TechnicalReportEditor extends StatefulWidget {
  const TechnicalReportEditor({
    super.key,
    required this.ticketId,
    required this.ticketNumber,
    required this.device,
    required this.repository,
  });

  final int ticketId;
  final String ticketNumber;
  final String device;
  final TicketsRepository repository;

  @override
  State<TechnicalReportEditor> createState() => _TechnicalReportEditorState();
}

class _TechnicalReportEditorState extends State<TechnicalReportEditor> {
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    unawaited(_run(widget.repository.ensureTechnicalReports(widget.ticketId)));
  }

  Future<void> _run(Future<void> action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action;
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Could not save the technical report: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addPhoto({int? parentEntryId}) async {
    try {
      final file = await openFile(
        acceptedTypeGroups: const [
          XTypeGroup(
            label: 'Images',
            extensions: ['jpg', 'jpeg', 'png', 'webp'],
          ),
        ],
      );
      if (file == null) return;
      if (await file.length() > 12 * 1024 * 1024) {
        throw const FormatException('Choose a photo smaller than 12 MB.');
      }
      final extension = p.extension(file.name).replaceFirst('.', '');
      await widget.repository.addTechnicalPhoto(
        ticketId: widget.ticketId,
        bytes: await file.readAsBytes(),
        extension: extension,
        parentEntryId: parentEntryId,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Could not attach that photo: $error');
    }
  }

  Future<void> _capturePhoto({int? parentEntryId}) async {
    await showTechnicalPhotoImportDialog(
      context,
      repository: widget.repository,
      ticketId: widget.ticketId,
      ticketNumber: widget.ticketNumber,
      device: widget.device,
      parentEntryId: parentEntryId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<List<TechnicalReportBlock>>(
      stream: widget.repository.watchTechnicalEntries(widget.ticketId),
      builder: (context, snapshot) {
        final entries = snapshot.data ?? const <TechnicalReportBlock>[];
        final photosByParent = <int, List<TechnicalReportBlock>>{};
        for (final entry in entries) {
          if (entry.kind != TechnicalEntryKind.photo) continue;
          final parentId = entry.parentEntryId;
          if (parentId != null) {
            photosByParent.putIfAbsent(parentId, () => []).add(entry);
          }
        }
        final topLevelEntries = entries
            .where((entry) =>
                entry.kind == TechnicalEntryKind.note ||
                entry.parentEntryId == null)
            .toList();

        return Padding(
          padding: const EdgeInsets.fromLTRB(40, 0, 8, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bench log',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Add notes and photos in the order you inspect the device. '
                'Everything starts in the client report draft for review.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                _ErrorText(_error!),
              ],
              if (snapshot.hasError) ...[
                const SizedBox(height: 8),
                const _ErrorText('Could not load technical report entries.'),
              ] else if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) ...[
                const SizedBox(height: 12),
                const LinearProgressIndicator(),
              ] else if (entries.isEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  'No bench notes or photos yet.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              for (final entry in topLevelEntries)
                if (entry.kind == TechnicalEntryKind.note)
                  _TechnicalNoteCard(
                    key: ValueKey('technical-note-${entry.id}'),
                    entry: entry,
                    photos: photosByParent[entry.id] ?? const [],
                    repository: widget.repository,
                    ticketId: widget.ticketId,
                    onAddPhoto: () => _addPhoto(parentEntryId: entry.id),
                    onCapturePhoto: () =>
                        _capturePhoto(parentEntryId: entry.id),
                    onDelete: () => _deleteEntry(entry.id),
                    onDeletePhoto: _deleteEntry,
                  )
                else
                  _TechnicalPhotoCard(
                    key: ValueKey('technical-photo-${entry.id}'),
                    entry: entry,
                    repository: widget.repository,
                    ticketId: widget.ticketId,
                    onDelete: () => _deleteEntry(entry.id),
                  ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    key: const Key('technical-add-note'),
                    onPressed: _busy
                        ? null
                        : () => _run(
                              widget.repository
                                  .addTechnicalNote(widget.ticketId),
                            ),
                    icon: const Icon(Icons.note_add_outlined),
                    label: const Text('Add note'),
                  ),
                  OutlinedButton.icon(
                    key: const Key('technical-add-photo'),
                    onPressed: _busy ? null : () => _addPhoto(),
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: const Text('Add photo'),
                  ),
                  OutlinedButton.icon(
                    key: const Key('technical-required-parts'),
                    onPressed: _busy
                        ? null
                        : () => showRequiredPartsDialog(
                              context,
                              repository: widget.repository,
                              ticketId: widget.ticketId,
                            ),
                    icon: const Icon(Icons.memory_outlined),
                    label: const Text('Parts Invoice'),
                  ),
                  if (defaultTargetPlatform == TargetPlatform.windows)
                    OutlinedButton.icon(
                      key: const Key('technical-capture-with-phone'),
                      onPressed: _busy ? null : () => _capturePhoto(),
                      icon: const Icon(Icons.qr_code_2),
                      label: const Text('Import with phone'),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteEntry(int entryId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove this bench entry?'),
        content: const Text(
          'It will also be removed from the client draft unless that copy has '
          'already been edited.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _run(
          widget.repository.deleteTechnicalEntry(widget.ticketId, entryId));
    }
  }
}

class _TechnicalNoteCard extends StatelessWidget {
  const _TechnicalNoteCard({
    super.key,
    required this.entry,
    required this.photos,
    required this.repository,
    required this.ticketId,
    required this.onAddPhoto,
    required this.onCapturePhoto,
    required this.onDelete,
    required this.onDeletePhoto,
  });

  final TechnicalReportBlock entry;
  final List<TechnicalReportBlock> photos;
  final TicketsRepository repository;
  final int ticketId;
  final VoidCallback onAddPhoto;
  final VoidCallback onCapturePhoto;
  final VoidCallback onDelete;
  final Future<void> Function(int entryId) onDeletePhoto;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notes, size: 18),
                const SizedBox(width: 8),
                const Expanded(child: Text('Bench note')),
                IconButton(
                  tooltip: 'Remove note',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            _AutosavingTextField(
              key: ValueKey('technical-note-field-${entry.id}'),
              initialText: entry.text ?? '',
              label: 'Observation or test result',
              hint: 'What did you test, see, or measure?',
              minLines: 3,
              onSave: (text) => repository.updateTechnicalEntry(
                ticketId: ticketId,
                entryId: entry.id,
                kind: TechnicalEntryKind.note,
                text: text,
              ),
            ),
            if (photos.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final photo in photos)
                    _TechnicalPhotoThumb(
                      entry: photo,
                      onDelete: () => onDeletePhoto(photo.id),
                      onSaveCaption: (caption) =>
                          repository.updateTechnicalEntry(
                        ticketId: ticketId,
                        entryId: photo.id,
                        kind: TechnicalEntryKind.photo,
                        caption: caption,
                      ),
                    ),
                ],
              ),
            ],
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton.icon(
                  onPressed: onAddPhoto,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('Attach photo'),
                ),
                if (defaultTargetPlatform == TargetPlatform.windows)
                  TextButton.icon(
                    key: Key('technical-note-capture-with-phone-${entry.id}'),
                    onPressed: onCapturePhoto,
                    icon: const Icon(Icons.qr_code_2),
                    label: const Text('Import with phone'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TechnicalPhotoCard extends StatelessWidget {
  const _TechnicalPhotoCard({
    super.key,
    required this.entry,
    required this.repository,
    required this.ticketId,
    required this.onDelete,
  });

  final TechnicalReportBlock entry;
  final TicketsRepository repository;
  final int ticketId;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Photo'),
                  const SizedBox(height: 8),
                  _PhotoImage(path: entry.photoPath, height: 180),
                  const SizedBox(height: 8),
                  _AutosavingTextField(
                    key: ValueKey('technical-caption-${entry.id}'),
                    initialText: entry.caption ?? '',
                    label: 'Caption',
                    hint: 'What does this photo show?',
                    onSave: (caption) => repository.updateTechnicalEntry(
                      ticketId: ticketId,
                      entryId: entry.id,
                      kind: TechnicalEntryKind.photo,
                      caption: caption,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Remove photo',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _TechnicalPhotoThumb extends StatelessWidget {
  const _TechnicalPhotoThumb({
    required this.entry,
    required this.onDelete,
    required this.onSaveCaption,
  });

  final TechnicalReportBlock entry;
  final VoidCallback onDelete;
  final Future<void> Function(String caption) onSaveCaption;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              _PhotoImage(path: entry.photoPath, height: 110, width: 150),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton.filledTonal(
                  tooltip: 'Remove photo',
                  onPressed: onDelete,
                  icon: const Icon(Icons.close, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _AutosavingTextField(
            key: ValueKey('technical-caption-${entry.id}'),
            initialText: entry.caption ?? '',
            label: 'Caption',
            onSave: onSaveCaption,
          ),
        ],
      ),
    );
  }
}

class ClientReportDraftEditor extends StatefulWidget {
  const ClientReportDraftEditor({
    super.key,
    required this.ticketId,
    required this.ticketNumber,
    required this.customerName,
    required this.device,
    required this.repository,
  });

  final int ticketId;
  final String ticketNumber;
  final String customerName;
  final String device;
  final TicketsRepository repository;

  @override
  State<ClientReportDraftEditor> createState() =>
      _ClientReportDraftEditorState();
}

class _ClientReportDraftEditorState extends State<ClientReportDraftEditor> {
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    try {
      await widget.repository.ensureTechnicalReports(widget.ticketId);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Could not initialize the client draft: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 0, 8, 16),
      child: StreamBuilder<List<ClientReportBlock>>(
        stream: widget.repository.watchClientReportEntries(widget.ticketId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _ErrorText('Could not load the client report draft.');
          }
          final entries = snapshot.data ?? const <ClientReportBlock>[];
          final photosByParent = <int, List<ClientReportBlock>>{};
          for (final entry in entries) {
            final parentId = entry.parentSourceEntryId;
            if (entry.kind == TechnicalEntryKind.photo && parentId != null) {
              photosByParent.putIfAbsent(parentId, () => []).add(entry);
            }
          }
          final topLevelEntries = entries
              .where((entry) =>
                  entry.kind == TechnicalEntryKind.note ||
                  entry.parentSourceEntryId == null)
              .toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_error != null) ...[
                _ErrorText(_error!),
                const SizedBox(height: 8),
              ],
              Text(
                'Editable client draft',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'New technical notes and photos sync here automatically. '
                'Edits you make here are kept when the bench log changes.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) ...[
                const SizedBox(height: 12),
                const LinearProgressIndicator(),
              ] else if (entries.isEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  'The draft will fill as you add technical notes and photos.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              for (final entry in topLevelEntries) ...[
                _ClientDraftEntryEditor(
                  key: ValueKey('client-entry-${entry.id}'),
                  entry: entry,
                  repository: widget.repository,
                ),
                if (entry.kind == TechnicalEntryKind.note &&
                    entry.sourceEntryId != null)
                  for (final photo
                      in photosByParent[entry.sourceEntryId!] ?? const [])
                    _ClientDraftEntryEditor(
                      key: ValueKey('client-entry-${photo.id}'),
                      entry: photo,
                      repository: widget.repository,
                    ),
              ],
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const Key('client-report-open-invoice'),
                onPressed: () => showInvoiceDialog(
                  context,
                  repository: widget.repository,
                  ticketId: widget.ticketId,
                  ticketNumber: widget.ticketNumber,
                  customerName: widget.customerName,
                  device: widget.device,
                ),
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('Open invoice'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ClientDraftEntryEditor extends StatelessWidget {
  const _ClientDraftEntryEditor({
    super.key,
    required this.entry,
    required this.repository,
  });

  final ClientReportBlock entry;
  final TicketsRepository repository;

  @override
  Widget build(BuildContext context) {
    final isNote = entry.kind == TechnicalEntryKind.note;
    return Card(
      margin: const EdgeInsets.only(top: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                isNote
                    ? 'Include note'
                    : entry.parentSourceEntryId == null
                        ? 'Include photo'
                        : 'Include attached photo',
              ),
              subtitle: Text(entry.contentEdited || entry.inclusionEdited
                  ? 'Customer copy edited'
                  : 'Synced from the bench log'),
              value: entry.included,
              onChanged: (included) => _setIncluded(context, included),
            ),
            if (isNote)
              _AutosavingTextField(
                key: ValueKey('client-note-${entry.id}'),
                initialText: entry.text ?? '',
                label: 'Customer wording',
                hint: 'Explain this finding in plain language.',
                minLines: 2,
                onSave: (text) => repository.updateClientReportEntry(
                  entryId: entry.id,
                  kind: entry.kind,
                  text: text,
                ),
              )
            else ...[
              _PhotoImage(path: entry.photoPath, height: 180),
              const SizedBox(height: 8),
              _AutosavingTextField(
                key: ValueKey('client-caption-${entry.id}'),
                initialText: entry.caption ?? '',
                label: 'Customer photo caption',
                onSave: (caption) => repository.updateClientReportEntry(
                  entryId: entry.id,
                  kind: entry.kind,
                  caption: caption,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _setIncluded(BuildContext context, bool included) async {
    try {
      await repository.updateClientReportEntry(
        entryId: entry.id,
        kind: entry.kind,
        included: included,
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update the draft: $error')),
      );
    }
  }
}

class _AutosavingTextField extends StatefulWidget {
  const _AutosavingTextField({
    super.key,
    required this.initialText,
    required this.label,
    required this.onSave,
    this.hint,
    this.minLines = 1,
  });

  final String initialText;
  final String label;
  final String? hint;
  final int minLines;
  final Future<void> Function(String value) onSave;

  @override
  State<_AutosavingTextField> createState() => _AutosavingTextFieldState();
}

class _AutosavingTextFieldState extends State<_AutosavingTextField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Timer? _timer;
  late String _savedText;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _savedText = widget.initialText;
    _controller = TextEditingController(text: _savedText);
    _focusNode = FocusNode()..addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant _AutosavingTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialText != widget.initialText &&
        !_focusNode.hasFocus &&
        _controller.text == _savedText) {
      _savedText = widget.initialText;
      _controller.text = _savedText;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_controller.text != _savedText) {
      unawaited(widget.onSave(_controller.text));
    }
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) _save();
  }

  Future<void> _save() async {
    _timer?.cancel();
    final text = _controller.text;
    if (text == _savedText || _saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(text);
      if (!mounted) return;
      setState(() {
        _savedText = text;
        _saving = false;
      });
      if (_controller.text != text) {
        _timer = Timer(const Duration(milliseconds: 700), _save);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Not saved: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          minLines: widget.minLines,
          maxLines: widget.minLines == 1 ? 3 : 8,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) {
            _timer?.cancel();
            _timer = Timer(const Duration(milliseconds: 700), _save);
          },
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            border: const OutlineInputBorder(),
            alignLabelWithHint: widget.minLines > 1,
          ),
        ),
        if (_error != null || _saving)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _error ?? 'Saving…',
              style: theme.textTheme.bodySmall?.copyWith(
                color: _error == null
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}

class _PhotoImage extends StatelessWidget {
  const _PhotoImage({
    required this.path,
    required this.height,
    this.width,
  });

  final String? path;
  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imagePath = path;
    if (imagePath == null) {
      return Container(
        height: height,
        width: width,
        color: theme.colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_outlined),
      );
    }
    return Image.file(
      File(imagePath),
      height: height,
      width: width,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: height,
        width: width,
        color: theme.colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_outlined),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    );
  }
}
