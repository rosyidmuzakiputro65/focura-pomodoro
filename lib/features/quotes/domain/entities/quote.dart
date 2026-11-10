import 'package:equatable/equatable.dart';

class Quote extends Equatable {
  const Quote({required this.id, required this.text, required this.author});

  final int id;
  final String text;
  final String author;

  @override
  List<Object?> get props => [id, text, author];
}

/// Satu halaman hasil pagination dari API.
class QuotePage extends Equatable {
  const QuotePage({
    required this.quotes,
    required this.total,
    required this.skip,
    this.fromCache = false,
  });

  final List<Quote> quotes;
  final int total;
  final int skip;

  /// `true` jika data diambil dari cache karena sedang offline.
  final bool fromCache;

  bool get hasMore => skip + quotes.length < total;

  @override
  List<Object?> get props => [quotes, total, skip, fromCache];
}
