import 'package:flutter/material.dart';
import 'package:wanderscout/davin/widgets/left_drawer.dart';
import 'package:wanderscout/davin/widgets/card.dart';

class MyHomePage extends StatelessWidget {
  final List<ItemHomepage> items = [
    ItemHomepage("Customer Reviews", Icons.comment, Color(0xFF3B82F6)), // blue-500
    ItemHomepage("Tourist Attractions", Icons.place, Color(0xFF10B981)), // green-500
    ItemHomepage("Restaurants", Icons.restaurant, Color(0xFFF59E0B)), // amber-500
    ItemHomepage("Cart", Icons.shopping_cart, Color(0xFF10B981)), // green-500
    ItemHomepage("News", Icons.newspaper, Color(0xFF3B82F6)), // blue-500
    ItemHomepage("Logout", Icons.logout, Color(0xFFEF4444)), // red-500
  ];

  MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WANDERSCOUT'),
        centerTitle: true,
      ),
      drawer: const LeftDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text(
              'Explore Jogja With Us!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 columns
                  crossAxisSpacing: 8, // Space between columns
                  mainAxisSpacing: 8, // Space between rows
                  childAspectRatio: 1.2, // Slightly taller than square
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ItemCard(items[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
