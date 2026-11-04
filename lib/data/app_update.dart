import 'dart:convert';
import 'dart:io';

/// Shown bottom-right of the main window; matches the GitHub release tag.
const String appBuildVersion = '0.06.03.11.26';

const _releasesApi =
    'https://api.github.com/repos/Gyakudos/Peaks-Fix/releases/latest';

/// A release published on GitHub.
class AppRelease {
  const AppRelease({
    required this.version,
    required this.url,
    this.notes = '',
    this.publishedAt,
  });

  final String version;
  final String url;
  final String notes;
  final DateTime? publishedAt;
}

/// Versions look like `0.05.03.11.26`: two build numbers, then day, month and
/// two-digit year. The date decides which is newer, then the build numbers.
bool isNewerVersion(String current, String latest) {
  List<int>? parse(String v) {
    final parts = v
        .trim()
        .replaceFirst(RegExp(r'^[vV]'), '')
        .split('.')
        .map(int.tryParse)
        .toList();
    if (parts.length != 5 || parts.any((p) => p == null)) return null;
    return parts.cast<int>();
  }

  final a = parse(current);
  final b = parse(latest);
  if (a == null || b == null) {
    return latest.trim().isNotEmpty && latest.trim() != current.trim();
  }
  int date(List<int> p) => (p[4] * 10000) + (p[3] * 100) + p[2];
  final byDate = date(b).compareTo(date(a));
  if (byDate != 0) return byDate > 0;
  final byMajor = b[0].compareTo(a[0]);
  if (byMajor != 0) return byMajor > 0;
  return b[1] > a[1];
}

/// Asks GitHub for the newest release.
Future<AppRelease> fetchLatestRelease({HttpClient? client}) async {
  final http = client ?? HttpClient();
  try {
    http.connectionTimeout = const Duration(seconds: 10);
    final request = await http.getUrl(Uri.parse(_releasesApi));
    request.headers
      ..set('Accept', 'application/vnd.github+json')
      ..set('User-Agent', 'PeaksFix');
    final response = await request.close().timeout(
          const Duration(seconds: 15),
        );
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode != 200) {
      throw HttpException('GitHub answered ${response.statusCode}');
    }
    final json = jsonDecode(body) as Map<String, dynamic>;
    return AppRelease(
      version: (json['tag_name'] as String).replaceFirst(RegExp(r'^[vV]'), ''),
      url: json['html_url'] as String,
      notes: json['body'] as String? ?? '',
      publishedAt: DateTime.tryParse(json['published_at'] as String? ?? ''),
    );
  } finally {
    http.close(force: true);
  }
}

/// Opens [url] in the default browser.
Future<void> openInBrowser(String url) async {
  if (Platform.isWindows) {
    await Process.run('rundll32', ['url.dll,FileProtocolHandler', url]);
  }
}
