import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

import '../../data/database.dart';
import '../../data/print_documents.dart';
import '../../data/shop_scope.dart';

/// Prints or emails one document for a ticket.
Future<void> runTicketPrint(
  BuildContext context,
  int ticketId,
  PrintKind kind,
  PrintAction action,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final repository = ShopScope.of(context);
  try {
    final data = await loadTicketPrintData(
      repository,
      AppDatabase.instance,
      ticketId,
    );
    if (data == null) return;
    final bytes = await buildTicketPdf(data, kind);
    final number = data.entry.summary.number;
    final name = '${kind.label.split(' ').first}_$number.pdf';
    if (action == PrintAction.print) {
      final url = await AppDatabase.instance.readSetting(printerUrlKey, '');
      final printer = url.isEmpty
          ? null
          : (await Printing.listPrinters())
              .where((p) => p.url == url)
              .firstOrNull;
      if (printer != null) {
        await Printing.directPrintPdf(
          printer: printer,
          onLayout: (_) async => bytes,
          name: name,
        );
        messenger.showSnackBar(
          SnackBar(content: Text('Sent to ${printer.name}.')),
        );
      } else {
        await Printing.layoutPdf(onLayout: (_) async => bytes, name: name);
      }
      return;
    }
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, name));
    await file.writeAsBytes(bytes, flush: true);
    final subject = '${data.shopName}: ${kind.label} for ticket $number';
    final body = 'Hello ${data.recipientName},\r\n\r\n'
        'Please find your ${kind.label.toLowerCase()} for ticket $number '
        'attached.\r\n\r\nThank you,\r\n${data.shopName}';
    final mailto = Uri(
      scheme: 'mailto',
      path: data.recipientEmail,
      query: 'subject=${Uri.encodeComponent(subject)}'
          '&body=${Uri.encodeComponent(body)}',
    ).toString();
    await Process.run('rundll32', ['url.dll,FileProtocolHandler', mailto]);
    await Process.run('explorer', ['/select,${file.path}']);
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 10),
        content: Text(
          data.recipientEmail.isEmpty
              ? 'No email on file for ${data.recipientName}. Your email app '
                  'opened; add the address and attach the PDF shown in the '
                  'folder.'
              : 'Your email app opened for ${data.recipientEmail}. Attach '
                  'the PDF shown in the folder.',
        ),
      ),
    );
  } catch (error) {
    messenger.showSnackBar(
      SnackBar(content: Text('Could not prepare: $error')),
    );
  }
}

/// Print and Email buttons for one document, shown inside a report section.
class PrintEmailButtons extends StatelessWidget {
  const PrintEmailButtons({
    super.key,
    required this.ticketId,
    required this.kind,
    this.label,
  });

  final int ticketId;
  final PrintKind kind;

  /// What the buttons are for when it differs from [PrintKind.label].
  final String? label;

  @override
  Widget build(BuildContext context) {
    final name = label ?? kind.label;
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        OutlinedButton.icon(
          key: Key('print-${kind.name}'),
          onPressed: () =>
              runTicketPrint(context, ticketId, kind, PrintAction.print),
          icon: const Icon(Icons.print, size: 18),
          label: Text('Print $name'),
        ),
        OutlinedButton.icon(
          key: Key('email-${kind.name}'),
          onPressed: () =>
              runTicketPrint(context, ticketId, kind, PrintAction.email),
          icon: const Icon(Icons.email_outlined, size: 18),
          label: Text('Email $name'),
        ),
      ],
    );
  }
}

/// App-bar menu on a ticket: print or email an invoice, report or warranty.
class TicketPrintMenu extends StatelessWidget {
  const TicketPrintMenu({super.key, required this.ticketId});

  final int ticketId;

  Future<void> _choose(BuildContext context, PrintKind kind) async {
    final action = await showDialog<PrintAction>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(kind.label),
        children: [
          SimpleDialogOption(
            key: const Key('print-action-print'),
            onPressed: () => Navigator.of(context).pop(PrintAction.print),
            child: const ListTile(
              leading: Icon(Icons.print),
              title: Text('Print'),
            ),
          ),
          SimpleDialogOption(
            key: const Key('print-action-email'),
            onPressed: () => Navigator.of(context).pop(PrintAction.email),
            child: const ListTile(
              leading: Icon(Icons.email_outlined),
              title: Text('Email to customer / partner'),
            ),
          ),
        ],
      ),
    );
    if (action == null || !context.mounted) return;
    await runTicketPrint(context, ticketId, kind, action);
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PrintKind>(
      key: const Key('ticket-print'),
      tooltip: 'Print or email',
      icon: const Icon(Icons.print),
      onSelected: (kind) => _choose(context, kind),
      itemBuilder: (context) => [
        for (final kind in PrintKind.values)
          PopupMenuItem(
            key: Key('ticket-print-${kind.name}'),
            value: kind,
            child: Text(kind.label),
          ),
      ],
    );
  }
}

enum PrintAction { print, email }
