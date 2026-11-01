import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vola_fix/data/database.dart';
import 'package:vola_fix/data/partners.dart';
import 'package:vola_fix/shell/app_access.dart';

void main() {
  test('partners save, reload sorted, and clamp the discount', () async {
    final db = AppDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    expect(await loadPartners(db), isEmpty);
    await savePartners(db, const [
      Partner(id: '2', name: 'Zed Cellular', discountPercent: 15),
      Partner(id: '1', name: 'Alpha Pawn', phone: '555'),
    ]);
    final loaded = await loadPartners(db);
    expect([for (final p in loaded) p.name], ['Alpha Pawn', 'Zed Cellular']);
    expect(loaded.last.discountPercent, 15);
    expect(
        Partner.fromJson({'id': 'x', 'discountPercent': 400}).discountPercent,
        100);
  });

  test('only admins open Partners', () {
    expect(const AppAccess.admin().canOpen('Partners'), isTrue);
    expect(const AppAccess('Front-Desk').canOpen('Partners'), isFalse);
  });
}
