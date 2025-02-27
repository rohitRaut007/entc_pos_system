// category_tab.dart
import 'package:flutter/material.dart';

class CategoryTabs extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final int activeTabIndex;
  final Function(int) onTabChange;

  const CategoryTabs({
    super.key,
    required this.categories,
    required this.activeTabIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          print("Rendering category: \$category");
          return GestureDetector(
            onTap: () => onTabChange(index),
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: index == activeTabIndex ? Colors.deepOrange : Colors.grey[800],
              ),
              child: Row(
                children: [
                  Image.asset(category['icon'], height: 30),
                  const SizedBox(width: 5),
                  Text(
                    category['title'],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: index == activeTabIndex ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}