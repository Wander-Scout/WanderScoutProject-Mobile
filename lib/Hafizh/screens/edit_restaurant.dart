import 'package:flutter/material.dart';
import 'package:wanderscout/Hafizh/models/restaurant.dart';
import 'package:wanderscout/Hafizh/services/restaurant_api.dart';
import 'package:wanderscout/Davin/widgets/left_drawer.dart';

class SearchAndEditRestaurantScreen extends StatefulWidget {
  const SearchAndEditRestaurantScreen({super.key});

  @override
  SearchAndEditRestaurantScreenState createState() =>
      SearchAndEditRestaurantScreenState();
}

class SearchAndEditRestaurantScreenState
    extends State<SearchAndEditRestaurantScreen> {
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Restaurant> _allRestaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  Restaurant? _selectedRestaurant;
  bool _isLoading = false;

  // Form fields
  late String name;
  late FoodPreference foodPreference;
  late int averagePrice;
  late double rating;
  late Atmosphere atmosphere;
  late String foodVariety;

  @override
  void initState() {
    super.initState();
    _fetchRestaurants();
    _searchController.addListener(_filterRestaurants);
  }

  Future<void> _fetchRestaurants() async {
    setState(() => _isLoading = true);
    try {
      final restaurants = await RestaurantApi().fetchRestaurants();
      if (!mounted) return;
      setState(() {
        _allRestaurants = restaurants;
        _filteredRestaurants = List.from(_allRestaurants);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching restaurants: $e')),
      );
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

  Future<void> _saveChanges() async {
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
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restaurant updated successfully!')),
        );

        setState(() => _selectedRestaurant = null);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _selectedRestaurant != null;

    return LayoutBuilder(builder: (context, constraints) {
      final isSmallScreen = constraints.maxWidth < 600;

      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Restaurant'),
          // If editing, show a back button in the app bar:
          leading: isEditing
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => setState(() => _selectedRestaurant = null),
                )
              : null,
        ),
        drawer: const LeftDrawer(),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: isEditing
                ? _buildEditForm(isSmallScreen)
                : _buildSearchAndList(isSmallScreen),
          ),
        ),
      );
    });
  }

  Widget _buildSearchAndList(bool isSmallScreen) {
    return Column(
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
                          final restaurant = _filteredRestaurants[index];
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
                                        fontSize: isSmallScreen ? 16 : 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    color: Colors.orange,
                                    onPressed: () =>
                                        _selectRestaurant(restaurant),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
      ],
    );
  }

  Widget _buildEditForm(bool isSmallScreen) {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          TextFormField(
            initialValue: name,
            decoration: const InputDecoration(labelText: 'Name'),
            onSaved: (value) => name = value!,
            validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a name' : null,
          ),
          DropdownButtonFormField<FoodPreference>(
            value: foodPreference,
            decoration: const InputDecoration(labelText: 'Food Preference'),
            items: FoodPreference.values
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e.displayName),
                    ))
                .toList(),
            onChanged: (value) => foodPreference = value!,
          ),
          TextFormField(
            initialValue: averagePrice.toString(),
            decoration: const InputDecoration(labelText: 'Average Price'),
            keyboardType: TextInputType.number,
            onSaved: (value) => averagePrice = int.parse(value!),
            validator: (value) =>
                value == null || value.isEmpty ? 'Please enter an average price' : null,
          ),
          TextFormField(
            initialValue: rating.toString(),
            decoration: const InputDecoration(labelText: 'Rating'),
            keyboardType: TextInputType.number,
            onSaved: (value) => rating = double.parse(value!),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a rating';
              }
              final val = double.tryParse(value);
              if (val == null || val < 0 || val > 5) {
                return 'Enter a rating between 0 and 5';
              }
              return null;
            },
          ),
          DropdownButtonFormField<Atmosphere>(
            value: atmosphere,
            decoration: const InputDecoration(labelText: 'Atmosphere'),
            items: Atmosphere.values
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e.displayName),
                    ))
                .toList(),
            onChanged: (value) => atmosphere = value!,
          ),
          TextFormField(
            initialValue: foodVariety,
            decoration: const InputDecoration(labelText: 'Food Variety'),
            onSaved: (value) => foodVariety = value!,
            validator: (value) =>
                value == null || value.isEmpty ? 'Please enter the food variety' : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveChanges,
            child: const Text('Save Changes'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => setState(() => _selectedRestaurant = null),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
