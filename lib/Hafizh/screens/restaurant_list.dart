import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/restaurant.dart'; // Import your Restaurant model
import 'package:wanderscout/davin/widgets/left_drawer.dart'; // Import LeftDrawer

class RestaurantListScreen extends StatefulWidget {
  @override
  _RestaurantListScreenState createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  List<Restaurant> displayedRestaurants = [];
  List<Restaurant> allRestaurants = [];
  List<Restaurant> filteredRestaurants = [];
  final int pageSize = 10;
  bool isLoading = false;

  String selectedFoodPreference = 'All';
  List<String> foodPreferences = ['All'];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchRestaurants();
  }

  Future<void> fetchRestaurants() async {
    try {
      // Retrieve the authentication token
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Authentication token not found. Please log in.');
      }

      // Fetch restaurants with token
      final url =
          Uri.parse('http://127.0.0.1:8000/restaurant/api_restaurant/');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Token $token',
        },
      );

      // Handle the API response
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          allRestaurants = data
              .map((item) => Restaurant.fromJson(item))
              .toList();

          // Extract unique food preferences for filtering
          final preferences = allRestaurants
              .map((restaurant) => restaurant.foodPreference)
              .toSet()
              .toList();
          foodPreferences = [
            'All',
            ...preferences.map((e) => e.displayName).toList()
          ];

          filteredRestaurants = List.from(allRestaurants);
          displayedRestaurants = filteredRestaurants.take(pageSize).toList();
        });
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      } else {
        throw Exception(
            'Failed to fetch restaurants: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching restaurants: $error');
    }
  }

  void filterRestaurants() {
    setState(() {
      // Apply both the food preference filter and search query
      filteredRestaurants = allRestaurants.where((restaurant) {
        final matchesFoodPreference = selectedFoodPreference == 'All' ||
            restaurant.foodPreference.displayName == selectedFoodPreference;
        final matchesSearchQuery = restaurant.name
            .toLowerCase()
            .contains(searchQuery.toLowerCase());
        return matchesFoodPreference && matchesSearchQuery;
      }).toList();

      // Reset displayedRestaurants for pagination
      displayedRestaurants = filteredRestaurants.take(pageSize).toList();
    });
  }

  void loadMoreRestaurants() {
    if (displayedRestaurants.length >= filteredRestaurants.length ||
        isLoading) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      final nextItems = filteredRestaurants
          .skip(displayedRestaurants.length)
          .take(pageSize)
          .toList();
      setState(() {
        displayedRestaurants.addAll(nextItems);
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
      ),
      drawer: const LeftDrawer(),
      body: Column(
        children: [
          // Search and Filter Row
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Search Bar
                Expanded(
                  flex: 2,
                  child: TextField(
                    onChanged: (value) {
                      searchQuery = value;
                      filterRestaurants();
                    },
                    decoration: InputDecoration(
                      labelText: 'Search by name...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Filter Dropdown
                Expanded(
                  flex: 1,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedFoodPreference,
                    items: foodPreferences
                        .map((preference) => DropdownMenuItem<String>(
                              value: preference,
                              child: Text(preference),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedFoodPreference = value;
                        filterRestaurants();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          // Restaurant List
          Expanded(
            child: allRestaurants.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                        loadMoreRestaurants();
                      }
                      return false;
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount:
                          displayedRestaurants.length + (isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < displayedRestaurants.length) {
                          final restaurant = displayedRestaurants[index];

                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.only(bottom: 16.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  // Restaurant Name
                                  Text(
                                    restaurant.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Rating
                                  Text(
                                    'Rating: ${restaurant.rating} / 5',
                                    style: const TextStyle(
                                        color: Colors.grey),
                                  ),
                                  const SizedBox(height: 4),
                                  // Average Price
                                  Text(
                                    'Average Price: Rp ${restaurant.averagePrice}',
                                    style: const TextStyle(
                                        color: Colors.grey),
                                  ),
                                  const SizedBox(height: 4),
                                  // Food Preference
                                  Text(
                                    'Food Preference: ${restaurant.foodPreference.displayName}',
                                    style: const TextStyle(
                                        color: Colors.grey),
                                  ),
                                  const SizedBox(height: 4),
                                  // Atmosphere
                                  Text(
                                    'Atmosphere: ${restaurant.atmosphere.displayName}',
                                    style: const TextStyle(
                                        color: Colors.grey),
                                  ),
                                  const SizedBox(height: 4),
                                  // Food Variety
                                  Text(
                                    'Food Variety: ${restaurant.foodVariety}',
                                    style: const TextStyle(
                                        color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
