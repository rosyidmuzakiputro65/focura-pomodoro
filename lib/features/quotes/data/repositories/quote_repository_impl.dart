import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/quote.dart';
import '../../domain/repositories/quote_repository.dart';
import '../datasources/quote_cache.dart';
import '../datasources/quote_remote_data_source.dart';

/// Strategi network-first: ambil dari API lalu simpan ke cache.
/// Jika offline, tampilkan data dari cache.
class QuoteRepositoryImpl implements QuoteRepository {
  QuoteRepositoryImpl({required this._remote, required this._cache});

  final QuoteRemoteDataSource _remote;
  final QuoteCache _cache;

  static String _key(int skip, int limit) => 'page_${skip}_$limit';

  @override
  Future<QuotePage> fetchQuotes({required int skip, required int limit}) async {
    try {
      final json = await _remote.fetchQuotes(skip: skip, limit: limit);
      await _cache.write(_key(skip, limit), {
        ...json,
        'cachedAt': DateTime.now().toIso8601String(),
      });
      return _parse(json, skip: skip, fromCache: false);
    } on NetworkException {
      final cached = await _cache.read(_key(skip, limit));
      if (cached == null) rethrow;
      return _parse(cached, skip: skip, fromCache: true);
    }
  }

  static QuotePage _parse(
    Map<String, dynamic> json, {
    required int skip,
    required bool fromCache,
  }) {
    final rawList = (json['quotes'] as List?) ?? const [];
    final quotes = rawList
        .whereType<Map>()
        .map(
          (item) => Quote(
            id: (item['id'] as num?)?.toInt() ?? 0,
            text: (item['quote'] as String?) ?? '',
            author: (item['author'] as String?) ?? 'Anonim',
          ),
        )
        .where((quote) => quote.text.isNotEmpty)
        .toList();
    return QuotePage(
      quotes: quotes,
      total: (json['total'] as num?)?.toInt() ?? quotes.length,
      skip: skip,
      fromCache: fromCache,
    );
  }
}
