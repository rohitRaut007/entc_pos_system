import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  final String currentPage;
  final Function(String) onPageSelected;

  const SideMenu({
    super.key,
    required this.currentPage,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          _logo(),
          const SizedBox(height: 110),
          _menuItem('Home', Icons.home),
          _menuItem('Products', Icons.inventory),
          _menuItem('Sales', Icons.show_chart),
          _menuItem('Inventory', Icons.storage),
          _menuItem('Invoice', Icons.picture_as_pdf),
          _menuItem('Settings', Icons.settings),
        ],
      ),
    );
  }

  Widget _logo() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.blueGrey,
      ),
      child: const Icon(
        Icons.electric_bolt,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  Widget _menuItem(String title, IconData icon) {
    return GestureDetector(
      onTap: () => onPageSelected(title),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: currentPage == title
                ? Colors.white.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(height: 5),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
