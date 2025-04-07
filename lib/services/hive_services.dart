import 'package:hive/hive.dart';
import '../models/product.dart';
import '../models/order_item.dart';
import '../models/sales.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static bool _isInitialized = false;

  // Initialize Hive and open all boxes
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      await Hive.initFlutter(); // Ensure Hive is initialized

      // Register adapters (this should already be done in main.dart, but we’ll include it here for safety)
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

      // Open all boxes
      await Hive.openBox<Product>('products');
      await Hive.openBox<OrderItem>('orders');
      await Hive.openBox<Sale>('sales');

      _isInitialized = true;
      print("✅ HiveService initialized and all boxes opened");
    } catch (e) {
      print("❌ Error initializing HiveService: $e");
      rethrow;
    }
  }

  // Access Boxes (with lazy loading if not open)
  static Box<Product> get productsBox {
    if (!Hive.isBoxOpen('products')) {
      throw HiveError('Products box not open. Call HiveService.init() first.');
    }
    return Hive.box<Product>('products');
  }

  static Box<OrderItem> get ordersBox {
    if (!Hive.isBoxOpen('orders')) {
      throw HiveError('Orders box not open. Call HiveService.init() first.');
    }
    return Hive.box<OrderItem>('orders');
  }

  static Box<Sale> get salesBox {
    if (!Hive.isBoxOpen('sales')) {
      throw HiveError('Sales box not open. Call HiveService.init() first.');
    }
    return Hive.box<Sale>('sales');
  }

  // Add Product
  static Future<void> addProduct(Product product) async {
    await _ensureInitialized();
    try {
      await productsBox.add(product);
      print("✅ Product added: ${product.name}");
    } catch (e) {
      print("❌ Error adding product: $e");
      rethrow;
    }
  }

  // Add Order
  static Future<void> addOrder(OrderItem order) async {
    await _ensureInitialized();
    try {
      await ordersBox.add(order);
      print("✅ Order added: ${order.productName}");
    } catch (e) {
      print("❌ Error adding order: $e");
      rethrow;
    }
  }

  // Add Sale
  static Future<void> addSale(Sale sale) async {
    await _ensureInitialized();
    try {
      print("Is sales box open? ${Hive.isBoxOpen('sales')}");
      await salesBox.add(sale);
      print("✅ Sale saved: ${sale.id} - ₹${sale.totalAmount}");
    } catch (e) {
      print("❌ Error saving sale: $e");
      rethrow;
    }
  }

  // Get All Products
  static List<Product> getProducts() {
    _ensureInitializedSync();
    return productsBox.values.toList();
  }

  // Get All Orders
  static List<OrderItem> getOrders() {
    _ensureInitializedSync();
    return ordersBox.values.toList();
  }

  // Get All Sales
  static List<Sale> getSales() {
    _ensureInitializedSync();
    return salesBox.values.toList();
  }

  // Delete Product by Key
  static Future<void> deleteProduct(dynamic key) async {
    await _ensureInitialized();
    try {
      await productsBox.delete(key);
      print("✅ Product deleted with key: $key");
    } catch (e) {
      print("❌ Error deleting product: $e");
      rethrow;
    }
  }

  // Delete Sale by Key
  static Future<void> deleteSale(dynamic key) async {
    await _ensureInitialized();
    try {
      await salesBox.delete(key);
      print("✅ Sale deleted with key: $key");
    } catch (e) {
      print("❌ Error deleting sale: $e");
      rethrow;
    }
  }

  // Delete Order by Key
  static Future<void> deleteOrder(dynamic key) async {
    await _ensureInitialized();
    try {
      await ordersBox.delete(key);
      print("✅ Order deleted with key: $key");
    } catch (e) {
      print("❌ Error deleting order: $e");
      rethrow;
    }
  }

  // Clear All Data (for testing or reset)
  static Future<void> clearAll() async {
    await _ensureInitialized();
    try {
      await Future.wait([
        productsBox.clear(),
        ordersBox.clear(),
        salesBox.clear(),
      ]);
      print("✅ All Hive boxes cleared");
    } catch (e) {
      print("❌ Error clearing boxes: $e");
      rethrow;
    }
  }

  // Check if Boxes are Initialized
  static bool isInitialized() => _isInitialized;

  // Close Hive (for cleanup)
  static Future<void> close() async {
    try {
      await Hive.close();
      _isInitialized = false;
      print("✅ Hive closed");
    } catch (e) {
      print("❌ Error closing Hive: $e");
      rethrow;
    }
  }

  // Helper method to ensure initialization (async)
  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  // Helper method to ensure initialization (sync for getters)
  static void _ensureInitializedSync() {
    if (!_isInitialized) {
      throw StateError('HiveService not initialized. Call HiveService.init() first.');
    }
  }
}