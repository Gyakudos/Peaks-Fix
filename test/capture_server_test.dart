import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vola_fix/data/capture_server.dart';

/// A real server on loopback: these tests exercise the exact routes and headers
/// the phone will hit, without needing a network.
void main() {
  late Directory temp;
  late CaptureServer server;
  late List<({int order, Uint8List bytes, String extension})> saved;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('capture_server_test');
    saved = [];
    server = await CaptureServer.start(
      address: InternetAddress.loopbackIPv4,
      ticketNumber: 'PF-000001',
      device: 'New 3DS XL',
      slots: const [
        CaptureSlot(order: 1, label: 'Front', hint: 'Screen off'),
        CaptureSlot(order: 2, label: 'Serial sticker'),
      ],
      save: (order, bytes, extension) async {
        final file = File('${temp.path}/slot-$order.$extension');
        await file.writeAsBytes(bytes);
        saved.add((order: order, bytes: bytes, extension: extension));
        return file.path;
      },
      lifetime: const Duration(minutes: 1),
    );
  });

  tearDown(() async {
    await server.close();
    await temp.delete(recursive: true);
  });

  Uri at(String path) => Uri.parse(server.url).replace(path: path);

  Future<({int status, String type, Uint8List body})> get(String path) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(at(path));
      final response = await request.close();
      final builder = BytesBuilder(copy: false);
      await response.forEach(builder.add);
      return (
        status: response.statusCode,
        type: response.headers.contentType?.mimeType ?? '',
        body: builder.takeBytes(),
      );
    } finally {
      client.close(force: true);
    }
  }

  Future<({int status, String type, Uint8List body})> post(
    String path,
    Uint8List body, {
    String type = 'image/jpeg',
  }) async {
    final client = HttpClient();
    try {
      final request = await client.postUrl(at(path));
      request.headers.contentType = ContentType.parse(type);
      request.contentLength = body.length;
      request.add(body);
      final response = await request.close();
      final builder = BytesBuilder(copy: false);
      await response.forEach(builder.add);
      return (
        status: response.statusCode,
        type: response.headers.contentType?.mimeType ?? '',
        body: builder.takeBytes(),
      );
    } finally {
      client.close(force: true);
    }
  }

  Uint8List jpeg([int extra = 16]) => Uint8List.fromList([
        0xFF,
        0xD8,
        0xFF,
        0xE0,
        ...List<int>.filled(extra, 0x11),
      ]);

  String text(Uint8List bytes) => utf8.decode(bytes);

  test('serves the mobile page for the live token only', () async {
    final page = await get('/c/${server.token}');
    expect(page.status, 200);
    expect(page.type, 'text/html');
    expect(text(page.body), contains('PF-000001'));
    expect(text(page.body), contains('New 3DS XL'));
    expect(text(page.body), contains('Serial sticker'));
    expect(text(page.body), contains(server.token));

    final wrong = await get('/c/not-the-token');
    expect(wrong.status, 404);
    expect(text(wrong.body), contains('expired'));
  });

  test('reports progress for the slot list', () async {
    final status = await get('/c/${server.token}/status');
    expect(status.status, 200);
    expect(status.type, 'application/json');
    expect(jsonDecode(text(status.body)), {
      'captured': <int>[],
      'total': 2,
      'complete': false,
    });
  });

  test('accepts a photo, then serves it back', () async {
    final upload = await post('/c/${server.token}/slot/1', jpeg());
    expect(upload.status, 200);
    expect(jsonDecode(text(upload.body)), {
      'ok': true,
      'captured': [1],
      'total': 2,
    });
    expect(saved, hasLength(1));
    expect(saved.single.order, 1);
    expect(saved.single.extension, 'jpg');

    final status = await get('/c/${server.token}/status');
    expect(jsonDecode(text(status.body))['captured'], [1]);

    final photo = await get('/c/${server.token}/photo/1');
    expect(photo.status, 200);
    expect(photo.type, 'image/jpeg');
    expect(photo.body, jpeg());

    expect((await get('/c/${server.token}/photo/2')).status, 404);
  });

  test('marks the checklist complete once every slot is captured', () async {
    await post('/c/${server.token}/slot/1', jpeg());
    await post('/c/${server.token}/slot/2', jpeg(4));

    final status = await get('/c/${server.token}/status');
    expect(jsonDecode(text(status.body)), {
      'captured': [1, 2],
      'total': 2,
      'complete': true,
    });
  });

  test('optional photo uploads do not count toward required completion',
      () async {
    final optionalServer = await CaptureServer.start(
      address: InternetAddress.loopbackIPv4,
      ticketNumber: 'PF-000002',
      device: 'Vacuum',
      slots: const [
        CaptureSlot(order: 1, label: 'Front'),
        CaptureSlot(order: 2, label: 'Damage close-up', required: false),
      ],
      save: (order, bytes, extension) async => 'optional-$order.$extension',
    );
    try {
      final client = HttpClient();
      try {
        final upload =
            await client.postUrl(Uri.parse('${optionalServer.url}/slot/2'));
        upload.headers.contentType = ContentType('image', 'jpeg');
        upload.add(jpeg());
        final response = await upload.close();
        expect(response.statusCode, 200);
        final uploadBody = await response.transform(utf8.decoder).join();
        expect(jsonDecode(uploadBody)['total'], 1);

        final statusRequest =
            await client.getUrl(Uri.parse('${optionalServer.url}/status'));
        final status = await statusRequest.close();
        final statusBody = await status.transform(utf8.decoder).join();
        expect(jsonDecode(statusBody), {
          'captured': [2],
          'total': 1,
          'complete': false,
        });
      } finally {
        client.close(force: true);
      }
    } finally {
      await optionalServer.close();
    }
  });

  test('rejects any route without the token', () async {
    expect((await get('/status')).status, 404);
    expect((await get('/c/abcd/status')).status, 404);
  });

  test('rejects unsupported photo formats', () async {
    final wrongType = await post(
      '/c/${server.token}/slot/1',
      jpeg(),
      type: 'application/octet-stream',
    );
    expect(wrongType.status, 415);
    expect(saved, isEmpty);

    // A PNG header behind a JPEG content type is still not a JPEG.
    final wrongMagic = await post(
      '/c/${server.token}/slot/1',
      Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A]),
    );
    expect(wrongMagic.status, 415);
    expect(saved, isEmpty);
  });

  test('rejects a slot that is not part of this ticket', () async {
    final response = await post('/c/${server.token}/slot/9', jpeg());
    expect(response.status, 404);
    expect(saved, isEmpty);
  });

  test('rejects photos over the size limit before reading them', () async {
    final oversized = Uint8List(12 * 1024 * 1024 + 1);
    oversized.setRange(0, 4, [0xFF, 0xD8, 0xFF, 0xE0]);
    final response = await post('/c/${server.token}/slot/1', oversized);
    expect(response.status, 413);
    expect(saved, isEmpty);
  });

  test('a closed server stops answering', () async {
    await server.close();
    await expectLater(get('/c/${server.token}/status'), throwsA(anything));
  });

  test('refuses odd methods on a valid token', () async {
    final client = HttpClient();
    try {
      final request = await client.openUrl(
        'PUT',
        at('/c/${server.token}/slot/1'),
      );
      final response = await request.close();
      expect(response.statusCode, 405);
      await response.drain<void>();
    } finally {
      client.close(force: true);
    }
  });
}
