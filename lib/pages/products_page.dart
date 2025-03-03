import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as excel;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/product.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late Box<Product> productBox;

  final List<Map<String, dynamic>> categories = [
    {'icon': 'assets/icons/icon-led.png', 'title': 'LEDs'},
    {'icon': 'assets/icons/icon-wire.png', 'title': 'Wires'},
    {'icon': 'assets/icons/icon-tools.png', 'title': 'Tools'},
    {'icon': 'assets/icons/icon-switch.png', 'title': 'Switches'},
  ];

  @override
  void initState() {
    super.initState();
    productBox = Hive.box<Product>('products');
  }

  Future<void> _exportToExcel() async {
    final workbook = excel.Workbook();
    final sheet = workbook.worksheets[0];

    sheet.getRangeByName('A1').setText('Name');
    sheet.getRangeByName('B1').setText('Price');
    sheet.getRangeByName('C1').setText('Quantity');
    sheet.getRangeByName('D1').setText('Category');

    for (int i = 0; i < productBox.length; i++) {
      final product = productBox.getAt(i);
      sheet.getRangeByIndex(i + 2, 1).setText(product?.name);
      sheet.getRangeByIndex(i + 2, 2).setNumber(product?.price);
      sheet.getRangeByIndex(i + 2, 3).setNumber(product?.quantity?.toDouble());
      sheet.getRangeByIndex(i + 2, 4).setText(product?.category);
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/products.xlsx';
    final file = File(path);
    final bytes = workbook.saveAsStream();
    await file.writeAsBytes(bytes);
    workbook.dispose();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exported to $path')),
    );
  }

  void _showProductDialog({Product? product}) {
    final nameController = TextEditingController(text: product?.name ?? '');
    final priceController =
        TextEditingController(text: product?.price.toString() ?? '');
    final quantityController =
        TextEditingController(text: product?.quantity.toString() ?? '');
    String selectedCategory = product?.category ?? categories.first['title'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xff2a2b38),
          title: Text(product == null ? 'Add Product' : 'Edit Product',
              style: const TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildInputField('Name', nameController),
                _buildInputField('Price', priceController, isNumeric: true),
                _buildInputField('Quantity', quantityController, isNumeric: true),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category['title'],
                      child: Text(category['title']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedCategory = value;
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                  dropdownColor: const Color(0xff2a2b38),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                final price = double.tryParse(priceController.text) ?? 0.0;
                final quantity = int.tryParse(quantityController.text) ?? 0;
                final category = selectedCategory;

                final imagePath = categories
                    .firstWhere((cat) => cat['title'] == category)['icon'];

                if (name.isNotEmpty && category.isNotEmpty) {
                  if (product == null) {
                    productBox.add(Product(
                      name: name,
                      price: price,
                      quantity: quantity,
                      category: category,
                      imagePath: imagePath,
                    ));
                  } else {
                    product.name = name;
                    product.price = price;
                    product.quantity = quantity;
                    product.category = category;
                    product.imagePath = imagePath;
                    product.save();
                  }
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              child: const Text('Save', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white)),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue)),
        ),
      ),
    );
  }

  void _deleteProduct(int index) {
    productBox.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1f2029),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.green,
            onPressed: _exportToExcel,
            child: const Icon(Icons.file_download, color: Colors.white),
            tooltip: 'Export to Excel',
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            backgroundColor: Colors.blueGrey,
            onPressed: () => _showProductDialog(),
            child: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Add Product',
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: productBox.length,
        itemBuilder: (context, index) {
          final product = productBox.getAt(index);
          return Card(
            color: const Color(0xff2a2b38),
            child: ListTile(
              leading: CircleAvatar(child: Text('${product?.quantity ?? 0}')),
              title: Text(product?.name ?? '',
                  style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                '₹ ${product?.price.toStringAsFixed(2)} - ${product?.category}',
                style: const TextStyle(color: Colors.grey),
              ),

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showProductDialog(product: product),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteProduct(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
