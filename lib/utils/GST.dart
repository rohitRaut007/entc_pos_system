/// GST Utilities for calculation
class GstUtils {
  /// Calculate GST amount from total
  static double calculateGstAmount({
    required double price,
    required int quantity,
    required double gstRate,
  }) {
    final total = price * quantity;
    return total * gstRate / 100;
  }

  /// Get total with GST included
  static double calculateTotalWithGst({
    required double price,
    required int quantity,
    required double gstRate,
  }) {
    final total = price * quantity;
    return total + calculateGstAmount(
      price: price,
      quantity: quantity,
      gstRate: gstRate,
    );
  }

  /// Split GST into CGST and SGST (equal halves)
  static Map<String, double> splitCgstSgst(double gstAmount) {
    return {
      'cgst': gstAmount / 2,
      'sgst': gstAmount / 2,
    };
  }

  /// Format GST rate (e.g., 18.0 → "18%")
  static String formatGstRate(double gstRate) {
    return "${gstRate.toStringAsFixed(0)}%";
  }
}
