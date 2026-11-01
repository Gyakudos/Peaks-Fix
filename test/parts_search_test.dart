import 'package:flutter_test/flutter_test.dart';
import 'package:vola_fix/data/tickets_repository.dart';
import 'package:vola_fix/features/inventory/parts_tab.dart';

void main() {
  const part = InventoryPart(
    id: 7,
    name: 'USB-C charging port',
    stock: 3,
    sku: '001-042',
    brand: 'Anker',
    category: 'Ports',
    location: 'Shelf B',
  );

  test('matches by ID, brand and generic terms', () {
    expect(partMatchesSearch(part, ''), isTrue);
    expect(partMatchesSearch(part, '001-042'), isTrue);
    expect(partMatchesSearch(part, 'anker'), isTrue);
    expect(partMatchesSearch(part, 'usb charging'), isTrue);
    expect(partMatchesSearch(part, 'shelf'), isTrue);
    expect(partMatchesSearch(part, 'anker battery'), isFalse);
  });
}
