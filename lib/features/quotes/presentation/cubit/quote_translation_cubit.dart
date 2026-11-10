import 'dart:async';
import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/quote.dart';
import '../../domain/repositories/translation_repository.dart';

enum TranslationStatus { loading, done, failed }

class QuoteTranslation extends Equatable {
  const QuoteTranslation(this.status, {this.text, this.error});

  final TranslationStatus status;
  final String? text;
  final AppError? error;

  @override
  List<Object?> get props => [status, text, error];
}

class QuoteTranslationState extends Equatable {
  const QuoteTranslationState({
    this.enabled = true,
    this.items = const {},
  });

  /// Pengguna bisa mematikan terjemahan dan hanya membaca teks asli.
  final bool enabled;

  /// Kunci: `"<bahasa>:<id kutipan>"`.
  final Map<String, QuoteTranslation> items;

  QuoteTranslation? of(Quote quote, String languageCode) =>
      items['$languageCode:${quote.id}'];

  QuoteTranslationState copyWith({
    bool? enabled,
    Map<String, QuoteTranslation>? items,
  }) {
    return QuoteTranslationState(
      enabled: enabled ?? this.enabled,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [enabled, items];
}

/// Menerjemahkan kutipan (English) ke bahasa aplikasi secara bertahap.
/// Hanya kutipan yang tampil di layar yang diterjemahkan (lazy), dengan
/// maksimal [maxConcurrent] permintaan sekaligus.
class QuoteTranslationCubit extends Cubit<QuoteTranslationState> {
  QuoteTranslationCubit(this._repository, {this.maxConcurrent = 2})
    : super(const QuoteTranslationState());

  final TranslationRepository _repository;
  final int maxConcurrent;
  final Queue<_Job> _queue = Queue<_Job>();
  int _running = 0;

  /// Bahasa sumber kutipan dari API.
  static const String sourceLanguage = 'en';

  void toggleEnabled() => emit(state.copyWith(enabled: !state.enabled));

  /// Minta terjemahan [quote] ke [languageCode] jika belum pernah diminta.
  /// Terjemahan yang gagal TIDAK dicoba otomatis (hemat kuota API);
  /// pengguna bisa menekan tombol coba lagi ([retry]).
  void ensure(Quote quote, String languageCode) {
    if (isClosed || languageCode == sourceLanguage || !state.enabled) return;
    final key = '$languageCode:${quote.id}';
    if (state.items.containsKey(key)) return;
    _enqueue(key, quote, languageCode);
  }

  /// Coba lagi terjemahan yang gagal.
  void retry(Quote quote, String languageCode) {
    if (isClosed || languageCode == sourceLanguage) return;
    final key = '$languageCode:${quote.id}';
    if (state.items[key]?.status == TranslationStatus.loading) return;
    _enqueue(key, quote, languageCode);
  }

  void _enqueue(String key, Quote quote, String languageCode) {
    _set(key, const QuoteTranslation(TranslationStatus.loading));
    _queue.add(_Job(key, quote.text, languageCode));
    _pump();
  }

  void _pump() {
    while (_running < maxConcurrent && _queue.isNotEmpty) {
      final job = _queue.removeFirst();
      _running++;
      unawaited(_run(job));
    }
  }

  Future<void> _run(_Job job) async {
    try {
      final text = await _repository.translate(
        job.text,
        from: sourceLanguage,
        to: job.languageCode,
      );
      _set(job.key, QuoteTranslation(TranslationStatus.done, text: text));
    } on AppException catch (exception) {
      _set(
        job.key,
        QuoteTranslation(TranslationStatus.failed, error: exception.error),
      );
    } catch (_) {
      _set(
        job.key,
        const QuoteTranslation(TranslationStatus.failed, error: AppError.unknown),
      );
    } finally {
      _running--;
      if (!isClosed) _pump();
    }
  }

  void _set(String key, QuoteTranslation value) {
    if (isClosed) return;
    emit(state.copyWith(items: {...state.items, key: value}));
  }
}

class _Job {
  const _Job(this.key, this.text, this.languageCode);

  final String key;
  final String text;
  final String languageCode;
}
