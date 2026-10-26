import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vola_fix/app.dart';
import 'package:vola_fix/data/database.dart';
import 'package:vola_fix/data/photo_templates.dart';
import 'package:vola_fix/data/tickets_repository.dart';

/// Stands in for SQLite so these tests never open a database file.
class FakeTicketsRepository implements TicketsRepository {
  FakeTicketsRepository({List<DeviceOption>? catalog})
      : catalog = catalog ?? _defaultCatalog;

  static const _defaultCatalog = <DeviceOption>[
    DeviceOption(
      modelId: 1,
      category: 'Consoles',
      modelName: 'PlayStation 5',
      label: 'Sony PlayStation 5',
    ),
    DeviceOption(
      modelId: 2,
      category: 'Handheld PCs',
      modelName: 'Steam Deck OLED',
      label: 'Valve Steam Deck OLED',
    ),
    DeviceOption(
      modelId: 3,
      category: 'Portable Consoles',
      modelName: '3DS',
      label: 'Nintendo 3DS',
    ),
  ];

  final List<DeviceOption> catalog;
  final List<CreateCall> creations = <CreateCall>[];

  TicketDetailEntry? _detail;
  PhotoChecklist _checklist = const PhotoChecklist(
    templateKey: null,
    templateName: null,
    slots: [],
  );

  @override
  Stream<List<TicketBoardEntry>> watchBoard() => Stream.value(const []);

  @override
  Stream<TicketDetailEntry?> watchTicket(int ticketId) => Stream.value(_detail);

  @override
  Stream<PhotoChecklist> watchPhotoChecklist(int ticketId) =>
      Stream.value(_checklist);

  @override
  Future<List<DeviceOption>> deviceCatalog() async => catalog;

  @override
  Future<NewTicket> createTicket({
    required String customerName,
    required String customerPhone,
    required String customerEmail,
    int? deviceModelId,
    String? deviceName,
    String? deviceVariant,
    String? serial,
    bool serialMissing = false,
    String? photoTemplateKey,
    required String complaint,
  }) async {
    creations.add(
      CreateCall(
        customerName: customerName,
        customerPhone: customerPhone,
        customerEmail: customerEmail,
        deviceModelId: deviceModelId,
        deviceName: deviceName,
        deviceVariant: deviceVariant,
        serial: serial,
        serialMissing: serialMissing,
        photoTemplateKey: photoTemplateKey,
        complaint: complaint,
      ),
    );

    const result = NewTicket(
      id: 7,
      number: 'VF-000001',
      shopTag: 'G-123456789',
      customerId: 1,
    );

    _detail = TicketDetailEntry(
      summary: TicketBoardEntry(
        id: result.id,
        number: result.number,
        status: TicketStatus.received,
        customerName: customerName,
        device: deviceName ?? 'Sony PlayStation 5',
        complaint: complaint,
        createdAt: DateTime(2026, 1, 2, 9, 30),
        shopTag: result.shopTag,
        serial: serial,
        serialMissing: serialMissing,
        deviceVariant: deviceVariant,
      ),
    );

    final seed = photoTemplateSeed(photoTemplateKey);
    _checklist = PhotoChecklist(
      templateKey: seed?.key,
      templateName: seed?.name,
      slots: [
        if (seed != null)
          for (var index = 0; index < seed.slots.length; index++)
            TicketPhotoSlotEntry(
              sortOrder: index + 1,
              label: seed.slots[index].label,
              hint: seed.slots[index].hint,
            ),
      ],
    );

    return result;
  }

  @override
  Future<void> updateStatus(int ticketId, TicketStatus status) async {}
}

class CreateCall {
  const CreateCall({
    required this.customerName,
    required this.customerEmail,
    required this.complaint,
    this.customerPhone,
    this.deviceModelId,
    this.deviceName,
    this.deviceVariant,
    this.serial,
    this.serialMissing = false,
    this.photoTemplateKey,
  });

  final String customerName;
  final String? customerPhone;
  final String customerEmail;
  final int? deviceModelId;
  final String? deviceName;
  final String? deviceVariant;
  final String? serial;
  final bool serialMissing;
  final String? photoTemplateKey;
  final String complaint;
}

Future<void> _openIntake(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(FilledButton, 'New repair'));
  await tester.pumpAndSettle();
}

Future<void> _selectDevice(WidgetTester tester) async {
  await tester.tap(find.byType(DropdownButtonFormField<String>));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Consoles').last);
  await tester.pumpAndSettle();

  await tester.tap(find.byType(DropdownButtonFormField<int>));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Sony PlayStation 5').last);
  await tester.pumpAndSettle();
}

