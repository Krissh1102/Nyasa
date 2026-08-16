import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/product.dart';
import 'api_config.dart';

/// Handles all product CRUD calls, mirroring CategoryService's
/// { success, message, data } response handling.
class ProductService {
  ProductService._();
  static final ProductService instance = ProductService._();

  Future<List<Product>> getAll() async {
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

      final data = body['data'] as Map<String, dynamic>?;
      final content = data?['content'] as List<dynamic>? ?? [];
      return content
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Could not load products: $e');
    }
  }

  Future<Product> create({
    required String name,
    required String description,
    required double price,
    required int categoryId,
    required List<String> imageUrl,
    required bool isActive,
    required int initialQuantity,
    required int lowStockAt,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.products),
        headers: await ApiConfig.authHeaders(),
        body: jsonEncode({
          'name': name,
          'description': description,
          'price': price,
          'categoryId': categoryId,
          'imageUrl': imageUrl,
          'isActive': isActive,
          'initialQuantity': initialQuantity,
          'lowStockAt': lowStockAt,
        }),
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
      throw Exception('Could not create product: $e');
    }
  }

  // TODO: confirm the update endpoint expects the same field names as
  // create (in particular "initialQuantity" vs. something like "quantity").
  Future<Product> update({
    required int id,
    required String name,
    required String description,
    required double price,
    required int categoryId,
    required List<String> imageUrl,
    required bool isActive,
    required int initialQuantity,
    required int lowStockAt,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.productById(id)),
        headers: await ApiConfig.authHeaders(),
        body: jsonEncode({
          'name': name,
          'description': description,
          'price': price,
          'categoryId': categoryId,
          'imageUrl': imageUrl,
          'isActive': isActive,
          'initialQuantity': initialQuantity,
          'lowStockAt': lowStockAt,
        }),
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
      throw Exception('Could not update product: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.productById(id)),
        headers: await ApiConfig.authHeaders(),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        var message = 'Something went wrong';
        try {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          message = body['message'] as String? ?? message;
        } catch (_) {}
        throw Exception(message);
      }
    } catch (e) {
      throw Exception('Could not delete product: $e');
    }
  }

  /// Uploads a single local image file and returns its hosted URL.
  /// TODO: adjust the response-parsing key ("url") to match your endpoint.
  Future<String> uploadImage(File file) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.upload),
      );
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Image upload failed (${response.statusCode})');
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final url = body['url'] as String?;
      if (url == null) throw Exception('Upload response missing "url"');
      return url;
    } catch (e) {
      throw Exception('Could not upload image: $e');
    }
  }
}
