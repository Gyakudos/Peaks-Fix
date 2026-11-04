import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'database.dart';
import 'partners.dart';
import 'tickets_repository.dart';
import 'warranty.dart';

const warrantyDisclaimerKey = 'warranty_disclaimer';
const shopLogoKey = 'shop_logo_path';

/// Settings keys for the shop's chosen printer (empty = ask every time).
const printerUrlKey = 'default_printer_url';
const printerNameKey = 'default_printer_name';

/// Which paper document to produce for a ticket.
enum PrintKind {
  invoice('Invoice'),
  report1('Report 1 - Intake'),
  report2('Report 2 - Technical'),
  report3('Report 3 - Client'),
  partsRequired('Parts required'),
  warranty('Warranty');

  const PrintKind(this.label);

  final String label;
}

/// Everything the printed documents draw from, read once per print.
class TicketPrintData {
  const TicketPrintData({
    required this.entry,
    required this.photos,
    required this.technical,
    required this.client,
    required this.warranty,
    required this.invoice,
    required this.payments,
    required this.shopName,
    required this.disclaimer,
    this.logoPath = '',
    this.requiredParts = const [],
    this.recipientEmail = '',
    this.recipientName = '',
  });

  final TicketDetailEntry entry;
  final PhotoChecklist photos;
  final List<TechnicalReportBlock> technical;
  final List<ClientReportBlock> client;
  final ClientReportWarranty warranty;
  final InvoiceDraft? invoice;
  final List<PaymentEntry> payments;
  final String shopName;
  final String disclaimer;
  final List<RequiredPart> requiredParts;
  final String logoPath;

  /// Where documents are emailed: the partner for partner bookings, otherwise
  /// the customer. Empty when no address is on file.
  final String recipientEmail;
  final String recipientName;
}

/// Reads a ticket's reports, invoice and the shop's print settings.
Future<TicketPrintData?> loadTicketPrintData(
  TicketsRepository repository,
  AppDatabase database,
  int ticketId,
) async {
  final entry = await repository.watchTicket(ticketId).first;
  if (entry == null) return null;
  var email = '';
  var name = entry.summary.customerName;
  final partnerName = entry.summary.partnerName;
  if (partnerName.isNotEmpty) {
    final partner = (await loadPartners(database))
        .where((p) => p.name.toLowerCase() == partnerName.toLowerCase())
        .firstOrNull;
    email = partner?.email.trim() ?? '';
    name = partnerName;
  } else {
    final ticket = await (database.select(database.tickets)
          ..where((t) => t.id.equals(ticketId)))
        .getSingleOrNull();
    final customer = ticket == null
        ? null
        : await (database.select(database.customers)
              ..where((c) => c.id.equals(ticket.customerId)))
            .getSingleOrNull();
    email = customer?.email?.trim() ?? '';
  }
  return TicketPrintData(
    recipientEmail: email,
    recipientName: name,
    logoPath: await database.readSetting(shopLogoKey, ''),
    requiredParts: await repository.watchRequiredParts(ticketId).first,
    entry: entry,
    photos: await repository.watchPhotoChecklist(ticketId).first,
    technical: await repository.watchTechnicalEntries(ticketId).first,
    client: await repository.watchClientReportEntries(ticketId).first,
    warranty: await repository.watchClientReportWarranty(ticketId).first,
    invoice: await repository.watchInvoice(ticketId).first,
    payments: await repository.watchTicketPayments(ticketId).first,
    shopName: await database.readSetting('shop_name', 'Peaks Fix'),
    disclaimer: (await database.readSetting(warrantyDisclaimerKey, '')).trim(),
  );
}

String _money(int cents) =>
    '${cents < 0 ? '-' : ''}\$${(cents.abs() / 100).toStringAsFixed(2)}';

String _date(DateTime? time) {
  if (time == null) return '';
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${time.day} ${months[time.month - 1]} ${time.year}';
}

/// Builds the PDF for [kind].
Future<Uint8List> buildTicketPdf(TicketPrintData data, PrintKind kind) async {
  final document =
      pw.Document(title: '${kind.label} ${data.entry.summary.number}');
  final logo = await _image(data.logoPath.isEmpty ? null : data.logoPath);
  final widgets = <pw.Widget>[
    ..._header(data, kind.label, logo),
    ...switch (kind) {
      PrintKind.invoice => _invoiceBody(data),
      PrintKind.report1 => await _report1Body(data),
      PrintKind.report2 => await _report2Body(data),
      PrintKind.report3 => await _report3Body(data),
      PrintKind.partsRequired => _partsRequiredBody(data),
      PrintKind.warranty => await _warrantyBody(data),
    },
  ];
  document.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.letter,
      margin: const pw.EdgeInsets.all(36),
      build: (context) => widgets,
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          '${data.shopName} - ${data.entry.summary.number} - '
          'page ${context.pageNumber} of ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
        ),
      ),
    ),
  );
  return document.save();
}

