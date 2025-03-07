import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Hive
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
  late Box<Product> productBox;

  @override
  void initState() {
    super.initState();
    productBox = Hive.box<Product>('products');
  }

  Future<void> _exportInventoryToExcel() async {
    final workbook = excel.Workbook();
    final sheet = workbook.worksheets.addWithName('Inventory');

    sheet.getRangeByName('A1').setText('Product Name');
    sheet.getRangeByName('B1').setText('Category');
    sheet.getRangeByName('C1').setText('Price');
    sheet.getRangeByName('D1').setText('Quantity');
    sheet.getRangeByName('E1').setText('Stock Status');

    for (var i = 0; i < productBox.length; i++) {
      final product = productBox.getAt(i);
      final row = i + 2;
      sheet.getRangeByName('A$row').setText(product?.name ?? '');
      sheet.getRangeByName('B$row').setText(product?.category ?? '');
      sheet.getRangeByName('C$row').setNumber(product?.price ?? 0.0);
      sheet.getRangeByName('D$row').setNumber((product?.quantity ?? 0) as double?);
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

  void _deleteProduct(int index) {
    productBox.deleteAt(index);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product deleted successfully.')),
    );
  }

  void _editProduct(int index, Product product) {
    productBox.putAt(index, product);
    setState(() {});
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
            onPressed: _exportInventoryToExcel,
            tooltip: 'Export to Excel',
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: productBox.listenable(),
        builder: (context, Box<Product> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No products available'));
          }

          int totalProducts = box.length;
          int totalStock = box.values.fold(0, (sum, item) => sum + item.quantity);
          double totalValue = box.values.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: ListTile(
                    title: const Text('Inventory Summary'),
                    subtitle: Text('Total Products: $totalProducts\nTotal Stock: $totalStock\nTotal Value: ₹${totalValue.toStringAsFixed(2)}'),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    final product = box.getAt(index);
                    return Slidable(
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) => _editProduct(index, product!),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: 'Edit',
                          ),
                          SlidableAction(
                            onPressed: (_) => _deleteProduct(index),
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
                            backgroundColor: product!.quantity > 0 ? Colors.green : Colors.red,
                            child: Text('${product.quantity}'),
                          ),
                          title: Text(product.name),
                          subtitle: Text('${product.category} - ₹${product.price.toStringAsFixed(2)}'),
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
    );
  }
}

Future<Directory?> getDownloadsDirectory() async {
  if (Platform.isWindows) {
    return Directory('${Platform.environment['USERPROFILE']}\Downloads');
  } else if (Platform.isLinux || Platform.isMacOS) {
    return Directory('/home/${Platform.environment['USER']}');
  } else {
    return getApplicationDocumentsDirectory();
  }
}