import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Salted PBKDF2-HMAC-SHA256 password hashing for staff logins.
///
/// Only the salt and hash are stored; the password itself is never kept.
class StaffCredentials {
  const StaffCredentials._();

  static const int minPasswordLength = 6;
  static const int _iterations = 20000;

  static String newSalt() {
    final random = Random.secure();
    return base64Encode([for (var i = 0; i < 16; i++) random.nextInt(256)]);
  }

  static String hash(String password, String salt) {
    final hmac = Hmac(sha256, utf8.encode(password));
    final saltBytes = base64Decode(salt);
    var block = hmac.convert([...saltBytes, 0, 0, 0, 1]).bytes;
    final result = List<int>.from(block);
    for (var i = 1; i < _iterations; i++) {
      block = hmac.convert(block).bytes;
      for (var j = 0; j < result.length; j++) {
        result[j] ^= block[j];
      }
    }
    return base64Encode(result);
  }

  static bool verify(String password, String salt, String expectedHash) {
    final actual = hash(password, salt);
    if (actual.length != expectedHash.length) return false;
    var diff = 0;
    for (var i = 0; i < actual.length; i++) {
      diff |= actual.codeUnitAt(i) ^ expectedHash.codeUnitAt(i);
    }
    return diff == 0;
  }
}
