import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/errors/app_exception.dart';

/// Memanggil External Public API: https://dummyjson.com/quotes
class QuoteRemoteDataSource {
  QuoteRemoteDataSource({
    required this._client,
    this.baseUrl = 'https://dummyjson.com',
    this.timeout = const Duration(seconds: 10),
  });

  final http.Client _client;
  final String baseUrl;
  final Duration timeout;

  Future<Map<String, dynamic>> fetchQuotes({
    required int skip,
    required int limit,
  }) async {
    final uri = Uri.parse('$baseUrl/quotes').replace(
      queryParameters: {'limit': '$limit', 'skip': '$skip'},
    );
    try {
      final response = await _client.get(uri).timeout(timeout);
      if (response.statusCode != 200) {
        throw const NetworkException(AppError.networkServer);
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['quotes'] is! List) {
        throw const NetworkException(AppError.networkBadData);
      }
      return decoded;
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
}
