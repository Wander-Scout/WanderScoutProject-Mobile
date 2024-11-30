import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:wanderscout/kez/screens/cart_screen.dart';
import 'package:wanderscout/davin/screens/login.dart';
import 'package:wanderscout/davin/screens/tourist_attraction_list.dart';

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
              onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TouristAttractionScreen()),
              );
            },
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.black),
            title: const Text('Logout'),
            onTap: () async {
              final request = Provider.of<CookieRequest>(context, listen: false);
              const logoutUrl = "http://127.0.0.1:8000/authentication/flutter_logout/";

              final response = await request.logout(logoutUrl);

              if (context.mounted) {
                String message = response["message"];
                if (response['status']) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("$message Goodbye"),
                    ),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
