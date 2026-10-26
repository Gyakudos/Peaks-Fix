import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Where photo files live, outside the database.
///
/// The SQLite file stays small and portable; only the path to each capture is
/// stored on the ticket. Files live with the app's support data, next to the
/// database, so nothing lands in Documents or syncs to OneDrive.
class PhotoStore {
  PhotoStore._();

  static Future<Directory> _root() async {
    final support = await getApplicationSupportDirectory();
    final dir = Directory(p.join(support.path, 'photos'));
    await dir.create(recursive: true);
    return dir;
  }

  static Future<Directory> ticketDirectory(int ticketId) async {
    final dir = Directory(p.join((await _root()).path, 'ticket_$ticketId'));
    await dir.create(recursive: true);
    return dir;
  }

  static Future<void> deleteTicketPhotos(int ticketId) async {
    final dir = Directory(p.join((await _root()).path, 'ticket_$ticketId'));
    if (await dir.exists()) await dir.delete(recursive: true);
  }

  /// Writes a capture for one Report 1 slot and returns its path.
  ///
  /// Every capture gets a new file name, so Flutter's image cache cannot serve
  /// the previous shot after a retake. Older files for the slot are removed
  /// once the new one is safely on disk.
  static Future<String> saveTicketSlot({
    required int ticketId,
    required int sortOrder,
    required Uint8List bytes,
    required String extension,
  }) async {
    if (bytes.isEmpty) {
      throw ArgumentError.value(bytes, 'bytes', 'empty capture');
    }
    final dir = await ticketDirectory(ticketId);
    // Microseconds plus noise makes a collision practically impossible, even
    // with two rapid retakes, while keeping the slot number visible in the
    // name for cleanup and support.
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final noise = Random().nextInt(0x10000).toRadixString(16).padLeft(4, '0');
    final file = File(
      p.join(dir.path, 'slot-${sortOrder}_${stamp}_$noise.$extension'),
    );
    final temp = File('${file.path}.part');
    await temp.writeAsBytes(bytes, flush: true);
    await temp.rename(file.path);

    await _removeOlderCaptures(dir, sortOrder, keep: file);
    return file.path;
  }

  static Future<String> saveReportPhoto({
    required int ticketId,
    required Uint8List bytes,
    required String extension,
  }) async {
    if (bytes.isEmpty) {
      throw ArgumentError.value(bytes, 'bytes', 'empty capture');
    }
    final normalizedExtension = extension.toLowerCase();
    if (!const {'jpg', 'jpeg', 'png', 'webp'}.contains(normalizedExtension)) {
      throw ArgumentError.value(extension, 'extension', 'unsupported image');
    }
    final dir = await ticketDirectory(ticketId);
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final noise = Random().nextInt(0x10000).toRadixString(16).padLeft(4, '0');
    final file = File(
      p.join(dir.path, 'report_${stamp}_$noise.$normalizedExtension'),
    );
    final temp = File('${file.path}.part');
    await temp.writeAsBytes(bytes, flush: true);
    await temp.rename(file.path);
    return file.path;
  }

  static Future<void> _removeOlderCaptures(
    Directory dir,
    int sortOrder, {
    required File keep,
  }) async {
    final pattern =
        RegExp('^slot-${sortOrder}_\\d+(_[a-z0-9]+)?\\.[a-z0-9]+\$');
    await for (final entity in dir.list()) {
      if (entity is! File || entity.path == keep.path) continue;
      if (!pattern.hasMatch(p.basename(entity.path))) continue;
      try {
        await entity.delete();
      } on FileSystemException {
        // A viewer may still hold the old image; the new file is already safe.
      }
    }
  }
}
