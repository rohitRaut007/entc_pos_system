import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final String image;
  final String title;
  final double price;
  final int stockQuantity; // Adding stockQuantity field
  final VoidCallback onTap;

  const ItemCard({
    super.key,
    required this.image,
    required this.title,
    required this.price,
    required this.stockQuantity, // Add stockQuantity parameter
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, height: 90),
            const SizedBox(height: 2),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("₹${price.toStringAsFixed(2)}"),
             // Check if stock is exactly 0 first
            if (stockQuantity == 0) 
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(top: 8),
                child: Text(
                  'Out of Stock!',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 245, 5, 5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            // Then check if stock is less than 10
            else if (stockQuantity < 10)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(top: 8),
                child: Text(
                  'Only $stockQuantity left!',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 245, 5, 5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            
          ],
        ),
      ),
    );
  }
}
