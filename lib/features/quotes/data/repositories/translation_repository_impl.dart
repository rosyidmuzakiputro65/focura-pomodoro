import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:hive_ce/hive.dart';

import '../../domain/repositories/translation_repository.dart';
import '../datasources/translation_remote_data_source.dart';

/// Cache-first: terjemahan yang sudah pernah diambil disimpan di Hive,
/// sehingga tidak memanggil API lagi (hemat kuota & bisa dibaca offline).
class TranslationRepositoryImpl implements TranslationRepository {
  TranslationRepositoryImpl({required this._remote, required this._cache});

  final TranslationRemoteDataSource _remote;
  final Box<dynamic> _cache;

  static String _key(String text, String from, String to) =>
      '$from|$to:${sha1.convert(utf8.encode(text))}';

  @override
  Future<String> translate(
    String text, {
    String from = 'en',
    required String to,
  }) async {
    if (from == to) return text;
    final key = _key(text, from, to);
    final cached = _cache.get(key) as String?;
    if (cached != null) return cached;
    final translated = await _remote.translate(text, from: from, to: to);
    await _cache.put(key, translated);
    return translated;
  }
}
