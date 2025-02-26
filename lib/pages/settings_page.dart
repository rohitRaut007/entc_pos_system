import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as excel;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../models/product.dart';
import '../models/sales.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;

  // Toggle Theme
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    // Implement theme switching logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isDarkMode ? 'Dark Mode Enabled' : 'Light Mode Enabled'),
      ),
    );
  }

  // Export Products and Sales to Excel
  Future<void> _exportDataToExcel() async {
    final productBox = Hive.box<Product>('products');
    final salesBox = Hive.box<Sale>('sales');

    final workbook = excel.Workbook();
    final productSheet = workbook.worksheets.addWithName('Products');
    final salesSheet = workbook.worksheets.addWithName('Sales');

    // Write Product Data
    productSheet.getRangeByName('A1').setText('Name');
    productSheet.getRangeByName('B1').setText('Category');
    productSheet.getRangeByName('C1').setText('Price');
    productSheet.getRangeByName('D1').setText('Quantity');

    for (var i = 0; i < productBox.length; i++) {
      final product = productBox.getAt(i);
      final row = i + 2;
      productSheet.getRangeByName('A$row').setText(product?.name ?? '');
      productSheet.getRangeByName('B$row').setText(product?.category ?? '');
      productSheet.getRangeByName('C$row').setNumber(product?.price ?? 0.0);
      // productSheet.getRangeByName('D$row').setNumber(product?.quantity ?? 0);
    }

    // Write Sales Data
    salesSheet.getRangeByName('A1').setText('Customer');
    salesSheet.getRangeByName('B1').setText('Total Amount');
    salesSheet.getRangeByName('C1').setText('Date');

    for (var i = 0; i < salesBox.length; i++) {
      final sale = salesBox.getAt(i);
      final row = i + 2;
      salesSheet.getRangeByName('A$row').setText(sale?.customerName ?? '');
      salesSheet.getRangeByName('B$row').setNumber(sale?.totalAmount ?? 0.0);
      salesSheet.getRangeByName('C$row').setText(sale?.date.toString() ?? '');
    }

    final bytes = workbook.saveAsStream();
    workbook.dispose();

    final directory = await getDownloadsDirectory();
    final path = '${directory?.path}/pos_data_export.xlsx';
    final file = File(path);
    await file.writeAsBytes(bytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data exported to: $path')),
    );
  }

  // Clear All Data (Products & Sales)
  Future<void> _clearAllData() async {
    await Hive.box<Product>('products').clear();
    await Hive.box<Sale>('sales').clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All data has been cleared!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? const Color(0xff1f2029) : Colors.white,
      appBar: AppBar(
        backgroundColor: _isDarkMode ? const Color(0xff2a2b38) : Colors.blue,
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingsItem(
            icon: Icons.dark_mode,
            title: 'Toggle Theme',
            onTap: _toggleTheme,
          ),
          _buildSettingsItem(
            icon: Icons.file_download,
            title: 'Export Data to Excel',
            onTap: _exportDataToExcel,
          ),
          _buildSettingsItem(
            icon: Icons.delete_forever,
            title: 'Clear All Data',
            onTap: _clearAllData,
          ),
          const Divider(),
          _buildSettingsItem(
            icon: Icons.info,
            title: 'About App',
            onTap: () => _showAboutDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
      {required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      color: _isDarkMode ? const Color(0xff2a2b38) : Colors.grey[200],
      child: ListTile(
        leading: Icon(icon, color: _isDarkMode ? Colors.white : Colors.black),
        title: Text(title, style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'POS System',
      applicationVersion: 'v1.0.0',
      applicationIcon: const Icon(Icons.shopping_cart, size: 40),
      children: [
        const Text('Developed by Rohit Raut'),
        const Text('Contact: 7769977012'),
        const Text('Website: https://rohitraut.vercel.app/'),
      ],
    );
  }
}

// Helper function to get the Downloads directory
Future<Directory?> getDownloadsDirectory() async {
  if (Platform.isWindows) {
    return Directory('${Platform.environment['USERPROFILE']}\\Downloads');
  } else if (Platform.isLinux || Platform.isMacOS) {
    return Directory('/home/${Platform.environment['USER']}');
  } else {
    return getApplicationDocumentsDirectory();
  }
}
