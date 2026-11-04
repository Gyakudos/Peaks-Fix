import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vola_fix/data/database.dart';
import 'package:vola_fix/data/inventory_file.dart';
import 'package:vola_fix/data/schedule.dart';
import 'package:vola_fix/shell/app_access.dart';

void main() {
  test('staff can change their own password only with the current one',
      () async {
    final db = AppDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    final admin = await createFirstAdmin(
      db,
      name: 'Boss',
      username: 'boss',
      password: 'secret1',
    );
    expect(
      await changeStaffPassword(db,
          staffId: admin.id, currentPassword: 'nope', newPassword: 'newpass1'),
      isFalse,
    );
    expect(
      await changeStaffPassword(db,
          staffId: admin.id,
          currentPassword: 'secret1',
          newPassword: 'newpass1'),
      isTrue,
    );
    final reloaded = (await loadStaffAccounts(db)).single;
    expect(reloaded.checkPassword('newpass1'), isTrue);
    expect(reloaded.checkPassword('secret1'), isFalse);
  });

  test('inventory exports to a file and imports into another shop', () async {
    final a = AppDatabase.withExecutor(NativeDatabase.memory());
    final b = AppDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(a.close);
    addTearDown(b.close);
    final screen = await a.createInventoryPart(
      name: 'Screen',
      sku: '001-001',
      vendorId: 'Acme',
      vendorSku: 'AC-9',
      startingStock: 4,
      rawCostCents: 1000,
      retailPriceCents: 2500,
    );
    final labour = await a.createInventoryPart(
      name: 'Screen swap',
      sku: '001-002',
      category: 'Labour',
      jobLevel: 2,
      startingStock: 0,
      retailPriceCents: 5000,
    );
    await a.setLabourIncludedParts(
      labour,
      [LabourIncludedPart(partId: screen, quantity: 1)],
    );
    await a.createMerchItem(
      name: 'Shirt',
      sku: '001-001',
      startingStock: 3,
      priceCents: 2000,
    );

    final file = await exportInventory(a);
    expect(file, isNot(contains('"stock"')));
    final first = await importInventory(b, file);
    expect(first.added, 3);
    final rows = await b.select(b.parts).get();
    final imported = rows.firstWhere((row) => row.sku == '001-001');
    expect(imported.vendorSku, 'AC-9');
    expect(imported.priceCents, 2500);
    expect(imported.stock, 0);
    expect(
      (await b.select(b.parts).get())
          .firstWhere((r) => r.sku == '001-002')
          .jobLevel,
      2,
    );
    expect(await b.select(b.merchProducts).get(), hasLength(1));
    final labourMap = await b.watchLabourIncludedParts().first;
    expect(labourMap.values.single.single.partId, imported.id);

    final again = await importInventory(b, file);
    expect((again.added, again.updated), (0, 3));
    expect(await b.select(b.parts).get(), hasLength(2));

    final withStock = await exportInventory(a, includeStock: true);
    await importInventory(b, withStock);
    expect(
      (await b.select(b.parts).get())
          .firstWhere((r) => r.sku == '001-001')
          .stock,
      4,
    );
    expect(
      () => importInventory(b, '{"hello": 1}'),
      throwsA(isA<FormatException>()),
    );
  });

  test('technicians are active Admin (Tech 0) and Tech 1-3 staff', () async {
    final db = AppDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    await db.writeSetting(
      'staff_roster',
      jsonEncode([
        {'id': 'a', 'name': 'Boss', 'job': 'Admin'},
        {'id': 'b', 'name': 'Tess', 'job': 'Tech 1'},
        {'id': 'c', 'name': 'Tim', 'job': 'Tech 3'},
        {'id': 'd', 'name': 'Fran', 'job': 'Front Desk'},
        {'id': 'e', 'name': 'Gone', 'job': 'Tech 2', 'isActive': false},
      ]),
    );
    final techs = await loadTechnicians(db);
    expect(
      [for (final t in techs) '${t.name}:${t.job}'],
      ['Boss:Tech 0', 'Tess:Tech 1', 'Tim:Tech 3'],
    );
  });
}
