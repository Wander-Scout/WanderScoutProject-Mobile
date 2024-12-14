import 'package:flutter/material.dart';

class RestaurantCard extends StatelessWidget {
  final dynamic restaurant; // JSON data for the restaurant
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 4.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder image
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10.0)),
            ),
            child: const Icon(Icons.restaurant, size: 60.0, color: Colors.grey),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant['name'] ?? 'Unnamed Restaurant',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Cuisine: ${restaurant['food_preference'] ?? 'Unknown'}',
                  style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                ),
                Text(
                  'Price: Rp ${restaurant['average_price']?.toString() ?? 'N/A'}',
                  style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                ),
                Text(
                  'Rating: ${restaurant['rating']?.toString() ?? 'N/A'}',
                  style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (onEdit != null || onDelete != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: onEdit,
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
