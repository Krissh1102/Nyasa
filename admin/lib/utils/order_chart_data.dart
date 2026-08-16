import '../models/order.dart';
import '../models/order_status.dart';

/// Computes GroupedBarChart-ready data from a raw order list.
/// 3 bars per bucket: Pending (active/in-progress) / Delivered / Cancelled.
class OrderChartData {
  final List<String> labels;
  final List<List<double>> groups; // [pending, delivered, cancelled] per bucket
  final double minY;
  final double maxY;
  final double step;

  const OrderChartData({
    required this.labels,
    required this.groups,
    required this.minY,
    required this.maxY,
    required this.step,
  });

  static const monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  static const weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  /// toggleIndex: 0 = Monthly, 1 = Weekly, 2 = Today
  /// (matches SegmentedToggle(options: ['Monthly', 'Weekly', 'Today']))
  factory OrderChartData.fromOrders(List<Order> orders, int toggleIndex) {
    switch (toggleIndex) {
      case 0:
        return _monthly(orders);
      case 2:
        return _today(orders);
      case 1:
      default:
        return _weekly(orders);
    }
  }

  static OrderChartData _monthly(List<Order> orders) {
    final now = DateTime.now();
    final buckets = List.generate(6, (i) => DateTime(now.year, now.month - (5 - i), 1));

    final labels = buckets.map((b) => monthNames[b.month - 1]).toList();
    final groups = buckets.map((b) {
      final matches = orders.where(
        (o) => o.createdAt.year == b.year && o.createdAt.month == b.month,
      );
      return _countTriple(matches);
    }).toList();

    return _withScale(labels, groups);
  }

  static OrderChartData _weekly(List<Order> orders) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final buckets = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));

    final labels = buckets.map((b) => weekdayNames[b.weekday - 1]).toList();
    final groups = buckets.map((b) {
      final matches = orders.where((o) {
        final d = DateTime(o.createdAt.year, o.createdAt.month, o.createdAt.day);
        return d == b;
      });
      return _countTriple(matches);
    }).toList();

    return _withScale(labels, groups);
  }

  static OrderChartData _today(List<Order> orders) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    // 6 buckets of 4 hours each: 12am, 4am, 8am, 12pm, 4pm, 8pm
    final bucketStarts = List.generate(6, (i) => todayStart.add(Duration(hours: i * 4)));
    final labels = bucketStarts.map(_hourLabel).toList();

    final groups = List.generate(6, (i) {
      final start = bucketStarts[i];
      final end = start.add(const Duration(hours: 4));
      final matches = orders.where(
        (o) => !o.createdAt.isBefore(start) && o.createdAt.isBefore(end),
      );
      return _countTriple(matches);
    });

    return _withScale(labels, groups);
  }

  static String _hourLabel(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final suffix = t.hour < 12 ? 'am' : 'pm';
    return '$h$suffix';
  }

  /// Buckets pending/confirmed/packed/outForDelivery together as "active"
  /// since the chart only has 3 series. Adjust here if you'd rather split
  /// them differently.
  static List<double> _countTriple(Iterable<Order> orders) {
    int pending = 0, delivered = 0, cancelled = 0;
    for (final o in orders) {
      switch (o.status) {
        case OrderStatus.pending:
        case OrderStatus.confirmed:
        case OrderStatus.packed:
        case OrderStatus.outForDelivery:
          pending++;
          break;
        case OrderStatus.delivered:
          delivered++;
          break;
        case OrderStatus.cancelled:
          cancelled++;
          break;
      }
    }
    return [pending.toDouble(), delivered.toDouble(), cancelled.toDouble()];
  }

  static OrderChartData _withScale(List<String> labels, List<List<double>> groups) {
    double maxVal = 0;
    for (final g in groups) {
      for (final v in g) {
        if (v > maxVal) maxVal = v;
      }
    }
    if (maxVal <= 0) maxVal = 4;

    final maxY = _niceMax(maxVal);
    final step = maxY / 4;

    return OrderChartData(labels: labels, groups: groups, minY: 0, maxY: maxY, step: step);
  }

  static double _niceMax(double value) {
    final rounded = (value / 4).ceil() * 4;
    return rounded < 4 ? 4 : rounded.toDouble();
  }
}