import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Grouped vertical bars (3 bars per day: black / gray / blush) — used for
/// the Orders screen bar chart.
class GroupedBarChart extends StatelessWidget {
  final List<String> labels;
  final List<List<double>> groups; // one list of 3 values per label
  final double minY;
  final double maxY;
  final double step;

  const GroupedBarChart({
    super.key,
    required this.labels,
    required this.groups,
    this.minY = 25,
    this.maxY = 60,
    this.step = 5,
  });

  static const barColors = [AppColors.ink, AppColors.cardMuted, AppColors.blush];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: CustomPaint(
        painter: _BarPainter(labels: labels, groups: groups, minY: minY, maxY: maxY, step: step),
        child: Container(),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  final List<String> labels;
  final List<List<double>> groups;
  final double minY;
  final double maxY;
  final double step;

  _BarPainter({required this.labels, required this.groups, required this.minY, required this.maxY, required this.step});

  @override
  void paint(Canvas canvas, Size size) {
    const leftAxisWidth = 26.0;
    const bottomAxisHeight = 20.0;
    final chartRect = Rect.fromLTWH(leftAxisWidth, 0, size.width - leftAxisWidth, size.height - bottomAxisHeight);

    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    const labelStyle = TextStyle(fontSize: 9.5, color: AppColors.inkFaint);

    final steps = ((maxY - minY) / step).round();
    for (int i = 0; i <= steps; i++) {
      final v = minY + step * i;
      final y = chartRect.bottom - ((v - minY) / (maxY - minY)) * chartRect.height;
      canvas.drawLine(Offset(chartRect.left, y), Offset(chartRect.right, y), gridPaint);
      final tp = TextPainter(text: TextSpan(text: v.round().toString(), style: labelStyle), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(leftAxisWidth - tp.width - 6, y - tp.height / 2));
    }

    final groupWidth = chartRect.width / groups.length;
    const barGap = 3.0;

    for (int g = 0; g < groups.length; g++) {
      final values = groups[g];
      final barWidth = (groupWidth - barGap * (values.length + 1)) / values.length;
      final groupLeft = chartRect.left + groupWidth * g;

      for (int b = 0; b < values.length; b++) {
        final v = values[b].clamp(minY, maxY);
        final barHeight = ((v - minY) / (maxY - minY)) * chartRect.height;
        final left = groupLeft + barGap + b * (barWidth + barGap);
        final rect = Rect.fromLTWH(left, chartRect.bottom - barHeight, barWidth, barHeight);
        final rrect = RRect.fromRectAndCorners(rect, topLeft: const Radius.circular(3), topRight: const Radius.circular(3));
        canvas.drawRRect(rrect, Paint()..color = GroupedBarChart.barColors[b % GroupedBarChart.barColors.length]);
      }

      final tp = TextPainter(text: TextSpan(text: labels[g], style: labelStyle), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(groupLeft + groupWidth / 2 - tp.width / 2, chartRect.bottom + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _BarPainter oldDelegate) => oldDelegate.groups != groups;
}
