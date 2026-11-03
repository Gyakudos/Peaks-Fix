import 'package:flutter_test/flutter_test.dart';
import 'package:vola_fix/data/app_update.dart';

void main() {
  test('newer release is detected by date then build number', () {
    expect(isNewerVersion('0.45.01.11.26', '0.05.03.11.26'), isTrue);
    expect(isNewerVersion('0.05.03.11.26', '0.45.01.11.26'), isFalse);
    expect(isNewerVersion('0.05.03.11.26', '0.05.03.11.26'), isFalse);
    expect(isNewerVersion('0.05.03.11.26', 'v0.06.03.11.26'), isTrue);
    expect(isNewerVersion('0.05.31.12.26', '0.05.01.01.27'), isTrue);
    expect(isNewerVersion('1', '2'), isTrue);
  });
}
