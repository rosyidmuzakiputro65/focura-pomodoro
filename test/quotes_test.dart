import 'dart:convert';

import 'package:flutter_application_1/core/errors/app_exception.dart';
import 'package:flutter_application_1/features/quotes/data/datasources/quote_cache.dart';
import 'package:flutter_application_1/features/quotes/data/datasources/quote_remote_data_source.dart';
import 'package:flutter_application_1/features/quotes/data/repositories/quote_repository_impl.dart';
import 'package:flutter_application_1/features/quotes/presentation/cubit/quote_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'helpers/fakes.dart';

void main() {
  group('QuoteRepositoryImpl', () {
    final body = jsonEncode({
      'quotes': [
        {'id': 1, 'quote': 'Fokus adalah kunci', 'author': 'Rod'},
      ],
      'total': 100,
      'skip': 0,
      'limit': 1,
    });

    test('memanggil API dengan limit & skip lalu menyimpan cache', () async {
      Uri? requested;
      final cache = InMemoryQuoteCache();
      final repo = QuoteRepositoryImpl(
        remote: QuoteRemoteDataSource(
          client: MockClient((request) async {
            requested = request.url;
            return http.Response(body, 200);
          }),
        ),
        cache: cache,
      );

      final page = await repo.fetchQuotes(skip: 0, limit: 1);
      expect(requested?.queryParameters, {'limit': '1', 'skip': '0'});
      expect(page.quotes.single.author, 'Rod');
      expect(page.hasMore, isTrue);
      expect(page.fromCache, isFalse);
      expect(await cache.read('page_0_1'), isNotNull);
    });

    test('offline -> memakai cache', () async {
      final cache = InMemoryQuoteCache();
      await cache.write('page_0_1', jsonDecode(body) as Map<String, dynamic>);
      final repo = QuoteRepositoryImpl(
        remote: QuoteRemoteDataSource(
          client: MockClient((_) async => throw http.ClientException('offline')),
        ),
        cache: cache,
      );
      final page = await repo.fetchQuotes(skip: 0, limit: 1);
      expect(page.fromCache, isTrue);
      expect(page.quotes.single.text, 'Fokus adalah kunci');
    });

    test('offline tanpa cache -> NetworkException', () async {
      final repo = QuoteRepositoryImpl(
        remote: QuoteRemoteDataSource(
          client: MockClient((_) async => http.Response('error', 500)),
        ),
        cache: InMemoryQuoteCache(),
      );
      expect(
        () => repo.fetchQuotes(skip: 0, limit: 1),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('QuoteCubit (pagination)', () {
    test('memuat halaman berikutnya sampai habis', () async {
      final repo = FakeQuoteRepository(total: 25);
      final cubit = QuoteCubit(repo, pageSize: 10);

      await cubit.loadInitial();
      expect(cubit.state.quotes.length, 10);
      expect(cubit.state.hasMore, isTrue);

      await cubit.loadMore();
      await cubit.loadMore();
      expect(cubit.state.quotes.length, 25);
      expect(cubit.state.hasMore, isFalse);

      await cubit.loadMore(); // tidak memanggil API lagi
      expect(repo.calls, 3);
      await cubit.close();
    });
  });
}
