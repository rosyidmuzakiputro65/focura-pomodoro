import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/quote.dart';
import '../../domain/repositories/quote_repository.dart';

part 'quote_state.dart';

/// Pagination / lazy loading: data diambil per [pageSize] item dan
/// halaman berikutnya baru dimuat saat pengguna menggulir ke bawah.
class QuoteCubit extends Cubit<QuoteState> {
  QuoteCubit(this._repository, {this.pageSize = 15}) : super(const QuoteState());

  final QuoteRepository _repository;
  final int pageSize;

  Future<void> loadInitial() async {
    if (state.status == QuoteStatus.loading) return;
    emit(state.copyWith(status: QuoteStatus.loading, clearError: true));
    try {
      final page = await _repository.fetchQuotes(skip: 0, limit: pageSize);
      emit(
        QuoteState(
          status: QuoteStatus.success,
          quotes: page.quotes,
          total: page.total,
          hasMore: page.hasMore,
          isOffline: page.fromCache,
        ),
      );
    } on AppException catch (exception) {
      emit(state.copyWith(status: QuoteStatus.failure, error: exception.error));
    }
  }

  Future<void> loadMore() async {
    if (state.status != QuoteStatus.success ||
        state.isLoadingMore ||
        !state.hasMore) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true, clearError: true));
    try {
      final page = await _repository.fetchQuotes(
        skip: state.quotes.length,
        limit: pageSize,
      );
      emit(
        state.copyWith(
          quotes: [...state.quotes, ...page.quotes],
          total: page.total,
          hasMore: page.hasMore && page.quotes.isNotEmpty,
          isLoadingMore: false,
          isOffline: page.fromCache,
        ),
      );
    } on AppException catch (exception) {
      emit(state.copyWith(isLoadingMore: false, error: exception.error));
    }
  }
}
