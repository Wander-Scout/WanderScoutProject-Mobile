// lib/davin/widgets/left_drawer.dart

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:wanderscout/Hafizh/screens/delete_restaurant.dart';
import 'package:wanderscout/kez/screens/cart_screen.dart';
import 'package:wanderscout/Davin/screens/login.dart';
import 'package:wanderscout/Davin/screens/tourist_attraction_list.dart';
import 'package:wanderscout/Ella/screens/list_review.dart';
import 'package:wanderscout/Ella/screens/reviewentry_form.dart';
import 'package:wanderscout/Hafizh/screens/restaurant_list.dart';
import 'package:wanderscout/hh/screens/news.dart'; 
import 'package:wanderscout/Davin/providers/user_provider.dart';
import 'package:wanderscout/Hafizh/screens/add_restaurant.dart';
import 'package:wanderscout/Hafizh/screens/edit_restaurant.dart';
import 'package:wanderscout/Hafizh/screens/edit_profile.dart';
import 'package:wanderscout/Davin/screens/admin_tourist.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    bool isAdmin = userProvider.isAdmin;

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
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
          // Example user menu
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
                  builder: (context) => TouristAttractionScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.restaurant, color: Colors.black),
            title: const Text('Restaurants'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RestaurantListScreen(),
                ),
              );
            },
          ),

          // ============================
          // ADMIN-ONLY MENU SECTION
          // ============================
          if (isAdmin) ...[
            ListTile(
              leading: const Icon(Icons.add_business, color: Colors.black),
              title: const Text('Add Restaurant'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddRestaurantScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_sharp, color: Colors.black),
              title: const Text('Edit Restaurant'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchAndEditRestaurantScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.black),
              title: const Text('Delete Restaurant'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchAndDeleteRestaurantScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.manage_search, color: Colors.black),
              title: const Text('Manage Attractions'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminTouristAttractionScreen(),
                  ),
                );
              },
            ),
          ],
          ListTile(
            leading: const Icon(Icons.newspaper, color: Colors.black),
            title: const Text('News'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewsPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart, color: Colors.black),
            title: const Text('Shopping Cart'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.black),
            title: const Text('Edit Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.black),
            title: const Text('Logout'),
            onTap: () async {
              final request = Provider.of<CookieRequest>(context, listen: false);
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              const logoutUrl =
                  "http://alano-davin-wanderscout.pbp.cs.ui.ac.id/authentication/flutter_logout/";

              try {
                final response = await request.logout(logoutUrl);
                if (context.mounted) {
                  if (response != null && response['status'] != null) {
                    String message = response["message"] ?? "Unexpected error occurred.";
                    if (response['status']) {
                      // Reset admin/user state
                      userProvider.reset();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("$message Goodbye")),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message)),
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
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error during logout: $e")),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
