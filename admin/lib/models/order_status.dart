import 'package:flutter/material.dart';

enum OrderStatus {
  pending,
  confirmed,
  packed,
  outForDelivery,
  delivered,
  cancelled,
}

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.packed:
        return 'Packed';
      case OrderStatus.outForDelivery:
        return 'Out for delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return const Color(0xFFB78103);
      case OrderStatus.confirmed:
        return const Color(0xFF2563EB);
      case OrderStatus.packed:
        return const Color(0xFF7C3AED);
      case OrderStatus.outForDelivery:
        return const Color(0xFFEA580C);
      case OrderStatus.delivered:
        return const Color(0xFF15803D);
      case OrderStatus.cancelled:
        return const Color(0xFFDC2626);
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.pending:
        return Icons.schedule_rounded;
      case OrderStatus.confirmed:
        return Icons.task_alt_rounded;
      case OrderStatus.packed:
        return Icons.inventory_2_rounded;
      case OrderStatus.outForDelivery:
        return Icons.local_shipping_rounded;
      case OrderStatus.delivered:
        return Icons.check_circle_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  /// The statuses that can be moved to next, in order. Empty once terminal.
  List<OrderStatus> get nextOptions {
    switch (this) {
      case OrderStatus.pending:
        return [OrderStatus.confirmed, OrderStatus.cancelled];
      case OrderStatus.confirmed:
        return [OrderStatus.packed, OrderStatus.cancelled];
      case OrderStatus.packed:
        return [OrderStatus.outForDelivery, OrderStatus.cancelled];
      case OrderStatus.outForDelivery:
        return [OrderStatus.delivered];
      case OrderStatus.delivered:
        return [];
      case OrderStatus.cancelled:
        return [];
    }
  }

  /// The string sent to / received from the backend, e.g. "OUT_FOR_DELIVERY".
  String get apiValue {
    switch (this) {
      case OrderStatus.pending:
        return 'PENDING';
      case OrderStatus.confirmed:
        return 'CONFIRMED';
      case OrderStatus.packed:
        return 'PACKED';
      case OrderStatus.outForDelivery:
        return 'OUT_FOR_DELIVERY';
      case OrderStatus.delivered:
        return 'DELIVERED';
      case OrderStatus.cancelled:
        return 'CANCELLED';
    }
  }
}

/// Parses the backend's status string (e.g. "PENDING", "OUT_FOR_DELIVERY")
/// into an [OrderStatus]. Defaults to [OrderStatus.pending] if unrecognized.
OrderStatus orderStatusFromApi(String? value) {
  switch (value?.toUpperCase()) {
    case 'PENDING':
      return OrderStatus.pending;
    case 'CONFIRMED':
      return OrderStatus.confirmed;
    case 'PACKED':
      return OrderStatus.packed;
    case 'OUT_FOR_DELIVERY':
      return OrderStatus.outForDelivery;
    case 'DELIVERED':
      return OrderStatus.delivered;
    case 'CANCELLED':
      return OrderStatus.cancelled;
    default:
      return OrderStatus.pending;
  }
}
