import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/product.dart';
import 'api_config.dart';

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
    required int weightGrams,
    required int categoryId,
    required List<String> imageUrls,
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
          'weightGrams': weightGrams,
          'categoryId': categoryId,
          'imageUrls': imageUrls,
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

  Future<Product> update({
    required int id,
    required String name,
    required String description,
    required double price,
    required int weightGrams,
    required int categoryId,
    required List<String> imageUrls,
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
          'weightGrams': weightGrams,
          'categoryId': categoryId,
          'imageUrls': imageUrls,
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

  Future<String> uploadImage(File file) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.upload),
      );

      request.headers.addAll(await ApiConfig.authHeaders());

      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Image upload failed (${response.statusCode})');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      final success = body['success'] as bool? ?? false;

      if (!success) {
        throw Exception(body['message'] as String? ?? 'Image upload failed');
      }

      // Your Spring Boot ApiResponse puts the Cloudinary URL in "data"
      final imageUrl = body['data'] as String?;

      if (imageUrl == null || imageUrl.isEmpty) {
        throw Exception('Upload response missing "data"');
      }

      return imageUrl;
    } catch (e) {
      throw Exception('Could not upload image: $e');
    }
  }

  /// Uploads multiple local image files in parallel and returns their
  /// hosted URLs in the same order as [files].
  Future<List<String>> uploadImages(List<File> files) async {
    if (files.isEmpty) return [];
    final futures = files.map(uploadImage);
    return Future.wait(futures);
  }
}
