class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int categoryId;
  final String categoryName;
  final String? imageUrl;
  final bool isActive;
  final int stockQuantity;
  final int lowStockAt;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.categoryName,
    this.imageUrl,
    this.isActive = true,
    required this.stockQuantity,
    this.lowStockAt = 5,
  });

  bool get isLowStock => stockQuantity <= lowStockAt;
  bool get isOutOfStock => stockQuantity <= 0;
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      categoryId: (json['categoryId'] as num?)?.toInt() ?? 0,
      categoryName: json['categoryName'] as String? ?? '',
      imageUrl: _parseImageUrl(json['imageUrl']),
      isActive: json['isActive'] as bool? ?? true,
      stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 0,
      lowStockAt: (json['lowStockAt'] as num?)?.toInt() ?? 5,
    );
  }

  static String? _parseImageUrl(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) return raw.isEmpty ? null : raw;
    if (raw is List) {
      return raw.isNotEmpty ? raw.first as String? : null;
    }
    return null;
  }

  Product copyWith({
    String? name,
    String? description,
    double? price,
    int? categoryId,
    String? categoryName,
    String? imageUrl,
    bool? isActive,
    int? stockQuantity,
    int? lowStockAt,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockAt: lowStockAt ?? this.lowStockAt,
    );
  }
}
