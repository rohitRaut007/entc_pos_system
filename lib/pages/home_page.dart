import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/hive_services.dart';
import '../widgets/top_menu.dart';
import '../widgets/category_tab.dart';
import '../widgets/item_card.dart';
import '../widgets/item_order.dart';
import '../widgets/bill_summary.dart';
import '../models/product.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int activeTabIndex = 0;
  String searchQuery = "";

  final List<Map<String, dynamic>> categories = [
  {'icon': 'assets/icons/icon-led.png', 'title': 'All'},
  {'icon': 'assets/icons/icon-led.png', 'title': 'LEDs'},
  {'icon': 'assets/icons/icon-led.png', 'title': 'Bulbs'},
  {'icon': 'assets/icons/icon-tubelight.png', 'title': 'Tube Lights'},
  {'icon': 'assets/icons/icon-wire.png', 'title': 'Wires'},
  {'icon': 'assets/icons/icon-switch.png', 'title': 'Switches'},
  {'icon': 'assets/icons/icon-socket.png', 'title': 'Sockets'},
  {'icon': 'assets/icons/icon-mcb.png', 'title': 'MCBs'},
  {'icon': 'assets/icons/icon-fan.png', 'title': 'Fans'},
  {'icon': 'assets/icons/icon-pipe.png', 'title': 'Pipes'},
  {'icon': 'assets/icons/icon-homeappliances.png', 'title': 'Home Appliances'},
  {'icon': 'assets/icons/icon-tools.png', 'title': 'Tools'},
  {'icon': 'assets/icons/icon-accessory.png', 'title': 'Accessories'},
];


  final List<Map<String, dynamic>> orderItems = [];

  @override
  void initState() {
    super.initState();
    // HiveService.init();
  }

  void addToOrder(Product product, int quantity) {
    print("Adding to order: Product: ${product.name}, Quantity: $quantity");
    print("Product name type: ${product.name.runtimeType}");

    setState(() {
      int index = orderItems.indexWhere((orderItem) => orderItem['title'] == product.name);
      if (index != -1) {
        orderItems[index]['quantity'] += quantity;
      } else {
        orderItems.add({
          'image': product.imagePath,
          'title': product.name.toString(), // Ensure it's a String
          'price': product.price.toDouble(), // Ensure it's a double
          'quantity': quantity,
        });
      }
    });
    print("Current orderItems: $orderItems");
  }

  Future<void> promptForQuantity(Product product) async {
    int quantity = 1;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Quantity"),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) => quantity = int.tryParse(value) ?? 1,
            decoration: const InputDecoration(hintText: "Quantity"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (quantity > 0 && product.quantity >= quantity) {
                  addToOrder(product, quantity);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Insufficient stock!")),
                  );
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void updateQuantity(int index, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        orderItems.removeAt(index); // Remove item if quantity is zero
      } else {
        orderItems[index]['quantity'] = newQuantity;
      }
    });
    print("Updated orderItems: $orderItems");
  }

  double calculateTotal() {
    return orderItems.fold(0.0, (sum, item) {
      final price = (item['price'] as double?) ?? 0.0;
      final quantity = (item['quantity'] as int?) ?? 0;
      return sum + price * quantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HiveService.productsBox.listenable(),
      builder: (context, Box<Product> box, _) {
        
        final selectedCategory = categories[activeTabIndex]['title'];

        // Filter logic
        final products = box.values.where((p) {
          final matchesCategory = selectedCategory == 'All' || p.category == selectedCategory;
          final matchesSearch = p.name.toLowerCase().contains(searchQuery.toLowerCase());

          // If search is empty, just filter by category
          if (searchQuery.isEmpty) return matchesCategory;

          // If search is active, match product name across all categories or selected category
          return matchesCategory && matchesSearch;
        }).toList();



        return Row(
          children: [
            Expanded(
              flex: 14,
              child: Column(
                children: [
                  TopMenu(
                    title: 'Electronics POS',
                    subTitle: DateFormat('d MMMM y').format(DateTime.now()),
                    action: _searchBar(),
                  ),
                  CategoryTabs(
                    categories: categories,
                    activeTabIndex: activeTabIndex,
                    onTabChange: (index) => setState(() => activeTabIndex = index),
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: (1 / 1.2),
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ItemCard(
                          image: product.imagePath,
                          title: product.name,
                          price: product.price,
                          stockQuantity: product.quantity, // Pass the product's stock quantity
                          onTap: () => promptForQuantity(product),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
           Expanded(flex: 0, child: SizedBox(width: 12)),
            Expanded(
              flex: 7,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    child: const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                   // ✅ Scrollable order list in expanded container
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ListView.builder(
                          itemCount: orderItems.length,
                          itemBuilder: (context, index) {
                            return ItemOrder(
                              item: orderItems[index],
                              onDelete: () => updateQuantity(index, 0),
                              onIncrease: () => updateQuantity(index, orderItems[index]['quantity'] + 1),
                              onDecrease: () => updateQuantity(index, orderItems[index]['quantity'] - 1),
                              onQuantityChange: (newQuantity) => updateQuantity(index, newQuantity),
                            );
                          },
                        ),
                      ),
                    ),
                    // ✅ BillSummary stays pinned at bottom
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: BillSummary(
                        total: calculateTotal(),
                        orderItems: orderItems,
                        onOrderCompleted: () {
                          setState(() => orderItems.clear());
                          print("✅ Order completed and UI updated!");
                        },
                      )
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _searchBar() {
    return SizedBox(
      width: 300,
      child: TextField(
        onChanged: (value) => setState(() => searchQuery = value),
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Search...',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}