import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vola_fix/data/database.dart';
import 'package:vola_fix/data/device_catalog.dart';
import 'package:vola_fix/data/tickets_repository.dart';
import 'package:vola_fix/data/warranty.dart';
import 'package:vola_fix/features/settings/settings_page.dart';

void main() {
  late AppDatabase database;
  late DeviceCatalog catalog;

  setUp(() {
    database = AppDatabase.withExecutor(NativeDatabase.memory());
    catalog = DeviceCatalog(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<DeviceCategory> categoryNamed(String name) =>
      (database.select(database.deviceCategories)
            ..where((category) => category.name.equals(name)))
          .getSingle();

  test('adds, renames and removes a category', () async {
    final id = await catalog.addCategory('  Printers  ');

    var categories = await catalog.watch().first;
    final added = categories.singleWhere((category) => category.id == id);
    expect(added.name, 'Printers');
    expect(added.isActive, isTrue);
    expect(added.brands, isEmpty);

    await catalog.renameCategory(id, 'Printers and scanners');
    categories = await catalog.watch().first;
    expect(
      categories.singleWhere((category) => category.id == id).name,
      'Printers and scanners',
    );

    await catalog.setCategoryActive(id, false);
    categories = await catalog.watch().first;
    expect(
      categories.singleWhere((category) => category.id == id).isActive,
      isFalse,
    );

    await catalog.deleteCategory(id);
    categories = await catalog.watch().first;
    expect(categories.where((category) => category.id == id), isEmpty);
  });

  test('rejects blank, overlong and duplicate names', () async {
    await catalog.addCategory('Printers');

    await expectLater(
      catalog.addCategory('   '),
      throwsA(isA<CatalogNameError>()),
    );
    await expectLater(
      catalog.addCategory('Printers'),
      throwsA(isA<CatalogNameError>()),
    );
    await expectLater(
      catalog.addCategory('x' * (DeviceCatalog.maxCategoryLength + 1)),
      throwsA(isA<CatalogNameError>()),
    );
  });

  test('adds headings and devices, and removing a heading takes them along',
      () async {
    final categoryId = await catalog.addCategory('Printers');
    final brandId = await catalog.addBrand(categoryId, 'Brother');
    final deviceId = await catalog.addDevice(brandId, 'HL-L2350DW');

    var categories = await catalog.watch().first;
    var category = categories.singleWhere((row) => row.id == categoryId);
    expect(category.brands.single.name, 'Brother');
    expect(category.brands.single.devices.single.name, 'HL-L2350DW');
    expect(category.deviceCount, 1);

    await catalog.renameBrand(brandId, 'Brother laser');
    await catalog.renameDevice(deviceId, 'HL-L2400D');
    categories = await catalog.watch().first;
    category = categories.singleWhere((row) => row.id == categoryId);
    expect(category.brands.single.name, 'Brother laser');
    expect(category.brands.single.devices.single.name, 'HL-L2400D');

    await catalog.deleteBrand(brandId);
    categories = await catalog.watch().first;
    category = categories.singleWhere((row) => row.id == categoryId);
    expect(category.brands, isEmpty);
    expect(await database.select(database.deviceModels).get(), isEmpty);
  });

  test('a removed device keeps its name on past tickets', () async {
    final customerId = await database
        .into(database.customers)
        .insert(CustomersCompanion.insert(name: 'Alex Customer'));
    final categoryId = await catalog.addCategory('Printers');
    final brandId = await catalog.addBrand(categoryId, 'Brother');
    final deviceId = await catalog.addDevice(brandId, 'HL-L2350DW');
    final ticketId = await database.into(database.tickets).insert(
          TicketsCompanion.insert(
            number: 'PF-000001',
            customerId: customerId,
            deviceModelId: drift.Value(deviceId),
            deviceName: const drift.Value('Brother HL-L2350DW'),
            complaint: 'Paper jam',
            status: TicketStatus.received,
          ),
        );

    await catalog.deleteDevice(deviceId);

    final ticket = await (database.select(database.tickets)
          ..where((row) => row.id.equals(ticketId)))
        .getSingle();
    expect(ticket.deviceModelId, isNull);
    expect(ticket.deviceName, 'Brother HL-L2350DW');
  });

  test('added devices show up in the intake catalog, hidden ones do not',
      () async {
    final repository = DriftTicketsRepository(database);
    final categoryId = await catalog.addCategory('Printers');
    final brandId = await catalog.addBrand(categoryId, 'Brother');
    final deviceId = await catalog.addDevice(brandId, 'HL-L2350DW');

    var options = await repository.deviceCatalog();
    expect(
      options.where((option) => option.modelName == 'HL-L2350DW'),
      hasLength(1),
    );
    expect(
      await repository.deviceCategories(),
      contains('Printers'),
    );

    await catalog.setDeviceActive(deviceId, false);
    options = await repository.deviceCatalog();
    expect(
      options.where((option) => option.modelName == 'HL-L2350DW'),
      isEmpty,
    );
  });

  test('categories carry a warranty period for Report 3', () async {
    final id = await catalog.addCategory('Printers');
    var categories = await catalog.watch().first;
    expect(
      categories.singleWhere((category) => category.id == id).warrantyDays,
      WarrantyConfig.defaultDays,
    );

    await catalog.setCategoryWarrantyDays(id, 120);
    categories = await catalog.watch().first;
    expect(
      categories.singleWhere((category) => category.id == id).warrantyDays,
      120,
    );

    await expectLater(
      catalog.setCategoryWarrantyDays(id, 0),
      throwsA(isA<CatalogNameError>()),
    );
    await expectLater(
      catalog.setCategoryWarrantyDays(id, WarrantyConfig.maxDays + 1),
      throwsA(isA<CatalogNameError>()),
    );
  });

  testWidgets('settings edits categories, headings and devices',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    /// Types into the open name dialog and lets the save button re-enable.
    Future<void> enterName(String name) async {
      await tester.enterText(find.byKey(const Key('catalog-name-field')), name);
      await tester.pump();
      await tester.tap(find.byKey(const Key('catalog-name-save')));
      await tester.pumpAndSettle();
    }

    await tester
        .pumpWidget(MaterialApp(home: SettingsPage(database: database)));
    await tester.pumpAndSettle();

    // Add a category from Settings.
    await tester.tap(find.byKey(const Key('catalog-add-category')));
    await tester.pumpAndSettle();
    await enterName('Printers');
    expect(find.text('Printers'), findsOneWidget);

    // Open it: no headings yet.
    await tester.tap(find.text('Printers'));
    await tester.pumpAndSettle();
    expect(find.text('No headings yet.'), findsOneWidget);
    expect(find.text('90 days · offered on Report 3'), findsOneWidget);

    // Change the warranty period for this category.
    await tester.tap(find.byKey(const Key('catalog-category-warranty-edit')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('catalog-warranty-days')),
      '120',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('catalog-warranty-save')));
    await tester.pumpAndSettle();
    expect(find.text('120 days · offered on Report 3'), findsOneWidget);

    // Add a brand heading and a device under it.
    await tester.tap(find.byKey(const Key('catalog-add-brand')));
    await tester.pumpAndSettle();
    await enterName('Brother');
    expect(find.text('Brother'), findsOneWidget);

    final brand = await (database.select(database.deviceBrands)
          ..where((row) => row.name.equals('Brother')))
        .getSingle();
    await tester.tap(find.byKey(Key('catalog-add-device-${brand.id}')));
    await tester.pumpAndSettle();
    await enterName('HL-L2350DW');
    expect(find.text('HL-L2350DW'), findsOneWidget);

    // Rename the device.
    final device = await (database.select(database.deviceModels)
          ..where((row) => row.name.equals('HL-L2350DW')))
        .getSingle();
    await tester.tap(find.byKey(Key('catalog-device-menu-${device.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rename device'));
    await tester.pumpAndSettle();
    await enterName('HL-L2400D');
    expect(find.text('HL-L2400D'), findsOneWidget);

    // Remove the heading, which takes its devices with it.
    await tester.tap(find.byKey(Key('catalog-brand-menu-${brand.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove heading'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('catalog-confirm-remove')));
    await tester.pumpAndSettle();
    expect(find.text('No headings yet.'), findsOneWidget);
    expect(find.text('HL-L2400D'), findsNothing);
    expect(await database.select(database.deviceModels).get(), isEmpty);

    // Back in Settings, remove the category.
    await tester.pageBack();
    await tester.pumpAndSettle();
    final category = await categoryNamed('Printers');
    await tester.tap(
      find.byKey(Key('catalog-category-menu-${category.id}')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove category'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('catalog-confirm-remove')));
    await tester.pumpAndSettle();
    expect(find.text('Printers'), findsNothing);

    // Unmount so drift's stream-cancel timer is flushed.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });
}
