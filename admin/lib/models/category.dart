class Category {
  final int id;
  final String name;
  final String description;
  final bool isActive;

  const Category({
    required this.id,
    required this.name,
    required this.description,
    this.isActive = true,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Body shape for POST/PUT — matches the endpoints you gave (no id).
  Map<String, dynamic> toRequestJson() => {
    'name': name,
    'description': description,
    'isActive': isActive,
  };

  Category copyWith({String? name, String? description, bool? isActive}) {
    return Category(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }
}
