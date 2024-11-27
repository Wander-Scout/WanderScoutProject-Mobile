import 'package:flutter/material.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor, // Use primary color
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'WANDERSCOUT',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Explore Yogyakarta with us!",
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.white70,
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.comment, color: Colors.black),
            title: const Text('Customer Reviews'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.place, color: Colors.black),
            title: const Text('Tourist Attractions'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.restaurant, color: Colors.black),
            title: const Text('Restaurants'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.newspaper, color: Colors.black),
            title: const Text('News'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart, color: Colors.black),
            title: const Text('Shopping Cart'),
            onTap: () {},
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.black),
            title: const Text('Logout'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
