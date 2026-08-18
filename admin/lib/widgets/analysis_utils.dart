import 'dart:math';

import '../models/order.dart';
import '../models/order_status.dart';

/// A single time bucket (e.g. one day, one 4-hour block) used to aggregate
/// orders into a chart series.
class ChartBucket {
  final DateTime start;
  final DateTime end;
  final String label;
  const ChartBucket({required this.start, required this.end, required this.label});
}

const _weekdayAbbr = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// toggleIndex: 0 = Monthly (6 buckets of 5 days, last 30 days),
/// 1 = Weekly (7 daily buckets, last 7 days), 2 = Today (6 buckets of 4h).
List<ChartBucket> bucketsForToggle(int toggleIndex, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);

  switch (toggleIndex) {
    case 0:
      final start = today.subtract(const Duration(days: 29));
      return List.generate(6, (i) {
        final bStart = start.add(Duration(days: i * 5));
        final bEnd = bStart.add(const Duration(days: 5));
        return ChartBucket(start: bStart, end: bEnd, label: '${bStart.day}/${bStart.month}');
      });
    case 2:
      return List.generate(6, (i) {
        final bStart = today.add(Duration(hours: i * 4));
        final bEnd = bStart.add(const Duration(hours: 4));
        final hour = bStart.hour;
        final label = hour == 0
            ? '12am'
            : hour < 12
                ? '${hour}am'
                : hour == 12
                    ? '12pm'
                    : '${hour - 12}pm';
        return ChartBucket(start: bStart, end: bEnd, label: label);
      });
    case 1:
    default:
      final start = today.subtract(const Duration(days: 6));
      return List.generate(7, (i) {
        final bStart = start.add(Duration(days: i));
        final bEnd = bStart.add(const Duration(days: 1));
        return ChartBucket(start: bStart, end: bEnd, label: _weekdayAbbr[bStart.weekday - 1]);
      });
  }
}

Duration periodLengthForToggle(int toggleIndex) {
  switch (toggleIndex) {
    case 0:
      return const Duration(days: 30);
    case 2:
      return const Duration(hours: 24);
    case 1:
    default:
      return const Duration(days: 7);
  }
}

/// Rounds up to a "nice" axis max (1/2/5/10 * 10^n) with ~20% headroom above
/// the data, and returns (minY, maxY, step) with 5 grid steps.
(double, double, double) axisRange(List<double> values) {
  final maxVal = values.isEmpty ? 0.0 : values.reduce((a, b) => a > b ? a : b);
  if (maxVal <= 0) return (0, 10, 2);

  final rawStep = (maxVal * 1.2) / 5;
  final magnitude = pow(10, (log(rawStep) / ln10).floor()).toDouble();
  final residual = rawStep / magnitude;

  double niceResidual;
  if (residual > 5) {
    niceResidual = 10;
  } else if (residual > 2) {
    niceResidual = 5;
  } else if (residual > 1) {
    niceResidual = 2;
  } else {
    niceResidual = 1;
  }

  final step = niceResidual * magnitude;
  return (0, step * 5, step);
}

class RevenueSeries {
  final List<String> labels;
  final List<double> current;
  final List<double> previous;
  final double minY;
  final double maxY;
  final double step;
  const RevenueSeries({
    required this.labels,
    required this.current,
    required this.previous,
    required this.minY,
    required this.maxY,
    required this.step,
  });
}

/// Revenue per bucket for the selected period, alongside the same buckets
/// one period earlier (so "this week" can be compared against "last week").
/// Cancelled orders are excluded.
RevenueSeries computeRevenueSeries(List<Order> orders, int toggleIndex) {
  final now = DateTime.now();
  final buckets = bucketsForToggle(toggleIndex, now);
  final periodLength = periodLengthForToggle(toggleIndex);

  double sumIn(DateTime start, DateTime end) => orders
      .where((o) =>
          o.status != OrderStatus.cancelled &&
          !o.createdAt.isBefore(start) &&
          o.createdAt.isBefore(end))
      .fold(0.0, (s, o) => s + o.totalAmount);

  final current = buckets.map((b) => sumIn(b.start, b.end)).toList();
  final previous = buckets
      .map((b) => sumIn(b.start.subtract(periodLength), b.end.subtract(periodLength)))
      .toList();

  final (minY, maxY, step) = axisRange([...current, ...previous]);
  return RevenueSeries(
    labels: buckets.map((b) => b.label).toList(),
    current: current,
    previous: previous,
    minY: minY,
    maxY: maxY,
    step: step,
  );
}

