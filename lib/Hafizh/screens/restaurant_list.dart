import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../services/restaurant_api.dart';
import 'package:wanderscout/Davin/widgets/left_drawer.dart';
import 'restaurant_detail.dart';

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key});

  @override
  RestaurantListScreenState createState() => RestaurantListScreenState();
}

class RestaurantListScreenState extends State<RestaurantListScreen> {
  final RestaurantApi _restaurantApi = RestaurantApi();

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
      final restaurants = await _restaurantApi.fetchRestaurants();
      if (!mounted) return;

      setState(() {
        allRestaurants = restaurants;

        final preferences = allRestaurants
            .map((restaurant) => restaurant.foodPreference)
            .toSet()
            .toList();
        foodPreferences = [
          'All',
          ...preferences.map((e) => e.displayName)
        ];

        filteredRestaurants = List.from(allRestaurants);
        displayedRestaurants = filteredRestaurants.take(pageSize).toList();
      });
    } catch (error) {
      debugPrint('Error fetching restaurants: $error');
    }
  }

  void filterRestaurants() {
    setState(() {
      filteredRestaurants = allRestaurants.where((restaurant) {
        final matchesFoodPreference = selectedFoodPreference == 'All' ||
            restaurant.foodPreference.displayName == selectedFoodPreference;
        final matchesSearchQuery = restaurant.name
            .toLowerCase()
            .contains(searchQuery.toLowerCase());
        return matchesFoodPreference && matchesSearchQuery;
      }).toList();

      displayedRestaurants = filteredRestaurants.take(pageSize).toList();
    });
  }

  void loadMoreRestaurants() {
    if (displayedRestaurants.length >= filteredRestaurants.length || isLoading) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final nextItems = filteredRestaurants
          .skip(displayedRestaurants.length)
          .take(pageSize);

      setState(() {
        displayedRestaurants.addAll(nextItems);
        isLoading = false;
      });
    });
  }

  String getImageForFoodPreference(String? foodPreference) {
    final typeValue =
        foodPreference?.toLowerCase().replaceAll(' ', '') ?? 'placeholder';
    return 'lib/static/food_pref/$typeValue.jpg';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Restaurants',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF313EBC), // Warna solid untuk judul
      ),
      drawer: const LeftDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF313EBC), Color(0xFFA6ADEF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
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
            Expanded(
              child: allRestaurants.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (!isLoading &&
                            scrollInfo.metrics.pixels ==
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

                            return Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFFFFFFFF), Color(0xFFECEB7F)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(16),
                                ),
                              ),
                              margin: const EdgeInsets.only(bottom: 16.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RestaurantDetailScreen(
                                        restaurant: restaurant,
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: isSmallScreen
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.asset(
                                                getImageForFoodPreference(
                                                    restaurant.foodPreference
                                                        .displayName),
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: 100,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            buildRestaurantDetails(restaurant),
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.asset(
                                                getImageForFoodPreference(
                                                    restaurant.foodPreference
                                                        .displayName),
                                                fit: BoxFit.cover,
                                                width: 100,
                                                height: 100,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: buildRestaurantDetails(
                                                  restaurant),
                                            ),
                                          ],
                                        ),
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
      ),
    );
  }

  Widget buildRestaurantDetails(Restaurant restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          restaurant.name.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Rating: ${restaurant.rating} / 5',
        ),
        Text(
          'Average Price: Rp ${restaurant.averagePrice}',
        ),
        Text(
          'Food Preference: ${restaurant.foodPreference.displayName}',
        ),
        Text(
          'Atmosphere: ${restaurant.atmosphere.displayName}',
        ),
        Text(
          'Food Variety: ${restaurant.foodVariety}',
        ),
      ],
    );
  }
}
