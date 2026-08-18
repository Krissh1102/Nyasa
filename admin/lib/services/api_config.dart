import 'auth_service.dart';

/// Centralized API configuration.
///
/// Update `baseUrl` to point at your real backend. Everything else is
/// derived from it so you only ever change one line.
class ApiConfig {
  ApiConfig._();

  // TODO: replace with your real backend URL.
  static const String baseUrl = 'http://localhost:8080';

  // TODO: adjust to your real login route if it differs.
  static const String login = '$baseUrl/api/admin/auth/login';
  

  static const String products = '$baseUrl/api/products';
  static const String categories = '$baseUrl/api/categories';
  static String categoryById(int id) => '$categories/$id';
  
  static const String adminOrders = '$baseUrl/api/admin/orders';
  static String adminOrderById(int id) => '$adminOrders/$id';
  static String adminOrderStatus(int id) => '$adminOrders/$id/status';
  static const String adminInventory = '$baseUrl/api/admin/inventory';
  static String adminInventoryById(int productId) =>
      '$adminInventory/$productId';

  // TODO: replace with your real image-upload endpoint. It should accept a
  // multipart file under the field name "file" and return the hosted URL
  // (adjust the response-parsing key in add_item_screen.dart to match).
 static String get upload => '$baseUrl/api/images';
  static String productById(int id) => '$products/$id';

  /// Headers for unauthenticated JSON requests (e.g. the login call itself).
  static Map<String, String> get jsonHeaders => const {
    'Content-Type': 'application/json',
  };

  /// Headers for authenticated JSON requests. Pulls the stored token (and
  /// its tokenType, e.g. "Bearer") from [AuthService] so every screen gets
  /// the current session automatically.
  static Future<Map<String, String>> authHeaders() async {
    final session = await AuthService.instance.getSession();
    final headers = {...jsonHeaders};
    if (session != null) {
      headers['Authorization'] = '${session.tokenType} ${session.token}';
    }
    return headers;
  }
}
