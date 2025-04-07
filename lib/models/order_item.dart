import 'package:hive/hive.dart';
part 'order_item.g.dart';

@HiveType(typeId: 1)
class OrderItem extends HiveObject {
  @HiveField(0)
  final String productName;

  @HiveField(1)
  final double price;

  @HiveField(2)
  final int quantity;

  OrderItem({
    required this.productName,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'price': price,
      'quantity': quantity,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productName: map['productName'],
      price: map['price'],
      quantity: map['quantity'],
    );
  }

  @override
  String toString() =>
      'OrderItem(productName: $productName, price: $price, quantity: $quantity)';
}
