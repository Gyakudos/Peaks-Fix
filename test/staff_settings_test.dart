import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vola_fix/data/database.dart';
import 'package:vola_fix/features/settings/settings_page.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.withExecutor(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> writeSetting(String key, Object value) async {
    await database.into(database.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(key: key, value: jsonEncode(value)),
        );
  }

  Future<void> writeRawSetting(String key, String value) async {
    await database.into(database.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(key: key, value: value),
        );
  }

  Future<void> writeRoster(List<Map<String, Object?>> roster) =>
      writeSetting('staff_roster', roster);

  Future<void> pumpPage(WidgetTester tester, Widget page) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: page));
    await tester.pumpAndSettle();
  }

  /// Removes the page before the test ends so drift's stream cancellation
  /// timer is flushed instead of tripping the pending-timer check.
  Future<void> disposePage(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('editing staff saves hourly pay and keeps older roster data',
      (WidgetTester tester) async {
    await writeRoster([
      {'id': 'alex', 'name': 'Alex Tech', 'job': 'Tech 2', 'isActive': true},
    ]);
    await pumpPage(tester, SettingsPage(database: database));

    // Roster entries written before pay tracking existed still load.
    final edit = find.byKey(const Key('staff-edit-alex'));
    await tester.scrollUntilVisible(
      edit,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Pay not set'), findsOneWidget);

    await tester.ensureVisible(edit);
    await tester.pumpAndSettle();
    await tester.tap(edit);
    await tester.pumpAndSettle();
    expect(find.text('Edit staff'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('staff-name-field')),
      'Alex Senior',
    );
    await tester.enterText(
      find.byKey(const Key('staff-rate-field')),
      '22.50',
    );
    await tester.tap(find.byKey(const Key('staff-edit-save')));
    await tester.pumpAndSettle();

    expect(find.text('Alex Senior'), findsOneWidget);
    expect(find.textContaining('\$22.50/hr'), findsOneWidget);

    final row = await (database.select(database.settings)
          ..where((setting) => setting.key.equals('staff_roster')))
        .getSingle();
    final roster = jsonDecode(row.value) as List<dynamic>;
    final member = roster.single as Map<String, dynamic>;
    expect(member['id'], 'alex');
    expect(member['name'], 'Alex Senior');
    expect(member['job'], 'Tech 2');
    expect(member['isActive'], true);
    expect(member['hourlyRateCents'], 2250);

    await disposePage(tester);
  });

  testWidgets('staff hours button totals shifts and estimates pay',
      (WidgetTester tester) async {
    await writeRoster([
      {
        'id': 'alex',
        'name': 'Alex Tech',
        'job': 'Tech 2',
        'isActive': true,
        'hourlyRateCents': 2000,
      },
    ]);
    await writeSetting('staff_clock_sessions', [
      {
        'id': 'shift-1',
        'staffId': 'alex',
        'name': 'Alex Tech',
        'job': 'Tech 2',
        'clockInAt': '2026-10-19T09:00:00.000',
        'clockOutAt': '2026-10-19T11:00:00.000',
      },
      {
        'id': 'shift-2',
        'staffId': 'alex',
        'name': 'Alex Tech',
        'job': 'Tech 2',
        'clockInAt': '2026-10-20T09:00:00.000',
        'clockOutAt': '2026-10-20T10:30:00.000',
      },
      {
        'id': 'shift-3',
        'staffId': 'sam',
        'name': 'Sam Desk',
        'job': 'Front Desk',
        'clockInAt': '2026-10-20T09:00:00.000',
        'clockOutAt': '2026-10-20T17:00:00.000',
      },
    ]);
    await pumpPage(tester, SettingsPage(database: database));

    final hours = find.byKey(const Key('staff-hours-alex'));
    await tester.scrollUntilVisible(
      hours,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(hours);
    await tester.pumpAndSettle();

    expect(find.text('Alex Tech · Hours'), findsOneWidget);
    expect(find.text('3h 30m'), findsOneWidget);
    expect(find.text('\$70.00'), findsOneWidget);
    expect(find.textContaining('2h 00m'), findsOneWidget);
    expect(find.textContaining('1h 30m'), findsOneWidget);
    expect(find.textContaining('Sam Desk'), findsNothing);

    await disposePage(tester);
  });

  testWidgets('staff ticket tracker lists only that staff assignment',
      (WidgetTester tester) async {
    final alexTicket = await database.createTicket(
      customerName: 'Alex Customer',
      customerPhone: '555-0101',
      customerEmail: 'alex@example.com',
      deviceName: 'Switch OLED',
      complaint: 'USB-C port',
    );
    final samTicket = await database.createTicket(
      customerName: 'Sam Customer',
      customerPhone: '555-0102',
      customerEmail: 'sam@example.com',
      deviceName: 'Steam Deck',
      complaint: 'Stick drift',
    );
    await writeRawSetting('ticket_staff_${alexTicket.id}_intake', 'alex');
    await writeRawSetting('ticket_staff_${alexTicket.id}_technical', 'alex');
    await writeRawSetting('ticket_staff_${samTicket.id}_client', 'sam');

    await pumpPage(
      tester,
      StaffTicketsPage(
        staffId: 'alex',
        staffName: 'Alex Tech',
        database: database,
      ),
    );

    expect(find.text('Alex Tech · Tickets'), findsOneWidget);
    expect(find.textContaining(alexTicket.number), findsOneWidget);
    expect(find.textContaining(samTicket.number), findsNothing);
    expect(find.text('Assigned: Intake, Technical'), findsOneWidget);
    expect(find.text('1 open'), findsOneWidget);
    expect(find.text('1 total'), findsOneWidget);

    await disposePage(tester);
  });
}
