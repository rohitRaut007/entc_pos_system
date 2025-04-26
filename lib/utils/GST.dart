/// GST Utilities for calculation
class GstUtils {
  /// Round off a value to the nearest integer
  static double roundOff(double value) {
    return double.parse(value.toStringAsFixed(0));
  }

  /// Calculate GST amount from total
  static double calculateGstAmount({
    required double price,
    required int quantity,
    required double gstRate,
  }) {
    final total = price * quantity;
    final gstAmount = total * gstRate / 100;
    return roundOff(gstAmount);
  }

  /// Get total with GST included
  static double calculateTotalWithGst({
    required double price,
    required int quantity,
    required double gstRate,
  }) {
    final total = price * quantity;
    final gstAmount = calculateGstAmount(
      price: price,
      quantity: quantity,
      gstRate: gstRate,
    );
    return roundOff(total + gstAmount);
  }

  /// Split GST into CGST and SGST (equal halves)
  static Map<String, double> splitCgstSgst(double gstAmount) {
    final cgst = roundOff(gstAmount / 2);
    final sgst = roundOff(gstAmount / 2);
    return {
      'cgst': cgst,
      'sgst': sgst,
    };
  }

  /// Format GST rate (e.g., 18.0 → "18%")
  static String formatGstRate(double gstRate) {
    return "${gstRate.toStringAsFixed(0)}%";
  }
}
