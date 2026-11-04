import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vola_fix/data/database.dart';
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
