import 'package:flutter/material.dart';
import 'package:wanderscout/Davin/models/touristattraction.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wanderscout/kez/services/cart_service.dart';

class AttractionDetailScreen extends StatelessWidget {
  final TouristAttraction attraction;

  const AttractionDetailScreen({super.key, required this.attraction});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          attraction.nama,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF313EBC),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF313EBC), Color(0xFFA6ADEF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        constraints: const BoxConstraints.expand(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: isSmallScreen
              ? _buildColumnLayout(context)
              : _buildRowLayout(context),
        ),
      ),
    );
  }

  Widget _buildColumnLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImage(),
        const SizedBox(height: 16),
        _buildDetails(context),
      ],
    );
  }

  Widget _buildRowLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 1, child: _buildImage()),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: _buildDetails(context)),
      ],
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        getImageForAttractionType(attraction.type),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 250,
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          attraction.nama,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          'Rating: ${attraction.voteAverage} / 5 (${attraction.voteCount} votes)',
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          'Type: ${attraction.type}',
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          'Weekday Price: IDR ${attraction.htmWeekday}',
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        Text(
          'Weekend Price: IDR ${attraction.htmWeekend}',
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          'Description:',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          attraction.description,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          'Location:',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          'Latitude: ${attraction.latitude}',
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        Text(
          'Longitude: ${attraction.longitude}',
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final url = attraction.gmapsUrl;
            final canLaunch = await canLaunchUrl(Uri.parse(url));
            if (canLaunch) {
              await launchUrl(Uri.parse(url));
            } else if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not launch Maps')),
              );
            }
          },
          child: const Text(
            'View on Google Maps',
            style: TextStyle(fontSize: 16, color: Colors.lightBlueAccent, decoration: TextDecoration.underline),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
          onPressed: () => _addToCart(context),
          child: const Text('Add to Cart'),
        ),
      ],
    );
  }

  Future<void> _addToCart(BuildContext context) async {
    try {
      await CartService.addToCart(attraction.id.toString(), 'attraction');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attraction added to cart successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add to cart: $e')),
        );
      }
    }
  }

  String getImageForAttractionType(String? type) {
    final firstCategory = type?.split(',').first.trim().replaceAll(' ', '').toLowerCase() ?? 'placeholder';
    return 'lib/static/attractions/$firstCategory.png';
  }
}
