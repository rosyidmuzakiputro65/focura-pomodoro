import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/errors/app_exception.dart';

/// External Public API kedua: MyMemory Translation
/// https://api.mymemory.translated.net/get?q=...&langpair=en|id
/// Gratis tanpa API key (ada batas harian), hasil disimpan di cache.
class TranslationRemoteDataSource {
  TranslationRemoteDataSource({
    required this._client,
    this.baseUrl = 'https://api.mymemory.translated.net',
    this.timeout = const Duration(seconds: 12),
  });

  final http.Client _client;
  final String baseUrl;
  final Duration timeout;

  Future<String> translate(String text, {required String from, required String to}) async {
    final uri = Uri.parse('$baseUrl/get').replace(
      queryParameters: {'q': text, 'langpair': '$from|$to'},
    );
    try {
      final response = await _client.get(uri).timeout(timeout);
      if (response.statusCode != 200) {
        throw const NetworkException(AppError.networkServer);
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const NetworkException(AppError.networkBadData);
      }
      final status = int.tryParse('${decoded['responseStatus']}') ?? 0;
      final data = decoded['responseData'];
      final translated = data is Map ? data['translatedText'] as String? : null;
      if (status != 200 ||
          translated == null ||
          translated.trim().isEmpty ||
          translated.toUpperCase().contains('MYMEMORY WARNING')) {
        throw const NetworkException(AppError.translationUnavailable);
      }
      return _decodeEntities(translated.trim());
    } on NetworkException {
      rethrow;
    } on TimeoutException {
      throw const NetworkException(AppError.networkTimeout);
    } on FormatException {
      throw const NetworkException(AppError.networkBadData);
    } catch (_) {
      throw const NetworkException(AppError.networkOffline);
    }
  }

  static String _decodeEntities(String value) => value
      .replaceAll('&#39;', "'")
      .replaceAll('&quot;', '"')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&amp;', '&');
}
