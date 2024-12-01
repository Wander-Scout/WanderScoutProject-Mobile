import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:wanderscout/davin/widgets/left_drawer.dart'; // Import LeftDrawer

class RestaurantListScreen extends StatefulWidget {
  @override
  _RestaurantListScreenState createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  final ApiService apiService = ApiService();
  List<dynamic> displayedRestaurants = [];
  List<dynamic> allRestaurants = [];
  List<dynamic> filteredRestaurants = []; // Stores restaurants after filtering
  final int pageSize = 10;
  bool isLoading = false;

  String selectedFoodPreference = 'All'; // Default filter value
  List<String> foodPreferences = ['All']; // Dropdown options
  String searchQuery = ''; // Holds the search query

  @override
  void initState() {
    super.initState();
    fetchRestaurants(); // Fetch data on screen load
  }

  Future<void> fetchRestaurants() async {
    try {
      final data = await apiService.fetchRestaurants(); // Fetch API data

      final restaurantList =
          data['restaurants'] ?? data as List; // Handle both cases
      setState(() {
        allRestaurants = restaurantList.map((item) {
          return item['fields'] ??
              item; // Access 'fields' or the flat structure
        }).toList();

        // Extract unique food preferences for filtering
        final preferences = allRestaurants
            .map((restaurant) => restaurant['food_preference'] as String?)
            .where((preference) => preference != null)
            .cast<String>() // Cast to non-nullable String
            .toSet()
            .toList();
        foodPreferences = ['All', ...preferences];

        filteredRestaurants =
            List.from(allRestaurants); // Initially, no filter applied
        displayedRestaurants = filteredRestaurants.take(pageSize).toList();
      });
    } catch (error) {
      print('Error fetching restaurants: $error'); // Log errors for debugging
    }
  }

  void filterRestaurants() {
    setState(() {
      // Apply both the food preference filter and search query
      filteredRestaurants = allRestaurants.where((restaurant) {
        final matchesFoodPreference = selectedFoodPreference == 'All' ||
            restaurant['food_preference'] == selectedFoodPreference;
        final matchesSearchQuery = restaurant['name']
                ?.toString()
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ??
            false;
        return matchesFoodPreference && matchesSearchQuery;
      }).toList();

      // Reset displayedRestaurants for pagination
      displayedRestaurants = filteredRestaurants.take(pageSize).toList();
    });
  }

  void loadMoreRestaurants() {
    if (displayedRestaurants.length >= filteredRestaurants.length ||
        isLoading) {
      return; // Stop loading if all data is displayed or already loading
    }

    setState(() {
      isLoading = true; // Set loading state
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      final nextItems = filteredRestaurants
          .skip(displayedRestaurants.length)
          .take(pageSize)
          .toList();
      setState(() {
        displayedRestaurants.addAll(nextItems);
        isLoading = false; // Reset loading state
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant List'),
      ),
      drawer: const LeftDrawer(), // Add LeftDrawer here
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
                      setState(() {
                        searchQuery = value;
                        filterRestaurants(); // Filter as the user types
                      });
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
                        setState(() {
                          selectedFoodPreference = value;
                          filterRestaurants(); // Filter when a new preference is selected
                        });
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
                        loadMoreRestaurants(); // Load more data when scrolled to bottom
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

                          // Safely access fields with default values
                          final name = restaurant['name'] ?? 'No Name';
                          final foodPreference =
                              restaurant['food_preference'] ?? 'Unknown';
                          final averagePrice =
                              restaurant['average_price']?.toString() ?? 'N/A';
                          final rating =
                              restaurant['rating']?.toString() ?? 'N/A';
                          final atmosphere =
                              restaurant['atmosphere'] ?? 'Unknown';
                          final foodVariety =
                              restaurant['food_variety'] ?? 'N/A';

                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.only(bottom: 16.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Restaurant Name
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Rating
                                  Text(
                                    'Rating: $rating / 5',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 4),
                                  // Average Price
                                  Text(
                                    'Average Price: Rp $averagePrice',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 4),
                                  // Food Preference
                                  Text(
                                    'Food Preference: $foodPreference',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 4),
                                  // Atmosphere
                                  Text(
                                    'Atmosphere: $atmosphere',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 4),
                                  // Food Variety
                                  Text(
                                    'Food Variety: $foodVariety',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          // Show loading spinner when more data is being loaded
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
