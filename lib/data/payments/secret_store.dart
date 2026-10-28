import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

/// Keeps API credentials out of plain text.
abstract class SecretStore {
  /// Encrypts [value] for storage; the result is safe to keep in the database.
  String seal(String value);

  /// Reverses [seal]. Returns '' when the value can't be read.
  String open(String sealed);
}

/// Test and non-Windows fallback; does not encrypt.
class PlainSecretStore implements SecretStore {
  const PlainSecretStore();

  @override
  String seal(String value) => base64Encode(utf8.encode(value));

  @override
  String open(String sealed) {
    try {
      return utf8.decode(base64Decode(sealed));
    } catch (_) {
      return '';
    }
  }
}

SecretStore defaultSecretStore() =>
    Platform.isWindows ? DpapiSecretStore() : const PlainSecretStore();

final class _DataBlob extends Struct {
  @Uint32()
  external int cbData;
  external Pointer<Uint8> pbData;
}

typedef _CryptNative = Int32 Function(
  Pointer<_DataBlob>,
  Pointer<Utf16>,
  Pointer<Void>,
  Pointer<Void>,
  Pointer<Void>,
  Uint32,
  Pointer<_DataBlob>,
);
typedef _CryptDart = int Function(
  Pointer<_DataBlob>,
  Pointer<Utf16>,
  Pointer<Void>,
  Pointer<Void>,
  Pointer<Void>,
  int,
  Pointer<_DataBlob>,
);

/// Windows DPAPI: only the signed-in Windows user can decrypt the value.
class DpapiSecretStore implements SecretStore {
  DpapiSecretStore() {
    final crypt = DynamicLibrary.open('crypt32.dll');
    _protect = crypt.lookupFunction<_CryptNative, _CryptDart>(
      'CryptProtectData',
    );
    _unprotect = crypt.lookupFunction<_CryptNative, _CryptDart>(
      'CryptUnprotectData',
    );
    _localFree = DynamicLibrary.open('kernel32.dll').lookupFunction<
        Pointer<Void> Function(Pointer<Void>),
        Pointer<Void> Function(Pointer<Void>)>('LocalFree');
  }

  late final _CryptDart _protect;
  late final _CryptDart _unprotect;
  late final Pointer<Void> Function(Pointer<Void>) _localFree;

  @override
  String seal(String value) {
    if (value.isEmpty) return '';
    return base64Encode(_run(_protect, utf8.encode(value)));
  }

  @override
  String open(String sealed) {
    if (sealed.isEmpty) return '';
    try {
      return utf8.decode(_run(_unprotect, base64Decode(sealed)));
    } catch (_) {
      return '';
    }
  }

  List<int> _run(_CryptDart fn, List<int> input) {
    final inBlob = calloc<_DataBlob>();
    final outBlob = calloc<_DataBlob>();
    final data = calloc<Uint8>(input.length);
    try {
      data.asTypedList(input.length).setAll(0, input);
      inBlob.ref
        ..cbData = input.length
        ..pbData = data;
      final ok = fn(inBlob, nullptr, nullptr, nullptr, nullptr, 0, outBlob);
      if (ok == 0) throw StateError('Windows could not process the secret.');
      final bytes = List<int>.from(
        outBlob.ref.pbData.asTypedList(outBlob.ref.cbData),
      );
      _localFree(outBlob.ref.pbData.cast());
      return bytes;
    } finally {
      calloc.free(data);
      calloc.free(inBlob);
      calloc.free(outBlob);
    }
  }
}
