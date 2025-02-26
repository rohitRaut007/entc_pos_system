import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as excel;
import 'package:path_provider/path_provider.dart';

import '../models/sales.dart';

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
    _openHiveBox();
  }

  Future<void> _openHiveBox() async {
    salesBox = await Hive.openBox<Sale>('sales');
    setState(() {});
  }

  Future<void> _exportSalesToExcel() async {
    if (!salesBox.isOpen || salesBox.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No sales data to export.')),
      );
      return;
    }

    final workbook = excel.Workbook();
    final sheet = workbook.worksheets.addWithName('Sales Report');

    sheet.getRangeByName('A1').setText('Customer Name');
    sheet.getRangeByName('B1').setText('Total Amount');
    sheet.getRangeByName('C1').setText('Date');

    for (var i = 0; i < salesBox.length; i++) {
      final sale = salesBox.getAt(i);
      final row = i + 2;

      sheet.getRangeByName('A$row').setText(sale?.customerName ?? '');
      sheet.getRangeByName('B$row').setNumber(sale?.totalAmount ?? 0.0);
      sheet.getRangeByName('C$row').setText(sale?.date.toString() ?? '');
    }

    final bytes = workbook.saveAsStream();
    workbook.dispose();

    final directory = await getDownloadsDirectory();
    final path = '${directory?.path}/sales_report.xlsx';
    final file = File(path);

    await file.writeAsBytes(bytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sales exported to: $path')),
    );
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
      body: salesBox.isEmpty
          ? const Center(child: Text('No Sales Data'))
          : ListView.builder(
              itemCount: salesBox.length,
              itemBuilder: (context, index) {
                final sale = salesBox.getAt(index);
                return ListTile(
                  title: Text(sale?.customerName ?? 'Unknown Customer'),
                  subtitle: Text('Amount: \$${sale?.totalAmount?.toStringAsFixed(2)}'),
                  trailing: Text(sale?.date.toString() ?? ''),
                );
              },
            ),
    );
  }
}
