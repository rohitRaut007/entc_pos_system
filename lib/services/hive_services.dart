import 'package:hive/hive.dart';
import '../models/product.dart';
import '../models/order_item.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.openBox<Product>('products');
    await Hive.openBox<OrderItem>('orders');
  }

  static Box<Product> get productsBox => Hive.box<Product>('products');
  static Box<OrderItem> get ordersBox => Hive.box<OrderItem>('orders');

  // Add product
  static Future<void> addProduct(Product product) async {
    await productsBox.add(product);
  }

  // Add order
  static Future<void> addOrder(OrderItem order) async {
    await ordersBox.add(order);
  }

  // Get all orders
  static List<OrderItem> getOrders() => ordersBox.values.toList();
}
