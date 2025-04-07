import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/sale_order.dart';
import 'transaction_details_page.dart';

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<SaleOrder>('sales').listenable(),
      builder: (context, Box<SaleOrder> box, _) {
        final sales = box.values.toList().reversed.toList();

        if (sales.isEmpty) {
          return const Center(
            child: Text(
              'No sales yet.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView.builder(
          itemCount: sales.length,
          itemBuilder: (context, index) {
            final sale = sales[index];

            return Card(
              color: const Color(0xff272833),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(
                  sale.customerName,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '₹${sale.orderAmount.toStringAsFixed(2)} - ${sale.transactionDateTime.toLocal()}',
                  style: const TextStyle(color: Colors.white60),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TransactionDetailsPage(saleOrder: sale),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
