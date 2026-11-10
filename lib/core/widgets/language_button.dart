import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/settings/presentation/cubit/settings_cubit.dart';
import '../constants/app_colors.dart';
import '../l10n/app_strings.dart';

/// Tombol kecil "ID / EN" untuk mengganti bahasa (dipakai di onboarding,
/// login, dan register).
class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final current = context.watch<SettingsCubit>().state.languageCode;
    return PopupMenuButton<String>(
      key: const Key('language_button'),
      tooltip: s.language,
      initialValue: current,
      onSelected: (code) => context.read<SettingsCubit>().changeLanguage(code),
      itemBuilder: (context) => [
        for (final locale in AppStrings.supportedLocales)
          CheckedPopupMenuItem(
            value: locale.languageCode,
            checked: locale.languageCode == current,
            child: Text(s.languageName(locale.languageCode)),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.translate_rounded, size: 18),
            const SizedBox(width: 6),
            Text(
              current.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

/// Baris pengaturan bahasa untuk halaman profil.
class LanguageSettingTile extends StatelessWidget {
  const LanguageSettingTile({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final current = context.watch<SettingsCubit>().state.languageCode;
    return ListTile(
      leading: const Icon(Icons.translate_rounded),
      title: Text(s.language),
      trailing: DropdownButton<String>(
        key: const Key('language_dropdown'),
        value: current,
        underline: const SizedBox.shrink(),
        borderRadius: BorderRadius.circular(12),
        items: [
          for (final locale in AppStrings.supportedLocales)
            DropdownMenuItem(
              value: locale.languageCode,
              child: Text(s.languageName(locale.languageCode)),
            ),
        ],
        onChanged: (code) async {
          if (code == null || code == current) return;
          final messenger = ScaffoldMessenger.of(context);
          await context.read<SettingsCubit>().changeLanguage(code);
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(AppStrings.forLanguageCode(code).languageChanged),
              ),
            );
        },
      ),
    );
  }
}
