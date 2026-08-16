import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The big value/label stat tile with a thin progress bar, in either the
/// dark (black bg, white text) or light (white bg, black text) variant seen
/// on the Dashboard/Analytics screens.
class StatTile extends StatelessWidget {
  final String value;
  final String label;
  final double progress; // 0..1
  final bool dark;

  const StatTile({
    super.key,
    required this.value,
    required this.label,
    required this.progress,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : AppColors.ink;
    final sub = dark ? Colors.white.withValues(alpha: 0.65) : AppColors.inkSoft;
    final trackColor = dark ? Colors.white.withValues(alpha: 0.18) : AppColors.border;
    final barColor = dark ? Colors.white : AppColors.ink;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? AppColors.ink : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: dark ? null : Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: fg)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 12.5, color: sub)),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('0%', style: TextStyle(fontSize: 10.5, color: sub)),
              const SizedBox(width: 6),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: trackColor,
                    valueColor: AlwaysStoppedAnimation(barColor),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text('${(progress * 100).round()}%', style: TextStyle(fontSize: 10.5, color: sub)),
            ],
          ),
        ],
      ),
    );
  }
}
