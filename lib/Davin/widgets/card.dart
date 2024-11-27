import 'package:flutter/material.dart';

class ItemHomepage {
  final String title;
  final IconData icon;
  final Color color;

  ItemHomepage(this.title, this.icon, this.color);
}

class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: item.color.withOpacity(0.1),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6), // Smaller corner radius
        side: BorderSide(
          color: item.color.withOpacity(0.6), // Border color for distinction
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          // Handle tap
        },
        child: Padding(
          padding: const EdgeInsets.all(4.0), // Minimized padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 24, color: item.color), // Smaller icon
              const SizedBox(height: 4),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10, // Smaller font size
                  color: item.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
