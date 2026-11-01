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
      Partner(
        id: '2',
        name: 'Zed Cellular',
        partsDiscountPercent: 15,
        labourDiscountPercent: 5,
      ),
      Partner(id: '1', name: 'Alpha Pawn', phone: '555'),
    ]);
    final loaded = await loadPartners(db);
    expect([for (final p in loaded) p.name], ['Alpha Pawn', 'Zed Cellular']);
    expect(loaded.last.partsDiscountPercent, 15);
    expect(loaded.last.labourDiscountPercent, 5);
    final legacy = Partner.fromJson({'id': 'x', 'discountPercent': 400});
    expect(legacy.partsDiscountPercent, 100);
    expect(legacy.labourDiscountPercent, 100);
  });

  test('partner discount splits across parts and labour', () {
    expect(
      invoiceDiscountCentsFor(
        subtotalCents: 30000,
        partsCents: 20000,
        labourCents: 10000,
        kind: InvoiceDiscountKind.none,
        value: 0,
        partnerPartsPercent: 10,
        partnerLabourPercent: 50,
      ),
      7000,
    );
    expect(
      invoiceDiscountCentsFor(
        subtotalCents: 30000,
        partsCents: 20000,
        labourCents: 0,
        kind: InvoiceDiscountKind.none,
        value: 0,
        partnerPartsPercent: 10,
      ),
      2000,
    );
  });

  test('only admins open Partners', () {
    expect(const AppAccess.admin().canOpen('Partners'), isTrue);
    expect(const AppAccess('Front-Desk').canOpen('Partners'), isFalse);
  });
}
