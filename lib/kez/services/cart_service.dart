import 'dart:convert';
import 'package:wanderscout/Davin/API/api_service.dart';
import 'package:wanderscout/kez/models/cart_item.dart'; 

class CartService {
  static const String baseUrl = 'http://localhost:8000/cart/api';
  static final ApiService _apiService = ApiService();

  // Fetch cart items
  static Future<CartDetails> fetchCartItems() async {
    final url = '$baseUrl/cart/items/';

    try {
      final response = await _apiService.get(url: url);
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Deserialize JSON response into CartDetails model
        return CartDetails.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch cart: ${response.body}');
      }
    } catch (e) {
      print('Error fetching cart items: $e');
      rethrow;
    }
  }

  // Add to cart
  static Future<void> addToCart(String itemId, String itemType) async {
    final url = '$baseUrl/cart/add/$itemId/';
    final body = {'item_type': itemType};

    try {
      final response = await _apiService.post(url: url, body: body);

      if (response.statusCode != 200) {
        throw Exception('Failed to add item to cart: ${response.body}');
      }
    } catch (e) {
      print('Error adding item to cart: $e');
      rethrow;
    }
  }

  // Remove from cart
  static Future<void> removeFromCart(String itemId) async {
    final url = '$baseUrl/cart/remove/$itemId/';

    try {
      final response = await _apiService.post(url: url);

      if (response.statusCode != 200) {
        throw Exception('Failed to remove item: ${response.body}');
      }
    } catch (e) {
      print('Error removing item from cart: $e');
      rethrow;
    }
  }

static Future<Receipt> checkout() async {
  final url = '$baseUrl/cart/checkout/';

  try {
    final response = await _apiService.post(url: url);
    print('Checkout Response Body: ${response.body}');


    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['success'] == true) {
        // Ensure correct parsing for the Receipt model
        return Receipt.fromJson(responseBody['receipt']);
      } else {
        throw Exception('Checkout failed: ${responseBody['error']}');
      }
    } else {
      throw Exception('Checkout failed: ${response.body}');
    }
  } catch (e) {
    print('Error during checkout: $e');
    throw Exception('An error occurred during checkout. Please try again.');
  }
}



}
