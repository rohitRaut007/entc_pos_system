// home_page.dart
import 'package:flutter/material.dart';
import '../widgets/top_menu.dart';
import '../widgets/category_tab.dart';
import '../widgets/item_card.dart';
import '../widgets/item_order.dart';
import '../widgets/bill_summary.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int activeTabIndex = 0;
  String searchQuery = "";
  final List<Map<String, dynamic>> categories = [
    {'icon': 'assets/icons/icon-led.png', 'title': 'LEDs'},
    {'icon': 'assets/icons/icon-wire.png', 'title': 'Wires'},
    {'icon': 'assets/icons/icon-tools.png', 'title': 'Tools'},
    {'icon': 'assets/icons/icon-switch.png', 'title': 'Switches'},
  ];

  final List<Map<String, dynamic>> items = [
    {'image': 'assets/items/4.png', 'title': 'LED Bulb', 'price': 1.99},
    {'image': 'assets/items/3.png', 'title': 'Copper Wire', 'price': 10.50},
    {'image': 'assets/items/2.png', 'title': 'Screwdriver Set', 'price': 15.00},
    {'image': 'assets/items/1.png', 'title': 'Power Switch', 'price': 5.00},
  ];

  final List<Map<String, dynamic>> orderItems = [];

  void addToOrder(Map<String, dynamic> item, int quantity) {
    setState(() {
      int index = orderItems.indexWhere((orderItem) => orderItem['title'] == item['title']);
      if (index != -1) {
        orderItems[index]['quantity'] += quantity;
      } else {
        orderItems.add({...item, 'quantity': quantity});
      }
    });
  }

  Future<void> promptForQuantity(Map<String, dynamic> item) async {
    int quantity = 1;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Quantity"),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              quantity = int.tryParse(value) ?? 1;
            },
            decoration: const InputDecoration(hintText: "Quantity"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                addToOrder(item, quantity);
                Navigator.of(context).pop();
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  double calculateTotal() {
    return orderItems.fold(0, (sum, item) => sum + (item['price'] as double) * (item['quantity'] as int));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 14,
          child: Column(
            children: [
              TopMenu(title: 'Electronics POS', subTitle: '23 February 2025', action: _searchBar()),
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
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return ItemCard(
                      image: items[index]['image'],
                      title: items[index]['title'],
                      price: items[index]['price'],
                      onTap: () => promptForQuantity(items[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(flex: 1, child: Container()),
        Expanded(
          flex: 5,
          child: Column(
            children: [
              const TopMenu(title: 'Order Summary', subTitle: 'Table 1', action: SizedBox()),
              Expanded(
                child: ListView.builder(
                  itemCount: orderItems.length,
                  itemBuilder: (context, index) {
                    return ItemOrder(item: orderItems[index]);
                  },
                ),
              ),
              BillSummary(total: calculateTotal()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _searchBar() {
    return SizedBox(
      width: 300,
      child: TextField(
        onChanged: (value) => setState(() => searchQuery = value),
        decoration: const InputDecoration(hintText: 'Search...', border: OutlineInputBorder()),
      ),
    );
  }
}
