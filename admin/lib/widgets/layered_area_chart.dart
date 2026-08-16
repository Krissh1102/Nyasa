import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Two overlapping filled "mountain" series — used for "Chart Orders" on
/// Analytics (light gray fill behind, solid black fill in front).
class LayeredAreaChart extends StatelessWidget {
  final List<String> labels;
  final List<double> backSeries; // light gray, drawn first
  final List<double> frontSeries; // black, drawn on top
  final double minY;
  final double maxY;
  final double step;

  const LayeredAreaChart({
    super.key,
    required this.labels,
    required this.backSeries,
    required this.frontSeries,
    this.minY = 15,
    this.maxY = 60,
    this.step = 5,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: CustomPaint(
        painter: _AreaPainter(labels: labels, backSeries: backSeries, frontSeries: frontSeries, minY: minY, maxY: maxY, step: step),
        child: Container(),
      ),
    );
  }
}

class _AreaPainter extends CustomPainter {
  final List<String> labels;
  final List<double> backSeries;
  final List<double> frontSeries;
  final double minY;
  final double maxY;
  final double step;

  _AreaPainter({
    required this.labels,
    required this.backSeries,
    required this.frontSeries,
    required this.minY,
    required this.maxY,
    required this.step,
  });

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

    for (int i = 0; i < labels.length; i++) {
      final x = chartRect.left + (chartRect.width / (labels.length - 1)) * i;
      final tp = TextPainter(text: TextSpan(text: labels[i], style: labelStyle), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, chartRect.bottom + 6));
    }

    _drawArea(canvas, chartRect, backSeries, AppColors.cardMuted, null);
    _drawArea(canvas, chartRect, frontSeries, AppColors.ink, null);
  }

  void _drawArea(Canvas canvas, Rect rect, List<double> series, Color fill, Color? stroke) {
    final points = <Offset>[];
    for (int i = 0; i < series.length; i++) {
      final x = rect.left + (rect.width / (series.length - 1)) * i;
      final y = rect.bottom - ((series[i] - minY) / (maxY - minY)) * rect.height;
      points.add(Offset(x, y));
    }

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      linePath.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
      if (i == points.length - 2) linePath.lineTo(p1.dx, p1.dy);
    }

    final fillPath = Path.from(linePath)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..close();

    canvas.drawPath(fillPath, Paint()..color = fill);
  }

  @override
  bool shouldRepaint(covariant _AreaPainter oldDelegate) =>
      oldDelegate.backSeries != backSeries || oldDelegate.frontSeries != frontSeries;
}
