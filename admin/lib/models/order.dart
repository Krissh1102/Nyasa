import 'order_item.dart';
import 'order_status.dart';
import 'order_status_event.dart';
import 'payment_status.dart';

class Order {
  final int id;
  final String customerName;
  final String phoneNumber;
  final String address;
  final double totalAmount;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final List<OrderLineItem> items;
  final List<OrderStatusEvent> history;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.customerName,
    required this.phoneNumber,
    required this.address,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    required this.items,
    required this.history,
    required this.createdAt,
  });

  Order copyWith({OrderStatus? status, List<OrderStatusEvent>? history}) {
    return Order(
      id: id,
      customerName: customerName,
      phoneNumber: phoneNumber,
      address: address,
      totalAmount: totalAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus,
      items: items,
      history: history ?? this.history,
      createdAt: createdAt,
    );
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: (json['id'] as num).toInt(),
      customerName: json['customerName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      address: json['address'] as String? ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      status: orderStatusFromApi(json['status'] as String?),
      paymentStatus: paymentStatusFromApi(json['paymentStatus'] as String?),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => OrderLineItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      history: (json['history'] as List<dynamic>? ?? [])
          .map((e) => OrderStatusEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}