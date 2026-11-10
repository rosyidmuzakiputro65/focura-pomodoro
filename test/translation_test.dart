import 'dart:convert';

import 'package:flutter_application_1/core/errors/app_exception.dart';
import 'package:flutter_application_1/features/quotes/data/datasources/translation_remote_data_source.dart';
import 'package:flutter_application_1/features/quotes/domain/entities/quote.dart';
import 'package:flutter_application_1/features/quotes/presentation/cubit/quote_translation_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'helpers/fakes.dart';

void main() {
  group('TranslationRemoteDataSource (MyMemory)', () {
    test('mengirim langpair dan membaca translatedText', () async {
      Uri? requested;
      final source = TranslationRemoteDataSource(
        client: MockClient((request) async {
          requested = request.url;
          return http.Response(
            jsonEncode({
              'responseData': {'translatedText': 'Fokus adalah kunci &#39;sukses&#39;'},
              'responseStatus': 200,
            }),
            200,
          );
        }),
      );
      final result = await source.translate('Focus is key', from: 'en', to: 'id');
      expect(requested?.queryParameters['langpair'], 'en|id');
      expect(requested?.queryParameters['q'], 'Focus is key');
      expect(result, "Fokus adalah kunci 'sukses'");
    });

    test('kuota habis -> translationUnavailable', () async {
      final source = TranslationRemoteDataSource(
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'responseData': {
                'translatedText':
                    'MYMEMORY WARNING: YOU USED ALL AVAILABLE FREE TRANSLATIONS FOR TODAY',
              },
              'responseStatus': 429,
            }),
            200,
          ),
        ),
      );
      expect(
        () => source.translate('Hi', from: 'en', to: 'id'),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.error,
            'error',
            AppError.translationUnavailable,
          ),
        ),
      );
    });
  });

  group('QuoteTranslationCubit', () {
    const quote = Quote(id: 1, text: 'Stay focused', author: 'Rod');

    test('menerjemahkan ke Indonesia dan tidak mengulang permintaan', () async {
      final repo = FakeTranslationRepository();
      final cubit = QuoteTranslationCubit(repo);
      cubit.ensure(quote, 'id');
      expect(cubit.state.of(quote, 'id')?.status, TranslationStatus.loading);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.of(quote, 'id')?.text, '[id] Stay focused');
      cubit.ensure(quote, 'id');
      expect(repo.calls, 1);
      await cubit.close();
    });

    test('bahasa English tidak perlu diterjemahkan', () async {
      final repo = FakeTranslationRepository();
      final cubit = QuoteTranslationCubit(repo);
      cubit.ensure(quote, 'en');
      expect(repo.calls, 0);
      await cubit.close();
    });

    test('gagal tidak dicoba otomatis, tapi bisa retry', () async {
      final repo = FakeTranslationRepository(fail: true);
      final cubit = QuoteTranslationCubit(repo);
      cubit.ensure(quote, 'id');
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.of(quote, 'id')?.status, TranslationStatus.failed);

      cubit.ensure(quote, 'id');
      expect(repo.calls, 1);

      repo.fail = false;
      cubit.retry(quote, 'id');
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.of(quote, 'id')?.status, TranslationStatus.done);
      expect(repo.calls, 2);
      await cubit.close();
    });
  });
}
