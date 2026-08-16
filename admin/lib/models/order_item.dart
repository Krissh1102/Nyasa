class OrderLineItem {
  final int productId;
  final String productName;
  final int quantity;
  final double price; // price at time of purchase

  const OrderLineItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  double get lineTotal => price * quantity;

  factory OrderLineItem.fromJson(Map<String, dynamic> json) {
    return OrderLineItem(
      productId: (json['productId'] as num).toInt(),
      productName: json['productName'] as String? ?? '',
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
    );
  }
}