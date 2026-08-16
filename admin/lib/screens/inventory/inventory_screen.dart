import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/inventory_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_search_field.dart';
import '../../widgets/empty_state.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Product> _products = [];
  bool _loading = true;
  String? _error;
  String _query = '';
  bool _lowStockOnly = false;

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
      final products = await InventoryService.instance.getAllProducts();
      if (!mounted) return;
      setState(() {
        _products = products;
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

  List<Product> get _filtered {
    return _products.where((p) {
      final q = _query.trim().toLowerCase();
      final matchesQuery = q.isEmpty || p.name.toLowerCase().contains(q);
      final matchesLowStock = !_lowStockOnly || p.isLowStock;
      return matchesQuery && matchesLowStock;
    }).toList();
  }

  void _editStock(Product product) {
    final qtyController = TextEditingController(
      text: product.stockQuantity.toString(),
    );
    final lowStockController = TextEditingController(
      text: product.lowStockAt.toString(),
    );
    bool saving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Update stock'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(fontSize: 13, color: AppColors.inkSoft),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                autofocus: true,
                enabled: !saving,
                decoration: const InputDecoration(
                  labelText: 'Quantity in stock',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lowStockController,
                keyboardType: TextInputType.number,
                enabled: !saving,
                decoration: const InputDecoration(
                  labelText: 'Low stock alert threshold',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      final qty = int.tryParse(qtyController.text.trim());
                      final lowStockAt = int.tryParse(
                        lowStockController.text.trim(),
                      );
                      if (qty == null || lowStockAt == null) return;

                      setDialogState(() => saving = true);

                      try {
                        await InventoryService.instance.updateStock(
                          productId: product.id,
                          quantity: qty,
                          lowStockAt: lowStockAt,
                        );
                        if (!mounted) return;
                        setState(() {
                          final idx = _products.indexWhere(
                            (p) => p.id == product.id,
                          );
                          if (idx != -1) {
                            _products[idx] = product.copyWith(
                              stockQuantity: qty,
                              lowStockAt: lowStockAt,
                            );
                          }
                        });
                        Navigator.pop(context);
                      } catch (e) {
                        setDialogState(() => saving = false);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              e.toString().replaceFirst('Exception: ', ''),
                            ),
                          ),
                        );
                      }
                    },
              child: saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
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

    final products = _filtered;
    final lowStockCount = _products.where((p) => p.isLowStock).length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: AppSearchField(
            hint: 'Search products',
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              FilterChip(
                label: Text('Low stock only ($lowStockCount)'),
                selected: _lowStockOnly,
                onSelected: (v) => setState(() => _lowStockOnly = v),
                showCheckmark: false,
                avatar: Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: _lowStockOnly ? AppColors.warning : AppColors.inkFaint,
                ),
                selectedColor: AppColors.warning.withValues(alpha: 0.12),
                labelStyle: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: _lowStockOnly ? AppColors.warning : AppColors.inkSoft,
                ),
                side: BorderSide(
                  color: _lowStockOnly
                      ? AppColors.warning.withValues(alpha: 0.4)
                      : AppColors.border,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: products.isEmpty
                ? ListView(
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(top: 80),
                        child: EmptyState(
                          icon: Icons.warehouse_rounded,
                          title: 'Nothing to show',
                          subtitle: 'Every product is comfortably stocked.',
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final p = products[i];
                      final statusColor = p.isOutOfStock
                          ? AppColors.danger
                          : (p.isLowStock
                                ? AppColors.warning
                                : const Color(0xFF15803D));
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        width: 7,
                                        height: 7,
                                        decoration: BoxDecoration(
                                          color: statusColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        p.isOutOfStock
                                            ? 'Out of stock'
                                            : '${p.stockQuantity} units · alert at ${p.lowStockAt}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: statusColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () => _editStock(p),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                              ),
                              child: const Text(
                                'Update',
                                style: TextStyle(fontSize: 12.5),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
