import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/invoice_data.dart';
import '../utils/gst.dart';

Future<Uint8List> generateInvoicePdf(InvoiceData invoice) async {
  final pdf = pw.Document();
  final dateFormat = DateFormat('dd/MM/yyyy');

  final subtotal = invoice.items.fold<double>(
    0,
    (sum, item) => sum + item.total,
  );

  final totalGst = invoice.items.fold<double>(
    0,
    (sum, item) => sum + (invoice.isQuotation ? 0 : item.gstAmount),
  );

  final totalAmount = subtotal + totalGst;

  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Text(
          invoice.isQuotation ? 'Quotation' : 'Tax Invoice',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        pw.Text('Invoice No: ${invoice.invoiceNumber}'),
        pw.Text('Date: ${dateFormat.format(invoice.date)}'),
        pw.SizedBox(height: 12),
        pw.Text('Buyer: ${invoice.buyerName}'),
        pw.Text('Mobile: ${invoice.buyerMobile}'),
        pw.Text('GSTIN: ${invoice.buyerGst}'),
        pw.SizedBox(height: 20),

        /// Table of items
        pw.Table.fromTextArray(
          border: pw.TableBorder.all(width: 0.5),
          headers: [
            'Item',
            'Qty',
            'Price',
            if (!invoice.isQuotation) 'GST %',
            'Amount'
          ],
          data: invoice.items.map((item) {
            final gstAmt = invoice.isQuotation ? 0 : item.gstAmount;
            final amount = item.total + gstAmt;

            return [
              item.name,
              item.quantity.toString(),
              item.price.toStringAsFixed(2),
              if (!invoice.isQuotation)
                GstUtils.formatGstRate(item.gstRate),
              amount.toStringAsFixed(2),
            ];
          }).toList(),
        ),

        pw.SizedBox(height: 12),
        pw.Divider(),

        /// Totals
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Subtotal: ₹${subtotal.toStringAsFixed(2)}'),
              if (!invoice.isQuotation)
                pw.Text('Total GST: ₹${totalGst.toStringAsFixed(2)}'),
              pw.Text(
                'Total Amount: ₹${totalAmount.toStringAsFixed(2)}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  return pdf.save();
}
