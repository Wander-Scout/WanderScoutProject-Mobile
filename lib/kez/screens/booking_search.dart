import 'package:flutter/material.dart';
import 'package:wanderscout/kez/services/cart_service.dart';
import 'package:wanderscout/kez/screens/receipt_screen.dart';

class BookingSearchScreen extends StatefulWidget {
  const BookingSearchScreen({super.key});

  @override
  State<BookingSearchScreen> createState() => _BookingSearchScreenState();
}

class _BookingSearchScreenState extends State<BookingSearchScreen> {
  final TextEditingController _bookingIdController = TextEditingController();
  bool _isLoading = false;

  Future<void> _searchBooking() async {
    final bookingId = _bookingIdController.text.trim();

    if (bookingId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a booking ID')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final receipt = await CartService.fetchBookingById(bookingId);

      if (mounted) {
        // Navigate to the ReceiptScreen with the fetched receipt
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ReceiptScreen(receipt: receipt),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Booking')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _bookingIdController,
              decoration: const InputDecoration(
                labelText: 'Booking ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _searchBooking,
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}
