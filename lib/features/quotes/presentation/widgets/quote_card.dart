import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../domain/entities/quote.dart';
import '../cubit/quote_translation_cubit.dart';

/// Kartu kutipan dengan tombol bolak-balik bahasa:
/// - EN: teks asli dari API (English),
/// - ID: terjemahan Bahasa Indonesia (diambil otomatis lewat API terjemahan).
/// Bahasa awal mengikuti bahasa aplikasi; pengguna bisa menekan tombol
/// "ID ⇄ EN" di setiap kartu kapan saja.
class QuoteCard extends StatefulWidget {
  const QuoteCard({
    super.key,
    required this.quote,
    this.accent = AppColors.longBreak,
  });

  final Quote quote;
  final Color accent;

  @override
  State<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard> {
  static const String _target = 'id';

  /// `null` = ikut pengaturan (bahasa aplikasi & tombol global).
  bool? _manualIndonesian;

  bool _wantsIndonesian(BuildContext context) {
    if (_manualIndonesian != null) return _manualIndonesian!;
    final appLanguage = AppStrings.of(context).languageCode;
    final enabled = context.read<QuoteTranslationCubit>().state.enabled;
    return appLanguage == _target && enabled;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _requestIfNeeded();
  }

  @override
  void didUpdateWidget(covariant QuoteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quote.id != widget.quote.id) {
      _manualIndonesian = null;
      _requestIfNeeded();
    }
  }

  /// Permintaan dijadwalkan setelah frame selesai digambar, supaya Cubit
  /// tidak mengubah state di tengah proses build.
  void _requestIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_wantsIndonesian(context)) return;
      context.read<QuoteTranslationCubit>().ensure(widget.quote, _target);
    });
  }

  void _toggleLanguage() {
    setState(() => _manualIndonesian = !_wantsIndonesian(context));
    _requestIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    // watch: kartu ikut diperbarui saat terjemahan selesai.
    final translations = context.watch<QuoteTranslationCubit>().state;
    final showIndonesian = _wantsIndonesian(context);
    final translation = translations.of(widget.quote, _target);
    final translated = showIndonesian &&
            translation?.status == TranslationStatus.done
        ? translation!.text
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 10, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.format_quote_rounded, color: widget.accent, size: 28),
                const Spacer(),
                _LanguageSwitch(
                  showIndonesian: showIndonesian,
                  tooltip: s.switchQuoteLanguage,
                  onPressed: _toggleLanguage,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translated ?? widget.quote.text,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                  if (translated != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      '${s.originalText} (EN): ${widget.quote.text}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '— ${widget.quote.author}',
                        style: TextStyle(
                          color: widget.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (showIndonesian)
                        _TranslationStatus(
                          translation: translation,
                          onRetry: () => context
                              .read<QuoteTranslationCubit>()
                              .retry(widget.quote, _target),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageSwitch extends StatelessWidget {
  const _LanguageSwitch({
    required this.showIndonesian,
    required this.tooltip,
    required this.onPressed,
  });

  final bool showIndonesian;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    Widget label(String text, bool active) => Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: active ? AppColors.textPrimary : AppColors.textSecondary,
      ),
    );
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              label('ID', showIndonesian),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.swap_horiz_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              label('EN', !showIndonesian),
            ],
          ),
        ),
      ),
    );
  }
}

class _TranslationStatus extends StatelessWidget {
  const _TranslationStatus({required this.translation, required this.onRetry});

  final QuoteTranslation? translation;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    const style = TextStyle(color: AppColors.textSecondary, fontSize: 11.5);
    switch (translation?.status) {
      case null:
      case TranslationStatus.loading:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 1.6),
            ),
            const SizedBox(width: 6),
            Text(s.translating, style: style),
          ],
        );
      case TranslationStatus.done:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.translate_rounded,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(s.translatedLabel, style: style),
          ],
        );
      case TranslationStatus.failed:
        return Tooltip(
          message: s.error(translation!.error ?? AppError.unknown),
          child: InkWell(
            onTap: onRetry,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.refresh_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(s.translationFailed, style: style),
              ],
            ),
          ),
        );
    }
  }
}
