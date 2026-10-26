import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

/// One Report 1 slot offered to the phone.
class CaptureSlot {
  const CaptureSlot({
    required this.order,
    required this.label,
    this.hint,
    this.required = true,
    this.captured = false,
    this.photoPath,
  });

  final int order;
  final String label;
  final String? hint;
  final bool required;
  final bool captured;
  final String? photoPath;
}

/// Saves one uploaded photo and returns the file path that now backs the slot.
typedef CaptureSaver = Future<String> Function(
  int order,
  Uint8List bytes,
  String extension,
);

/// A short-lived HTTP server that lets a phone on the same network send photos
/// into one open ticket.
///
/// The URL contains a random one-time token. The server only listens while the
/// QR dialog is open, exposes nothing outside `/c/<token>/…`, and accepts only
/// image uploads for slots that belong to this ticket.
class CaptureServer {
  CaptureServer._(
    this._http, {
    required this.ticketNumber,
    required this.device,
    required List<CaptureSlot> slots,
    required CaptureSaver save,
  })  : _slots = List.unmodifiable(slots),
        _save = save,
        token = _newToken() {
    for (final slot in slots) {
      if (slot.photoPath != null) _paths[slot.order] = slot.photoPath!;
      if (slot.captured) _captured.add(slot.order);
    }
  }

  static const int _maxPhotoBytes = 12 * 1024 * 1024;

  final HttpServer _http;
  final List<CaptureSlot> _slots;
  final CaptureSaver _save;
  final String token;
  final String ticketNumber;
  final String device;

  final Map<int, String> _paths = {};
  final Set<int> _captured = {};
  Timer? _expiry;
  bool _closed = false;

  /// The link to encode in the QR. Uses the address the server is bound to.
  String get url => 'http://${_http.address.address}:${_http.port}/c/$token';

  int get port => _http.port;

  int get _requiredTotal => _slots.where((slot) => slot.required).length;

  int get _capturedRequired => _slots
      .where((slot) => slot.required && _captured.contains(slot.order))
      .length;

  static Future<CaptureServer> start({
    required InternetAddress address,
    required String ticketNumber,
    required String device,
    required List<CaptureSlot> slots,
    required CaptureSaver save,
    Duration lifetime = const Duration(minutes: 30),
  }) async {
    final http = await HttpServer.bind(address, 0, shared: false);
    final server = CaptureServer._(
      http,
      ticketNumber: ticketNumber,
      device: device,
      slots: slots,
      save: save,
    );
    http.listen(server._handle);
    server._expiry = Timer(lifetime, server.close);
    return server;
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    _expiry?.cancel();
    await _http.close(force: true);
  }

  Future<void> _handle(HttpRequest request) async {
    try {
      final segments = request.uri.pathSegments;
      if (segments.length < 2 || segments[0] != 'c' || segments[1] != token) {
        return await _notFound(request);
      }

      if (request.method == 'GET' && segments.length == 2) {
        return await _servePage(request);
      }
      if (request.method == 'GET' &&
          segments.length == 3 &&
          segments[2] == 'status') {
        return await _serveStatus(request);
      }
      if (request.method == 'GET' &&
          segments.length == 4 &&
          segments[2] == 'photo') {
        return await _servePhoto(request, int.tryParse(segments[3]));
      }
      if (request.method == 'POST' &&
          segments.length == 4 &&
          segments[2] == 'slot') {
        return await _receivePhoto(request, int.tryParse(segments[3]));
      }

      request.response.statusCode = HttpStatus.methodNotAllowed;
      await _writeText(request, HttpStatus.methodNotAllowed, 'Not here.');
    } catch (error) {
      stderr.writeln('Phone capture failed: $error');
      try {
        await _writeText(
          request,
          HttpStatus.internalServerError,
          'Could not save that photo. Try again.',
        );
      } catch (_) {
        // The phone may have gone away mid-request; nothing left to tell it.
      }
    }
  }

