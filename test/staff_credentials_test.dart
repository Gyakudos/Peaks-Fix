import 'package:flutter_test/flutter_test.dart';
import 'package:vola_fix/data/staff_credentials.dart';

void main() {
  test('password hashes verify only the right password', () {
    final salt = StaffCredentials.newSalt();
    final hash = StaffCredentials.hash('secret1', salt);

    expect(StaffCredentials.verify('secret1', salt, hash), isTrue);
    expect(StaffCredentials.verify('secret2', salt, hash), isFalse);
    expect(hash, isNot(contains('secret1')));
    expect(
      StaffCredentials.hash('secret1', StaffCredentials.newSalt()),
      isNot(hash),
    );
  });
}
