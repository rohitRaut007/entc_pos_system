import 'package:flutter/material.dart';

class ItemOrder extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onDelete;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final Function(int) onQuantityChange;

  const ItemOrder({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onIncrease,
    required this.onDecrease,
    required this.onQuantityChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              item['image'] ?? 'assets/default_image.png',
              height: 70,
              width: 70,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              item['title'] ?? 'Unknown Item',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: onDecrease,
                icon: const Icon(Icons.remove_circle_outline),
                color: Colors.grey[800],
              ),
              GestureDetector(
                onTap: () async {
                  final newQuantity = await _showQuantityDialog(context, item['quantity']);
                  if (newQuantity != null) {
                    onQuantityChange(newQuantity);
                  }
                },
                child: Text(
                  '${item['quantity'] ?? 0}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: onIncrease,
                icon: const Icon(Icons.add_circle_outline),
                color: Colors.grey[800],
              ),
            ],
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${item['price'] ?? 0.0}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.close),
                color: Colors.redAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<int?> _showQuantityDialog(BuildContext context, int currentQuantity) async {
    final TextEditingController controller = TextEditingController(text: currentQuantity.toString());
    return await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Quantity'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter new quantity'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newQuantity = int.tryParse(controller.text) ?? currentQuantity;
              Navigator.pop(context, newQuantity);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