  Future<void> _servePage(HttpRequest request) async {
    final html = _buildPage();
    request.response.headers.contentType = ContentType.html;
    _noStore(request);
    request.response.headers.set(
      'Content-Security-Policy',
      "default-src 'none'; img-src 'self' blob: data:; "
          "style-src 'unsafe-inline'; script-src 'unsafe-inline'; "
          "connect-src 'self'; base-uri 'none'; form-action 'none'",
    );
    request.response.write(html);
    await request.response.close();
  }

  Future<void> _serveStatus(HttpRequest request) async {
    final captured = _captured.toList()..sort();
    await _writeText(
      request,
      HttpStatus.ok,
      jsonEncode({
        'captured': captured,
        'total': _requiredTotal,
        'complete': _capturedRequired >= _requiredTotal,
      }),
      type: ContentType.json,
    );
  }

  Future<void> _servePhoto(HttpRequest request, int? order) async {
    final path = order == null ? null : _paths[order];
    if (path == null) return _notFound(request);

    final file = File(path);
    if (!await file.exists()) {
      _paths.remove(order);
      return _notFound(request);
    }

    request.response.headers.contentType = _contentTypeFor(path);
    _noStore(request);
    request.response.contentLength = await file.length();
    await request.response.addStream(file.openRead());
    await request.response.close();
  }

  Future<void> _receivePhoto(HttpRequest request, int? order) async {
    final slot = order == null
        ? null
        : _slots.where((entry) => entry.order == order).firstOrNull;
    if (slot == null) {
      return _writeText(
        request,
        HttpStatus.notFound,
        'That shot is not part of this ticket.',
      );
    }

    final extension = _extensionFor(request.headers.contentType);
    if (extension == null) {
      return _writeText(
        request,
        HttpStatus.unsupportedMediaType,
        'That photo format is not supported. Retake it from the camera.',
      );
    }

    final declared = request.contentLength;
    if (declared > _maxPhotoBytes) {
      return _writeText(
        request,
        HttpStatus.requestEntityTooLarge,
        'That photo is too large. Retake it at a lower resolution.',
      );
    }

    final builder = BytesBuilder(copy: false);
    await for (final chunk in request) {
      if (builder.length + chunk.length > _maxPhotoBytes) {
        return _writeText(
          request,
          HttpStatus.requestEntityTooLarge,
          'That photo is too large. Retake it at a lower resolution.',
        );
      }
      builder.add(chunk);
    }

    final bytes = builder.takeBytes();
    if (bytes.isEmpty || !_looksLikeImage(bytes, extension)) {
      return _writeText(
        request,
        HttpStatus.unsupportedMediaType,
        'That file is not a readable photo. Try again.',
      );
    }

    final path = await _save(order!, bytes, extension);
    _paths[order] = path;
    _captured.add(order);

    final captured = _captured.toList()..sort();
    await _writeText(
      request,
      HttpStatus.ok,
      jsonEncode({
        'ok': true,
        'captured': captured,
        'total': _requiredTotal,
      }),
      type: ContentType.json,
    );
  }

  Future<void> _notFound(HttpRequest request) => _writeText(
        request,
        HttpStatus.notFound,
        'This capture link has expired. Ask for a new QR code on the PC.',
      );

  Future<void> _writeText(
    HttpRequest request,
    int status,
    String body, {
    ContentType? type,
  }) async {
    request.response.statusCode = status;
    request.response.headers.contentType = type ?? ContentType.text;
    _noStore(request);
    request.response.write(body);
    await request.response.close();
  }

  void _noStore(HttpRequest request) {
    request.response.headers.set('Cache-Control', 'no-store');
    request.response.headers.set('X-Content-Type-Options', 'nosniff');
    request.response.headers.set('Referrer-Policy', 'no-referrer');
  }

