import 'package:shared_preferences/shared_preferences.dart';

/// A service to handle local key-value storage using SharedPreferences.
/// Wraps all SharedPreferences operations to keep code centralized and testable.
class LocalStorageService {
  SharedPreferences? _preferences;

  /// Initialize SharedPreferences instance. Must be called before usage.
  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  /// Save a String value with the given [key].
  Future<bool> saveString(String key, String value) async {
    if (_preferences == null) await init();
    return await _preferences!.setString(key, value);
  }

  /// Read a String value for the given [key]. Returns null if not found.
  String? getString(String key) {
    return _preferences?.getString(key);
  }

  /// Save a bool value with the given [key].
  Future<bool> saveBool(String key, bool value) async {
    if (_preferences == null) await init();
    return await _preferences!.setBool(key, value);
  }

  /// Read a bool value for the given [key]. Returns null if not found.
  bool? getBool(String key) {
    return _preferences?.getBool(key);
  }

  /// Save an int value with the given [key].
  Future<bool> saveInt(String key, int value) async {
    if (_preferences == null) await init();
    return await _preferences!.setInt(key, value);
  }

  /// Read an int value for the given [key]. Returns null if not found.
  int? getInt(String key) {
    return _preferences?.getInt(key);
  }

  /// Save a double value with the given [key].
  Future<bool> saveDouble(String key, double value) async {
    if (_preferences == null) await init();
    return await _preferences!.setDouble(key, value);
  }

  /// Read a double value for the given [key]. Returns null if not found.
  double? getDouble(String key) {
    return _preferences?.getDouble(key);
  }

  /// Save a list of strings with the given [key].
  Future<bool> saveStringList(String key, List<String> value) async {
    if (_preferences == null) await init();
    return await _preferences!.setStringList(key, value);
  }

  /// Read a list of strings for the given [key]. Returns null if not found.
  List<String>? getStringList(String key) {
    return _preferences?.getStringList(key);
  }

  /// Remove a value for the given [key].
  Future<bool> remove(String key) async {
    if (_preferences == null) await init();
    return await _preferences!.remove(key);
  }

  /// Clear all stored values (use carefully).
  Future<bool> clear() async {
    if (_preferences == null) await init();
    return await _preferences!.clear();
  }
}
