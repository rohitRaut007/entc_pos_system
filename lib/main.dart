import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Models
import 'models/invoice_data.dart';
import 'models/order_item.dart';
import 'models/product.dart';
import 'models/sale_order.dart'; // ✅ Updated model import

// Pages
import 'pages/home_page.dart';
import 'pages/invoice_page.dart';
import 'pages/products_page.dart';
import 'pages/sales_page.dart';
import 'pages/inventory_page.dart';
import 'pages/settings_page.dart';

// Widgets
import 'widgets/side_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await _initHive();

   // 🚨 Only set this to true if you want to reset Hive (e.g., after changing typeIds)
  // await _initHive(resetHive: true);
  runApp(const MyApp());
}

Future<void> _initHive({bool resetHive = false}) async {

    try {
    // 🧹 Delete old Hive boxes if reset is true
    if (resetHive) {
      await Hive.deleteBoxFromDisk('orders');
      await Hive.deleteBoxFromDisk('products');
      await Hive.deleteBoxFromDisk('sales');
      await Hive.deleteBoxFromDisk('invoices');
      debugPrint('🧹 Deleted old Hive boxes.');
    }

    // Register Adapters
    if (!Hive.isAdapterRegistered(OrderItemAdapter().typeId)) {
      Hive.registerAdapter(OrderItemAdapter());
    }
    if (!Hive.isAdapterRegistered(ProductAdapter().typeId)) {
      Hive.registerAdapter(ProductAdapter());
    }
    if (!Hive.isAdapterRegistered(SaleOrderAdapter().typeId)) {
      Hive.registerAdapter(SaleOrderAdapter());
    }
    if (!Hive.isAdapterRegistered(InvoiceDataAdapter().typeId)) {
      Hive.registerAdapter(InvoiceDataAdapter());
    }
    if (!Hive.isAdapterRegistered(InvoiceItemAdapter().typeId)) {
      Hive.registerAdapter(InvoiceItemAdapter());
    }

    // Open Boxes
    await Hive.openBox<OrderItem>('orders');
    await Hive.openBox<Product>('products');
    await Hive.openBox<SaleOrder>('sales'); // ✅ Updated box
    await Hive.openBox<InvoiceData>('invoices');

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 216, 190, 154),
        ),
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
    setState(() => currentPage = page);
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
      case 'Invoice':
        final dummyInvoice = InvoiceData(
          invoiceNumber: 'INV-TEST-001',
          buyerName: 'John Doe',
          buyerMobile: '9876543210',
          buyerGst: '27ABCDE1234F1Z5',
          date: DateTime.now(),
          isQuotation: true,
          items: [
            InvoiceItem(
              name: 'LED Tube Light',
              quantity: 5,
              price: 150.0,
              gstRate: 0.0,
            ),
            InvoiceItem(
              name: 'Ceiling Fan',
              quantity: 2,
              price: 1200.0,
              gstRate: 0.0,
            ),
          ],
        );
        return InvoicePage(invoiceData: dummyInvoice);
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
