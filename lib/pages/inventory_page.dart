import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  Future<void> _exportInventoryToExcel(Box<Product> productBox) async {
    final workbook = excel.Workbook();
    final sheet = workbook.worksheets.addWithName('Inventory');

    sheet.getRangeByName('A1').setText('Product Name');
    sheet.getRangeByName('B1').setText('Category');
    sheet.getRangeByName('C1').setText('Price');
    sheet.getRangeByName('D1').setText('Quantity');
    sheet.getRangeByName('E1').setText('Stock Status');

    final keys = productBox.keys.cast<int>().toList();
    for (var i = 0; i < keys.length; i++) {
      final product = productBox.get(keys[i]);
      final row = i + 2;
      sheet.getRangeByName('A$row').setText(product?.name ?? '');
      sheet.getRangeByName('B$row').setText(product?.category ?? '');
      sheet.getRangeByName('C$row').setNumber(product?.price ?? 0.0);
      sheet.getRangeByName('D$row').setNumber((product?.quantity ?? 0).toDouble());
      sheet.getRangeByName('E$row').setText(product!.quantity > 0 ? 'In Stock' : 'Out of Stock');
    }

    final bytes = workbook.saveAsStream();
    workbook.dispose();

    final directory = await getDownloadsDirectory();
    final path = '${directory?.path}/inventory_export.xlsx';
    final file = File(path);
    await file.writeAsBytes(bytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Inventory exported to: $path')),
    );
  }

  void _deleteProduct(int key) {
    Hive.box<Product>('products').delete(key);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product deleted successfully.')),
    );
  }

  void _editProduct(int key, Product updatedProduct) {
    Hive.box<Product>('products').put(key, updatedProduct);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product updated successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
              final box = Hive.box<Product>('products');
              _exportInventoryToExcel(box);
            },
            tooltip: 'Export to Excel',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or category',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          setState(() => searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() => searchQuery = value);
              },
            ),
          ),

          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<Product>('products').listenable(),
              builder: (context, Box<Product> box, _) {
                final keys = box.keys.cast<int>().where((key) {
                  final product = box.get(key)!;
                  return product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                      product.category.toLowerCase().contains(searchQuery.toLowerCase());
                }).toList();

                if (keys.isEmpty) {
                  return const Center(child: Text('No products found'));
                }

                final totalProducts = keys.length;
                final totalStock = keys.fold(0, (sum, key) => sum + box.get(key)!.quantity);
                final totalValue = keys.fold(0.0,
                    (sum, key) => sum + (box.get(key)!.price * box.get(key)!.quantity));

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Card(
                        child: ListTile(
                          title: const Text('Inventory Summary'),
                          subtitle: Text(
                              'Total Products: $totalProducts\nTotal Stock: $totalStock\nTotal Value: ₹${totalValue.toStringAsFixed(2)}'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: keys.length,
                        itemBuilder: (context, index) {
                          final key = keys[index];
                          final product = box.get(key)!;

                          return Slidable(
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (_) => _editProduct(key, product),
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  icon: Icons.edit,
                                  label: 'Edit',
                                ),
                                SlidableAction(
                                  onPressed: (_) => _deleteProduct(key),
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                ),
                              ],
                            ),
                            child: Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: product.quantity > 0 ? Colors.green : Colors.red,
                                  child: Text('${product.quantity}'),
                                ),
                                title: Text(product.name),
                                subtitle: Text(
                                    '${product.category} - ₹${product.price.toStringAsFixed(2)}'),
                                trailing: product.quantity < 5
                                    ? const Icon(Icons.warning, color: Colors.orange)
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<Directory?> getDownloadsDirectory() async {
  if (Platform.isWindows) {
    return Directory('${Platform.environment['USERPROFILE']}\\Downloads');
  } else if (Platform.isLinux || Platform.isMacOS) {
    return Directory('/home/${Platform.environment['USER']}');
  } else {
    return getApplicationDocumentsDirectory();
  }
}
