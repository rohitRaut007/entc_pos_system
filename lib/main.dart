import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/order_item.dart';
import 'models/product.dart';
import 'pages/home_page.dart';
import 'pages/products_page.dart';
import 'pages/sales_page.dart';
import 'pages/inventory_page.dart';
import 'pages/settings_page.dart';
import 'widgets/side_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and register adapters
  await Hive.initFlutter();
  Hive.registerAdapter(OrderItemAdapter());
  Hive.registerAdapter(ProductAdapter());

  // Open Hive boxes for storing data
  await Hive.openBox<OrderItem>('orders');
  await Hive.openBox<Product>('products'); // ✅ Fixed: Opened the products box

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS Electrical Tools',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
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

  void _setPage(String page) {
    setState(() {
      currentPage = page;
    });
  }

  Widget _pageContent() {
    switch (currentPage) {
      case 'Home':
        return const HomePage();
      case 'Products':
        return const ProductsPage();
      case 'Sales':
        return const SalesPage();
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
