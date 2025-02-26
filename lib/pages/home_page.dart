import 'package:flutter/material.dart';

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
    {'image': 'assets/items/4.png', 'title': 'LED Bulb', 'price': 1.99, 'item': '50 pcs'},
    {'image': 'assets/items/3.png', 'title': 'Copper Wire', 'price': 10.50, 'item': '20 rolls'},
    {'image': 'assets/items/2.png', 'title': 'Screwdriver Set', 'price': 15.00, 'item': '10 sets'},
    {'image': 'assets/items/1.png', 'title': 'Power Switch', 'price': 5.00, 'item': '30 pcs'},
  ];

  final List<Map<String, dynamic>> orderItems = [];

  void addToOrder(Map<String, dynamic> item) {
    setState(() {
      orderItems.add(item);
    });
  }

  double calculateTotal() {
    return orderItems.fold(0, (sum, item) => sum + (item['price'] as double));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 14,
          child: Column(
            children: [
              _topMenu(title: 'Electronics POS', subTitle: '23 February 2025', action: _searchBar()),
              _categoryTabs(),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: (1 / 1.2),
                  ),
                  itemCount: items.where((item) => item['title'].toLowerCase().contains(searchQuery.toLowerCase())).length,
                  itemBuilder: (context, index) {
                    final filteredItems = items.where((item) => item['title'].toLowerCase().contains(searchQuery.toLowerCase())).toList();
                    return GestureDetector(
                      onTap: () => addToOrder(filteredItems[index]),
                      child: _item(
                        image: filteredItems[index]['image'],
                        title: filteredItems[index]['title'],
                        price: '\$${filteredItems[index]['price']}',
                        item: filteredItems[index]['item'],
                      ),
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
              _topMenu(title: 'Order Summary', subTitle: 'Table 1', action: Container()),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: orderItems.length,
                  itemBuilder: (context, index) {
                    return _itemOrder(
                      image: orderItems[index]['image'],
                      title: orderItems[index]['title'],
                      qty: '1',
                      price: '\$${orderItems[index]['price']}',
                    );
                  },
                ),
              ),
              _billSummary(),
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
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Search...',
          hintStyle: TextStyle(color: Colors.white54),
          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _categoryTabs() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => setState(() => activeTabIndex = index),
            child: _itemTab(
              icon: categories[index]['icon'],
              title: categories[index]['title'],
              isActive: index == activeTabIndex,
            ),
          );
        },
      ),
    );
  }

  Widget _topMenu({required String title, required String subTitle, required Widget action}) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xff1f2029),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Text(subTitle, style: const TextStyle(color: Colors.white54)),
            ],
          ),
          action,
        ],
      ),
    );
  }

  Widget _item({required String image, required String title, required String price, required String item}) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xff1f2029),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(image, height: 100, fit: BoxFit.cover),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.white)),
          Text(price, style: const TextStyle(color: Colors.deepOrange)),
        ],
      ),
    );
  }

  Widget _itemOrder({required String image, required String title, required String qty, required String price}) {
    return ListTile(
      leading: Image.asset(image, height: 50, fit: BoxFit.cover),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text('$qty x $price', style: const TextStyle(color: Colors.white54)),
    );
  }

   Widget _itemTab({required String icon, required String title, required bool isActive}) {
    return Container(
      margin: const EdgeInsets.only(right: 26),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: isActive ? Colors.deepOrange : const Color(0xff1f2029),
      ),
      child: Row(
        children: [
          Image.asset(icon, height: 30),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _billSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: const Color(0xff1f2029)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total: \$${calculateTotal().toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Implement print functionality
            },
            child: const Text('Print Receipt'),
          ),
        ],
      ),
    );
  }
}
