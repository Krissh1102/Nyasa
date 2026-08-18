class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int weightGrams;
  final int categoryId;
  final String categoryName;
  final List<String> imageUrls;
  final bool isActive;
  final int stockQuantity;
  final int lowStockAt;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.weightGrams = 0,
    required this.categoryId,
    required this.categoryName,
    required this.imageUrls,
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
      weightGrams: (json['weightGrams'] as num?)?.toInt() ?? 0,
      categoryId: (json['categoryId'] as num?)?.toInt() ?? 0,
      categoryName: json['categoryName'] as String? ?? '',
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isActive: json['isActive'] as bool? ?? true,
      stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 0,
      lowStockAt: (json['lowStockAt'] as num?)?.toInt() ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'weightGrams': weightGrams,
      'categoryId': categoryId,
      'imageUrls': imageUrls,
      'isActive': isActive,
      'stockQuantity': stockQuantity,
      'lowStockAt': lowStockAt,
    };
  }

  Product copyWith({
    String? name,
    String? description,
    double? price,
    int? weightGrams,
    int? categoryId,
    String? categoryName,
    List<String>? imageUrls,
    bool? isActive,
    int? stockQuantity,
    int? lowStockAt,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      weightGrams: weightGrams ?? this.weightGrams,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      imageUrls: imageUrls ?? this.imageUrls,
      isActive: isActive ?? this.isActive,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockAt: lowStockAt ?? this.lowStockAt,
    );
  }
}