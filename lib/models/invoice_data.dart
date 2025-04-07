// File: models/invoice_data.dart
import 'package:hive/hive.dart';
part 'invoice_data.g.dart';

@HiveType(typeId: 10)
class InvoiceData extends HiveObject {
  @HiveField(0)
  String invoiceNumber;

  @HiveField(1)
  String buyerName;

  @HiveField(2)
  String buyerMobile;

  @HiveField(3)
  String buyerGst;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  List<InvoiceItem> items;

  @HiveField(6)
  bool isQuotation;

  InvoiceData({
    required this.invoiceNumber,
    required this.buyerName,
    required this.buyerMobile,
    required this.buyerGst,
    required this.date,
    required this.items,
    required this.isQuotation,
  });

  InvoiceData copyWith({
    String? invoiceNumber,
    String? buyerName,
    String? buyerMobile,
    String? buyerGst,
    DateTime? date,
    List<InvoiceItem>? items,
    bool? isQuotation,
  }) {
    return InvoiceData(
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      buyerName: buyerName ?? this.buyerName,
      buyerMobile: buyerMobile ?? this.buyerMobile,
      buyerGst: buyerGst ?? this.buyerGst,
      date: date ?? this.date,
      items: items ?? this.items,
      isQuotation: isQuotation ?? this.isQuotation,
    );
  }
}

@HiveType(typeId: 11)
class InvoiceItem {
  @HiveField(0)
  String name;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  double price;

  @HiveField(3)
  double gstRate;

  InvoiceItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.gstRate,
  });

  double get total => quantity * price;
  double get gstAmount => isTaxable ? total * gstRate / 100 : 0;
  bool get isTaxable => gstRate > 0;

  InvoiceItem copyWith({
    String? name,
    int? quantity,
    double? price,
    double? gstRate,
  }) {
    return InvoiceItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      gstRate: gstRate ?? this.gstRate,
    );
  }
}
