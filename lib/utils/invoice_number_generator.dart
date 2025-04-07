int _invoiceCounter = 1; // You can persist this in Hive or SharedPreferences later

String generateInvoiceNumber({bool isQuotation = false}) {
  final prefix = isQuotation ? "QUO" : "INV";
  final number = _invoiceCounter.toString().padLeft(4, '0');
  _invoiceCounter++;
  return "$prefix-$number";
}
