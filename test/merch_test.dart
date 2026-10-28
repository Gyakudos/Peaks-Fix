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

  test('merchandise keeps its own SKUs, stock, cost and retail price',
      () async {
    await repository.createInventoryPart(
      name: 'USB-C charging port',
      startingStock: 1,
    );
    await repository.createMerchItem(
      name: 'Peaks Fix T-shirt',
      description: 'Black cotton shirt',
      category: 'Apparel',
      location: 'Shelf A2',
      startingStock: 12,
      costCents: 1000,
      priceCents: 2000,
    );

    final items = await repository.watchMerchItems().first;
    expect(items, hasLength(1));
    final item = items.single;
    expect(item.name, 'Peaks Fix T-shirt');
    expect(item.description, 'Black cotton shirt');
    expect(item.category, 'Apparel');
    expect(item.location, 'Shelf A2');
    expect(item.stock, 12);
    expect(item.costCents, 1000);
    expect(item.priceCents, 2000);
    expect(item.profitCents, 1000);

    // Merchandise has its own sequence, so the part keeps 001-001 too.
    expect(item.sku, '001-001');
    expect(await repository.nextPartSku(), '001-002');
    expect(await repository.nextMerchSku(), '001-002');
  });

  test('editing merchandise preserves a blank SKU and removing hides it',
      () async {
    await repository.createMerchItem(
      name: 'Sticker',
      startingStock: 30,
      costCents: 100,
      priceCents: 300,
    );
    final itemId = (await repository.watchMerchItems().first).single.id;

    await repository.updateMerchItem(
      itemId: itemId,
      name: 'Logo sticker',
      description: 'Holographic',
      sku: '',
      category: 'Accessories',
      location: 'Counter',
      stock: 28,
      costCents: 150,
      priceCents: 400,
    );

    final edited = (await repository.watchMerchItems().first).single;
    expect(edited.name, 'Logo sticker');
    expect(edited.sku, '001-001');
    expect(edited.stock, 28);
    expect(edited.costCents, 150);
    expect(edited.priceCents, 400);

    await repository.removeMerchItem(itemId);
    expect(await repository.watchMerchItems().first, isEmpty);
  });

  test('merchandise rejects negative stock and costs', () async {
    expect(
      () => repository.createMerchItem(name: 'Bad', startingStock: -1),
      throwsArgumentError,
    );
    expect(
      () => repository.createMerchItem(
        name: 'Bad',
        startingStock: 1,
        costCents: -1,
      ),
      throwsArgumentError,
    );

    await repository.createMerchItem(name: 'Good', startingStock: 1);
    final itemId = (await repository.watchMerchItems().first).single.id;
    expect(
      () => repository.updateMerchItem(
        itemId: itemId,
        name: 'Good',
        stock: 1,
        costCents: 0,
        priceCents: -1,
      ),
      throwsArgumentError,
    );
  });
}
