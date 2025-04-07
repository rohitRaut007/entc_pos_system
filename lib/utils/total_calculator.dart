import '../models/invoice_data.dart';

double calculateSubtotal(List<InvoiceItem> items) {
  return items.fold(0, (sum, item) => sum + item.total);
}

double calculateTotalGst(List<InvoiceItem> items) {
  return items.fold(0, (sum, item) => sum + item.gstAmount);
}

double calculateGrandTotal(List<InvoiceItem> items, {bool includeGst = true}) {
  return items.fold(0, (sum, item) =>
    sum + item.total + (includeGst ? item.gstAmount : 0));
}
