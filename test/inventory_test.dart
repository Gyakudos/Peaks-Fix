import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vola_fix/data/database.dart';
import 'package:vola_fix/data/tickets_repository.dart';

void main() {
  late AppDatabase database;
  late DriftTicketsRepository repository;

  setUp(() {
    database = AppDatabase.withExecutor(NativeDatabase.memory());
    repository = DriftTicketsRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<int> newTicket(String name) async {
    final ticket = await database.createTicket(
      customerName: name,
      customerPhone: '555-0100',
      customerEmail: '$name@example.com',
      deviceName: 'Switch OLED',
      complaint: 'USB-C port',
    );
    return ticket.id;
  }

  Future<InventoryPart> readPart() async =>
      (await repository.watchInventoryParts().first).single;

  Future<void> closeTicket(int ticketId) async {
    await database.setTicketStatus(ticketId, TicketStatus.ready);
    await database.closeTicketAfterPayment(ticketId);
  }

  test('committed counts parts on open tickets only', () async {
    final partId = await database.createInventoryPart(
      name: 'USB-C charging port',
      startingStock: 6,
    );
    final openTicket = await newTicket('open');
    final closingTicket = await newTicket('closing');
    final cancelledTicket = await newTicket('cancelled');

    await database.addRequiredPart(
      ticketId: openTicket,
      partId: partId,
      quantity: 2,
    );
    await database.addRequiredPart(
      ticketId: closingTicket,
      partId: partId,
      quantity: 3,
    );
    await database.addRequiredPart(
      ticketId: cancelledTicket,
      partId: partId,
      quantity: 4,
    );
    await database.setTicketStatus(cancelledTicket, TicketStatus.cancelled);

    // Adding a part to a ticket leaves the shelf count alone.
    var part = await readPart();
    expect(part.stock, 6);
    expect(part.committedQuantity, 5);

    // Closing a ticket takes its parts out of stock; the cancelled one never
    // counted.
    await closeTicket(closingTicket);
    part = await readPart();
    expect(part.stock, 3);
    expect(part.committedQuantity, 2);
  });

  test('closing a ticket records the part movement', () async {
    final partId = await database.createInventoryPart(
      name: 'USB-C charging port',
      startingStock: 4,
    );
    final ticketId = await newTicket('movement');
    await database.addRequiredPart(
      ticketId: ticketId,
      partId: partId,
      quantity: 2,
    );

    await closeTicket(ticketId);

    final movements = await database.select(database.partMovements).get();
    expect(movements, hasLength(2));
    final used = movements.firstWhere((row) => row.delta == -2);
    expect(used.partId, partId);
    expect(used.ticketId, ticketId);
    expect(used.note, 'Used on closed ticket');
  });

  test('reopening a ticket does not deduct its parts twice', () async {
    final partId = await database.createInventoryPart(
      name: 'Joy-Con rail',
      startingStock: 5,
    );
    final ticketId = await newTicket('warranty');
    await database.addRequiredPart(
      ticketId: ticketId,
      partId: partId,
      quantity: 2,
    );

    await closeTicket(ticketId);
    expect((await readPart()).stock, 3);

    // Reopen for warranty work. The fitted parts stay consumed, so the job
    // does not reserve them again.
    await database.setTicketStatus(ticketId, TicketStatus.inRepair);
    var part = await readPart();
    expect(part.stock, 3);
    expect(part.committedQuantity, 0);

    // A part added for the second visit is only taken out on the next close.
    await database.addRequiredPart(
      ticketId: ticketId,
      partId: partId,
      quantity: 1,
    );
    part = await readPart();
    expect(part.stock, 3);
    expect(part.committedQuantity, 1);

    await closeTicket(ticketId);
    part = await readPart();
    expect(part.stock, 2);
    expect(part.committedQuantity, 0);

    final movements = await database.select(database.partMovements).get();
    final used = movements.where((row) => row.delta < 0).toList();
    expect(used, hasLength(2));
    expect(used.map((row) => row.delta).reduce((a, b) => a + b), -3);
  });

  test('stock stops at zero when a ticket uses more than is on hand', () async {
    final partId = await database.createInventoryPart(
      name: 'Screen protector',
      startingStock: 1,
    );
    final ticketId = await newTicket('short');
    await database.addRequiredPart(
      ticketId: ticketId,
      partId: partId,
      quantity: 3,
    );

    await closeTicket(ticketId);

    expect((await readPart()).stock, 0);
    final movements = await database.select(database.partMovements).get();
    final used = movements.firstWhere((row) => row.delta < 0);
    expect(used.delta, -1);
    expect(used.note, 'Used on closed ticket (stock short by 2)');
  });

  test('committed follows quantity edits and removed lines', () async {
    final partId = await database.createInventoryPart(
      name: 'USB-C charging port',
      startingStock: 10,
    );
    final ticketId = await newTicket('edits');

    await database.addRequiredPart(
      ticketId: ticketId,
      partId: partId,
      quantity: 1,
    );
    expect((await readPart()).committedQuantity, 1);

    // Adding the same part again stacks onto the existing ticket line.
    await database.addRequiredPart(
      ticketId: ticketId,
      partId: partId,
      quantity: 3,
    );
    expect((await readPart()).committedQuantity, 4);

    final line = (await repository.watchRequiredParts(ticketId).first).single;
    await repository.removeRequiredPart(
      ticketId: ticketId,
      ticketItemId: line.ticketItemId,
    );
    expect((await readPart()).committedQuantity, 0);
    expect((await readPart()).stock, 10);
  });

  test('committed ignores parts on tickets that were deleted', () async {
    final partId = await database.createInventoryPart(
      name: 'Screen protector',
      startingStock: 2,
    );
    final ticketId = await newTicket('deleted');
    await database.addRequiredPart(
      ticketId: ticketId,
      partId: partId,
      quantity: 1,
    );
    expect((await readPart()).committedQuantity, 1);

    await database.deleteTicket(ticketId);
    expect((await readPart()).committedQuantity, 0);
  });
}