  static String _newToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(24, (_) => random.nextInt(256));
    return [for (final byte in bytes) byte.toRadixString(16).padLeft(2, '0')]
        .join();
  }

  static String? _extensionFor(ContentType? type) {
    switch (type?.mimeType.toLowerCase()) {
      case 'image/jpeg':
      case 'image/jpg':
        return 'jpg';
      case 'image/png':
        return 'png';
      case 'image/webp':
        return 'webp';
      default:
        return null;
    }
  }

  static bool _looksLikeImage(Uint8List bytes, String extension) {
    switch (extension) {
      case 'jpg':
        return bytes.length > 3 &&
            bytes[0] == 0xFF &&
            bytes[1] == 0xD8 &&
            bytes[2] == 0xFF;
      case 'png':
        return bytes.length > 8 &&
            bytes[0] == 0x89 &&
            bytes[1] == 0x50 &&
            bytes[2] == 0x4E &&
            bytes[3] == 0x47;
      case 'webp':
        return bytes.length > 12 &&
            bytes[0] == 0x52 &&
            bytes[1] == 0x49 &&
            bytes[2] == 0x46 &&
            bytes[3] == 0x46 &&
            bytes[8] == 0x57 &&
            bytes[9] == 0x45 &&
            bytes[10] == 0x42 &&
            bytes[11] == 0x50;
      default:
        return false;
    }
  }

  static ContentType _contentTypeFor(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return ContentType('image', 'png');
    if (lower.endsWith('.webp')) return ContentType('image', 'webp');
    return ContentType('image', 'jpeg');
  }

  String _buildPage() {
    final slotJson = _jsonForScript([
      for (final slot in _slots)
        {
          'order': slot.order,
          'label': slot.label,
          'hint': slot.hint ?? '',
          'required': slot.required,
          'captured': _captured.contains(slot.order),
        },
    ]);
    return _fill(_pageTemplate, {
      '__TOKEN__': token,
      '__SLOTS__': slotJson,
      '__TOTAL__': '$_requiredTotal',
      '__TICKET__': const HtmlEscape().convert(ticketNumber),
      '__DEVICE__': const HtmlEscape().convert(device),
      '__TITLE__': const HtmlEscape().convert('Capture · $ticketNumber'),
    });
  }

  /// Single-pass fill so a device or slot name that happens to contain a
  /// placeholder can never be expanded again.
  static String _fill(String template, Map<String, String> values) {
    return template.replaceAllMapped(
      RegExp('__[A-Z]+__'),
      (match) => values[match[0]!] ?? match[0]!,
    );
  }

  static String _jsonForScript(Object value) {
    return jsonEncode(value)
        .replaceAll('<', r'\u003c')
        .replaceAll('>', r'\u003e')
        .replaceAll('&', r'\u0026')
        .replaceAll('\u2028', r'\u2028')
        .replaceAll('\u2029', r'\u2029');
  }
}

/// The best private IPv4 address to put in the QR, or null when the PC has no
/// usable LAN connection.
///
/// Virtual adapters (Hyper-V, WSL, Docker, VPNs) are skipped: a QR pointing at
/// one of those opens fine on the PC and never loads on the phone.
Future<InternetAddress?> findLanAddress() async {
  const virtualNames = [
    'vethernet',
    'virtualbox',
    'vmware',
    'hyper-v',
    'wsl',
    'docker',
    'loopback',
    'npcap',
    'tap-',
    'tun',
    'vpn',
    'tailscale',
    'zerotier',
    'bluetooth',
  ];

  final candidates = <(int, InternetAddress)>[];
  try {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLinkLocal: false,
    );
    for (final interface in interfaces) {
      final name = interface.name.toLowerCase();
      if (virtualNames.any(name.contains)) continue;
      for (final address in interface.addresses) {
        final ip = address.address;
        if (ip.startsWith('127.') || ip.startsWith('169.254.')) continue;

        var score = _isPrivate(ip) ? 10 : 0;
        if (name.contains('wi-fi') ||
            name.contains('wifi') ||
            name.contains('wlan')) {
          score += 4;
        }
        if (name.contains('ethernet') || name.contains('eth')) {
          score += 3;
        }
        candidates.add((score, address));
      }
    }
  } on SocketException {
    return null;
  }

  if (candidates.isEmpty) return null;
  candidates.sort((a, b) => b.$1.compareTo(a.$1));
  return candidates.first.$2;
}

