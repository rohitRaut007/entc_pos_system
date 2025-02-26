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

  OrderItem({required this.productName, required this.price, required this.quantity});
}
