import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as excel;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/product.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  late Box<Product> productBox;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    productBox = Hive.box<Product>('products');
  }

  List<Product> getFilteredProducts() {
    if (searchQuery.isEmpty) {
      return productBox.values.toList();
    }
    return productBox.values
        .where((product) => product.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> exportToExcel() async {
    final workbook = excel.Workbook();
    final sheet = workbook.worksheets[0];

    // Set headers
    sheet.getRangeByName('A1').setText('Name');
    sheet.getRangeByName('B1').setText('Price');
    sheet.getRangeByName('C1').setText('Quantity');
    sheet.getRangeByName('D1').setText('Category');

    // Populate data
    final products = productBox.values.toList();
    for (int i = 0; i < products.length; i++) {
      final product = products[i];
      sheet.getRangeByIndex(i + 2, 1).setText(product.name);
      sheet.getRangeByIndex(i + 2, 2).setNumber(product.price);
      sheet.getRangeByIndex(i + 2, 3).setNumber(product.quantity.toDouble());
      sheet.getRangeByIndex(i + 2, 4).setText(product.category);
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/Inventory.xlsx';
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exported to: $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = getFilteredProducts();

    return Scaffold(
      backgroundColor: const Color(0xff1f2029),
      appBar: AppBar(
        backgroundColor: const Color(0xff2a2b38),
        title: const Text('Inventory', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download, color: Colors.white),
            onPressed: exportToExcel,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return Card(
                  color: const Color(0xff2a2b38),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueGrey,
                      child: Text('${product.quantity}', style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(product.name, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(
                      '₹ ${product.price.toStringAsFixed(2)} - ${product.category}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}