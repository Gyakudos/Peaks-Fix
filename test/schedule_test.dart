import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vola_fix/data/database.dart';
import 'package:vola_fix/data/schedule.dart';

void main() {
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
