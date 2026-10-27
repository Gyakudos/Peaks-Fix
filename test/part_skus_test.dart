import 'package:flutter_test/flutter_test.dart';
import 'package:vola_fix/data/part_skus.dart';

void main() {
  test('parses and formats the 000-000 shop SKU format', () {
    expect(PartSku.parse('001-001'), 1001);
    expect(PartSku.parse(' 123-456 '), 123456);
    expect(PartSku.parse('001-01'), isNull);
    expect(PartSku.parse('ABC-123'), isNull);
    expect(PartSku.parse(null), isNull);

    expect(PartSku.format(1001), '001-001');
    expect(PartSku.format(0), '000-000');
    expect(PartSku.format(123456), '123-456');

    expect(PartSku.isValid('000-000'), isTrue);
    expect(PartSku.isValid('1-1'), isFalse);
  });

  test('generates the next SKU after the highest formatted value', () {
    expect(PartSku.next(const []), '001-001');
    expect(PartSku.next(const ['001-001', '001-002']), '001-003');
    expect(PartSku.next(const ['001-999']), '002-000');
    expect(PartSku.next(const ['001-003', '001-001']), '001-004');
  });

  test('ignores hand-written SKUs when choosing the next sequence', () {
    expect(PartSku.next(const ['USB-C-01', '001-002', 'PORT-9']), '001-003');
    expect(PartSku.next(const ['USB-C-01']), '001-001');
  });
}
