import 'package:flutter/material.dart';

import '../models/admin.dart';
import '../models/category.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/order_status.dart';
import '../models/order_status_event.dart';
import '../models/payment_status.dart';
import '../models/product.dart';
import '../models/trending_item.dart';

/// Static, in-memory data for a jewellery store admin app. Nothing here
/// talks to a network — swap this out once the backend is wired up.
class MockData {
  static final admin = const AdminUser(
    name: 'Ananya Rao',
    email: 'admin@aurajewels.com',
    role: AdminRole.superAdmin,
  );

  static const storeName = 'Aura Jewels';

  static final categories = <Category>[
    const Category(id: 1, name: 'Rings', description: 'Engagement, solitaire & statement rings'),
    const Category(id: 2, name: 'Necklaces', description: 'Gold, kundan & temple necklaces'),
    const Category(id: 3, name: 'Earrings', description: 'Studs, drops & jhumkas'),
    const Category(id: 4, name: 'Bracelets', description: 'Tennis, chain & charm bracelets'),
    const Category(id: 5, name: 'Bangles', description: 'Gold & rose gold bangle sets'),
    const Category(id: 6, name: 'Pendants', description: 'Gemstone & solitaire pendants', isActive: false),
  ];

  /// Simple category -> icon mapping used in place of product photos.
  static IconData iconForCategory(String categoryName) {
    switch (categoryName) {
      case 'Rings':
        return Icons.diamond_outlined;
      case 'Necklaces':
        return Icons.workspace_premium_outlined;
      case 'Earrings':
        return Icons.auto_awesome_outlined;
      case 'Bracelets':
        return Icons.watch_outlined;
      case 'Bangles':
        return Icons.circle_outlined;
      case 'Pendants':
        return Icons.diamond_outlined;
      default:
        return Icons.diamond_outlined;
    }
  }

  static final products = <Product>[
    const Product(id: 1, name: 'Solitaire Diamond Ring', description: '18K white gold, VVS1 clarity centre stone', price: 45000, categoryId: 1, categoryName: 'Rings', stockQuantity: 12, lowStockAt: 5),
    const Product(id: 2, name: 'Gold Kundan Necklace', description: '22K gold, handcrafted kundan work', price: 68500, categoryId: 2, categoryName: 'Necklaces', stockQuantity: 5, lowStockAt: 4),
    const Product(id: 3, name: 'Pearl Drop Earrings', description: 'Freshwater pearls, sterling silver hooks', price: 8200, categoryId: 3, categoryName: 'Earrings', stockQuantity: 34, lowStockAt: 10),
    const Product(id: 4, name: 'Rose Gold Bangle Set', description: 'Set of 2, 18K rose gold finish', price: 21500, categoryId: 5, categoryName: 'Bangles', stockQuantity: 3, lowStockAt: 6),
    const Product(id: 5, name: 'Emerald Halo Pendant', description: 'Natural emerald with diamond halo', price: 15600, categoryId: 6, categoryName: 'Pendants', stockQuantity: 0, lowStockAt: 4),
    const Product(id: 6, name: 'Sapphire Tennis Bracelet', description: 'Blue sapphire line bracelet, 14K gold', price: 32000, categoryId: 4, categoryName: 'Bracelets', stockQuantity: 9, lowStockAt: 5),
    const Product(id: 7, name: 'Antique Temple Necklace', description: 'Temple-style choker, antique gold plating', price: 54000, categoryId: 2, categoryName: 'Necklaces', stockQuantity: 6, lowStockAt: 5),
    const Product(id: 8, name: 'Diamond Stud Earrings', description: 'Classic 4-prong diamond studs', price: 12800, categoryId: 3, categoryName: 'Earrings', stockQuantity: 40, lowStockAt: 12),
    const Product(id: 9, name: 'Gold Chain Bracelet', description: '18K gold figaro chain bracelet', price: 18700, categoryId: 4, categoryName: 'Bracelets', stockQuantity: 2, lowStockAt: 6),
    const Product(id: 10, name: 'Ruby Halo Ring', description: 'Burmese ruby with diamond halo setting', price: 39500, categoryId: 1, categoryName: 'Rings', stockQuantity: 14, lowStockAt: 5),
  ];

