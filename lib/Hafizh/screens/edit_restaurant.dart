import 'package:flutter/material.dart';
import 'package:wanderscout/Hafizh/models/restaurant.dart';
import 'package:wanderscout/Hafizh/services/restaurant_api.dart';

class SearchAndEditRestaurantScreen extends StatefulWidget {
  const SearchAndEditRestaurantScreen({Key? key}) : super(key: key);

  @override
  _SearchAndEditRestaurantScreenState createState() =>
      _SearchAndEditRestaurantScreenState();
}

class _SearchAndEditRestaurantScreenState
    extends State<SearchAndEditRestaurantScreen> {
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Restaurant> _restaurants = [];
  Restaurant? _selectedRestaurant;
  bool _isLoading = false;

  // Form fields
  late String name;
  late FoodPreference foodPreference;
  late int averagePrice;
  late double rating;
  late Atmosphere atmosphere;
  late String foodVariety;

  Future<void> _searchRestaurants() async {
    setState(() => _isLoading = true);
    try {
      final restaurants = await RestaurantApi().fetchRestaurants();
      final query = _searchController.text.toLowerCase();
      setState(() {
        _restaurants = restaurants
            .where((r) => r.name.toLowerCase().contains(query))
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching restaurants: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _selectRestaurant(Restaurant restaurant) {
    setState(() {
      _selectedRestaurant = restaurant;
      // Populate form fields
      name = restaurant.name;
      foodPreference = restaurant.foodPreference;
      averagePrice = restaurant.averagePrice;
      rating = restaurant.rating;
      atmosphere = restaurant.atmosphere;
      foodVariety = restaurant.foodVariety;
    });
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate() && _selectedRestaurant != null) {
      _formKey.currentState!.save();

      try {
        await RestaurantApi().editRestaurant(
          restaurantId: _selectedRestaurant!.id,
          name: name,
          foodPreference: foodPreference,
          averagePrice: averagePrice,
          rating: rating,
          atmosphere: atmosphere,
          foodVariety: foodVariety,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restaurant updated successfully!')),
        );

        setState(() => _selectedRestaurant = null);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search and Edit Restaurant')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search for a restaurant',
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: (_) => _searchRestaurants(),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : _selectedRestaurant == null
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: _restaurants.length,
                          itemBuilder: (context, index) {
                            final restaurant = _restaurants[index];
                            return ListTile(
                              title: Text(restaurant.name),
                              subtitle: Text(
                                  'Food: ${restaurant.foodPreference.displayName}'),
                              onTap: () => _selectRestaurant(restaurant),
                            );
                          },
                        ),
                      )
                    : Expanded(
                        child: Form(
                          key: _formKey,
                          child: ListView(
                            children: [
                              TextFormField(
                                initialValue: name,
                                decoration:
                                    const InputDecoration(labelText: 'Name'),
                                onSaved: (value) => name = value!,
                              ),
                              DropdownButtonFormField<FoodPreference>(
                                value: foodPreference,
                                decoration: const InputDecoration(
                                    labelText: 'Food Preference'),
                                items: FoodPreference.values
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e.displayName),
                                        ))
                                    .toList(),
                                onChanged: (value) =>
                                    foodPreference = value!,
                              ),
                              TextFormField(
                                initialValue: averagePrice.toString(),
                                decoration: const InputDecoration(
                                    labelText: 'Average Price'),
                                keyboardType: TextInputType.number,
                                onSaved: (value) =>
                                    averagePrice = int.parse(value!),
                              ),
                              TextFormField(
                                initialValue: rating.toString(),
                                decoration:
                                    const InputDecoration(labelText: 'Rating'),
                                keyboardType: TextInputType.number,
                                onSaved: (value) =>
                                    rating = double.parse(value!),
                              ),
                              DropdownButtonFormField<Atmosphere>(
                                value: atmosphere,
                                decoration: const InputDecoration(
                                    labelText: 'Atmosphere'),
                                items: Atmosphere.values
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e.displayName),
                                        ))
                                    .toList(),
                                onChanged: (value) =>
                                    atmosphere = value!,
                              ),
                              TextFormField(
                                initialValue: foodVariety,
                                decoration: const InputDecoration(
                                    labelText: 'Food Variety'),
                                onSaved: (value) => foodVariety = value!,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _saveChanges,
                                child: const Text('Save Changes'),
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: () =>
                                    setState(() => _selectedRestaurant = null),
                                child: const Text('Cancel'),
                              ),
                            ],
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
