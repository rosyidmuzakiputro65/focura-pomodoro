import 'package:hive_ce/hive.dart';

/// Penyimpanan cache respons API.
abstract class QuoteCache {
  Future<Map<String, dynamic>?> read(String key);

  Future<void> write(String key, Map<String, dynamic> value);
}

class HiveQuoteCache implements QuoteCache {
  HiveQuoteCache(this._box);

  final Box<dynamic> _box;

  @override
  Future<Map<String, dynamic>?> read(String key) async {
    final raw = _box.get(key);
    if (raw == null) return null;
    return _deepCast(raw as Map);
  }

  @override
  Future<void> write(String key, Map<String, dynamic> value) =>
      _box.put(key, value);

  /// Hive mengembalikan `Map<dynamic, dynamic>`; ubah kembali ke tipe JSON.
  static Map<String, dynamic> _deepCast(Map raw) {
    return raw.map((key, value) {
      if (value is Map) return MapEntry('$key', _deepCast(value));
      if (value is List) {
        return MapEntry(
          '$key',
          value.map((item) => item is Map ? _deepCast(item) : item).toList(),
        );
      }
      return MapEntry('$key', value);
    });
  }
}

/// Cache di memori, dipakai untuk pengujian.
class InMemoryQuoteCache implements QuoteCache {
  final Map<String, Map<String, dynamic>> _store = {};

  @override
  Future<Map<String, dynamic>?> read(String key) async => _store[key];

  @override
  Future<void> write(String key, Map<String, dynamic> value) async {
    _store[key] = value;
  }
}
