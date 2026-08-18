import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../services/category_service.dart';
import '../../services/product_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_search_field.dart';
import '../../widgets/empty_state.dart';
import 'product_form_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _query = '';
  int? _categoryFilter;

  bool _loading = true;
  String? _error;
  List<Product> _products = [];
  List<Category> _categories = [];

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
        CategoryService.instance.getAll(),
      ]);
      if (!mounted) return;
      setState(() {
        _products = results[0] as List<Product>;
        _categories = results[1] as List<Category>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<Product> get _filtered {
    return _products.where((p) {
      final matchesCategory =
          _categoryFilter == null || p.categoryId == _categoryFilter;
      final q = _query.trim().toLowerCase();
      final matchesQuery = q.isEmpty || p.name.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void _openForm({Product? product}) async {
    final result = await Navigator.of(context).push<Object>(
      MaterialPageRoute(builder: (_) => ProductFormScreen(product: product)),
    );
    if (result == null) return;

    setState(() {
      if (result is Product) {
        final idx = _products.indexWhere((p) => p.id == result.id);
        if (idx == -1) {
          _products.insert(0, result);
        } else {
          _products[idx] = result;
        }
      } else if (result is int) {
        // Product was deleted; result is its id.
        _products.removeWhere((p) => p.id == result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _openForm(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add product', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _products.isEmpty) {
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

    final products = _filtered;

    return RefreshIndicator(
      onRefresh: _load,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: AppSearchField(
              hint: 'Search products',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _CategoryChip(
                  label: 'All',
                  selected: _categoryFilter == null,
                  onTap: () => setState(() => _categoryFilter = null),
                ),
                for (final c in _categories.where((c) => c.isActive))
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _CategoryChip(
                      label: c.name,
                      selected: _categoryFilter == c.id,
                      onTap: () => setState(() => _categoryFilter = c.id),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: products.isEmpty
                ? ListView(
                    // Wrapped in a scrollable so pull-to-refresh still works
                    // when the filtered/empty state is showing.
                    children: const [
                      SizedBox(height: 80),
                      EmptyState(
                        icon: Icons.inventory_2_rounded,
                        title: 'No products found',
                        subtitle: 'Try a different search or category filter.',
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _ProductCard(
                      product: products[i],
                      onTap: () => _openForm(product: products[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: AppColors.primaryLight,
      labelStyle: TextStyle(
        fontSize: 12.5,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        color: selected ? AppColors.primary : AppColors.inkSoft,
      ),
      side: BorderSide(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.4)
            : AppColors.border,
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
            Container(
  width: 52,
  height: 52,
  decoration: BoxDecoration(
    color: AppColors.background,
    borderRadius: BorderRadius.circular(12),
  ),
  clipBehavior: Clip.antiAlias,
  child: product.imageUrls.isNotEmpty
      ? Image.network(
          product.imageUrls.first,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.shopping_bag_outlined,
            color: AppColors.inkFaint,
          ),
        )
      : const Icon(
          Icons.shopping_bag_outlined,
          color: AppColors.inkFaint,
        ),
),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        if (!product.isActive)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Inactive',
                              style: TextStyle(
                                fontSize: 9.5,
                                color: AppColors.inkFaint,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      product.categoryName,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.inkFaint,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '₹${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          product.isOutOfStock
                              ? Icons.error_rounded
                              : (product.isLowStock
                                    ? Icons.warning_amber_rounded
                                    : Icons.check_circle_rounded),
                          size: 13,
                          color: product.isOutOfStock
                              ? AppColors.danger
                              : (product.isLowStock
                                    ? AppColors.warning
                                    : const Color(0xFF15803D)),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          product.isOutOfStock
                              ? 'Out of stock'
                              : '${product.stockQuantity} in stock',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: product.isOutOfStock
                                ? AppColors.danger
                                : (product.isLowStock
                                      ? AppColors.warning
                                      : AppColors.inkSoft),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.inkFaint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
