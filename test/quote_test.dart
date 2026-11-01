import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vola_fix/data/database.dart';
import 'package:vola_fix/data/ticket_due.dart';
import 'package:vola_fix/data/tickets_repository.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase.withExecutor(NativeDatabase.memory()));
  tearDown(() => database.close());

  test('a quote is not active and has no stock committed', () async {
    final quote = await database.createQuote(customerName: 'Sam');
    final row = await (database.select(database.tickets)
          ..where((t) => t.id.equals(quote.id)))
        .getSingle();
    expect(row.status, TicketStatus.quote);
    expect(row.status.isActive, isFalse);
  });

  test('quotes expire after 14 days', () async {
    final quote = await database.createQuote();
    expect(await database.expiredQuoteIds(), isEmpty);
    final later = DateTime.now().add(const Duration(days: 15));
    expect(await database.expiredQuoteIds(now: later), [quote.id]);

    final repository = DriftTicketsRepository(database);
    // Fresh quote is kept, so purge now removes nothing.
    await repository.purgeExpiredQuotes();
    expect(await database.select(database.tickets).get(), hasLength(1));
  });

  test('adopting a quote moves its lines and removes it', () async {
    final quote = await database.createQuote(customerName: 'Sam');
    await database.into(database.ticketItems).insert(
          TicketItemsCompanion.insert(
            ticketId: quote.id,
            kind: TicketItemKind.custom,
            description: 'Labour',
            unitPriceCents: const Value(5000),
          ),
        );
    final repair = await database.createTicket(
      customerName: 'Sam',
      customerPhone: '555',
      customerEmail: 'a@b.c',
      deviceName: 'Phone',
      complaint: 'Cracked',
    );
    await database.adoptQuote(quoteId: quote.id, ticketId: repair.id);

    final items = await database.select(database.ticketItems).get();
    expect(items.single.ticketId, repair.id);
    final ids = (await database.select(database.tickets).get())
        .map((t) => t.id)
        .toList();
    expect(ids, [repair.id]);
  });

  test('quote expiry date is 14 days after opening', () {
    expect(quoteExpiryDate(DateTime(2026, 10, 28, 9)), DateTime(2026, 11, 11));
  });
}
