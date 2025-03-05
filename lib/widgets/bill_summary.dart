import 'package:flutter/material.dart';
import '../models/sales.dart';
import '../services/hive_services.dart';

class BillSummary extends StatefulWidget {
  final double total;
  final String customerName = 'rr';
  final List<Map<String, dynamic>> orderItems;
  final VoidCallback onOrderCompleted; // Callback for real-time updates

  const BillSummary({
    super.key,
    required this.total,
    // required this.customerName,
    required this.orderItems,
    required this.onOrderCompleted,
  });

  @override
  State<BillSummary> createState() => _BillSummaryState();
}

class _BillSummaryState extends State<BillSummary> {
  bool isPrinting = false;

  Future<void> _handlePrint() async {
    if (_isInvalidOrder()) return;

    setState(() => isPrinting = true);

    try {
      await _saveOrderToSales();
      widget.onOrderCompleted(); // Trigger real-time update
      _showOrderCompletedDialog();
    } catch (e) {
      _showErrorDialog("Failed to save order. Please try again.");
    } finally {
      setState(() => isPrinting = false);
    }
  }

  bool _isInvalidOrder() {
    if (widget.customerName.isEmpty) {
      _showErrorDialog("Customer name cannot be empty.");
      return true;
    }
    if (widget.orderItems.isEmpty) {
      _showErrorDialog("Order items cannot be empty.");
      return true;
    }
    return false;
  }

  Future<void> _saveOrderToSales() async {
    final sale = Sale(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerName: widget.customerName,
      items: widget.orderItems.map((item) {
        return SaleItem(
          name: item['name']?.toString() ?? 'Unknown',
          quantity: (item['quantity'] as int?) ?? 0,
          price: (item['price'] as double?) ?? 0.0,
        );
      }).toList(),
      totalAmount: widget.total,
      date: DateTime.now(),
    );

    await HiveService.addSale(sale);
    print("✅ Sale saved: \${sale.customerName} - ₹\${sale.totalAmount}");
  }

  void _showOrderCompletedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Completed'),
        content: const Text('The order has been successfully saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Total Display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              Flexible(
                child: Text(
                  "₹${widget.total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Print Bill Button
          ElevatedButton(
            onPressed: isPrinting ? null : _handlePrint,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: isPrinting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Print Bill'),
          ),
        ],
      ),
    );
  }
}