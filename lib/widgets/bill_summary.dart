import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/sale_order.dart';
import '../models/invoice_data.dart';
import '../services/hive_services.dart';
import '../pages/invoice_page.dart';
import '../models/order_item.dart';
import 'package:intl/intl.dart';

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
  bool isQuotation = true; // Default to Quotation

  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();

  @override
  void dispose() {
    _customerNameController.dispose();
    _mobileNumberController.dispose();
    super.dispose();
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
    if (!RegExp(r'^\d{10}$').hasMatch(_mobileNumberController.text.trim())) {
      _showErrorDialog("Please enter a valid 10-digit mobile number.");
      return true;
    }
    return false;
  }

  Future<void> _handlePrint() async {
    FocusScope.of(context).unfocus();

    if (_isInvalidOrder()) return;

    setState(() => isPrinting = true);

    try {
      // await _saveOrderToSales();
      final invoice = await _generateInvoiceData();

      widget.onOrderCompleted(); // Clear the order after saving

      if (!mounted) return;

      // Navigate to InvoicePage with the generated invoice
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InvoicePage(
            invoiceData: invoice,
          ),
        ),
      );
    } catch (e) {
      _showErrorDialog("Failed to complete order. Please try again.\nError: $e");
    } finally {
      if (mounted) setState(() => isPrinting = false);
    }
  }

//   Future<void> _saveOrderToSales() async {
//   final orderItems = widget.orderItems.map((item) => OrderItem(
//     productName: item['title'].toString(),
//     quantity: item['quantity'] as int,
//     price: item['price'] as double,
//   )).toList();

//   final now = DateTime.now();

// final saleOrder = SaleOrder(
//   id: now.millisecondsSinceEpoch.toString(),
//   date: DateFormat('yyyy-MM-dd').format(now), // ✅ format to String
//   time: DateFormat('HH:mm:ss').format(now),   // ✅ also format time if needed
//   customerName: _customerNameController.text.trim(),
//   customerMobile: _mobileNumberController.text.trim(),
//   items: orderItems,
//   orderAmount: widget.total,
//   transactionId: now.microsecondsSinceEpoch.toString(),
//   transactionSynced: false,
//   transactionDateTime: now,
//   paymentMethod: 'Cash', // or your logic
//   paymentStatus: creditAmount > 0 ? 'Credit' : 'Paid',
//   paidAmount: paid,
//   creditAmount: creditAmount,
// );

//   final box = await Hive.openBox<SaleOrder>('sales');
//   await box.add(saleOrder);
// }


  Future<InvoiceData> _generateInvoiceData() async {
    final items = widget.orderItems.map((item) => InvoiceItem(
          name: item['title'].toString(),
          quantity: item['quantity'] as int,
          price: item['price'] as double,
          gstRate: isQuotation ? 0.0 : 18.0, // GST only for Tax Invoice
        )).toList();

    final invoice = InvoiceData(
      invoiceNumber: "INV-${DateTime.now().millisecondsSinceEpoch}",
      buyerName: _customerNameController.text.trim(),
      buyerMobile: _mobileNumberController.text.trim(),
      buyerGst: 'NA', // You can make this editable in settings if needed
      date: DateTime.now(),
      items: items,
      isQuotation: isQuotation,
    );

    final box = await Hive.openBox<InvoiceData>('invoices');
    await box.add(invoice);

    return invoice;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Invoice Type:', style: TextStyle(color: Colors.white)),
              Row(
                children: [
                  const Text('Quotation', style: TextStyle(color: Colors.white)),
                  Switch(
                    value: !isQuotation,
                    onChanged: (val) => setState(() => isQuotation = !val),
                  ),
                  const Text('Tax Invoice', style: TextStyle(color: Colors.white)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          TextField(
            controller: _customerNameController,
            decoration: InputDecoration(
              labelText: 'Customer Name',
              labelStyle: const TextStyle(color: Colors.white),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              counterText: "",
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:', style: TextStyle(fontSize: 20, color: Colors.white)),
              Text(
                "₹${widget.total.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: isPrinting ? null : _handlePrint,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: isPrinting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(isQuotation ? 'Generate Quotation PDF' : 'Generate Tax Invoice PDF'),
          ),
        ],
      ),
    );
  }
}