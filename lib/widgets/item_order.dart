import 'package:flutter/material.dart';

class ItemOrder extends StatelessWidget {
  final Map<String, dynamic> item;

  const ItemOrder({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    print("Rendering ItemOrder: $item");
    return ListTile(
      leading: Image.asset(item['image'], height: 40),
      title: Text(item['title']),
      subtitle: Text(item['item']),
      trailing: Text("\$${item['price']}"),
    );
  }
}
