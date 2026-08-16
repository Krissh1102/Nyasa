import 'package:admin/utils/order_chart_data.dart';
import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../models/order_status.dart';
import '../../services/order_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_search_field.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/grouped_bar_chart.dart';
import '../../widgets/segmented_toggle.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _chartToggle = 1;
  int _listToggle = 1;
  OrderStatus? _statusFilter;
  String _query = '';

  List<Order> _orders = [];
  bool _loading = true;
  String? _error;

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
      final orders = await OrderService.instance.getAll();
      if (!mounted) return;
      setState(() {
        _orders = orders;
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

  List<Order> get _filtered {
    return _orders.where((o) {
      final matchesStatus = _statusFilter == null || o.status == _statusFilter;
      final q = _query.trim().toLowerCase();
      final matchesQuery =
          q.isEmpty ||
          o.customerName.toLowerCase().contains(q) ||
          o.id.toString().contains(q);
      return matchesStatus && matchesQuery;
    }).toList();
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter by status',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _statusFilter == null,
                      onSelected: (_) {
                        setState(() => _statusFilter = null);
                        Navigator.pop(context);
                      },
                      selectedColor: AppColors.ink,
                      labelStyle: TextStyle(
                        color: _statusFilter == null
                            ? Colors.white
                            : AppColors.inkSoft,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                    for (final status in OrderStatus.values)
                      ChoiceChip(
                        label: Text(status.label),
                        selected: _statusFilter == status,
                        onSelected: (_) {
                          setState(() => _statusFilter = status);
                          Navigator.pop(context);
                        },
                        selectedColor: AppColors.ink,
                        labelStyle: TextStyle(
                          color: _statusFilter == status
                              ? Colors.white
                              : AppColors.inkSoft,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _CircleIconButton(
              icon: Icons.tune_rounded,
              onTap: _openFilterSheet,
            ),
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
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.inkSoft),
              ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final orders = _filtered;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Orders', style: Theme.of(context).textTheme.titleMedium),
              SegmentedToggle(
                options: const ['Monthly', 'Weekly', 'Today'],
                selectedIndex: _chartToggle,
                onChanged: (i) => setState(() => _chartToggle = i),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Builder(
            builder: (context) {
              final chartData = OrderChartData.fromOrders(
                _orders,
                _chartToggle,
              );
              return Container(
                padding: const EdgeInsets.fromLTRB(4, 16, 16, 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    GroupedBarChart(
                      labels: chartData.labels,
                      groups: chartData.groups,
                      minY: chartData.minY,
                      maxY: chartData.maxY,
                      step: chartData.step,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        _LegendDot(color: AppColors.ink, label: 'Pending'),
                        SizedBox(width: 16),
                        _LegendDot(
                          color: AppColors.cardMuted,
                          label: 'Delivered',
                        ),
                        SizedBox(width: 16),
                        _LegendDot(color: AppColors.blush, label: 'Cancelled'),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          AppSearchField(
            hint: 'Search by name or order id',
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order List',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SegmentedToggle(
                options: const ['Monthly', 'Weekly', 'Today'],
                selectedIndex: _listToggle,
                onChanged: (i) => setState(() => _listToggle = i),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (orders.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: EmptyState(
                icon: Icons.receipt_long_rounded,
                title: 'No orders found',
                subtitle: 'Try a different filter or search term.',
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
                  for (int i = 0; i < orders.length; i++) ...[
                    _OrderRow(
                      order: orders[i],
                      onUpdated: (updated) {
                        setState(() {
                          final idx = _orders.indexWhere(
                            (o) => o.id == updated.id,
                          );
                          if (idx != -1) _orders[idx] = updated;
                        });
                      },
                    ),
                    if (i != orders.length - 1)
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

class _OrderRow extends StatelessWidget {
  final Order order;
  final ValueChanged<Order> onUpdated;
  const _OrderRow({required this.order, required this.onUpdated});

  String get _initials {
    final parts = order.customerName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final updated = await Navigator.of(context).push<Order>(
            MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
          );
          if (updated != null) onUpdated(updated);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.background,
                child: Text(
                  _initials,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formattedDate(order.createdAt),
                      style: const TextStyle(
                        fontSize: 11.5,
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
                    '+₹${order.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status.label,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formattedDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.inkSoft),
        ),
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
