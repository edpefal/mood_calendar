enum PurchaseFailureReason { cancelled, network, productUnavailable, unknown }

class PurchaseException implements Exception {
  final PurchaseFailureReason reason;

  const PurchaseException(this.reason);

  @override
  String toString() => 'PurchaseException($reason)';
}
