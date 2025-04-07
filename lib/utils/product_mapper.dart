import '../models/product.dart';
import '../models/invoice_data.dart';

List<InvoiceItem> convertProductsToInvoiceItems(List<Product> products) {
  return products.map((product) {
    return InvoiceItem(
      name: product.name,
      quantity: product.quantity,
      price: product.price,
      gstRate: 18.0, // Static GST rate; change per product if needed
    );
  }).toList();
}
