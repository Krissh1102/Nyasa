import 'package:admin/widgets/analysis_utils.dart';
import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../models/product.dart';
import '../../services/order_service.dart';
import '../../services/product_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/icon_stat_tile.dart';
import '../../widgets/layered_area_chart.dart';
import '../../widgets/segmented_toggle.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_tile.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/dual_line_chart.dart';
import '../orders/order_detail_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _revenueToggle = 1;
  int _chartToggle = 1;
  int _trendingToggle = 1;

  bool _loading = true;
  String? _error;
  List<Product> _products = [];
  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        ProductService.instance.getAll(),
        OrderService.instance.getAll(),
      ]);
      if (!mounted) return;
      setState(() {
        _products = results[0] as List<Product>;
        _orders = results[1] as List<Order>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  double get _totalRevenue =>
      _orders.fold(0.0, (sum, o) => sum + o.totalAmount);

  double get _averageSale =>
      _orders.isEmpty ? 0 : _totalRevenue / _orders.length;

  // Orders don't carry a separate customer id in what's wired up so far, so
  // this counts distinct customer names as a stand-in for "clients". Swap
  // for a real customers endpoint/count once one exists.
  int get _approxClientCount =>
      _orders.map((o) => o.customerName).toSet().length;

  String _formatCurrency(double amount) {
    if (amount >= 10000000)
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(1)}k';
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _CircleIconButton(icon: Icons.tune_rounded, onTap: () {}),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.danger,
                size: 36,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.inkSoft),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final revenue = computeRevenueSeries(_orders, _revenueToggle);
    final ordersChart = computeOrdersSeries(_orders, _chartToggle);
    final trending = computeTrendingProducts(_orders, _trendingToggle);

    final sortedOrders = [..._orders]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final recentOrders = sortedOrders.take(3).toList();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              StatTile(
                value: '${_products.length}',
                label: 'Total Products',
                progress: 1,
                dark: true,
              ),
              StatTile(
                value: '${_orders.length}',
                label: 'Total Orders',
                progress: 1,
              ),
              StatTile(
                value: '$_approxClientCount',
                label: 'Total Clients',
                progress: 1,
              ),
              StatTile(
                value: _formatCurrency(_totalRevenue),
                label: 'Revenue',
                progress: 1,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Revenue', style: Theme.of(context).textTheme.titleMedium),
              SegmentedToggle(
                options: const ['Monthly', 'Weekly', 'Today'],
                selectedIndex: _revenueToggle,
                onChanged: (i) => setState(() => _revenueToggle = i),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _ChartLegend(
            items: [
              ('This period', AppColors.blushDeep),
              ('Previous period', AppColors.ink),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.fromLTRB(4, 16, 16, 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: DualLineChart(
              labels: revenue.labels,
              seriesA: revenue.current,
              seriesB: revenue.previous,
              minY: revenue.minY,
              maxY: revenue.maxY,
              step: revenue.step,
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Recent orders'),
          const SizedBox(height: 12),
          if (recentOrders.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No orders yet.',
                style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
              ),
            )
          else
            ...recentOrders.map(
              (order) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => OrderDetailScreen(order: order),
                          ),
                        )
                        .then((_) => _load()),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '#${order.id} · ${order.customerName}',
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${order.items.length} item${order.items.length == 1 ? '' : 's'} · ₹${order.totalAmount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.inkSoft,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(status: order.status, compact: true),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: IconStatTile(
                  icon: Icons.bar_chart_rounded,
                  value: _formatCurrency(_totalRevenue),
                  label: 'Total Sales',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: IconStatTile(
                  icon: Icons.show_chart_rounded,
                  value: _formatCurrency(_averageSale),
                  label: 'Average Sale',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Chart Orders',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SegmentedToggle(
                options: const ['Monthly', 'Weekly', 'Today'],
                selectedIndex: _chartToggle,
                onChanged: (i) => setState(() => _chartToggle = i),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _ChartLegend(
            items: [
              ('Total orders', AppColors.cardMuted),
              ('Delivered', AppColors.ink),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.fromLTRB(4, 16, 16, 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: LayeredAreaChart(
              labels: ordersChart.labels,
              backSeries: ordersChart.total,
              frontSeries: ordersChart.delivered,
              minY: ordersChart.minY,
              maxY: ordersChart.maxY,
              step: ordersChart.step,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trending Items',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SegmentedToggle(
                options: const ['Monthly', 'Weekly', 'Today'],
                selectedIndex: _trendingToggle,
                onChanged: (i) => setState(() => _trendingToggle = i),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (trending.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'No sales in this period yet.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < trending.length; i++) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.shopping_bag_outlined,
                              color: AppColors.ink,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trending[i].name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  trending[i].subtitle,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.inkFaint,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${trending[i].salesCount}',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Sales ${trending[i].isUp ? '+' : ''}${trending[i].changePercent.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: trending[i].isUp
                                      ? AppColors.success
                                      : AppColors.danger,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (i != trending.length - 1)
                      const Divider(height: 1, indent: 12, endIndent: 12),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final List<(String, Color)> items;
  const _ChartLegend({required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (label, color) in items) ...[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.inkSoft,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 14),
        ],
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 18, color: AppColors.ink),
        ),
      ),
    );
  }
}
