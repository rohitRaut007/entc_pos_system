import 'package:flutter/material.dart';

class TopMenu extends StatelessWidget {
  final String title;
  final String subTitle;
  final Widget action;

  const TopMenu({
    super.key,
    required this.title,
    required this.subTitle,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    print("Rendering TopMenu: title=$title, subTitle=$subTitle");
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 24,color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subTitle, style: const TextStyle(fontSize: 16,color: Colors.white)),
            ],
          ),
          action,
        ],
      ),
    );
  }
}
