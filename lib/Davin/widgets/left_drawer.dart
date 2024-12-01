import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:wanderscout/kez/screens/cart_screen.dart';
import 'package:wanderscout/davin/screens/login.dart';
import 'package:wanderscout/davin/screens/tourist_attraction_list.dart';
import 'package:wanderscout/ella/screens/list_review.dart';
import 'package:wanderscout/ella/screens/reviewentry_form.dart';
import 'package:wanderscout/Hafizh/screens/restaurant_list.dart';

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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReviewListPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_comment, color: Colors.black),
            title: const Text('Add a Review'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReviewEntryFormPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.place, color: Colors.black),
            title: const Text('Tourist Attractions'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TouristAttractionScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.restaurant, color: Colors.black),
            title: const Text('Restaurants'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RestaurantListScreen()),
              );
            },
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
              final request =
                  Provider.of<CookieRequest>(context, listen: false);
              const logoutUrl =
                  "http://127.0.0.1:8000/authentication/flutter_logout/";

              try {
                final response = await request.logout(logoutUrl);

                if (context.mounted) {
                  if (response != null && response['status'] != null) {
                    String message =
                        response["message"] ?? "Unexpected error occurred.";
                    if (response['status']) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("$message Goodbye"),
                        ),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Failed to log out. Please try again."),
                      ),
                    );
                  }
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Error during logout: $e"),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}