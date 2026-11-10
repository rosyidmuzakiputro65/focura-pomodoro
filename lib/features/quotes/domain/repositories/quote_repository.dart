import '../entities/quote.dart';

abstract class QuoteRepository {
  /// Mengambil kutipan dengan pagination (`skip` = offset, `limit` = jumlah).
  Future<QuotePage> fetchQuotes({required int skip, required int limit});
}
