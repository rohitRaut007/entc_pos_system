//item order


import 'package:flutter/material.dart';

class ItemOrder extends StatelessWidget {
  final Map<String, dynamic> item;

  const ItemOrder({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[850], // Lighter background for better contrast
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Image.asset(item['image'], height: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Improved contrast
                  ),
                ),
                Text(
                  'Quantity: ${item['quantity']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[300], // Lighter for better visibility
                  ),
                ),
              ],
            ),
          ),
          Text(
            "₹${item['price']}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
