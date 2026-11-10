import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: size * 0.4,
          ),
        ],
      ),
      child: Icon(Icons.timer_rounded, color: Colors.white, size: size * 0.55),
    );
  }
}
