// Checks that the Material icon font in a release build contains a glyph for
// every `Icons.*` used in `lib/`.
//
// Flutter tree-shakes the Material icon font at build time, keeping only the
// glyphs the Dart code asks for. Windows incremental builds can reuse a stale
// font asset, which makes newly added tab or page icons render as nothing at
// all — invisible in widget tests, since the `Icon` widget is still there.
//
// Run it after a Windows release build:
//
//   dart run tool/check_icon_font.dart
//
// Pass a different font path as the first argument if needed. Exits 1 and
// lists the offending icons when the font is out of date.
import 'dart:io';
import 'dart:typed_data';

const _defaultFont =
    'build/windows/x64/runner/Release/data/flutter_assets/fonts/'
    'MaterialIcons-Regular.otf';

void main(List<String> args) {
  final fontPath = args.isNotEmpty ? args.first : _defaultFont;
  final font = File(fontPath);
  if (!font.existsSync()) {
    stderr.writeln('Icon font not found: $fontPath');
    stderr.writeln('Build the Windows release first.');
    exit(1);
  }

  final iconsSource = _iconsSource();
  if (iconsSource == null) {
    stderr.writeln(
      'Could not find the Flutter SDK icon list. Set FLUTTER_ROOT or run '
      'this with the `dart` from your Flutter SDK.',
    );
    exit(1);
  }

  final codePoints = _iconCodePoints(iconsSource);
  final used = _usedIcons();
  final glyphs = _fontCodePoints(font.readAsBytesSync());

  final missing = <String, List<String>>{};
  final unknown = <String>{};
  for (final entry in used.entries) {
    final codePoint = codePoints[entry.key];
    if (codePoint == null) {
      unknown.add(entry.key);
      continue;
    }
    if (!glyphs.contains(codePoint)) {
      missing[entry.key] = entry.value;
    }
  }

  stdout.writeln(
    '${used.length} icons used, ${glyphs.length} glyphs in '
    '${font.path.split(Platform.pathSeparator).last}.',
  );
  if (unknown.isNotEmpty) {
    stdout.writeln(
      'Skipped ${unknown.length} icon(s) not found in the SDK icon list: '
      '${unknown.join(', ')}',
    );
  }
  if (missing.isEmpty) {
    stdout.writeln('Every used icon has a glyph.');
    return;
  }

  stderr.writeln('');
  stderr.writeln('${missing.length} icon(s) have no glyph in this font:');
  final names = missing.keys.toList()..sort();
  for (final name in names) {
    final files = missing[name]!..sort();
    stderr.writeln('  Icons.$name — ${files.join(', ')}');
  }
  stderr.writeln('');
  stderr.writeln(
    'The build reused a stale icon font. Rebuild with a clean build or '
    '`flutter build windows --release --no-tree-shake-icons`.',
  );
  exit(1);
}

/// Reads `Icons.*` names from every Dart file under `lib/`.
Map<String, List<String>> _usedIcons() {
  final used = <String, List<String>>{};
  final pattern = RegExp(r'Icons\.([a-zA-Z0-9_]+)');
  final lib = Directory('lib');
  if (!lib.existsSync()) {
    stderr.writeln('No lib/ directory here; run from the project root.');
    exit(1);
  }
  for (final entity in lib.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final relative = entity.path.replaceAll(r'\', '/');
    final text = entity.readAsStringSync();
    for (final match in pattern.allMatches(text)) {
      final name = match.group(1)!;
      used.putIfAbsent(name, () => <String>[]).add(relative);
    }
  }
  return used;
}

/// Maps `Icons.foo` to its code point using the SDK's `icons.dart`.
String? _iconsSource() {
  for (final entry in const ['FLUTTER_ROOT', 'FLUTTER_HOME']) {
    final root = Platform.environment[entry];
    if (root == null) continue;
    final file = File('$root/packages/flutter/lib/src/material/icons.dart');
    if (file.existsSync()) return file.readAsStringSync();
  }
  final root = _flutterRoot();
  if (root == null) return null;
  return File('$root/packages/flutter/lib/src/material/icons.dart')
      .readAsStringSync();
}

/// Finds the Flutter SDK by walking up from the running `dart` executable,
/// which lives at `<root>/bin/cache/dart-sdk/bin/dart(.exe)`.
String? _flutterRoot() {
  var dir = Directory(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 8; i++) {
    final marker =
        File('${dir.path}/packages/flutter/lib/src/material/icons.dart');
    if (marker.existsSync()) return dir.path;
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  return null;
}

Map<String, int> _iconCodePoints(String source) {
  final pattern = RegExp(
    r'static const IconData (\w+) = IconData\(\s*(0x[0-9a-fA-F]+)',
  );
  return {
    for (final match in pattern.allMatches(source))
      match.group(1)!: int.parse(match.group(2)!.substring(2), radix: 16),
  };
}

/// Code points present in an OpenType/TrueType font's `cmap` table.
Set<int> _fontCodePoints(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  final numTables = data.getUint16(4);
  var cmap = -1;
  for (var i = 0; i < numTables; i++) {
    final record = 12 + i * 16;
    final tag = String.fromCharCodes(bytes.sublist(record, record + 4));
    if (tag == 'cmap') {
      cmap = data.getUint32(record + 8);
      break;
    }
  }
  if (cmap < 0) {
    throw const FormatException('Font has no cmap table.');
  }

  final codePoints = <int>{};
  final subtables = data.getUint16(cmap + 2);
  for (var i = 0; i < subtables; i++) {
    final record = cmap + 4 + i * 8;
    final offset = cmap + data.getUint32(record + 4);
    final format = data.getUint16(offset);
    if (format == 4) {
      final segments = data.getUint16(offset + 6) ~/ 2;
      final ends = offset + 14;
      final starts = ends + segments * 2 + 2;
      for (var segment = 0; segment < segments; segment++) {
        final start = data.getUint16(starts + segment * 2);
        final end = data.getUint16(ends + segment * 2);
        if (start == 0xFFFF) continue;
        for (var codePoint = start; codePoint <= end; codePoint++) {
          codePoints.add(codePoint);
        }
      }
    } else if (format == 12) {
      final groups = data.getUint32(offset + 12);
      for (var group = 0; group < groups; group++) {
        final record = offset + 16 + group * 12;
        final start = data.getUint32(record);
        final end = data.getUint32(record + 4);
        for (var codePoint = start; codePoint <= end; codePoint++) {
          codePoints.add(codePoint);
        }
      }
    }
  }
  return codePoints;
}
