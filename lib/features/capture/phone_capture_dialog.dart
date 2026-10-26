import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../data/capture_server.dart';
import '../../data/tickets_repository.dart';

/// Shows a QR the phone can scan to send Report 1 photos into this ticket.
///
/// The link is one-time and only lives while this dialog is open. Nothing is
/// exposed beyond the random token in the URL, and the server stops the moment
/// the dialog closes.
Future<void> showPhoneCaptureDialog(
  BuildContext context, {
  required TicketsRepository repository,
  required int ticketId,
  required String ticketNumber,
  required String device,
  required PhotoChecklist checklist,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => PhoneCaptureDialog(
      repository: repository,
      ticketId: ticketId,
      ticketNumber: ticketNumber,
      device: device,
      checklist: checklist,
    ),
  );
}

Future<void> showTechnicalPhotoImportDialog(
  BuildContext context, {
  required TicketsRepository repository,
  required int ticketId,
  required String ticketNumber,
  required String device,
  int? parentEntryId,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => TechnicalPhotoImportDialog(
      repository: repository,
      ticketId: ticketId,
      ticketNumber: ticketNumber,
      device: device,
      parentEntryId: parentEntryId,
    ),
  );
}

class TechnicalPhotoImportDialog extends StatefulWidget {
  const TechnicalPhotoImportDialog({
    super.key,
    required this.repository,
    required this.ticketId,
    required this.ticketNumber,
    required this.device,
    this.parentEntryId,
  });

  final TicketsRepository repository;
  final int ticketId;
  final String ticketNumber;
  final String device;
  final int? parentEntryId;

  @override
  State<TechnicalPhotoImportDialog> createState() =>
      _TechnicalPhotoImportDialogState();
}

