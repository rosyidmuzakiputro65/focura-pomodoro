import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../cubit/quote_cubit.dart';
import '../cubit/quote_translation_cubit.dart';
import '../widgets/quote_card.dart';

/// Daftar kutipan motivasi dari DummyJSON dengan lazy loading
/// (infinite scroll) dan cache offline.
class QuotesPage extends StatefulWidget {
  const QuotesPage({super.key});

  @override
  State<QuotesPage> createState() => _QuotesPageState();
}

class _QuotesPageState extends State<QuotesPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    final cubit = context.read<QuoteCubit>();
    if (cubit.state.status == QuoteStatus.initial) cubit.loadInitial();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    // Muat halaman berikutnya ketika tersisa ~300px sebelum dasar list.
    if (position.pixels >= position.maxScrollExtent - 300) {
      context.read<QuoteCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.motivationTitle),
        actions: [
          // Tombol terjemahan hanya muncul jika bahasa aplikasi bukan English.
          if (s.languageCode != QuoteTranslationCubit.sourceLanguage)
            BlocBuilder<QuoteTranslationCubit, QuoteTranslationState>(
              buildWhen: (p, c) => p.enabled != c.enabled,
              builder: (context, translation) => IconButton(
                key: const Key('translation_toggle'),
                tooltip: translation.enabled
                    ? s.hideTranslation
                    : s.showTranslation,
                isSelected: translation.enabled,
                icon: const Icon(Icons.translate_rounded),
                selectedIcon: const Icon(
                  Icons.g_translate_rounded,
                  color: AppColors.shortBreak,
                ),
                onPressed: context.read<QuoteTranslationCubit>().toggleEnabled,
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<QuoteCubit, QuoteState>(
        listenWhen: (p, c) =>
            c.status == QuoteStatus.success &&
            c.error != null &&
            p.error != c.error,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(s.error(state.error!))),
          );
        },
        builder: (context, state) {
          final cubit = context.read<QuoteCubit>();
          switch (state.status) {
            case QuoteStatus.initial:
            case QuoteStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case QuoteStatus.failure:
              return EmptyState(
                icon: Icons.wifi_off_rounded,
                title: s.quotesLoadFailed,
                message: s.error(state.error ?? AppError.networkOffline),
                action: FilledButton.icon(
                  onPressed: cubit.loadInitial,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(s.retry),
                ),
              );
            case QuoteStatus.success:
              return RefreshIndicator(
                onRefresh: cubit.loadInitial,
                child: ResponsiveCenter(
                  maxWidth: 720,
                  child: ListView.separated(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: state.quotes.length + 2,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == 0) return _Header(state: state);
                      if (index == state.quotes.length + 1) {
                        return _Footer(state: state, onRetry: cubit.loadMore);
                      }
                      return QuoteCard(quote: state.quotes[index - 1]);
                    },
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.state});

  final QuoteState state;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.isOffline)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.longBreak.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  color: AppColors.longBreak,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(s.offlineBanner)),
              ],
            ),
          ),
        Text(
          s.showingQuotes(state.quotes.length, state.total),
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.state, required this.onRetry});

  final QuoteState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!state.hasMore) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            s.allQuotesShown,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }
    return Center(
      child: TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.expand_more_rounded),
        label: Text(s.loadMore),
      ),
    );
  }
}
