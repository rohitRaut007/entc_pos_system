import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../models/invoice_data.dart';
import '../services/pdf_generator.dart';

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
  bool isQuotation = true; // Sync with the invoice data

  @override
  void initState() {
    super.initState();
    isQuotation = widget.invoiceData.isQuotation; // Initialize based on passed data
  }

  void _toggleInvoiceType(bool value) {
    setState(() {
      isQuotation = value;
      final updatedItems = widget.invoiceData.items.map((item) => item.copyWith(
            gstRate: isQuotation ? 0.0 : 18.0, // Update GST rate based on toggle
          )).toList();
      widget.invoiceData.items.clear();
      widget.invoiceData.items.addAll(updatedItems);
      widget.invoiceData.isQuotation = isQuotation; // Update the invoice data
    });
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
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Generate PDF"),
              onPressed: () {
                Printing.layoutPdf(
                  onLayout: (_) => generateInvoicePdf(invoiceData.copyWith(
                    isQuotation: isQuotation,
                    items: invoiceData.items.map((item) => item.copyWith(
                          gstRate: isQuotation ? 0.0 : 18.0,
                        )).toList(),
                  )),
                );
              },
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
            _infoRow(context, "GST No.", invoiceData.buyerGst.isNotEmpty ? invoiceData.buyerGst : '-'),
          ],
        ),
      ),
    );
  }

  Widget _productDetailCard(BuildContext context) {
    final invoiceData = widget.invoiceData;
    double subtotal = invoiceData.items.fold(0, (sum, item) => sum + item.total);
    double gstTotal = invoiceData.items.fold(0, (sum, item) => sum + item.gstAmount);

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
            _infoRow(context, "Total Amount", CurrencyFormatter.format(subtotal + (isQuotation ? 0 : gstTotal))),
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
  static String format(double amount) => '₹${amount.toStringAsFixed(2)}';
}