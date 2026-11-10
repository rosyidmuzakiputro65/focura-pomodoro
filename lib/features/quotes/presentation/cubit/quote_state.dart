part of 'quote_cubit.dart';

enum QuoteStatus { initial, loading, success, failure }

class QuoteState extends Equatable {
  const QuoteState({
    this.status = QuoteStatus.initial,
    this.quotes = const [],
    this.total = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.isOffline = false,
    this.error,
  });

  final QuoteStatus status;
  final List<Quote> quotes;
  final int total;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isOffline;
  final AppError? error;

  /// Kutipan untuk ditampilkan di layar istirahat.
  Quote? quoteFor(int seed) =>
      quotes.isEmpty ? null : quotes[seed.abs() % quotes.length];

  QuoteState copyWith({
    QuoteStatus? status,
    List<Quote>? quotes,
    int? total,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isOffline,
    AppError? error,
    bool clearError = false,
  }) {
    return QuoteState(
      status: status ?? this.status,
      quotes: quotes ?? this.quotes,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isOffline: isOffline ?? this.isOffline,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    status,
    quotes,
    total,
    hasMore,
    isLoadingMore,
    isOffline,
    error,
  ];
}
