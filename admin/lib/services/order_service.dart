import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/order.dart';
import 'api_config.dart';

class OrderService {
  OrderService._();
  static final OrderService instance = OrderService._();
  Future<List<Order>> getAll() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.adminOrders),
        headers: await ApiConfig.authHeaders(),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final success = body['success'] as bool? ?? false;
      final message = body['message'] as String? ?? 'Something went wrong';

      if (response.statusCode < 200 || response.statusCode >= 300 || !success) {
        throw Exception(message);
      }

      final rawData = body['data'];
      late List<dynamic> data;

      if (rawData is List) {
        data = rawData;
      } else if (rawData is Map<String, dynamic>) {
        // Paginated response, e.g. Spring's Page<T> -> { content, totalElements, ... }
        data = (rawData['content'] as List<dynamic>?) ?? [];
      } else {
        data = [];
      }

      return data
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Could not load orders: $e');
    }
  }

  Future<Order> getById(int id) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.adminOrderById(id)),
        headers: await ApiConfig.authHeaders(),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final success = body['success'] as bool? ?? false;
      final message = body['message'] as String? ?? 'Something went wrong';

      if (response.statusCode < 200 || response.statusCode >= 300 || !success) {
        throw Exception(message);
      }

      final data = body['data'] as Map<String, dynamic>?;
      if (data == null) throw Exception('Malformed response from server');
      return Order.fromJson(data);
    } catch (e) {
      throw Exception('Could not load order: $e');
    }
  }

  Future<Order> updateStatus(int id, OrderStatusValue status) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.adminOrderStatus(id)),
        headers: await ApiConfig.authHeaders(),
        body: jsonEncode({'status': status.apiValue}),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final success = body['success'] as bool? ?? false;
      final message = body['message'] as String? ?? 'Something went wrong';

      if (response.statusCode < 200 || response.statusCode >= 300 || !success) {
        throw Exception(message);
      }

      final data = body['data'] as Map<String, dynamic>?;
      if (data == null) throw Exception('Malformed response from server');
      return Order.fromJson(data);
    } catch (e) {
      throw Exception('Could not update order status: $e');
    }
  }
}

// Type alias so this file doesn't need to import order_status.dart's enum
// under a different name — just re-exported for clarity at call sites.
typedef OrderStatusValue = dynamic;
