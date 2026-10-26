import 'package:flutter_test/flutter_test.dart';
import 'package:vola_fix/data/photo_templates.dart';

void main() {
  test('every photo template ends with the serial label', () {
    expect(photoTemplateSeeds, isNotEmpty);
    for (final template in photoTemplateSeeds) {
      expect(template.slots, hasLength(5), reason: template.key);
      expect(template.slots.last.label, 'Serial label', reason: template.key);
    }
  });

  test('the 3DS family gets the hinged checklist', () {
    final template = photoTemplateSeed('hinged');
    expect(template, isNotNull);
    expect(
      template!.slots.map((slot) => slot.label),
      [
        'Top screen (closed)',
        'Back (closed)',
        'Charger port',
        'Open (both screens)',
        'Serial label',
      ],
    );
  });

  test('slab handhelds get the four edge shots', () {
    final template = photoTemplateSeed('slab');
    expect(template, isNotNull);
    expect(
      template!.slots.map((slot) => slot.label),
      ['Front', 'Back', 'Top edge', 'Bottom edge', 'Serial label'],
    );
  });

  test('categories map to their device family', () {
    expect(photoTemplateKeyFor('Portable Consoles', '3DS'), 'hinged');
    expect(photoTemplateKeyFor('Portable Consoles', 'New 3DS XL'), 'hinged');
    expect(photoTemplateKeyFor('Portable Consoles', 'PSP'), 'slab');
    expect(photoTemplateKeyFor('Portable Consoles', 'Game Boy'), 'slab');
    expect(photoTemplateKeyFor('Consoles', 'PlayStation 5'), 'console');
    expect(photoTemplateKeyFor('Retro consoles', 'Dreamcast'), 'console');
    expect(photoTemplateKeyFor('Handheld PCs', 'Steam Deck OLED'), 'pc');
    expect(
        photoTemplateKeyFor('Controllers', 'DualSense 5 (PS5)'), 'controller');
  });

  test('a future category falls back to the console checklist', () {
    expect(photoTemplateKeyFor('Arcade', 'Candy Cab'), 'console');
  });
}