List<pw.Widget> _header(
  TicketPrintData data,
  String title,
  pw.MemoryImage? logo,
) {
  final summary = data.entry.summary;
  return [
    pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('Ticket ${summary.number}'),
          ],
        ),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              data.shopName,
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            if (logo != null) ...[
              pw.SizedBox(width: 10),
              pw.SizedBox(height: 54, child: pw.Image(logo)),
            ],
          ],
        ),
      ],
    ),
    pw.Divider(),
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Customer: ${summary.customerName}'),
              if (summary.partnerName.isNotEmpty)
                pw.Text('Partner: ${summary.partnerName}'),
              pw.Text('Opened: ${_date(summary.createdAt)}'),
            ],
          ),
        ),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Device: ${summary.deviceWithVariant}'),
              pw.Text('Serial: ${summary.serial ?? 'not recorded'}'),
              if (summary.shopTag != null)
                pw.Text('Shop tag: ${summary.shopTag}'),
            ],
          ),
        ),
      ],
    ),
    pw.SizedBox(height: 14),
  ];
}

pw.Widget _heading(String text) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 10, bottom: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
      ),
    );

pw.Widget _paragraph(String text) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4), child: pw.Text(text));

Future<pw.MemoryImage?> _image(String? path) async {
  if (path == null) return null;
  final lower = path.toLowerCase();
  if (!(lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.png'))) {
    return null;
  }
  final file = File(path);
  if (!await file.exists()) return null;
  try {
    return pw.MemoryImage(await file.readAsBytes());
  } catch (_) {
    return null;
  }
}

Future<pw.Widget> _photo(String? path, String? caption) async {
  final image = await _image(path);
  return pw.Container(
    width: 240,
    padding: const pw.EdgeInsets.all(4),
    decoration:
        pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400)),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (image != null)
          pw.SizedBox(height: 170, child: pw.Center(child: pw.Image(image)))
        else
          pw.SizedBox(
            height: 40,
            child: pw.Center(child: pw.Text('No photo taken')),
          ),
        if (caption != null && caption.trim().isNotEmpty)
          pw.Text(caption, style: const pw.TextStyle(fontSize: 9)),
      ],
    ),
  );
}

Future<List<pw.Widget>> _report1Body(TicketPrintData data) async {
  final notes = data.entry.intakeNotes?.trim() ?? '';
  return [
    _heading('Reported fault'),
    _paragraph(data.entry.summary.complaint),
    _heading('Condition at drop-off'),
    _paragraph(notes.isEmpty ? 'No condition notes.' : notes),
    if (data.entry.report1CompletedAt != null)
      _paragraph('Completed ${_date(data.entry.report1CompletedAt)}'),
    _heading('Photos'),
    if (data.photos.slots.isEmpty)
      _paragraph('No photo checklist on this ticket.')
    else
      pw.Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final slot in data.photos.slots)
            await _photo(slot.photoPath, '${slot.sortOrder}. ${slot.label}'),
        ],
      ),
  ];
}

Future<List<pw.Widget>> _technicalBlocks(
  List<TechnicalReportBlock> blocks,
) async {
  if (blocks.isEmpty) return [_paragraph('No technical entries.')];
  final ordered = [...blocks]
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  final out = <pw.Widget>[];
  for (final block in ordered) {
    final indent = block.parentEntryId == null ? 0.0 : 16.0;
    if (block.kind == TechnicalEntryKind.photo) {
      out.add(
        pw.Padding(
          padding: pw.EdgeInsets.only(left: indent, bottom: 6),
          child: await _photo(block.photoPath, block.caption),
        ),
      );
    } else if ((block.text ?? '').trim().isNotEmpty) {
      out.add(
        pw.Padding(
          padding: pw.EdgeInsets.only(left: indent, bottom: 4),
          child: pw.Text(block.text!.trim()),
        ),
      );
    }
  }
  return out;
}

Future<List<pw.Widget>> _report2Body(TicketPrintData data) async {
  final diagnosis = data.entry.diagnosis?.trim() ?? '';
  return [
    if (diagnosis.isNotEmpty) ...[
      _heading('Diagnosis'),
      _paragraph(diagnosis),
    ],
    _heading('Technical report'),
    ...await _technicalBlocks(data.technical),
    if (data.entry.report2CompletedAt != null)
      _paragraph('Completed ${_date(data.entry.report2CompletedAt)}'),
  ];
}

