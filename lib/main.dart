import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/order_item.dart';
import 'models/product.dart';
import 'models/sales.dart'; // ✅ Import Sale & SaleItem models
import 'pages/home_page.dart';
import 'pages/products_page.dart';
import 'pages/sales_page.dart';
import 'pages/inventory_page.dart';
import 'pages/settings_page.dart';
import 'widgets/side_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initHive(); // Initialize Hive storage

  runApp(const MyApp());
}

// Initialize Hive and open all necessary boxes
Future<void> _initHive() async {
  try {
    await Hive.initFlutter();

    // Register Hive Adapters (Prevent Duplicate Registration)
    if (!Hive.isAdapterRegistered(OrderItemAdapter().typeId)) {
      Hive.registerAdapter(OrderItemAdapter());
    }
    if (!Hive.isAdapterRegistered(ProductAdapter().typeId)) {
      Hive.registerAdapter(ProductAdapter());
    }
    if (!Hive.isAdapterRegistered(SaleAdapter().typeId)) {
      Hive.registerAdapter(SaleAdapter());
    }
    if (!Hive.isAdapterRegistered(SaleItemAdapter().typeId)) {
      Hive.registerAdapter(SaleItemAdapter());
    }

    // Open Hive Boxes (Open Once Only)
    await Future.wait([
      if (!Hive.isBoxOpen('orders')) Hive.openBox<OrderItem>('orders'),
      if (!Hive.isBoxOpen('products')) Hive.openBox<Product>('products'),
      if (!Hive.isBoxOpen('sales')) Hive.openBox<Sale>('sales'),
    ]);

    debugPrint('✅ Hive successfully initialized.');
  } catch (e) {
    debugPrint('❌ Hive initialization error: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS Electrical Tools',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 246, 247, 247)),
        useMaterial3: true,
      ),
      home: const MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String currentPage = 'Home';

  // Update the active page
  void _setPage(String page) {
    setState(() => currentPage = page);
  }

  // Map pages to widgets
  Widget _pageContent() {
    switch (currentPage) {
      case 'Home':
        return const HomePage();
      case 'Products':
        return const ProductsPage();
      case 'Sales':
        return const SalesPage(); // ✅ Ensure Sales Page is displayed
      case 'Inventory':
        return const InventoryPage();
      case 'Settings':
        return const SettingsPage();
      default:
        return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1f2029),
      body: Row(
        children: [
          SideMenu(currentPage: currentPage, onPageSelected: _setPage),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xff17181f),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: _pageContent(),
            ),
          ),
        ],
      ),
    );
  }
}
