import 'package:hive/hive.dart';

part 'sales.g.dart';

@HiveType(typeId: 5) // Ensure a unique and consistent typeId
class Sale extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String customerName;

  @HiveField(2)
  final String mobileNumber;

  @HiveField(3)
  final List<SaleItem> items;

  @HiveField(4)
  final double totalAmount;

  @HiveField(5)
  final DateTime date;

  Sale({
    required this.id,
    required this.customerName,
    required this.mobileNumber,
    required this.items,
    required this.totalAmount,
    required this.date,
  });
}

@HiveType(typeId: 4) // Ensure a unique and consistent typeId
class SaleItem extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int quantity;

  @HiveField(2)
  final double price;

  SaleItem({
    required this.name,
    required this.quantity,
    required this.price,
  });
}
