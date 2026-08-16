import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/category.dart';
import 'api_config.dart';

/// Handles all category CRUD calls, mirroring AuthService's
/// { success, message, data } response handling.
class CategoryService {
  CategoryService._();
  static final CategoryService instance = CategoryService._();

  Future<List<Category>> getAll() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.categories),
        headers: await ApiConfig.authHeaders(),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final success = body['success'] as bool? ?? false;
      final message = body['message'] as String? ?? 'Something went wrong';

      if (response.statusCode < 200 || response.statusCode >= 300 || !success) {
        throw Exception(message);
      }

      final data = body['data'] as List<dynamic>? ?? [];
      return data.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Could not load categories: $e');
    }
  }

  Future<Category> create({
    required String name,
    required String description,
    required bool isActive,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.categories),
        headers: await ApiConfig.authHeaders(),
        body: jsonEncode({
          'name': name,
          'description': description,
          'isActive': isActive,
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
      return Category.fromJson(data);
    } catch (e) {
      throw Exception('Could not create category: $e');
    }
  }

  Future<Category> update({
    required int id,
    required String name,
    required String description,
    required bool isActive,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.categoryById(id)),
        headers: await ApiConfig.authHeaders(),
        body: jsonEncode({
          'name': name,
          'description': description,
          'isActive': isActive,
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
      return Category.fromJson(data);
    } catch (e) {
      throw Exception('Could not update category: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.categoryById(id)),
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
      throw Exception('Could not delete category: $e');
    }
  }
}