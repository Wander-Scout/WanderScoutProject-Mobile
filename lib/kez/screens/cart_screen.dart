import 'package:flutter/material.dart';
import 'package:wanderscout/kez/screens/receipt_screen.dart';
import 'package:wanderscout/kez/services/cart_service.dart';
import 'package:wanderscout/kez/models/cart_item.dart'; // Import the models

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Item> _cartItems = []; // Full list of cart items
  List<Item> _displayedItems = []; // Items currently displayed
  double _totalCost = 0.0;
  bool _isLoading = true; // Initial loading
  bool _isFetchingMore = false; // Loading during scroll
  final int _itemsToShow = 10; // Number of items to display per batch

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchCart();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  /// Fetch cart items from the server
  Future<void> _fetchCart() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cartDetails = await CartService.fetchCartItems(); // Use CartDetails model
      setState(() {
        _cartItems = cartDetails.cart.items; // Extract items
        _totalCost = _cartItems.fold(
          0.0,
          (sum, item) => sum + (item.price * item.quantity),
        ); // Calculate total cost
        _displayedItems = _cartItems.take(_itemsToShow).toList(); // Show initial items
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching cart: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Handle scroll listener to load more items
  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
        !_isFetchingMore) {
      _loadMoreItems();
    }
  }

  /// Load more items when scrolling down
  void _loadMoreItems() {
    if (_displayedItems.length >= _cartItems.length) {
      return; // No more items to load
    }

    setState(() {
      _isFetchingMore = true; // Start showing the loading spinner
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        final nextItems = _cartItems.skip(_displayedItems.length).take(_itemsToShow).toList();
        _displayedItems.addAll(nextItems);
        _isFetchingMore = false; // Stop showing the loading spinner
      });
    });
  }

  /// Handle removing an item
  Future<void> _removeItem(String itemId) async {
    try {
      await CartService.removeFromCart(itemId);
      setState(() {
        _cartItems.removeWhere((item) => item.id == itemId);
        _displayedItems = _cartItems.take(_displayedItems.length).toList();
        _totalCost = _cartItems.fold(
          0.0,
          (sum, item) => sum + (item.price * item.quantity),
        );
      });
    } catch (e) {
      print('Error removing item: $e');
    }
  }

  /// Handle checkout
 Future<void> _checkout() async {
  try {
    final receipt = await CartService.checkout();

    // Navigate to ReceiptScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptScreen(
          bookingId: receipt.bookingId,
          services: receipt.items.map((item) => item.name).toList(),
          totalPrice: receipt.totalPrice, // Ensure this is a double
        ),
      ),
    );
  } catch (e) {
    print('Checkout error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Checkout failed: $e')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _displayedItems.length + 1, // Add 1 for the loading spinner
                    itemBuilder: (_, index) {
                      if (index == _displayedItems.length) {
                        // Show loading spinner at the bottom if fetching more items
                        return _isFetchingMore
                            ? const Center(child: CircularProgressIndicator())
                            : const SizedBox.shrink();
                      }

                      final item = _displayedItems[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Price: Rp ${item.price} x ${item.quantity}'),
                            Text(item.isWeekend ? 'Weekend Special' : 'Regular'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeItem(item.id),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Total: Rp $_totalCost'),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _cartItems.isEmpty ? null : _checkout,
                        child: const Text('Checkout'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
