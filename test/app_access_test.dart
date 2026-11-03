import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vola_fix/data/staff_credentials.dart';
import 'package:vola_fix/shell/app_access.dart';

StaffAccount account(String name, String job, String user, String password) {
  final salt = StaffCredentials.newSalt();
  return StaffAccount(
    id: user,
    name: name,
    job: job,
    username: user,
    passwordSalt: salt,
    passwordHash: StaffCredentials.hash(password, salt),
  );
}

Widget host(AppSession session, StaffAccountLoader? loader,
        {AdminCreator? createAdmin}) =>
    MaterialApp(
      home: LoginGate(
        session: session,
        loadAccounts: loader,
        createAdmin: createAdmin,
        child: Builder(
          builder: (context) {
            final access = AppSessionScope.accessOf(context);
            return Scaffold(
              body: Column(
                children: [
                  Text('Inside as ${access.job}'),
                  Text(access.canOpen('Settings') ? 'settings' : 'no settings'),
                  Text(access.canChangeInventory ? 'can edit' : 'view only'),
                ],
              ),
            );
          },
        ),
      ),
    );

Widget scoped(AppSession session, StaffAccountLoader? loader,
        {AdminCreator? createAdmin}) =>
    AppSessionScope(
      session: session,
      child: host(session, loader, createAdmin: createAdmin),
    );

void main() {
  test('admin opens everything, others only the front desk pages', () {
    const admin = AppAccess.admin();
    const desk = AppAccess('Front Desk');
    for (final label in [
      'Tickets',
      'Invoicing',
      'Calendar',
      'Customers',
      'Inventory',
      'Financial',
      'Staff Login',
      'Settings',
    ]) {
      expect(admin.canOpen(label), isTrue, reason: label);
    }
    expect(
      [
        for (final l in ['Tickets', 'Calendar', 'Inventory', 'Staff Login']) l
      ].every(desk.canOpen),
      isTrue,
    );
    for (final label in ['Invoicing', 'Customers', 'Financial', 'Settings']) {
      expect(desk.canOpen(label), isFalse, reason: label);
    }
    expect(admin.canChangeInventory, isTrue);
    expect(desk.canChangeInventory, isFalse);
  });

  testWidgets('no admin login leaves the app open', (tester) async {
    final session = AppSession();
    await tester.pumpWidget(scoped(session, () async => []));
    await tester.pumpAndSettle();
    expect(find.text('Inside as Admin'), findsOneWidget);

    final deskOnly = AppSession();
    await tester.pumpWidget(
      scoped(deskOnly,
          () async => [account('Dee', 'Front Desk', 'dee', 'secret1')]),
    );
    await tester.pumpAndSettle();
    expect(find.text('Inside as Admin'), findsOneWidget);
  });

  test('job levels: Admin and Tech 1 do everything, Tech 3 only Tech 3', () {
    expect(const AppAccess.admin().canDoJobLevel(1), isTrue);
    expect(const AppAccess.admin().techLevel, lessThan(1));
    expect(const AppAccess.admin().canSchedule, isTrue);
    expect(const AppAccess('Front Desk').canSchedule, isTrue);
    expect(const AppAccess('Tech 1').canSchedule, isFalse);
    expect(const AppAccess('Tech 1').canDoJobLevel(1), isTrue);
    expect(const AppAccess('Tech 2').canDoJobLevel(1), isFalse);
    expect(const AppAccess('Tech 2').canDoJobLevel(2), isTrue);
    expect(const AppAccess('Tech 3').canDoJobLevel(2), isFalse);
    expect(const AppAccess('Tech 3').canDoJobLevel(3), isTrue);
    expect(const AppAccess('Front Desk').canDoJobLevel(3), isTrue);
    expect(const AppAccess('Front Desk').canDoJobLevel(null), isTrue);
  });

  testWidgets('new shop must create an Admin before using the app',
      (tester) async {
    final session = AppSession();
    final created = <String>[];
    await tester.pumpWidget(
      scoped(
        session,
        () async => [],
        createAdmin: (name, username, password) async {
          created.add('$name/$username');
          return account(name, 'Admin', username, password);
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('setup-submit')), findsOneWidget);
    expect(find.text('Inside as Admin'), findsNothing);

    await tester.enterText(find.byKey(const Key('setup-name')), 'Ann');
    await tester.enterText(find.byKey(const Key('setup-username')), 'ann');
    await tester.enterText(find.byKey(const Key('setup-password')), 'adminpw1');
    await tester.enterText(find.byKey(const Key('setup-confirm')), 'nope');
    await tester.tap(find.byKey(const Key('setup-submit')));
    await tester.pump();
    expect(find.text('The passwords do not match.'), findsOneWidget);
    expect(created, isEmpty);

    await tester.enterText(find.byKey(const Key('setup-confirm')), 'adminpw1');
    await tester.tap(find.byKey(const Key('setup-submit')));
    await tester.pumpAndSettle();
    expect(created, ['Ann/ann']);
    expect(find.text('Inside as Admin'), findsOneWidget);
  });

  testWidgets('login screen checks the password and applies the role',
      (tester) async {
    final accounts = [
      account('Ann', 'Admin', 'ann', 'adminpw1'),
      account('Dee', 'Front Desk', 'Dee', 'secret1'),
    ];
    final session = AppSession();
    await tester.pumpWidget(scoped(session, () async => accounts));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login-submit')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('login-username')), 'dee');
    await tester.enterText(find.byKey(const Key('login-password')), 'wrong');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();
    expect(find.text('Wrong username or password.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('login-password')), 'secret1');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();
    expect(find.text('Inside as Front Desk'), findsOneWidget);
    expect(find.text('no settings'), findsOneWidget);
    expect(find.text('view only'), findsOneWidget);

    session.signOut();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login-submit')), findsOneWidget);
  });
}
