import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
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

    final trending = MockData.trendingItems;
    final sortedOrders = [..._orders]..sort((a, b) => b.id.compareTo(a.id));
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
          const SizedBox(height: 6),
          const _SampleDataNote(),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.fromLTRB(4, 16, 16, 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: DualLineChart(
              labels: MockData.chartDayLabels,
              seriesA: MockData.revenuePink,
              seriesB: MockData.revenueBlack,
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
          const SizedBox(height: 6),
          const _SampleDataNote(),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.fromLTRB(4, 16, 16, 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: LayeredAreaChart(
              labels: MockData.chartDayLabels,
              backSeries: MockData.analyticsBack,
              frontSeries: MockData.analyticsFront,
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
          const SizedBox(height: 6),
          const _SampleDataNote(),
          const SizedBox(height: 8),
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
                          child: Icon(
                            trending[i].icon,
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

/// Small inline flag for sections still backed by MockData because no
/// analytics endpoint exists yet. Remove once a real one is wired up.
class _SampleDataNote extends StatelessWidget {
  const _SampleDataNote();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Sample data — connect an analytics endpoint to make this live',
      style: TextStyle(
        fontSize: 11,
        color: AppColors.inkFaint.withValues(alpha: 0.8),
        fontStyle: FontStyle.italic,
      ),
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