List<pw.Widget> _warrantyBlock(TicketPrintData data) {
  final warranty = data.warranty;
  return [
    _heading('Warranty'),
    _paragraph(
      'Length: ${WarrantyConfig.daysLabel(warranty.effectiveDays)}'
      '${warranty.expiresAt == null ? '' : ' - until ${_date(warranty.expiresAt)}'}',
    ),
    _paragraph(warranty.effectiveTerms),
  ];
}

Future<List<pw.Widget>> _report3Body(TicketPrintData data) async {
  final included = data.client.where((block) => block.included).toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  final out = <pw.Widget>[_heading('What we did')];
  if (included.isEmpty) out.add(_paragraph('No report entries.'));
  for (final block in included) {
    if (block.kind == TechnicalEntryKind.photo) {
      out.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 6),
          child: await _photo(block.photoPath, block.caption),
        ),
      );
    } else if ((block.text ?? '').trim().isNotEmpty) {
      out.add(_paragraph(block.text!.trim()));
    }
  }
  return [...out, ..._warrantyBlock(data)];
}

Future<List<pw.Widget>> _warrantyBody(TicketPrintData data) async {
  return [
    ..._warrantyBlock(data),
    if (data.disclaimer.isNotEmpty) ...[
      _heading('Warranty disclaimer'),
      _paragraph(data.disclaimer),
    ],
    _heading('Technician report - intake photos'),
    if ((data.entry.intakeNotes ?? '').trim().isNotEmpty)
      _paragraph(data.entry.intakeNotes!.trim()),
    pw.Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final slot in data.photos.slots)
          if (slot.captured)
            await _photo(slot.photoPath, '${slot.sortOrder}. ${slot.label}'),
      ],
    ),
    _heading('Diagnostics'),
    if ((data.entry.diagnosis ?? '').trim().isNotEmpty)
      _paragraph(data.entry.diagnosis!.trim()),
    ...await _technicalBlocks(data.technical),
  ];
}

List<pw.Widget> _partsRequiredBody(TicketPrintData data) {
  if (data.requiredParts.isEmpty) {
    return [_paragraph('No parts have been listed for this ticket.')];
  }
  return [
    pw.TableHelper.fromTextArray(
      headers: const ['Part', 'SKU', 'Qty', 'Location', 'Unit', 'Total'],
      data: [
        for (final part in data.requiredParts)
          [
            part.name,
            part.sku ?? '',
            '${part.quantity}',
            part.location ?? '',
            _money(part.retailPriceCents),
            _money(part.retailPriceCents * part.quantity),
          ],
      ],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignments: {
        2: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
      },
    ),
  ];
}

List<pw.Widget> _invoiceBody(TicketPrintData data) {
  final invoice = data.invoice;
  if (invoice == null || invoice.lines.isEmpty) {
    return [_paragraph('This ticket has no invoice lines yet.')];
  }
  final paid = data.payments.fold<int>(
    0,
    (total, payment) => payment.kind == PaymentKind.refund
        ? total - payment.amountCents
        : total + payment.amountCents,
  );
  pw.Widget row(String label, String value, {bool bold = false}) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              label,
              style: bold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null,
            ),
          ),
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: bold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null,
            ),
          ),
        ],
      );
  return [
    pw.TableHelper.fromTextArray(
      headers: const ['Description', 'Qty', 'Unit', 'Total'],
      data: [
        for (final line in invoice.lines)
          [
            line.description + (line.isShopSupply ? ' (included)' : ''),
            '${line.quantity}',
            line.isShopSupply ? '' : _money(line.unitPriceCents),
            line.isShopSupply ? '' : _money(line.lineTotalCents),
          ],
      ],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
      columnWidths: {
        0: const pw.FlexColumnWidth(5),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2),
      },
    ),
    pw.SizedBox(height: 10),
    row('Subtotal', _money(invoice.subtotalCents)),
    if (invoice.discountCents > 0)
      row('Discount', _money(-invoice.discountCents)),
    for (final tax in invoice.taxLines) row(tax.label, _money(tax.amountCents)),
    row('Total', _money(invoice.totalCents), bold: true),
    if (data.payments.isNotEmpty) ...[
      pw.SizedBox(height: 8),
      for (final payment in data.payments)
        row(
          '${payment.kind.name[0].toUpperCase()}${payment.kind.name.substring(1)}'
          ' (${payment.method.label}, ${_date(payment.at)})',
          _money(
            payment.kind == PaymentKind.refund
                ? -payment.amountCents
                : payment.amountCents,
          ),
        ),
      row('Balance due', _money(invoice.totalCents - paid), bold: true),
    ],
  ];
}