class OrdersSeries {
  final List<String> labels;
  final List<double> total;
  final List<double> delivered;
  final double minY;
  final double maxY;
  final double step;
  const OrdersSeries({
    required this.labels,
    required this.total,
    required this.delivered,
    required this.minY,
    required this.maxY,
    required this.step,
  });
}

/// Total orders placed vs. orders that reached "delivered", per bucket.
OrdersSeries computeOrdersSeries(List<Order> orders, int toggleIndex) {
  final buckets = bucketsForToggle(toggleIndex, DateTime.now());

  int countIn(DateTime start, DateTime end, {OrderStatus? status}) => orders
      .where((o) =>
          (status == null || o.status == status) &&
          !o.createdAt.isBefore(start) &&
          o.createdAt.isBefore(end))
      .length;

  final total = buckets.map((b) => countIn(b.start, b.end).toDouble()).toList();
  final delivered =
      buckets.map((b) => countIn(b.start, b.end, status: OrderStatus.delivered).toDouble()).toList();

  final (minY, maxY, step) = axisRange([...total, ...delivered]);
  return OrdersSeries(
    labels: buckets.map((b) => b.label).toList(),
    total: total,
    delivered: delivered,
    minY: minY,
    maxY: maxY,
    step: step,
  );
}

class TrendingProductStat {
  final String name;
  final String subtitle;
  final int salesCount;
  final double changePercent;
  const TrendingProductStat({
    required this.name,
    required this.subtitle,
    required this.salesCount,
    required this.changePercent,
  });
  bool get isUp => changePercent >= 0;
}

/// Top-selling products (by quantity) in the selected period, with
/// changePercent comparing that period to the one immediately before it.
/// Cancelled orders are excluded.
List<TrendingProductStat> computeTrendingProducts(
  List<Order> orders,
  int toggleIndex, {
  int limit = 5,
}) {
  final now = DateTime.now();
  final periodLength = periodLengthForToggle(toggleIndex);
  final currentStart = now.subtract(periodLength);
  final previousStart = currentStart.subtract(periodLength);

  final currentQty = <int, int>{};
  final currentRevenue = <int, double>{};
  final previousQty = <int, int>{};
  final names = <int, String>{};

  for (final order in orders) {
    if (order.status == OrderStatus.cancelled) continue;
    final inCurrent = !order.createdAt.isBefore(currentStart);
    final inPrevious = !inCurrent &&
        !order.createdAt.isBefore(previousStart) &&
        order.createdAt.isBefore(currentStart);
    if (!inCurrent && !inPrevious) continue;

    for (final item in order.items) {
      names[item.productId] = item.productName;
      if (inCurrent) {
        currentQty[item.productId] = (currentQty[item.productId] ?? 0) + item.quantity;
        currentRevenue[item.productId] = (currentRevenue[item.productId] ?? 0) + item.lineTotal;
      } else {
        previousQty[item.productId] = (previousQty[item.productId] ?? 0) + item.quantity;
      }
    }
  }

  final productIds = currentQty.keys.toList()
    ..sort((a, b) => (currentQty[b] ?? 0).compareTo(currentQty[a] ?? 0));

  return productIds.take(limit).map((id) {
    final curr = currentQty[id] ?? 0;
    final prev = previousQty[id] ?? 0;
    final change = prev == 0 ? (curr > 0 ? 100.0 : 0.0) : ((curr - prev) / prev) * 100;
    final revenue = currentRevenue[id] ?? 0;
    return TrendingProductStat(
      name: names[id] ?? 'Product #$id',
      subtitle: '₹${revenue.toStringAsFixed(0)} this period',
      salesCount: curr,
      changePercent: change,
    );
  }).toList();
}