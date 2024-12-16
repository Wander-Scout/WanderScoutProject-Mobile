import 'dart:convert';
import 'package:wanderscout/Davin/API/api_service.dart';
import 'package:wanderscout/kez/models/cart_item.dart'; 

class CartService {
  static const String baseUrl = 'https://alano-davin-wanderscout.pbp.cs.ui.ac.id';
  static final ApiService _apiService = ApiService();

  static Future<CartDetails> fetchCartItems() async {
    final url = '$baseUrl/cart/api/cart/items';

    try {
      final response = await _apiService.get(url: url);

      if (response.statusCode == 200) {
        return CartDetails.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch cart: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> addToCart(String itemId, String itemType) async {
    final url = '$baseUrl/cart/api/cart/add/$itemId/';
    final body = {'item_type': itemType};

    try {
      final response = await _apiService.post(url: url, body: body);

      if (response.statusCode != 200) {
        throw Exception('Failed to add item to cart: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> removeFromCart(String itemId) async {
    final url = '$baseUrl/cart/api/cart/remove/$itemId/';

    try {
      final response = await _apiService.post(url: url);

      if (response.statusCode != 200) {
        throw Exception('Failed to remove item: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Receipt> checkout() async {
    final url = '$baseUrl/cart/api/cart/checkout/';

    try {
      final response = await _apiService.post(url: url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Receipt.fromJson(json["receipt"]);
      } else {
        throw Exception('Checkout failed: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Receipt> fetchBookingById(String bookingId) async {
    final url = '$baseUrl/cart/api/search/?booking_id=$bookingId';

    try {
      final response = await _apiService.get(url: url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Receipt.fromJson(json); // Deserialize into Receipt model
      } else if (response.statusCode == 404) {
        throw Exception('Booking not found.');
      } else {
        throw Exception('Failed to fetch booking: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}

