import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';
import 'api_config.dart';

class InventoryService {
  InventoryService._();
  static final InventoryService instance = InventoryService._();

  /// Loads the full product list (includes current stock/lowStockAt).
  Future<List<Product>> getAllProducts() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.products),
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
        data = (rawData['content'] as List<dynamic>?) ?? [];
      } else {
        data = [];
      }

      return data.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Could not load products: $e');
    }
  }

  Future<Product> getOne(int productId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.adminInventoryById(productId)),
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
      return Product.fromJson(data);
    } catch (e) {
      throw Exception('Could not load product: $e');
    }
  }


  
Future<void> updateStock({
  required int productId,
  required int quantity,
  required int lowStockAt,
}) async {
  try {
    final response = await http.put(
      Uri.parse(ApiConfig.adminInventoryById(productId)),
      headers: await ApiConfig.authHeaders(),
      body: jsonEncode({
        'quantity': quantity,
        'lowStockAt': lowStockAt,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final success = body['success'] as bool? ?? false;
    final message = body['message'] as String? ?? 'Something went wrong';

    if (response.statusCode < 200 || response.statusCode >= 300 || !success) {
      throw Exception(message);
    }
  } catch (e) {
    throw Exception('Could not update stock: $e');
  }

  }
}