Future<void> _selectPortableDevice(
  WidgetTester tester,
  String label,
) async {
  await tester.tap(find.byType(DropdownButtonFormField<String>));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Portable Consoles').last);
  await tester.pumpAndSettle();

  await tester.tap(find.byType(DropdownButtonFormField<int>));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

Future<void> _fillCustomer(WidgetTester tester) async {
  await tester.enterText(
    find.byKey(const Key('intake-customer')),
    'Ana Ribeiro',
  );
  await tester.enterText(find.byKey(const Key('intake-phone')), '555 0102');
  await tester.enterText(
    find.byKey(const Key('intake-email')),
    'ana@example.com',
  );
  await tester.enterText(
    find.byKey(const Key('intake-complaint')),
    'Lid hinge cracked',
  );
}

void main() {
  testWidgets('app builds with all five tabs', (WidgetTester tester) async {
    await tester.pumpWidget(VolaFixApp(tickets: FakeTicketsRepository()));

    expect(find.text('Vola Fix'), findsWidgets);
    expect(find.text('Tickets'), findsWidgets);
    expect(find.text('Customers'), findsWidgets);
    expect(find.text('Merch'), findsWidgets);
    expect(find.text('Parts'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('wide layout uses a rail and switches tabs',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(VolaFixApp(tickets: FakeTicketsRepository()));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(find.text('Merch'));
    await tester.pumpAndSettle();

    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.selectedIndex, 2);
  });

  testWidgets('narrow layout uses the bottom bar', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(VolaFixApp(tickets: FakeTicketsRepository()));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('intake opens from the Tickets page',
      (WidgetTester tester) async {
    await tester.pumpWidget(VolaFixApp(tickets: FakeTicketsRepository()));
    await _openIntake(tester);

    expect(find.text('New repair'), findsWidgets);
    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('No serial number sticker'), findsOneWidget);
  });

  testWidgets('missing serial sticker clears and disables the serial field',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(VolaFixApp(tickets: FakeTicketsRepository()));
    await _openIntake(tester);

    final field = find.byKey(const Key('intake-serial'));
    expect(tester.widget<TextField>(field).enabled, isTrue);

    await tester.enterText(field, 'XKW1000123');
    await tester.ensureVisible(find.text('No serial number sticker'));
    await tester.tap(find.text('No serial number sticker'));
    await tester.pumpAndSettle();

    final disabled = tester.widget<TextField>(field);
    expect(disabled.enabled, isFalse);
    expect(disabled.controller!.text, isEmpty);
    expect(
      find.textContaining('Shop tag G-000000000 is issued'),
      findsOneWidget,
    );

    await tester.tap(find.text('No serial number sticker'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(field).enabled, isTrue);
    expect(
      find.textContaining('Shop tag G-000000000 is issued'),
      findsNothing,
    );
  });

  testWidgets('intake refuses to save without a customer name',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await _openIntake(tester);

    await tester.scrollUntilVisible(
      find.byKey(const Key('intake-save')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('intake-save')));
    await tester.pumpAndSettle();

    expect(find.text('Enter the customer name.'), findsOneWidget);
    expect(repository.creations, isEmpty);
  });

  testWidgets('intake requires a phone number', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await _openIntake(tester);

    await tester.enterText(
      find.byKey(const Key('intake-customer')),
      'Ana Ribeiro',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('intake-save')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('intake-save')));
    await tester.pumpAndSettle();

    expect(find.text('Enter the customer phone number.'), findsOneWidget);
    expect(repository.creations, isEmpty);
  });

  testWidgets('intake requires an email address', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await _openIntake(tester);

    await tester.enterText(
      find.byKey(const Key('intake-customer')),
      'Ana Ribeiro',
    );
    await tester.enterText(find.byKey(const Key('intake-phone')), '555 0102');
    await tester.scrollUntilVisible(
      find.byKey(const Key('intake-save')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('intake-save')));
    await tester.pumpAndSettle();

    expect(find.text('Enter the customer email address.'), findsOneWidget);
    expect(repository.creations, isEmpty);
  });

  testWidgets('intake rejects a malformed email', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await _openIntake(tester);

    await tester.enterText(
      find.byKey(const Key('intake-customer')),
      'Ana Ribeiro',
    );
    await tester.enterText(find.byKey(const Key('intake-phone')), '555 0102');
    await tester.enterText(
      find.byKey(const Key('intake-email')),
      'ana(at)example.com',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('intake-save')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('intake-save')));
    await tester.pumpAndSettle();

    expect(
        find.text('That email address does not look right.'), findsOneWidget);
    expect(repository.creations, isEmpty);
  });

  testWidgets('intake creates a ticket and opens it',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await _openIntake(tester);

    await tester.enterText(
      find.byKey(const Key('intake-customer')),
      'Ana Ribeiro',
    );
    await tester.enterText(find.byKey(const Key('intake-phone')), '555 0102');
    await tester.enterText(
      find.byKey(const Key('intake-email')),
      'ana@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('intake-serial')),
      'XKW1000123',
    );
    await tester.enterText(
      find.byKey(const Key('intake-complaint')),
      'No HDMI output',
    );
    await _selectDevice(tester);

    await tester.scrollUntilVisible(
      find.byKey(const Key('intake-save')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('intake-save')));
    await tester.pumpAndSettle();

    expect(repository.creations, hasLength(1));
    final created = repository.creations.single;
    expect(created.customerName, 'Ana Ribeiro');
    expect(created.customerPhone, '555 0102');
    expect(created.customerEmail, 'ana@example.com');
    expect(created.deviceModelId, 1);
    expect(created.serial, 'XKW1000123');
    expect(created.serialMissing, isFalse);
    expect(created.complaint, 'No HDMI output');

    // The intake route is replaced by the new ticket.
    expect(find.text('VF-000001'), findsWidgets);
    expect(find.text('No HDMI output'), findsOneWidget);
    expect(find.text('G-123456789'), findsWidgets);
  });

  testWidgets('intake records a model number below the model',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await _openIntake(tester);

    await tester.enterText(
      find.byKey(const Key('intake-customer')),
      'Ana Ribeiro',
    );
    await tester.enterText(find.byKey(const Key('intake-phone')), '555 0102');
    await tester.enterText(
      find.byKey(const Key('intake-email')),
      'ana@example.com',
    );
    await _selectDevice(tester);
    await tester.enterText(
      find.byKey(const Key('intake-device-variant')),
      'PSP-3000',
    );
    await tester.enterText(
      find.byKey(const Key('intake-serial')),
      'XKW1000123',
    );
    await tester.enterText(
      find.byKey(const Key('intake-complaint')),
      'Screen flicker',
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('intake-save')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('intake-save')));
    await tester.pumpAndSettle();

    expect(repository.creations, hasLength(1));
    expect(repository.creations.single.deviceVariant, 'PSP-3000');
    expect(find.text('MODEL NUMBER'), findsOneWidget);
    expect(find.text('PSP-3000'), findsWidgets);
  });

  testWidgets('intake saves a device with no serial sticker',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await _openIntake(tester);

    await tester.enterText(
      find.byKey(const Key('intake-customer')),
      'Ana Ribeiro',
    );
    await tester.enterText(find.byKey(const Key('intake-phone')), '555 0102');
    await tester.enterText(
      find.byKey(const Key('intake-email')),
      'ana@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('intake-complaint')),
      'Will not power on',
    );
    await tester.ensureVisible(find.text('No serial number sticker'));
    await tester.tap(find.text('No serial number sticker'));
    await tester.pumpAndSettle();
    await _selectDevice(tester);

    await tester.scrollUntilVisible(
      find.byKey(const Key('intake-save')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('intake-save')));
    await tester.pumpAndSettle();

    expect(repository.creations, hasLength(1));
    final created = repository.creations.single;
    expect(created.serial, isNull);
    expect(created.serialMissing, isTrue);
    expect(find.text('not present'), findsOneWidget);
  });

  testWidgets('intake previews the 3DS photo checklist',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(VolaFixApp(tickets: FakeTicketsRepository()));
    await _openIntake(tester);
    await _selectPortableDevice(tester, 'Nintendo 3DS');

    expect(find.text('Report 1 · 5 photos'), findsOneWidget);
    expect(find.text('Hinged handheld (3DS / DS)'), findsOneWidget);

    await tester.tap(find.text('Report 1 · 5 photos'));
    await tester.pumpAndSettle();

    for (final label in const [
      'Top screen (closed)',
      'Back (closed)',
      'Charger port',
      'Open (both screens)',
      'Serial label',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('ticket report 1 keeps the 3DS shot list',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeTicketsRepository();
    await tester.pumpWidget(VolaFixApp(tickets: repository));
    await _openIntake(tester);

    await _fillCustomer(tester);
    await _selectPortableDevice(tester, 'Nintendo 3DS');
    await tester.enterText(
      find.byKey(const Key('intake-serial')),
      'CW123456789',
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('intake-save')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('intake-save')));
    await tester.pumpAndSettle();

    expect(repository.creations, hasLength(1));
    expect(repository.creations.single.photoTemplateKey, 'hinged');

    await tester.scrollUntilVisible(
      find.text('Intake / cosmetic'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Intake / cosmetic'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Checklist + 5 photos · Hinged handheld'),
      findsOneWidget,
    );
    expect(find.text('Top screen (closed)'), findsOneWidget);
    expect(find.text('Open (both screens)'), findsOneWidget);
    expect(find.text('not captured'), findsNWidgets(5));
  });
}
