import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:drift/drift.dart';
// ignore: experimental_member_use
import 'package:drift/remote.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'database.dart';

/// How this copy of the app gets its data.
enum NetworkMode {
  /// This PC keeps its own database.
  standalone,

  /// This PC keeps the database and shares it on the shop network.
  host,

  /// This PC uses the database of a host PC.
  client,
}

const int defaultHostPort = 8765;
const String _keyHeader = 'x-shop-key';
const String _schemaHeader = 'x-shop-schema';

/// Cloud settings, kept in a small file beside the app's data rather than in
/// the database, because a client PC has no local database to put them in.
class NetworkSettings {
  const NetworkSettings({
    this.mode = NetworkMode.standalone,
    this.port = defaultHostPort,
    this.key = '',
    this.hostAddress = '',
  });

  final NetworkMode mode;

  /// Port the host listens on.
  final int port;

  /// Shared secret. Hosts accept only clients that present it.
  final String key;

  /// `address` or `address:port` of the host, used in client mode.
  final String hostAddress;

  NetworkSettings copyWith({
    NetworkMode? mode,
    int? port,
    String? key,
    String? hostAddress,
  }) =>
      NetworkSettings(
        mode: mode ?? this.mode,
        port: port ?? this.port,
        key: key ?? this.key,
        hostAddress: hostAddress ?? this.hostAddress,
      );

  Map<String, Object?> toJson() => {
        'mode': mode.name,
        'port': port,
        'key': key,
        'hostAddress': hostAddress,
      };

  static NetworkSettings fromJson(Map<String, Object?> json) => NetworkSettings(
        mode: NetworkMode.values.firstWhere(
          (mode) => mode.name == json['mode'],
          orElse: () => NetworkMode.standalone,
        ),
        port: json['port'] is int ? json['port'] as int : defaultHostPort,
        key: json['key'] as String? ?? '',
        hostAddress: json['hostAddress'] as String? ?? '',
      );

  /// A new random shop key.
  static String generateKey() {
    const alphabet = 'abcdefghjkmnpqrstuvwxyz23456789';
    final random = Random.secure();
    return List.generate(
      16,
      (_) => alphabet[random.nextInt(alphabet.length)],
    ).join();
  }

  static Future<File> _file() async {
    final directory = await getApplicationSupportDirectory();
    return File(p.join(directory.path, 'cloud_settings.json'));
  }

  static Future<NetworkSettings> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return const NetworkSettings();
      final decoded = jsonDecode(await file.readAsString());
      return decoded is Map<String, Object?>
          ? fromJson(decoded)
          : const NetworkSettings();
    } catch (_) {
      return const NetworkSettings();
    }
  }

  Future<void> save() async {
    final file = await _file();
    await file.writeAsString(jsonEncode(toJson()));
  }
}

/// Drift moves only primitives, lists and byte arrays; WebSocket text frames
/// carry JSON, so bytes are tagged and restored on the way through.
Object? _encode(Object? value) {
  if (value is Uint8List) return {'\$b': base64Encode(value)};
  if (value is List) return [for (final item in value) _encode(item)];
  return value;
}

Object? _decode(Object? value) {
  if (value is Map && value.containsKey('\$b')) {
    return base64Decode(value['\$b'] as String);
  }
  if (value is List) return [for (final item in value) _decode(item)];
  return value;
}

StreamChannel<Object?> _driftChannel(StreamChannel<dynamic> socket) {
  final controller = StreamChannelController<Object?>(sync: true);
  socket.stream.listen(
    (message) =>
        controller.local.sink.add(_decode(jsonDecode(message as String))),
    onError: controller.local.sink.addError,
    onDone: controller.local.sink.close,
  );
  controller.local.stream.listen(
    (message) => socket.sink.add(jsonEncode(_encode(message))),
    onDone: socket.sink.close,
  );
  return controller.foreign;
}

