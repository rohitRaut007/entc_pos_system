import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double price;

  @HiveField(2)
  int quantity; // Ensure quantity exists

  @HiveField(3)
  String category;

  @HiveField(4)
  String imagePath;

  Product({
    required this.name,
    required this.price,
    required this.quantity, // Add quantity here
    required this.category,
    required this.imagePath,
  });

   Product copyWith({
    String? name,
    double? price,
    int? quantity,
    String? category,
    String? imagePath,
  }) {
    return Product(
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
    );
  }

}
