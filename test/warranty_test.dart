import 'package:flutter_test/flutter_test.dart';
import 'package:vola_fix/data/warranty.dart';

void main() {
  test('warranty defaults to 90 days and formats the length', () {
    expect(WarrantyConfig.defaultDays, 90);
    expect(WarrantyConfig.daysLabel(1), '1 day');
    expect(WarrantyConfig.daysLabel(90), '90 days');
    expect(
      WarrantyConfig.expiryFor(DateTime(2026, 1, 31), 90),
      DateTime(2026, 5, 1),
    );
  });

  test('warranty length is limited to a usable range', () {
    expect(WarrantyConfig.requireDays(1), 1);
    expect(WarrantyConfig.requireDays(WarrantyConfig.maxDays),
        WarrantyConfig.maxDays);
    expect(() => WarrantyConfig.requireDays(0), throwsArgumentError);
    expect(
      () => WarrantyConfig.requireDays(WarrantyConfig.maxDays + 1),
      throwsArgumentError,
    );
  });

  test('the report block falls back to defaults until it is recorded', () {
    const warranty = ClientReportWarranty(
      defaultDays: 120,
      defaultTerms: 'Standard terms',
      categoryName: 'Consoles',
    );

    expect(warranty.effectiveDays, 120);
    expect(warranty.effectiveTerms, 'Standard terms');
    expect(warranty.expiresAt, isNull);
    expect(warranty.isRecorded, isFalse);
    expect(warranty.defaultLabel, 'Consoles default: 120 days');
  });

  test('the report block freezes its own days and terms', () {
    final warranty = ClientReportWarranty(
      defaultDays: 120,
      defaultTerms: 'Standard terms',
      days: 30,
      terms: '  Board only.  ',
      startAt: DateTime(2026, 2, 3),
    );

    expect(warranty.effectiveDays, 30);
    expect(warranty.effectiveTerms, 'Board only.');
    expect(warranty.expiresAt, DateTime(2026, 3, 5));
    expect(warranty.isRecorded, isTrue);
    expect(warranty.defaultLabel, 'Shop default: 120 days');
  });
}
