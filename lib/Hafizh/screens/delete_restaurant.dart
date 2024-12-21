import 'package:flutter/material.dart';
import 'package:wanderscout/Hafizh/models/restaurant.dart'; 
import 'package:wanderscout/Hafizh/services/restaurant_api.dart';
import 'package:wanderscout/Davin/widgets/left_drawer.dart';


class SearchAndDeleteRestaurantScreen extends StatefulWidget {
  const SearchAndDeleteRestaurantScreen({super.key});

  @override
  SearchAndDeleteRestaurantScreenState createState() =>
      SearchAndDeleteRestaurantScreenState();
}

class SearchAndDeleteRestaurantScreenState
    extends State<SearchAndDeleteRestaurantScreen> {
  final _searchController = TextEditingController();
  List<Restaurant> _allRestaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterRestaurants);
    _searchRestaurants();
  }

  Future<void> _searchRestaurants() async {
    setState(() => _isLoading = true);
    try {
      final restaurants = await RestaurantApi().fetchRestaurants();
      if (!mounted) return;
      setState(() {
        _allRestaurants = restaurants;
        _filteredRestaurants = List.from(_allRestaurants);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching restaurants: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterRestaurants() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredRestaurants = _allRestaurants
          .where((r) => r.name.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _confirmDelete(String restaurantId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Do you really want to delete this restaurant?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the modal
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the modal
                await _deleteRestaurant(restaurantId);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteRestaurant(String restaurantId) async {
    try {
      await RestaurantApi().deleteRestaurant(restaurantId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restaurant deleted successfully!')),
      );

      setState(() {
        _filteredRestaurants = _filteredRestaurants
            .where((restaurant) => restaurant.id != restaurantId)
            .toList();
        _allRestaurants = _allRestaurants
            .where((restaurant) => restaurant.id != restaurantId)
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isSmallScreen = constraints.maxWidth < 600;

      return Scaffold(
        appBar: AppBar(title: const Text('Delete Restaurant')),
        drawer: const LeftDrawer(),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search for a restaurant',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : Expanded(
                        child: _filteredRestaurants.isEmpty
                            ? const Text('No restaurants found.')
                            : ListView.builder(
                                padding: const EdgeInsets.all(16.0),
                                itemCount: _filteredRestaurants.length,
                                itemBuilder: (context, index) {
                                  final restaurant =
                                      _filteredRestaurants[index];
                                  return Card(
                                    elevation: 4,
                                    margin: const EdgeInsets.only(bottom: 16.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              restaurant.name,
                                              style: TextStyle(
                                                fontSize: isSmallScreen
                                                    ? 16
                                                    : 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            color: Colors.red,
                                            onPressed: () =>
                                                _confirmDelete(restaurant.id),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
