import 'package:hive/hive.dart';
import '../models/product.dart';
import '../models/order_item.dart';
import '../models/sales.dart';

class HiveService {
  // Initialize Hive and Open Boxes
  static Future<void> init() async {
    _registerAdapters();

    // Open Hive Boxes
    await Future.wait([
      Hive.openBox<Product>('products'),
      Hive.openBox<OrderItem>('orders'),
      Hive.openBox<Sale>('sales'),
    ]);
  }

  // Register Adapters (Ensure they're registered only once)
  static void _registerAdapters() {
    if (!Hive.isAdapterRegistered(ProductAdapter().typeId)) {
      Hive.registerAdapter(ProductAdapter());
    }
    if (!Hive.isAdapterRegistered(OrderItemAdapter().typeId)) {
      Hive.registerAdapter(OrderItemAdapter());
    }
    if (!Hive.isAdapterRegistered(SaleAdapter().typeId)) {
      Hive.registerAdapter(SaleAdapter());
    }
    if (!Hive.isAdapterRegistered(SaleItemAdapter().typeId)) {
      Hive.registerAdapter(SaleItemAdapter());
    }
  }

  // Access Boxes (Lazy initialization)
  static Box<Product> get productsBox => Hive.box<Product>('products');
  static Box<OrderItem> get ordersBox => Hive.box<OrderItem>('orders');
  static Box<Sale> get salesBox => Hive.box<Sale>('sales');

  // Add Product
  static Future<void> addProduct(Product product) async {
    await productsBox.add(product);
  }

  // Add Order
  static Future<void> addOrder(OrderItem order) async {
    await ordersBox.add(order);
  }

  // Add Sale
  static Future<void> addSale(Sale sale) async {
    await salesBox.add(sale);
  }

  // Get All Products
  static List<Product> getProducts() => productsBox.values.toList();

  // Get All Orders
  static List<OrderItem> getOrders() => ordersBox.values.toList();

  // Get All Sales
  static List<Sale> getSales() => salesBox.values.toList();

  // Delete Product by Key
  static Future<void> deleteProduct(dynamic key) async {
    await productsBox.delete(key);
  }

  // Delete Sale by Key
  static Future<void> deleteSale(dynamic key) async {
    await salesBox.delete(key);
  }

  // Delete Order by Key
  static Future<void> deleteOrder(dynamic key) async {
    await ordersBox.delete(key);
  }

  // Clear All Data (for testing or reset)
  static Future<void> clearAll() async {
    await Future.wait([
      productsBox.clear(),
      ordersBox.clear(),
      salesBox.clear(),
    ]);
  }

  // Check if Boxes are Initialized
  static bool isInitialized() =>
      Hive.isBoxOpen('products') &&
      Hive.isBoxOpen('orders') &&
      Hive.isBoxOpen('sales');

  // Close Hive (for cleanup)
  static Future<void> close() async {
    await Hive.close();
  }
}