import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vola_fix/data/database.dart';
import 'package:vola_fix/data/print_documents.dart';
import 'package:vola_fix/data/tickets_repository.dart';

void main() {
  test('every document builds a PDF and email goes to the customer', () async {
    final database = AppDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftTicketsRepository(database);
    final ticket = await database.createTicket(
      customerName: 'Pat Client',
      customerPhone: '555-0100',
      customerEmail: 'pat@example.com',
      deviceName: 'Switch OLED',
      complaint: 'USB-C port',
    );
    await database.addInvoiceLaborLine(
      ticketId: ticket.id,
      description: 'USB-C port replacement',
      quantity: 1,
      unitPriceCents: 6000,
    );
    await database.writeSetting(warrantyDisclaimerKey, 'No refunds on wear.');

    final data = await loadTicketPrintData(repository, database, ticket.id);
    expect(data, isNotNull);
    expect(data!.recipientEmail, 'pat@example.com');
    expect(data.disclaimer, 'No refunds on wear.');
    for (final kind in PrintKind.values) {
      final bytes = await buildTicketPdf(data, kind);
      expect(String.fromCharCodes(bytes.take(4)), '%PDF', reason: kind.label);
    }
  });
}
