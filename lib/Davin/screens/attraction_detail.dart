import 'package:flutter/material.dart';
import 'package:wanderscout/Davin/models/touristattraction.dart';
import 'package:url_launcher/url_launcher.dart';

class AttractionDetailScreen extends StatelessWidget {
  final TouristAttraction attraction;

  const AttractionDetailScreen({super.key, required this.attraction});

  @override
  Widget build(BuildContext context) {
    // Get screen width to adjust layout for small or large screens
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(attraction.nama),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: isSmallScreen
            ? _buildColumnLayout(context)
            : _buildRowLayout(context),
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
    // Placeholder image logic; replace with actual image logic as needed
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
        // Name
        Text(
          attraction.nama,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // Rating
        Text(
          'Rating: ${attraction.voteAverage} / 5 (${attraction.voteCount} votes)',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        // Type
        Text(
          'Type: ${attraction.type}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        // Prices
        Text(
          'Weekday Price: IDR ${attraction.htmWeekday}',
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          'Weekend Price: IDR ${attraction.htmWeekend}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        // Description
        Text(
          'Description:',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          attraction.description,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        // Location (Latitude, Longitude)
        Text(
          'Location:',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Latitude: ${attraction.latitude}',
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          'Longitude: ${attraction.longitude}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        // Google Maps URL
        InkWell(
          onTap: () async {
            final url = attraction.gmapsUrl;
            final canLaunch = await canLaunchUrl(Uri.parse(url));

            if (canLaunch) {
              await launchUrl(Uri.parse(url));
            } else if (context.mounted) {
              // Check if widget is still mounted
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not launch Maps')),
              );
            }
          },
          child: const Text(
            'View on Google Maps',
            style: TextStyle(fontSize: 16, color: Colors.blue),
          ),
        )
      ],
    );
  }

  String getImageForAttractionType(String? type) {
    final firstCategory = type
            ?.split(',')
            .first
            .trim()
            .replaceAll(' ', '')
            .toLowerCase() ??
        'placeholder';
    return 'lib/static/attractions/$firstCategory.png';
  }
}
