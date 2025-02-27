import 'package:flutter/material.dart';

class BillSummary extends StatelessWidget {
  final double total;

  const BillSummary({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    print("Rendering BillSummary: total=$total");
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total:', style: TextStyle(fontSize: 20, color: Colors.white)),
          Text("\$${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}
