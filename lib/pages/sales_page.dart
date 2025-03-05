import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as excel;
import 'package:path_provider/path_provider.dart';
import '../models/sales.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  late Box<Sale> salesBox;

  @override
  void initState() {
    super.initState();
    _openSalesBox();
  }

  Future<void> _openSalesBox() async {
    salesBox = await Hive.openBox<Sale>('sales');
    setState(() {});
  }

  // Export sales data to Excel
  Future<void> _exportSalesToExcel() async {
    if (!salesBox.isOpen || salesBox.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No sales data to export.')),
      );
      return;
    }

    try {
      final workbook = excel.Workbook();
      final sheet = workbook.worksheets.addWithName('Sales Report');

      // Header row
      final headers = ['Customer Name', 'Total Amount', 'Date', 'Items'];
      for (var i = 0; i < headers.length; i++) {
        sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
      }

      for (var i = 0; i < salesBox.length; i++) {
        final sale = salesBox.getAt(i);
        if (sale == null) continue;

        final row = i + 2;

        sheet.getRangeByIndex(row, 1).setText(sale.customerName);
        sheet.getRangeByIndex(row, 2).setNumber(sale.totalAmount);
        sheet.getRangeByIndex(row, 3).setText(sale.date.toString());

        final items = sale.items.map((item) {
          return '${item.name} (x${item.quantity}) - ₹${item.price.toStringAsFixed(2)}';
        }).join(', ');

        sheet.getRangeByIndex(row, 4).setText(items);
      }

      final bytes = workbook.saveAsStream();
      workbook.dispose();

      final directory = await getDownloadsDirectory();
      final path = '${directory?.path}/sales_report.xlsx';
      final file = File(path);

      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Sales exported to: $path')),
      );
    } catch (e) {
      debugPrint('❌ Excel export error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to export sales data.')),
      );
    }
  }

  // Get the correct directory based on platform
  Future<Directory?> getDownloadsDirectory() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    } else if (Platform.isWindows) {
      return Directory('${Platform.environment['USERPROFILE']}\Downloads');
    } else if (Platform.isLinux || Platform.isMacOS) {
      return Directory('/home/${Platform.environment['USER']}/Downloads');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportSalesToExcel,
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Sale>('sales').listenable(),
        builder: (context, Box<Sale> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No Sales Data'));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final sale = box.getAt(index);
              if (sale == null) return const SizedBox.shrink();

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(sale.customerName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Amount: ₹${sale.totalAmount.toStringAsFixed(2)}'),
                      Text('Date: ${sale.date.toLocal()}'),
                      Text('Items: ${_formatItems(sale.items)}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Helper function to format sale items for display
  String _formatItems(List<SaleItem> items) {
    if (items.isEmpty) return 'No items';
    return items.map((item) => '${item.name} (x${item.quantity})').join(', ');
  }
}
