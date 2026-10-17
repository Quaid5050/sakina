import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Small local settings store. Reads are synchronous (values are cached in
/// memory at start-up); writes are persisted asynchronously.
///
/// This holds device-local preferences only (language, onboarding state,
/// prayer settings). It is never synced (ADR-0013).
abstract interface class KeyValueStore {
  String? getString(String key);
  bool? getBool(String key);
  int? getInt(String key);
  double? getDouble(String key);
  Future<void> setString(String key, String value);
  Future<void> setBool(String key, {required bool value});
  Future<void> setInt(String key, int value);
  Future<void> setDouble(String key, double value);
  Future<void> remove(String key);
}

/// Overridden in `bootstrap()` with [SharedPreferencesStore] and in tests
/// with [InMemoryKeyValueStore].
final Provider<KeyValueStore> keyValueStoreProvider = Provider<KeyValueStore>(
  (ref) => throw UnimplementedError('keyValueStoreProvider must be overridden'),
);

class SharedPreferencesStore implements KeyValueStore {
  SharedPreferencesStore(this._prefs);

  final SharedPreferences _prefs;

  static Future<SharedPreferencesStore> create() async =>
      SharedPreferencesStore(await SharedPreferences.getInstance());

  @override
  String? getString(String key) => _prefs.getString(key);
  @override
  bool? getBool(String key) => _prefs.getBool(key);
  @override
  int? getInt(String key) => _prefs.getInt(key);
  @override
  double? getDouble(String key) => _prefs.getDouble(key);
  @override
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }
  @override
  Future<void> setBool(String key, {required bool value}) async {
    await _prefs.setBool(key, value);
  }
  @override
  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }
  @override
  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }
  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
}

/// In-memory store for tests and previews.
class InMemoryKeyValueStore implements KeyValueStore {
  InMemoryKeyValueStore([Map<String, Object>? initial])
    : _values = <String, Object>{...?initial};

  final Map<String, Object> _values;

  Map<String, Object> get snapshot => Map<String, Object>.unmodifiable(_values);

  T? _get<T>(String key) {
    final value = _values[key];
    return value is T ? value : null;
  }

  @override
  String? getString(String key) => _get<String>(key);
  @override
  bool? getBool(String key) => _get<bool>(key);
  @override
  int? getInt(String key) => _get<int>(key);
  @override
  double? getDouble(String key) => _get<double>(key);
  @override
  Future<void> setString(String key, String value) async {
    _values[key] = value;
  }
  @override
  Future<void> setBool(String key, {required bool value}) async {
    _values[key] = value;
  }
  @override
  Future<void> setInt(String key, int value) async {
    _values[key] = value;
  }
  @override
  Future<void> setDouble(String key, double value) async {
    _values[key] = value;
  }
  @override
  Future<void> remove(String key) async {
    _values.remove(key);
  }
}
