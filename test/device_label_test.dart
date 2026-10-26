import 'package:flutter_test/flutter_test.dart';

import 'package:vola_fix/data/tickets_repository.dart';

void main() {
  test('joins brand and model', () {
    expect(deviceLabel('Sony', 'PlayStation 5'), 'Sony PlayStation 5');
    expect(deviceLabel('8BitDo', 'Pro 2'), '8BitDo Pro 2');
    expect(deviceLabel('Microsoft', 'Xbox Elite Series 2'),
        'Microsoft Xbox Elite Series 2');
  });

  test('does not repeat a brand already in the model name', () {
    expect(deviceLabel('Nintendo', 'Nintendo 64'), 'Nintendo 64');
    expect(
      deviceLabel('Nintendo', 'Nintendo Entertainment System (NES)'),
      'Nintendo Entertainment System (NES)',
    );
    expect(deviceLabel('3DO', '3DO Interactive Multiplayer'),
        '3DO Interactive Multiplayer');
    expect(deviceLabel('Coleco', 'ColecoVision'), 'ColecoVision');
  });

  test('is case-insensitive and trims padding', () {
    expect(deviceLabel('nintendo', 'NINTENDO 64'), 'NINTENDO 64');
    expect(deviceLabel(' Sony ', ' PlayStation 4 '), 'Sony PlayStation 4');
    expect(deviceLabel('', 'Mystery console'), 'Mystery console');
  });
}
