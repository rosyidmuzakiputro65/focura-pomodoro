import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../domain/entities/focus_track.dart';
import '../cubit/focus_music_cubit.dart';

String trackLabel(AppStrings s, FocusTrack track) => switch (track) {
  FocusTrack.none => s.musicOff,
  FocusTrack.piano => s.trackPiano,
  FocusTrack.ambient => s.trackAmbient,
  FocusTrack.rain => s.trackRain,
  FocusTrack.ocean => s.trackOcean,
  FocusTrack.brownNoise => s.trackBrownNoise,
};

IconData trackIcon(FocusTrack track) => switch (track) {
  FocusTrack.none => Icons.music_off_rounded,
  FocusTrack.piano => Icons.piano_rounded,
  FocusTrack.ambient => Icons.wb_twilight_rounded,
  FocusTrack.rain => Icons.water_drop_outlined,
  FocusTrack.ocean => Icons.waves_rounded,
  FocusTrack.brownNoise => Icons.graphic_eq_rounded,
};

/// Kartu pemilihan musik penenang di halaman timer.
class FocusMusicCard extends StatelessWidget {
  const FocusMusicCard({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final state = context.watch<FocusMusicCubit>().state;
    final cubit = context.read<FocusMusicCubit>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.headphones_rounded, color: AppColors.shortBreak),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.musicTitle,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.musicSubtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  key: const Key('music_toggle'),
                  tooltip: state.isPlaying ? s.musicPause : s.musicPreview,
                  onPressed: state.isOff ? null : cubit.togglePlay,
                  icon: Icon(
                    state.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                  ),
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.shortBreak,
                    backgroundColor: AppColors.shortBreak.withValues(alpha: 0.12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final track in FocusTrack.values)
                    _TrackChip(
                      label: trackLabel(s, track),
                      icon: trackIcon(track),
                      selected: state.track == track,
                      onTap: () => cubit.selectTrack(track),
                    ),
                ],
              ),
            ),
            if (!state.isOff) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    state.volume == 0
                        ? Icons.volume_off_rounded
                        : Icons.volume_down_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  Expanded(
                    child: Slider(
                      value: state.volume,
                      onChanged: cubit.setVolume,
                      onChangeEnd: (_) => cubit.saveVolume(),
                      activeColor: AppColors.shortBreak,
                      label: '${(state.volume * 100).round()}%',
                      semanticFormatterCallback: (v) =>
                          '${s.musicVolume} ${(v * 100).round()}%',
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.only(right: 8),
                dense: true,
                value: state.playDuringBreaks,
                onChanged: cubit.setPlayDuringBreaks,
                activeThumbColor: AppColors.shortBreak,
                title: Text(s.musicPlayDuringBreaks),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Chip pilihan lagu dengan kontras teks yang jelas saat dipilih.
class _TrackChip extends StatelessWidget {
  const _TrackChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.shortBreak : AppColors.textSecondary;
    return ChoiceChip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(label),
      labelStyle: TextStyle(
        color: selected ? AppColors.shortBreak : AppColors.textPrimary,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      backgroundColor: AppColors.cardBg,
      selectedColor: AppColors.shortBreak.withValues(alpha: 0.16),
      side: BorderSide(
        color: selected ? AppColors.shortBreak : AppColors.border,
      ),
    );
  }
}
