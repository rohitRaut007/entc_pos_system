import 'package:flutter/material.dart';
import '../models/sales.dart';
import '../services/hive_services.dart';

class BillSummary extends StatefulWidget {
  final double total;
  final List<Map<String, dynamic>> orderItems;
  final VoidCallback onOrderCompleted;

  const BillSummary({
    super.key,
    required this.total,
    required this.orderItems,
    required this.onOrderCompleted,
  });

  @override
  State<BillSummary> createState() => _BillSummaryState();
}

class _BillSummaryState extends State<BillSummary> {
  bool isPrinting = false;

  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();

  @override
  void dispose() {
    _customerNameController.dispose();
    _mobileNumberController.dispose();
    super.dispose();
  }

  Future<void> _handlePrint() async {
    FocusScope.of(context).unfocus();

    if (_isInvalidOrder()) return;

    if (mounted) setState(() => isPrinting = true);

    try {
      await _saveOrderToSales();
      widget.onOrderCompleted();
      _showOrderCompletedDialog();
    } catch (e) {
      _showErrorDialog("Failed to save order. Please try again.");
    } finally {
      if (mounted) setState(() => isPrinting = false);
    }
  }

  bool _isInvalidOrder() {
    if (widget.orderItems.isEmpty) {
      _showErrorDialog("Order items cannot be empty.");
      return true;
    }
    if (widget.total <= 0) {
      _showErrorDialog("Total amount must be greater than zero.");
      return true;
    }
    if (_customerNameController.text.trim().isEmpty) {
      _showErrorDialog("Customer name cannot be empty.");
      return true;
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(_mobileNumberController.text.trim())) {
      _showErrorDialog("Please enter a valid 10-digit mobile number.");
      return true;
    }
    return false;
  }

  Future<void> _saveOrderToSales() async {
    try {
      final sale = Sale(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customerName: _customerNameController.text.trim(),
        mobileNumber: _mobileNumberController.text.trim(),
        items: widget.orderItems.map((item) {
          return SaleItem(
            name: item['title']?.toString() ?? 'Unknown',
            quantity: (item['quantity'] as int?) ?? 0,
            price: (item['price'] as num?)?.toDouble() ?? 0.0,
          );
        }).toList(),
        totalAmount: widget.total,
        date: DateTime.now(),
      );

      print("📝 Saving sale: $sale");
      await HiveService.addSale(sale);
      print("✅ Sale saved: \${sale.id} - ₹\${sale.totalAmount}");
    } catch (e, stack) {
      print("❌ Error saving sale: $e");
      print(stack);
      throw e;
    }
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
          TextField(
            controller: _customerNameController,
            decoration: InputDecoration(
              labelText: 'Customer Name',
              labelStyle: const TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _mobileNumberController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            decoration: InputDecoration(
              labelText: 'Mobile Number',
              labelStyle: const TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              counterText: "",
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),

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