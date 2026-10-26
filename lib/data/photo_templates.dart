/// Report 1 photo checklists, one per device family.
///
/// The list is seeded into the database and copied onto each ticket at intake,
/// so editing a template later never rewrites a job that is already open.
///
/// Every template ends with the serial / shop-tag shot: the five-photo rule is
/// still five photos, just the first four change with the hardware.
library;

/// One numbered shot in a checklist.
class PhotoSlotSeed {
  const PhotoSlotSeed(this.label, this.hint);

  final String label;
  final String hint;
}

/// A checklist family, e.g. `hinged` for 3DS/DS clamshells.
class PhotoTemplateSeed {
  const PhotoTemplateSeed({
    required this.key,
    required this.name,
    required this.slots,
  });

  final String key;
  final String name;
  final List<PhotoSlotSeed> slots;
}

/// Models with a hinge: the lid closed is its own shot, and the open shot
/// shows both screens.
const Set<String> hingedModels = <String>{
  '3DS',
  '3DS XL',
  'New 3DS',
  'New 3DS XL',
  '2DS XL',
  'DS',
  'DS Lite',
  'DSi',
  'Game Boy Advance SP',
};

const List<PhotoTemplateSeed> photoTemplateSeeds = <PhotoTemplateSeed>[
  PhotoTemplateSeed(
    key: 'hinged',
    name: 'Hinged handheld (3DS / DS)',
    slots: [
      PhotoSlotSeed(
        'Top screen (closed)',
        'Lid shut, whole top surface straight on',
      ),
      PhotoSlotSeed(
        'Back (closed)',
        'Bottom shell, hinge pointing away',
      ),
      PhotoSlotSeed(
        'Charger port',
        'Charging port straight on, cable out',
      ),
      PhotoSlotSeed(
        'Open (both screens)',
        'Lid open far enough that both screens are readable',
      ),
      PhotoSlotSeed(
        'Serial label',
        'Original sticker, or the shop tag when there is no readable one',
      ),
    ],
  ),
  PhotoTemplateSeed(
    key: 'slab',
    name: 'Slab handheld (PSP / Game Boy)',
    slots: [
      PhotoSlotSeed('Front', 'Screen on or off, straight on'),
      PhotoSlotSeed('Back', 'Battery door, UMD door or cartridge slot'),
      PhotoSlotSeed('Top edge', 'Shoulder buttons and top ports'),
      PhotoSlotSeed('Bottom edge', 'Charger port and headphone jack'),
      PhotoSlotSeed(
        'Serial label',
        'Original sticker, or the shop tag when there is no readable one',
      ),
    ],
  ),
  PhotoTemplateSeed(
    key: 'console',
    name: 'Home console',
    slots: [
      PhotoSlotSeed('Front', 'Face of the unit, ports visible'),
      PhotoSlotSeed('Back', 'Rear ports and vents'),
      PhotoSlotSeed('Left side', 'Left edge, straight on'),
      PhotoSlotSeed('Right side', 'Right edge, straight on'),
      PhotoSlotSeed(
        'Serial label',
        'Original sticker, or the shop tag when there is no readable one',
      ),
    ],
  ),
  PhotoTemplateSeed(
    key: 'pc',
    name: 'Handheld PC',
    slots: [
      PhotoSlotSeed('Front', 'Screen and sticks, straight on'),
      PhotoSlotSeed('Back', 'Back shell and vents'),
      PhotoSlotSeed('Left edge', 'Left grips, ports and triggers'),
      PhotoSlotSeed('Right edge', 'Right grips, ports and triggers'),
      PhotoSlotSeed(
        'Serial label',
        'Original sticker, or the shop tag when there is no readable one',
      ),
    ],
  ),
  PhotoTemplateSeed(
    key: 'controller',
    name: 'Controller',
    slots: [
      PhotoSlotSeed('Front', 'Face buttons and sticks'),
      PhotoSlotSeed('Back', 'Back shell and grip seams'),
      PhotoSlotSeed('Top edge', 'Triggers, bumpers and USB port'),
      PhotoSlotSeed('Battery bay', 'Battery cover off, contacts visible'),
      PhotoSlotSeed(
        'Serial label',
        'Original sticker, or the shop tag when there is no readable one',
      ),
    ],
  ),
];

/// Which checklist a model gets. Category decides by default; clamshell models
/// are the exception, because the lid is its own photo.
String photoTemplateKeyFor(String category, String modelName) {
  return switch (category) {
    'Controllers' => 'controller',
    'Handheld PCs' => 'pc',
    'Portable Consoles' => hingedModels.contains(modelName) ? 'hinged' : 'slab',
    _ => 'console',
  };
}

/// Lookup used when a ticket only stored the key.
PhotoTemplateSeed? photoTemplateSeed(String? key) {
  for (final template in photoTemplateSeeds) {
    if (template.key == key) return template;
  }
  return null;
}
