import 'package:entc_pos_system/utils/invoice_number_generator.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/invoice_data.dart';
import '../models/order_item.dart';
import '../models/sale_order.dart';
import '../models/product.dart'; // Import your Product model
import '../services/pdf_generator.dart';
import 'package:hive/hive.dart';

class InvoicePage extends StatefulWidget {
  final InvoiceData invoiceData;  

  const InvoicePage({
    super.key,
    required this.invoiceData,
  });

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  bool isQuotation = true;
  final TextEditingController _paidAmountController = TextEditingController();
  final TextEditingController _gstinController = TextEditingController();
  double creditAmount = 0.0;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    isQuotation = widget.invoiceData.isQuotation;
    _gstinController.text = widget.invoiceData.buyerGst; // Set existing GST if available
  }

  double get subtotal => widget.invoiceData.items.fold(0, (sum, item) => sum + item.total);
  double get gstTotal => widget.invoiceData.items.fold(0, (sum, item) => sum + item.gstAmount);
  double get totalAmount => subtotal + (isQuotation ? 0.0 : gstTotal);

  void _toggleInvoiceType(bool value) {
    setState(() {
      isQuotation = value;
      final updatedItems = widget.invoiceData.items.map((item) => item.copyWith(
            gstRate: isQuotation ? 0.0 : 18.0,
          )).toList();
      widget.invoiceData.items
        ..clear()
        ..addAll(updatedItems);
      widget.invoiceData.isQuotation = isQuotation;
    });
  }

  Future<void> _confirmAndSaveOrder() async {
    FocusScope.of(context).unfocus();

    if (_paidAmountController.text.trim().isEmpty) {
      _showError("Please enter paid amount.");
      return;
    }

    final paid = double.tryParse(_paidAmountController.text.trim());
    if (paid == null || paid < 0) {
      _showError("Invalid paid amount.");
      return;
    }

    if (paid > totalAmount) {
      _showError("Paid amount cannot be more than total.");
      return;
    }

    setState(() => isSaving = true);
    creditAmount = totalAmount - paid;

    final items = widget.invoiceData.items.map((item) => OrderItem(
          productName: item.name,
          quantity: item.quantity,
          price: item.price,
        )).toList();

    final now = DateTime.now();

    final transactionId = await generateTransactionId();  

    final saleOrder = SaleOrder(
      id: transactionId ,
      date: DateFormat('yyyy-MM-dd').format(now),
      time: DateFormat('HH:mm:ss').format(now),
      customerName: widget.invoiceData.buyerName,
      customerMobile: widget.invoiceData.buyerMobile,
      items: items,
      gstin: _gstinController.text.trim(), // ✅ Add this line
      orderAmount: totalAmount.roundToDouble(),
      transactionId: now.microsecondsSinceEpoch.toString(),
      transactionSynced: false,
      transactionDateTime: now,
      paymentMethod: 'Cash',
      paymentStatus: creditAmount.round() > 0 ? 'Credit' : 'Paid',
      paidAmount: paid,
      creditAmount: creditAmount,
    );

    // Save sale
    final salesBox = await Hive.openBox<SaleOrder>('sales');
    await salesBox.add(saleOrder);

    // Update product stock
    final productBox = await Hive.openBox<Product>('products');
    for (var item in widget.invoiceData.items) {
      final index = productBox.values.toList().indexWhere((p) => p.name == item.name);
      if (index != -1) {
        final product = productBox.getAt(index);
        if (product != null) {
          final updatedQty = (product.quantity - item.quantity).clamp(0, double.infinity).toInt();
          final updatedProduct = product.copyWith(quantity: updatedQty);
          await productBox.putAt(index, updatedProduct);
        }
      }
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(msg),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }

  @override
  void dispose() {
    _paidAmountController.dispose();
    _gstinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invoiceData = widget.invoiceData;

    return Scaffold(
      backgroundColor: const Color(0xff17181f),
      appBar: AppBar(
        title: Text(isQuotation ? 'Quotation' : 'Tax Invoice'),
        backgroundColor: const Color.fromARGB(255, 184, 189, 235),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              Printing.layoutPdf(
                onLayout: (_) => generateInvoicePdf(invoiceData.copyWith(
                  isQuotation: isQuotation,
                  buyerGst: _gstinController.text.trim(), // Save updated GSTIN before printing
                  items: invoiceData.items.map((item) => item.copyWith(
                        gstRate: isQuotation ? 0.0 : 18.0,
                      )).toList(),
                )),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _status(context),
            const SizedBox(height: 20),
            _buyerDetailCard(context),
            const SizedBox(height: 20),
            _productDetailCard(context),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Tax Invoice", style: TextStyle(color: Colors.white)),
                Switch(
                  value: isQuotation,
                  onChanged: _toggleInvoiceType,
                ),
                const Text("Quotation", style: TextStyle(color: Colors.white)),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _gstinController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: "Customer GSTIN (optional)",
                labelStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _paidAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Paid Amount",
                labelStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Generate PDF"),
              onPressed: () {
                Printing.layoutPdf(
                  onLayout: (_) => generateInvoicePdf(invoiceData.copyWith(
                    isQuotation: isQuotation,
                    buyerGst: _gstinController.text.trim(),
                    items: invoiceData.items.map((item) => item.copyWith(
                          gstRate: isQuotation ? 0.0 : 18.0,
                        )).toList(),
                  )),
                );
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle_outline),
              label: isSaving ? const Text("Saving...") : const Text("Confirm Order"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              ),
              onPressed: isSaving ? null : _confirmAndSaveOrder,
            ),
          ],
        ),
      ),
    );
  }

  Widget _status(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 60),
        const SizedBox(height: 8),
        Text(
          isQuotation ? 'Quotation Created' : 'Invoice Created',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buyerDetailCard(BuildContext context) {
    final invoiceData = widget.invoiceData;
    return Card(
      color: const Color(0xff1f2029),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow(context, "Invoice No.", invoiceData.invoiceNumber),
            _infoRow(context, "Date", invoiceData.date.toString().substring(0, 19)),
            _infoRow(context, "Customer Name", invoiceData.buyerName),
            _infoRow(context, "Mobile", invoiceData.buyerMobile),
            _infoRow(context, "GST No.", _gstinController.text.trim().isNotEmpty ? _gstinController.text.trim() : '-'),
          ],
        ),
      ),
    );
  }

  Widget _productDetailCard(BuildContext context) {
    final invoiceData = widget.invoiceData;
    return Card(
      color: const Color(0xff1f2029),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow(context, "Ordered Products", invoiceData.items.length.toString()),
            const Divider(color: Colors.grey),
            ...invoiceData.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _productRow(context, item),
                )),
            const Divider(color: Colors.grey),
            _infoRow(context, "Subtotal", CurrencyFormatter.format(subtotal)),
            if (!isQuotation) _infoRow(context, "GST", CurrencyFormatter.format(gstTotal)),
            _infoRow(context, "Total Amount", CurrencyFormatter.format(totalAmount)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _productRow(BuildContext context, InvoiceItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${CurrencyFormatter.format(item.price)} x ${item.quantity}', style: const TextStyle(color: Colors.white70)),
            Text(CurrencyFormatter.format(item.total), style: const TextStyle(color: Colors.white)),
          ],
        ),
        if (!isQuotation)
          Text('GST (${item.gstRate}%): ${CurrencyFormatter.format(item.gstAmount)}', style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}

class CurrencyFormatter {
  static String format(double amount) => '₹${amount.round()}'; 
}


// Future<String> generateTransactionId() async {
//   final now = DateTime.now();
//   final year = now.year % 100; // e.g., 2025 → 25
//   final prYear = year - 1;     // → 24
//   final Original_month = 5;
//   final month = now.month.toString().padLeft(2, '0');

//   // Open your Hive box that stores SaleOrders
//   final saleBox = await Hive.openBox<SaleOrder>('sale_orders');

//   int serial = 1;
//    // Default if no transaction exists, initialize to 001

//   // Ensure serial is at least 3 digits
//   final serialStr = serial.toString().padLeft(3, '0');

//   final generatedId = '$prYear$year$month$serialStr';
//   print("Generated Transaction ID: $generatedId");

//   return generatedId;
// }