bool _sameSecret(String a, String b) {
  if (a.length != b.length) return false;
  var difference = 0;
  for (var i = 0; i < a.length; i++) {
    difference |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return difference == 0;
}

/// Shares a database with other PCs on the network.
class ShopHost {
  ShopHost._(this._http);

  final HttpServer _http;
  int _clients = 0;

  int get port => _http.port;

  /// How many other PCs are connected right now.
  int get clientCount => _clients;

  /// Serves [server] on [port]. Clients must send [key] and the same schema
  /// version as this build.
  static Future<ShopHost> start({
    required DriftServer server,
    required int port,
    required String key,
    required int schemaVersion,
  }) async {
    final http = await HttpServer.bind(InternetAddress.anyIPv4, port);
    final host = ShopHost._(http);
    http.listen((request) async {
      final presented = request.headers.value(_keyHeader) ?? '';
      final schema = request.headers.value(_schemaHeader) ?? '';
      if (!WebSocketTransformer.isUpgradeRequest(request) ||
          key.isEmpty ||
          !_sameSecret(presented, key)) {
        request.response.statusCode = HttpStatus.unauthorized;
        await request.response.close();
        return;
      }
      if (schema != '$schemaVersion') {
        request.response.statusCode = HttpStatus.conflict;
        await request.response.close();
        return;
      }
      final socket = await WebSocketTransformer.upgrade(request);
      socket.pingInterval = const Duration(seconds: 20);
      host._clients++;
      final channel = _driftChannel(IOWebSocketChannel(socket));
      unawaited(server.serve(channel).whenComplete(() => host._clients--));
    });
    return host;
  }

  Future<void> stop() => _http.close(force: true);
}

class HostConnectionException implements Exception {
  const HostConnectionException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Runs the local database through an in-process drift server, so this PC and
/// the clients it serves share one transaction queue and update stream.
Future<({AppDatabase database, DriftServer server})> openHostDatabase() async {
  final server = DriftServer(AppDatabase.openLocalExecutor());
  final controller = StreamChannelController<Object?>(sync: true);
  unawaited(server.serve(controller.local, serialize: false));
  final connection = await connectToRemoteAndInitialize(
    controller.foreign,
    serialize: false,
  );
  return (database: AppDatabase.withExecutor(connection), server: server);
}

/// Connects to a host PC. Throws [HostConnectionException] with a message the
/// shop can act on.
Future<AppDatabase> connectToHost(NetworkSettings settings) async {
  final address = settings.hostAddress.trim();
  if (address.isEmpty) {
    throw const HostConnectionException('Enter the host address first.');
  }
  final withPort =
      address.contains(':') ? address : '$address:${settings.port}';
  final socket = IOWebSocketChannel.connect(
    Uri.parse('ws://$withPort/vola'),
    headers: {
      _keyHeader: settings.key,
      _schemaHeader: '${AppDatabase.currentSchemaVersion}',
    },
    pingInterval: const Duration(seconds: 20),
    connectTimeout: const Duration(seconds: 8),
  );
  try {
    await socket.ready;
  } on WebSocketChannelException catch (error) {
    final text = '${error.inner ?? error.message}';
    if (text.contains('401')) {
      throw const HostConnectionException('The shop key was not accepted.');
    }
    if (text.contains('409')) {
      throw const HostConnectionException(
        'The host runs a different version of the app. Update both PCs to '
        'the same version.',
      );
    }
    throw HostConnectionException(
      'Could not reach $withPort. Check the address, that the host app is '
      'running, and that its firewall allows the app.',
    );
  }
  final connection = await connectToRemoteAndInitialize(_driftChannel(socket));
  return AppDatabase.withExecutor(connection);
}

/// IPv4 addresses of this PC, shown so the address can be typed elsewhere.
Future<List<String>> localAddresses() async {
  final interfaces = await NetworkInterface.list(
    type: InternetAddressType.IPv4,
  );
  return [
    for (final interface in interfaces)
      for (final address in interface.addresses)
        if (!address.isLoopback) address.address,
  ];
}