  static final orders = <Order>[
    Order(
      id: 5042,
      customerName: 'Riya Mehta',
      phoneNumber: '+91 98765 43210',
      address: '204, Sunrise Apartments, Baner Road, Pune, Maharashtra 411045',
      totalAmount: 45000,
      status: OrderStatus.outForDelivery,
      paymentStatus: PaymentStatus.paid,
      items: const [
        OrderLineItem(productId: 1, productName: 'Solitaire Diamond Ring', quantity: 1, price: 45000),
      ],
      history: [
        OrderStatusEvent(status: OrderStatus.pending, changedBy: 'SYSTEM', createdAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 40))),
        OrderStatusEvent(status: OrderStatus.confirmed, changedBy: 'admin@aurajewels.com', createdAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 20))),
        OrderStatusEvent(status: OrderStatus.packed, changedBy: 'admin@aurajewels.com', createdAt: DateTime.now().subtract(const Duration(hours: 2))),
        OrderStatusEvent(status: OrderStatus.outForDelivery, changedBy: 'admin@aurajewels.com', createdAt: DateTime.now().subtract(const Duration(minutes: 45))),
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 40)),
    ),
    Order(
      id: 5041,
      customerName: 'John Smith',
      phoneNumber: '+91 90210 11223',
      address: 'Flat 12B, Green Meadows, Kothrud, Pune, Maharashtra 411038',
      totalAmount: 10000,
      status: OrderStatus.pending,
      paymentStatus: PaymentStatus.cod,
      items: const [
        OrderLineItem(productId: 3, productName: 'Pearl Drop Earrings', quantity: 1, price: 8200),
        OrderLineItem(productId: 8, productName: 'Diamond Stud Earrings', quantity: 1, price: 1800),
      ],
      history: [
        OrderStatusEvent(status: OrderStatus.pending, changedBy: 'SYSTEM', createdAt: DateTime(2024, 8, 21)),
      ],
      createdAt: DateTime(2024, 8, 21),
    ),
    Order(
      id: 5040,
      customerName: 'Adam James',
      phoneNumber: '+91 99887 65544',
      address: 'B-7, Om Society, Aundh, Pune, Maharashtra 411007',
      totalAmount: 8500,
      status: OrderStatus.confirmed,
      paymentStatus: PaymentStatus.cod,
      items: const [
        OrderLineItem(productId: 9, productName: 'Gold Chain Bracelet', quantity: 1, price: 8500),
      ],
      history: [
        OrderStatusEvent(status: OrderStatus.pending, changedBy: 'SYSTEM', createdAt: DateTime(2024, 8, 21)),
        OrderStatusEvent(status: OrderStatus.confirmed, changedBy: 'admin@aurajewels.com', createdAt: DateTime(2024, 8, 21)),
      ],
      createdAt: DateTime(2024, 8, 21),
    ),
    Order(
      id: 5039,
      customerName: 'Clara David',
      phoneNumber: '+91 91234 56789',
      address: '15, Lake View Residency, Wakad, Pune, Maharashtra 411057',
      totalAmount: 14000,
      status: OrderStatus.delivered,
      paymentStatus: PaymentStatus.paid,
      items: const [
        OrderLineItem(productId: 6, productName: 'Sapphire Tennis Bracelet', quantity: 1, price: 14000),
      ],
      history: [
        OrderStatusEvent(status: OrderStatus.pending, changedBy: 'SYSTEM', createdAt: DateTime(2024, 8, 20)),
        OrderStatusEvent(status: OrderStatus.confirmed, changedBy: 'admin@aurajewels.com', createdAt: DateTime(2024, 8, 20)),
        OrderStatusEvent(status: OrderStatus.packed, changedBy: 'admin@aurajewels.com', createdAt: DateTime(2024, 8, 20)),
        OrderStatusEvent(status: OrderStatus.outForDelivery, changedBy: 'admin@aurajewels.com', createdAt: DateTime(2024, 8, 20)),
        OrderStatusEvent(status: OrderStatus.delivered, changedBy: 'admin@aurajewels.com', createdAt: DateTime(2024, 8, 20)),
      ],
      createdAt: DateTime(2024, 8, 20),
    ),
    Order(
      id: 5038,
      customerName: 'Emily John',
      phoneNumber: '+91 98123 44556',
      address: '9, Pearl Heights, Viman Nagar, Pune, Maharashtra 411014',
      totalAmount: 12300,
      status: OrderStatus.cancelled,
      paymentStatus: PaymentStatus.failed,
      items: const [
        OrderLineItem(productId: 4, productName: 'Rose Gold Bangle Set', quantity: 1, price: 12300),
      ],
      history: [
        OrderStatusEvent(status: OrderStatus.pending, changedBy: 'SYSTEM', createdAt: DateTime(2024, 8, 19)),
        OrderStatusEvent(status: OrderStatus.cancelled, changedBy: 'admin@aurajewels.com', createdAt: DateTime(2024, 8, 19)),
      ],
      createdAt: DateTime(2024, 8, 19),
    ),
  ];

  static final trendingItems = <TrendingItem>[
    TrendingItem(name: 'Solitaire Diamond Ring', subtitle: 'Rings', icon: Icons.diamond_outlined, salesCount: 383, changePercent: 12),
    TrendingItem(name: 'Antique Temple Necklace', subtitle: 'Necklaces', icon: Icons.workspace_premium_outlined, salesCount: 144, changePercent: -9),
    TrendingItem(name: 'Pearl Drop Earrings', subtitle: 'Earrings', icon: Icons.auto_awesome_outlined, salesCount: 268, changePercent: 6),
    TrendingItem(name: 'Sapphire Tennis Bracelet', subtitle: 'Bracelets', icon: Icons.watch_outlined, salesCount: 97, changePercent: -3),
  ];

  // ---- Chart series (mock, matching the shapes in the reference design) ----

  static const chartDayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  static const revenuePink = [25.0, 33.0, 46.0, 30.0, 22.0, 55.0, 40.0];
  static const revenueBlack = [40.0, 22.0, 35.0, 25.0, 42.0, 30.0, 55.0];

  static const analyticsBack = [18.0, 45.0, 30.0, 22.0, 52.0, 28.0, 20.0];
  static const analyticsFront = [15.0, 32.0, 22.0, 18.0, 38.0, 20.0, 16.0];

  static const orderBarLabels = ['Aug 19', 'Aug 20', 'Aug 21', 'Aug 22'];
  static const orderBarGroups = [
    [45.0, 40.0, 30.0],
    [30.0, 32.0, 34.0],
    [30.0, 55.0, 43.0],
    [30.0, 38.0, 45.0],
  ];

  // ---- Derived stats ----

  static double get totalSales => products.fold(0.0, (sum, p) => sum + p.price * 3);

  static List<Product> get lowStockProducts =>
      products.where((p) => p.isActive && p.isLowStock).toList();

  static double get todayRevenue =>
      orders.where((o) => o.status != OrderStatus.cancelled).fold(0.0, (sum, o) => sum + o.totalAmount);

  static int get pendingOrderCount =>
      orders.where((o) => o.status == OrderStatus.pending).length;

  static const totalClients = 150;
}