bool _isPrivate(String ip) {
  final parts = ip.split('.').map(int.tryParse).toList();
  if (parts.length != 4 || parts.any((part) => part == null)) return false;
  final a = parts[0]!;
  final b = parts[1]!;
  return a == 10 || (a == 192 && b == 168) || (a == 172 && b >= 16 && b <= 31);
}

const _pageTemplate = r'''<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta name="theme-color" content="#3f51b5">
<meta name="robots" content="noindex, nofollow">
<title>__TITLE__</title>
<style>
  :root {
    color-scheme: light dark;
    --bg: #f3f4fa;
    --card: #ffffff;
    --ink: #1b1d2a;
    --muted: #5e6377;
    --line: #dfe2ee;
    --brand: #3f51b5;
    --brand-ink: #ffffff;
    --ok: #1c7c4c;
    --danger: #b3261e;
  }
  @media (prefers-color-scheme: dark) {
    :root {
      --bg: #12131a;
      --card: #1c1e28;
      --ink: #f1f2f8;
      --muted: #a6aabc;
      --line: #303344;
      --brand: #8f9cff;
      --brand-ink: #10122a;
      --ok: #67d39a;
      --danger: #ffb4ab;
    }
  }
  * { box-sizing: border-box; -webkit-tap-highlight-color: transparent; }
  body {
    margin: 0;
    font-family: system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;
    background: var(--bg);
    color: var(--ink);
    min-height: 100vh;
  }
  header {
    position: sticky;
    top: 0;
    z-index: 2;
    padding: 18px 18px 14px;
    background: var(--brand);
    color: var(--brand-ink);
  }
  .brand {
    font-size: 12px;
    letter-spacing: 1.4px;
    text-transform: uppercase;
    opacity: .82;
    font-weight: 700;
  }
  h1 { margin: 4px 0 2px; font-size: 26px; letter-spacing: .4px; }
  .device { font-size: 14px; opacity: .9; }
  .track {
    margin-top: 14px;
    height: 6px;
    border-radius: 999px;
    background: color-mix(in srgb, var(--brand-ink) 26%, transparent);
    overflow: hidden;
  }
  #bar {
    height: 100%;
    width: 0%;
    border-radius: 999px;
    background: var(--brand-ink);
    transition: width .3s ease;
  }
  #count { margin-top: 7px; font-size: 13px; font-weight: 600; opacity: .92; }
  main {
    width: 100%;
    max-width: 620px;
    margin: 0 auto;
    padding: 16px 16px 8px;
    display: grid;
    gap: 12px;
  }
  .slot {
    background: var(--card);
    border: 1px solid var(--line);
    border-radius: 16px;
    padding: 14px;
    box-shadow: 0 6px 18px rgba(20, 24, 60, .05);
  }
  .slot.done { border-color: var(--ok); }
  .head { display: flex; gap: 12px; align-items: flex-start; }
  .num {
    flex: 0 0 30px;
    width: 30px;
    height: 30px;
    border-radius: 50%;
    display: grid;
    place-items: center;
    background: color-mix(in srgb, var(--brand) 14%, transparent);
    color: var(--brand);
    font-weight: 700;
    font-size: 14px;
  }
  .slot.done .num {
    background: color-mix(in srgb, var(--ok) 15%, transparent);
    color: var(--ok);
  }
  .copy { min-width: 0; flex: 1; }
  .copy h2 { margin: 1px 0 3px; font-size: 16px; line-height: 1.25; }
  .copy p { margin: 0; color: var(--muted); font-size: 13px; line-height: 1.4; }
  .state {
    margin-left: auto;
    font-size: 11px;
    font-weight: 700;
    letter-spacing: .6px;
    text-transform: uppercase;
    color: var(--muted);
    white-space: nowrap;
    padding-top: 6px;
  }
  .slot.done .state { color: var(--ok); }
  .thumb { margin-top: 10px; }
  .thumb img {
    display: block;
    width: 100%;
    max-height: 240px;
    object-fit: cover;
    border-radius: 12px;
    background: var(--line);
  }
  .action { display: block; margin-top: 12px; }
  .action input { display: none; }
  .action span {
    display: block;
    padding: 13px 16px;
    border-radius: 12px;
    text-align: center;
    font-size: 15px;
    font-weight: 700;
    background: var(--brand);
    color: var(--brand-ink);
  }
  .slot.done .action span {
    background: transparent;
    color: var(--brand);
    border: 1px solid var(--brand);
  }
  .busy { opacity: .62; pointer-events: none; }
  .error { margin-top: 9px; font-size: 13px; line-height: 1.4; color: var(--danger); }
  footer {
    max-width: 620px;
    margin: 2px auto 30px;
    padding: 0 20px;
    color: var(--muted);
    font-size: 12px;
    line-height: 1.55;
  }
  .all-done {
    background: color-mix(in srgb, var(--ok) 13%, transparent);
    border: 1px solid var(--ok);
    color: var(--ok);
    border-radius: 14px;
    padding: 14px 16px;
    font-size: 14px;
    font-weight: 650;
    text-align: center;
  }
</style>
</head>
<body>
<header>
  <div class="brand">Peaks Fix · phone capture</div>
  <h1>__TICKET__</h1>
  <div class="device">__DEVICE__</div>
  <div class="track"><div id="bar"></div></div>
  <div id="count">0 of __TOTAL__ captured</div>
</header>
<main id="slots"></main>
<footer>
  Photos are sent straight to the shop PC over your local network. Nothing is
  uploaded to the internet. Keep this page open until each shot says
  <strong>Saved</strong>.
</footer>
<script>
  const TOKEN = "__TOKEN__";
  const SLOTS = __SLOTS__;
  const TOTAL = SLOTS.filter(slot => slot.required).length;
  const slotsEl = document.getElementById('slots');
  const countEl = document.getElementById('count');
  const barEl = document.getElementById('bar');
  const byOrder = new Map(SLOTS.map(slot => [slot.order, slot]));

  function capturedCount() {
    return SLOTS.filter(slot => slot.required && slot.captured).length;
  }

  function updateProgress() {
    const captured = capturedCount();
    barEl.style.width = TOTAL ? (100 * captured / TOTAL) + '%' : '0%';
    countEl.textContent = captured >= TOTAL && TOTAL > 0
      ? 'All shots captured · you can close this page'
      : captured + ' of ' + TOTAL + ' captured';
  }

  function renderSlot(slot) {
    const card = document.createElement('section');
    card.className = 'slot' + (slot.captured ? ' done' : '');
    card.dataset.order = slot.order;

    const head = document.createElement('div');
    head.className = 'head';

    const num = document.createElement('span');
    num.className = 'num';
    num.textContent = slot.order;

    const copy = document.createElement('div');
    copy.className = 'copy';
    const heading = document.createElement('h2');
    heading.textContent = slot.label;
    copy.appendChild(heading);
    if (slot.hint) {
      const hint = document.createElement('p');
      hint.textContent = slot.hint;
      copy.appendChild(hint);
    }

    const state = document.createElement('span');
    state.className = 'state';
    state.textContent = slot.captured ? 'Saved' : (slot.required ? 'Needed' : 'Optional');

    head.append(num, copy, state);

    const thumb = document.createElement('div');
    thumb.className = 'thumb';
    if (slot.captured) {
      const image = document.createElement('img');
      image.alt = slot.label;
      image.src = '/c/' + TOKEN + '/photo/' + slot.order + '?v=' + Date.now();
      thumb.appendChild(image);
    }

    const action = document.createElement('label');
    action.className = 'action';
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = 'image/*';
    input.setAttribute('capture', 'environment');
    const button = document.createElement('span');
    button.textContent = slot.captured ? 'Retake photo' : 'Take photo';
    action.append(input, button);

    const error = document.createElement('div');
    error.className = 'error';

    input.addEventListener('change', () => {
      const file = input.files && input.files[0];
      if (file) upload(slot, file, card, state, thumb, button, error);
      input.value = '';
    });

    card.append(head, thumb, action, error);
    return card;
  }

  function render() {
    slotsEl.innerHTML = '';
    SLOTS.forEach(slot => slotsEl.appendChild(renderSlot(slot)));
    updateProgress();
  }

  async function prepare(file) {
    const MAX_EDGE = 2000;
    try {
      let source;
      if ('createImageBitmap' in window) {
        source = await createImageBitmap(file, { imageOrientation: 'from-image' });
      } else {
        source = await new Promise((resolve, reject) => {
          const image = new Image();
          image.onload = () => resolve(image);
          image.onerror = reject;
          image.src = URL.createObjectURL(file);
        });
      }
      const width = source.width;
      const height = source.height;
      if (!width || !height) throw new Error('No image size');
      const scale = Math.min(1, MAX_EDGE / Math.max(width, height));
      const canvas = document.createElement('canvas');
      canvas.width = Math.max(1, Math.round(width * scale));
      canvas.height = Math.max(1, Math.round(height * scale));
      canvas.getContext('2d').drawImage(source, 0, 0, canvas.width, canvas.height);
      if (source.close) source.close();
      const blob = await new Promise(resolve =>
        canvas.toBlob(resolve, 'image/jpeg', 0.86));
      if (!blob) throw new Error('Could not encode');
      return blob;
    } catch (_) {
      // Let the server accept or reject the original rather than uploading a
      // half-converted file.
      return file;
    }
  }

  async function upload(slot, file, card, state, thumb, button, error) {
    card.classList.add('busy');
    state.textContent = 'Uploading…';
    error.textContent = '';
    try {
      const blob = await prepare(file);
      const response = await fetch('/c/' + TOKEN + '/slot/' + slot.order, {
        method: 'POST',
        headers: {
          'Content-Type': blob.type || file.type || 'application/octet-stream'
        },
        body: blob
      });
      if (!response.ok) {
        const message = await response.text();
        throw new Error(message || ('Upload failed (' + response.status + ')'));
      }
      slot.captured = true;
      card.classList.add('done');
      state.textContent = 'Saved';
      button.textContent = 'Retake photo';
      let image = thumb.querySelector('img');
      if (!image) {
        image = document.createElement('img');
        image.alt = slot.label;
        thumb.appendChild(image);
      }
      image.src = '/c/' + TOKEN + '/photo/' + slot.order + '?v=' + Date.now();
      updateProgress();
    } catch (failure) {
      state.textContent = slot.captured ? 'Saved' : 'Needed';
      error.textContent = (failure && failure.message)
        ? failure.message
        : 'Upload failed. Try again.';
    } finally {
      card.classList.remove('busy');
    }
  }

  async function sync() {
    try {
      const response = await fetch('/c/' + TOKEN + '/status', { cache: 'no-store' });
      if (!response.ok) return;
      const data = await response.json();
      data.captured.forEach(order => {
        const slot = byOrder.get(order);
        if (slot) slot.captured = true;
      });
      updateProgress();
    } catch (_) {
      // Offline for a moment; the next upload or focus event retries.
    }
  }

  render();
  setInterval(sync, 4000);
  document.addEventListener('visibilitychange', () => {
    if (!document.hidden) sync();
  });
</script>
</body>
</html>''';