class _TechnicalPhotoImportDialogState
    extends State<TechnicalPhotoImportDialog> {
  CaptureServer? _server;
  String? _error;
  bool _starting = true;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    final server = _server;
    _server = null;
    if (server != null) unawaited(server.close());
    super.dispose();
  }

  Future<void> _start() async {
    setState(() {
      _starting = true;
      _error = null;
    });
    final address = await findLanAddress();
    if (!mounted) return;
    if (address == null) {
      setState(() {
        _starting = false;
        _error = 'This PC is not on a network the phone can reach. Connect '
            'both to the same Wi-Fi or router, then try again.';
      });
      return;
    }

    try {
      final server = await CaptureServer.start(
        address: address,
        ticketNumber: widget.ticketNumber,
        device: widget.device,
        slots: const [CaptureSlot(order: 1, label: 'Technical photo')],
        save: (_, bytes, extension) => widget.repository.addTechnicalPhoto(
          ticketId: widget.ticketId,
          bytes: bytes,
          extension: extension,
          parentEntryId: widget.parentEntryId,
        ),
      );
      if (!mounted) {
        await server.close();
        return;
      }
      setState(() {
        _server = server;
        _starting = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _starting = false;
        _error = 'Could not open the capture page: $error';
      });
    }
  }

  Future<void> _restart() async {
    final server = _server;
    _server = null;
    await server?.close();
    if (!mounted) return;
    await _start();
  }

  Future<void> _copy(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    setState(() => _copied = true);
    Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final server = _server;
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.qr_code_2, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Import technical photo',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${widget.ticketNumber} · ${widget.device}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  child: _starting
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 42),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : server == null
                          ? _ErrorBody(
                              message: _error ??
                                  'The capture page could not be opened.',
                              onRetry: _restart,
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color:
                                              theme.colorScheme.outlineVariant,
                                        ),
                                      ),
                                      child: QrImageView(
                                        data: server.url,
                                        size: 188,
                                        backgroundColor: Colors.white,
                                        eyeStyle: const QrEyeStyle(
                                          eyeShape: QrEyeShape.square,
                                          color: Colors.black,
                                        ),
                                        dataModuleStyle:
                                            const QrDataModuleStyle(
                                          dataModuleShape:
                                              QrDataModuleShape.square,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 18),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Scan with your phone camera',
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Both devices must be on the same '
                                            'Wi-Fi. The page is only reachable '
                                            'while this window is open.',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: theme
                                                  .colorScheme.onSurfaceVariant,
                                              height: 1.45,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          const Text('Or type this address:'),
                                          SelectableText(server.url),
                                          TextButton.icon(
                                            onPressed: () => _copy(server.url),
                                            icon: Icon(
                                              _copied
                                                  ? Icons.check
                                                  : Icons.copy_all_outlined,
                                              size: 18,
                                            ),
                                            label: Text(
                                              _copied ? 'Copied' : 'Copy link',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'The uploaded photo will be added to this '
                                  'technical report automatically.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: _restart,
                                  icon: const Icon(Icons.refresh, size: 18),
                                  label: const Text('New link'),
                                ),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PhoneCaptureDialog extends StatefulWidget {
  const PhoneCaptureDialog({
    super.key,
    required this.repository,
    required this.ticketId,
    required this.ticketNumber,
    required this.device,
    required this.checklist,
  });

  final TicketsRepository repository;
  final int ticketId;
  final String ticketNumber;
  final String device;
  final PhotoChecklist checklist;

  @override
  State<PhoneCaptureDialog> createState() => _PhoneCaptureDialogState();
}

class _PhoneCaptureDialogState extends State<PhoneCaptureDialog> {
  CaptureServer? _server;
  String? _error;
  bool _starting = true;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    final server = _server;
    _server = null;
    if (server != null) unawaited(server.close());
    super.dispose();
  }

  Future<void> _start() async {
    setState(() {
      _starting = true;
      _error = null;
    });

    final address = await findLanAddress();
    if (!mounted) return;
    if (address == null) {
      setState(() {
        _starting = false;
        _error = 'This PC is not on a network the phone can reach. Connect '
            'both to the same Wi-Fi or router, then try again.';
      });
      return;
    }

    try {
      final server = await CaptureServer.start(
        address: address,
        ticketNumber: widget.ticketNumber,
        device: widget.device,
        slots: [
          for (final slot in widget.checklist.slots)
            CaptureSlot(
              order: slot.sortOrder,
              label: slot.label,
              hint: slot.hint,
              required: slot.required,
              captured: slot.captured,
              photoPath: slot.photoPath,
            ),
        ],
        save: (order, bytes, extension) => widget.repository.savePhotoSlot(
          ticketId: widget.ticketId,
          sortOrder: order,
          bytes: bytes,
          extension: extension,
        ),
      );
      if (!mounted) {
        await server.close();
        return;
      }
      setState(() {
        _server = server;
        _starting = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _starting = false;
        _error = 'Could not open the capture page: $error';
      });
    }
  }

  Future<void> _restart() async {
    final server = _server;
    _server = null;
    await server?.close();
    if (!mounted) return;
    await _start();
  }

  Future<void> _copy(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    setState(() => _copied = true);
    Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final server = _server;

    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.qr_code_2, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Capture with phone',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${widget.ticketNumber} · ${widget.device}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  child: _starting
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 42),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : server == null
                          ? _ErrorBody(
                              message: _error ??
                                  'The capture page could not be opened.',
                              onRetry: _restart,
                            )
                          : _ReadyBody(
                              server: server,
                              repository: widget.repository,
                              ticketId: widget.ticketId,
                              checklist: widget.checklist,
                              copied: _copied,
                              onCopy: () => _copy(server.url),
                              onNewLink: _restart,
                            ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadyBody extends StatelessWidget {
  const _ReadyBody({
    required this.server,
    required this.repository,
    required this.ticketId,
    required this.checklist,
    required this.copied,
    required this.onCopy,
    required this.onNewLink,
  });

  final CaptureServer server;
  final TicketsRepository repository;
  final int ticketId;
  final PhotoChecklist checklist;
  final bool copied;
  final VoidCallback onCopy;
  final VoidCallback onNewLink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: QrImageView(
                data: server.url,
                size: 188,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Colors.black,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scan with your phone camera',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Both devices must be on the same Wi-Fi. The page is only '
                    'reachable while this window is open.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Or type this address:',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  SelectableText(
                    server.url,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                      height: 1.4,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: onCopy,
                      icon: Icon(
                        copied ? Icons.check : Icons.copy_all_outlined,
                        size: 18,
                      ),
                      label: Text(copied ? 'Copied' : 'Copy link'),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<PhotoChecklist>(
          stream: repository.watchPhotoChecklist(ticketId),
          builder: (context, snapshot) {
            final live = snapshot.data ?? checklist;
            final total = live.slots.where((slot) => slot.required).length;
            final captured = live.slots
                .where((slot) => slot.required && slot.captured)
                .length;
            final ratio = total == 0 ? 0.0 : captured / total;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      captured >= total && total > 0
                          ? 'All $total shots captured'
                          : '$captured of $total captured',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (captured >= total && total > 0)
                      Icon(
                        Icons.check_circle,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final slot in live.slots)
                      _SlotPreview(
                        path: slot.photoPath,
                        number: slot.sortOrder,
                        label: slot.label,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.wifi_tethering,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Photos save straight into this ticket. You can keep '
                        'using Peaks Fix while the phone uploads.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onNewLink,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('New link'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SlotPreview extends StatelessWidget {
  const _SlotPreview({
    required this.path,
    required this.number,
    required this.label,
  });

  final String? path;
  final int number;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final file = path == null ? null : File(path!);
    final hasPhoto = file != null && file.existsSync();

    return Tooltip(
      message: label,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasPhoto
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
          ),
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        clipBehavior: Clip.antiAlias,
        child: hasPhoto
            ? Image.file(
                file,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(theme),
              )
            : _placeholder(theme),
      ),
    );
  }

  Widget _placeholder(ThemeData theme) {
    return Center(
      child: Text(
        '$number',
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.wifi_off, color: theme.colorScheme.error),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
