import 'package:flutter/material.dart';
import 'package:wanderscout/kez/screens/booking_search.dart';
import 'package:wanderscout/kez/services/cart_service.dart';
import 'package:wanderscout/kez/models/cart_item.dart';
import 'package:wanderscout/kez/screens/receipt_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Item> _cartItems = [];
  List<Item> _displayedItems = [];
  double _totalCost = 0.0;
  bool _isLoading = true;
  bool _isFetchingMore = false;
  final int _itemsToShow = 10;

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

  Future<void> _fetchCart() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cartDetails = await CartService.fetchCartItems();
      setState(() {
        _cartItems = cartDetails.cart.items;
        _totalCost = _cartItems.fold(
          0.0,
          (sum, item) => sum + (item.price * item.quantity),
        );
        _displayedItems = _cartItems.take(_itemsToShow).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
        !_isFetchingMore) {
      _loadMoreItems();
    }
  }

  void _loadMoreItems() {
    if (_displayedItems.length >= _cartItems.length) {
      return;
    }

    setState(() {
      _isFetchingMore = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        final nextItems = _cartItems.skip(_displayedItems.length).take(_itemsToShow).toList();
        _displayedItems.addAll(nextItems);
        _isFetchingMore = false;
      });
    });
  }

  Future<void> _checkout() async {
    try {
      final receipt = await CartService.checkout();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ReceiptScreen(receipt: receipt),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to checkout. Please try again.')),
        );
      }
    }
  }

  Future<void> _removeItem(String itemId) async {
    try {
      await CartService.removeFromCart(itemId);
      if (mounted) {
        setState(() {
          _cartItems.removeWhere((item) => item.id == itemId);
          _displayedItems = _cartItems.take(_displayedItems.length).toList();
          _totalCost = _cartItems.fold(
            0.0,
            (sum, item) => sum + (item.price * item.quantity),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove item: $e')),
        );
      }
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
                    itemCount: _displayedItems.length + 1,
                    itemBuilder: (_, index) {
                      if (index == _displayedItems.length) {
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
                        onPressed: _checkout,
                        child: const Text('Checkout'),
                      ),
                      ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BookingSearchScreen(),
                          ),
                        );
                      },
                      child: const Text('Search Booking'),
                    ),

                    ],
                  ),
                ),
              ],
            ),
    );
  }
}