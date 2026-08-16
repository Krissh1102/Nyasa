import 'order_status.dart';

class OrderStatusEvent {
  final OrderStatus status;
  final String changedBy;
  final DateTime createdAt;

  const OrderStatusEvent({
    required this.status,
    required this.changedBy,
    required this.createdAt,
  });

  factory OrderStatusEvent.fromJson(Map<String, dynamic> json) {
    return OrderStatusEvent(
      status: orderStatusFromApi(json['status'] as String?),
      changedBy: json['changedBy'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}