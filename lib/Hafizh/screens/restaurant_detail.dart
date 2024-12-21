import 'package:flutter/material.dart';
import '../models/restaurant.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          restaurant.name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Section
            Stack(
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[800],
                    image: DecorationImage(
                      image: AssetImage(
                        getImageForFoodPreference(restaurant.foodPreference.displayName),
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      restaurant.name,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 5,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),

            // Details Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // About Section
                  const SizedBox(height: 16),
                  Text(
                    "About ${restaurant.name}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),

                  // Template Description
                    const SizedBox(height: 8),
                    Text(
                      "${restaurant.name} is a popular destination for food enthusiasts looking for ${restaurant.foodPreference.displayName} cuisine. "
                      "The restaurant offers a unique atmosphere with a ${restaurant.atmosphere.displayName} vibe, "
                      "and its signature dishes are known for their ${restaurant.foodVariety.toLowerCase()}. With an average price of Rp ${restaurant.averagePrice}, "
                      "${restaurant.name} is a perfect choice for those seeking a ${restaurant.atmosphere.displayName} dining experience. "
                      "Rated ${restaurant.rating}/5, it’s no wonder ${restaurant.name} is a favorite among locals and tourists alike.",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 8),
                  

                  // Key Information Section
                  const Text(
                    "Key Information",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow("Food Preference", restaurant.foodPreference.displayName),
                  _buildInfoRow("Rating", "${restaurant.rating} / 5"),
                  _buildInfoRow("Average Price", "Rp ${restaurant.averagePrice}"),
                  _buildInfoRow("Atmosphere", restaurant.atmosphere.displayName),
                  _buildInfoRow("Food Varietys", restaurant.foodVariety),

                  const SizedBox(height: 16),

                  // Call-to-Action Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Plan Your Visit",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Make sure to visit ${restaurant.name} and enjoy the delicious food and great atmosphere!",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Add to cart logic here
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: const Text("Add to Plan"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title:",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  String getImageForFoodPreference(String foodPreference) {
    final typeValue = foodPreference.toLowerCase().replaceAll(' ', '');
    return 'lib/static/food_pref/$typeValue.jpg';
  }
}
