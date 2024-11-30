import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:wanderscout/Davin/widgets/left_drawer.dart';
import 'package:wanderscout/kez/models/cart_item.dart'; // Adjust the import if necessary

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<CartDetails> fetchCart() async {
    try {
      // Retrieve the authentication token
      final token = await _storage.read(key: 'auth_token');

      if (token == null) {
        throw Exception('Authentication token not found. Please log in.');
      }

      print('Token being sent: $token');

      // Make the HTTP GET request to fetch the cart
      final url = Uri.parse('http://localhost:8000/cart/api/cart/');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Token $token',
        },
      );

      print('Request headers: ${response.request?.headers}');
      print('Response body: ${response.body}');

      // Handle the response
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return CartDetails.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      } else {
        throw Exception('Failed to fetch cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      drawer: const LeftDrawer(),
      body: FutureBuilder(
        future: fetchCart(),
        builder: (context, AsyncSnapshot<CartDetails> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.cart.items.isEmpty) {
            return const Center(
              child: Text(
                'No items in the cart.',
                style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
              ),
            );
          } else {
            final cartItems = snapshot.data!.cart.items;
            return ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (_, index) {
                final item = cartItems[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8.0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text("Price: IDR ${item.price}"),
                      const SizedBox(height: 10),
                      Text("Quantity: ${item.quantity}"),
                      const SizedBox(height: 10),
                      Text(item.isWeekend ? 'Weekend Special' : 'Regular'),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Handle item removal or any other functionality
                        },
                        child: const Text('Remove from Cart'),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
