import 'package:flutter/material.dart';
import '../models/sale_order.dart';
import '../models/order_item.dart';

class TransactionDetailsPage extends StatelessWidget {
  final SaleOrder saleOrder;

  const TransactionDetailsPage({super.key, required this.saleOrder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xff17181f),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoTile('Customer Name', saleOrder.customerName),
            _buildInfoTile('Mobile Number', saleOrder.customerMobile),
            _buildInfoTile('Transaction ID', saleOrder.transactionId),
            _buildInfoTile('Date & Time', saleOrder.transactionDateTime.toString()),
            _buildInfoTile('Total Amount', '₹${saleOrder.orderAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const Text(
              'Ordered Items',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: saleOrder.items.length,
                itemBuilder: (context, index) {
                  OrderItem item = saleOrder.items[index];
                  return ListTile(
                    title: Text(item.productName, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(
                      '${item.quantity} x ₹${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Text(
                      '₹${(item.quantity * item.price).toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.greenAccent),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
