import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Two smoothed line series over shared day labels — used for the "Revenue"
/// chart on the Home screen (pink line + black line, like the reference).
class DualLineChart extends StatelessWidget {
  final List<String> labels;
  final List<double> seriesA; // pink
  final List<double> seriesB; // black
  final double minY;
  final double maxY;
  final double step;

  const DualLineChart({
    super.key,
    required this.labels,
    required this.seriesA,
    required this.seriesB,
    this.minY = 15,
    this.maxY = 60,
    this.step = 5,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: CustomPaint(
        painter: _DualLinePainter(
          labels: labels,
          seriesA: seriesA,
          seriesB: seriesB,
          minY: minY,
          maxY: maxY,
          step: step,
        ),
        child: Container(),
      ),
    );
  }
}

class _DualLinePainter extends CustomPainter {
  final List<String> labels;
  final List<double> seriesA;
  final List<double> seriesB;
  final double minY;
  final double maxY;
  final double step;

  _DualLinePainter({
    required this.labels,
    required this.seriesA,
    required this.seriesB,
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
    final labelStyle = const TextStyle(fontSize: 9.5, color: AppColors.inkFaint);

    // Horizontal grid lines + y labels
    final steps = ((maxY - minY) / step).round();
    for (int i = 0; i <= steps; i++) {
      final v = minY + step * i;
      final y = chartRect.bottom - ((v - minY) / (maxY - minY)) * chartRect.height;
      canvas.drawLine(Offset(chartRect.left, y), Offset(chartRect.right, y), gridPaint);
      final tp = TextPainter(text: TextSpan(text: v.round().toString(), style: labelStyle), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(leftAxisWidth - tp.width - 6, y - tp.height / 2));
    }

    // X labels
    for (int i = 0; i < labels.length; i++) {
      final x = chartRect.left + (chartRect.width / (labels.length - 1)) * i;
      final tp = TextPainter(text: TextSpan(text: labels[i], style: labelStyle), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, chartRect.bottom + 6));
    }

    _drawSmoothLine(canvas, chartRect, seriesA, AppColors.blushDeep);
    _drawSmoothLine(canvas, chartRect, seriesB, AppColors.ink);
  }

  void _drawSmoothLine(Canvas canvas, Rect rect, List<double> series, Color color) {
    final points = <Offset>[];
    for (int i = 0; i < series.length; i++) {
      final x = rect.left + (rect.width / (series.length - 1)) * i;
      final y = rect.bottom - ((series[i] - minY) / (maxY - minY)) * rect.height;
      points.add(Offset(x, y));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
      if (i == points.length - 2) path.lineTo(p1.dx, p1.dy);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    for (final p in [points.first, points.last]) {
      canvas.drawCircle(p, 3.2, Paint()..color = color);
      canvas.drawCircle(p, 3.2, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.4);
    }
  }

  @override
  bool shouldRepaint(covariant _DualLinePainter oldDelegate) =>
      oldDelegate.seriesA != seriesA || oldDelegate.seriesB != seriesB;
}
