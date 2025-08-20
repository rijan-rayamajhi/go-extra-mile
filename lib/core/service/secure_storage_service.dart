import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service to securely store key-value data using flutter_secure_storage.
class SecureStorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Write a secure value with the given [key].
  Future<void> write({required String key, required String value}) async {
    await _secureStorage.write(key: key, value: value);
  }

  /// Read a secure value for the given [key].
  Future<String?> read({required String key}) async {
    return await _secureStorage.read(key: key);
  }

  /// Delete the value associated with the given [key].
  Future<void> delete({required String key}) async {
    await _secureStorage.delete(key: key);
  }

  /// Delete all keys and values.
  Future<void> deleteAll() async {
    await _secureStorage.deleteAll();
  }

  /// Check if a key exists in storage.
  Future<bool> containsKey({required String key}) async {
    final allKeys = await _secureStorage.readAll();
    return allKeys.containsKey(key);
  }
}
