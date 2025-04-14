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
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isActive = index == activeTabIndex;

          return GestureDetector(
            onTap: () => onTabChange(index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: isActive
                    ? Colors.deepOrange
                    : const Color(0xff2a2b38).withOpacity(0.8),
                border: isActive
                    ? null
                    : Border.all(color: Colors.white24, width: 1),
              ),
              child: Row(
                children: [
                  Image.asset(
                    category['icon'],
                    height: 24,
                    width: 24,
                    color: isActive ? Colors.white : Colors.white70,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.image_not_supported,
                          color: isActive ? Colors.white : Colors.white70);
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category['title'],
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white70,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w400,
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
