import 'package:flutter/material.dart';
import '../models/sale_order.dart';
import 'package:intl/intl.dart';

class TransactionCard extends StatelessWidget {
  final SaleOrder saleOrder;
  final VoidCallback onTap;

  const TransactionCard({
    super.key,
    required this.saleOrder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("Customer: ${saleOrder.customerName}"),
      subtitle: Text(DateFormat('dd MMM yyyy – hh:mm a').format(saleOrder.transactionDateTime)),
      trailing: Text("₹${saleOrder.orderAmount.toStringAsFixed(2)}"),
      onTap: onTap,
    );
  }
}
