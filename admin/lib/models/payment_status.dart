enum PaymentStatus { cod, pending, paid, failed, refunded }

extension PaymentStatusX on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.cod:
        return 'Cash on delivery';
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  String get apiValue {
    switch (this) {
      case PaymentStatus.cod:
        return 'COD';
      case PaymentStatus.pending:
        return 'PENDING';
      case PaymentStatus.paid:
        return 'PAID';
      case PaymentStatus.failed:
        return 'FAILED';
      case PaymentStatus.refunded:
        return 'REFUNDED';
    }
  }
}

/// Since only COD is supported today, this defaults to [PaymentStatus.cod]
/// if the backend omits the field or sends something unrecognized.
PaymentStatus paymentStatusFromApi(String? value) {
  switch (value?.toUpperCase()) {
    case 'COD':
      return PaymentStatus.cod;
    case 'PENDING':
      return PaymentStatus.pending;
    case 'PAID':
      return PaymentStatus.paid;
    case 'FAILED':
      return PaymentStatus.failed;
    case 'REFUNDED':
      return PaymentStatus.refunded;
    default:
      return PaymentStatus.cod;
  }
}