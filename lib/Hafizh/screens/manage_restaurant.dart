import 'package:flutter/material.dart';
import 'package:wanderscout/Hafizh/models/restaurant.dart';
import 'package:wanderscout/Hafizh/services/restaurant_api.dart';
import 'package:wanderscout/Davin/API/api_service.dart';
import 'package:wanderscout/Davin/widgets/left_drawer.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ManageRestaurantsScreen extends StatefulWidget {
  const ManageRestaurantsScreen({super.key});

  @override
  ManageRestaurantsScreenState createState() => ManageRestaurantsScreenState();
}

class ManageRestaurantsScreenState extends State<ManageRestaurantsScreen> {
  final RestaurantApi _restaurantApi = RestaurantApi();
  final TextEditingController _searchController = TextEditingController();

  List<Restaurant> _allRestaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  bool _isLoading = false;

  Restaurant? _selectedRestaurant; 

  // For editing
  final _formKeyEdit = GlobalKey<FormState>();
  late String _editName;
  late FoodPreference _editFoodPreference;
  late int _editAveragePrice;
  late double _editRating;
  late Atmosphere _editAtmosphere;
  late String _editFoodVariety;

  // For adding
  bool _isAddMode = false;
  final _formKeyAdd = GlobalKey<FormState>();
  String _addName = '';
  String _addFoodPreference = 'Indonesia';
  int _addAveragePrice = 0;
  double _addRating = 0.0;
  String _addAtmosphere = 'Santai';
  String _addFoodVariety = '';

  final List<String> foodPreferences = [
    'Indonesia',
    'Chinese',
    'Western',
    'Japanese',
    'Middle Eastern'
  ];
  final List<String> atmospheres = ['Santai', 'Formal'];

  bool _fetchedOnce = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterRestaurants);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_fetchedOnce) {
      _fetchedOnce = true;
      _fetchRestaurants();
    }
  }

  // ----------------------------------------------------------------
  // FETCH
  Future<void> _fetchRestaurants() async {
    setState(() => _isLoading = true);


    final messenger = ScaffoldMessenger.of(context);

    try {
      final restaurants = await _restaurantApi.fetchRestaurants();
      if (!mounted) return;
      setState(() {
        _allRestaurants = restaurants;
        _filteredRestaurants = List.from(restaurants);
      });
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Error fetching restaurants: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterRestaurants() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredRestaurants = _allRestaurants
          .where((r) => r.name.toLowerCase().contains(query))
          .toList();
    });
  }

  // ----------------------------------------------------------------
  // DELETE
  Future<void> _confirmDelete(String restaurantId) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you really want to delete this restaurant?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _deleteRestaurant(restaurantId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRestaurant(String restaurantId) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      await _restaurantApi.deleteRestaurant(restaurantId);
      if (!mounted) return;
      setState(() {
        _allRestaurants =
            _allRestaurants.where((r) => r.id != restaurantId).toList();
        _filteredRestaurants =
            _filteredRestaurants.where((r) => r.id != restaurantId).toList();
      });
      messenger.showSnackBar(
        const SnackBar(content: Text('Restaurant deleted successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    }
  }

  // ----------------------------------------------------------------
  // EDIT
  void _selectForEdit(Restaurant restaurant) {
    setState(() {
      _selectedRestaurant = restaurant;
      _editName = restaurant.name;
      _editFoodPreference = restaurant.foodPreference;
      _editAveragePrice = restaurant.averagePrice;
      _editRating = restaurant.rating;
      _editAtmosphere = restaurant.atmosphere;
      _editFoodVariety = restaurant.foodVariety;
    });
  }

  void _cancelEdit() {
    setState(() => _selectedRestaurant = null);
  }

  Future<void> _saveEditChanges() async {
    if (_formKeyEdit.currentState!.validate() && _selectedRestaurant != null) {
      _formKeyEdit.currentState!.save();

      final messenger = ScaffoldMessenger.of(context);

      try {
        await _restaurantApi.editRestaurant(
          restaurantId: _selectedRestaurant!.id,
          name: _editName,
          foodPreference: _editFoodPreference,
          averagePrice: _editAveragePrice,
          rating: _editRating,
          atmosphere: _editAtmosphere,
          foodVariety: _editFoodVariety,
        );

        if (!mounted) return;
        setState(() {
          _selectedRestaurant!
            ..name = _editName
            ..foodPreference = _editFoodPreference
            ..averagePrice = _editAveragePrice
            ..rating = _editRating
            ..atmosphere = _editAtmosphere
            ..foodVariety = _editFoodVariety;
          _selectedRestaurant = null;
        });

        messenger.showSnackBar(
          const SnackBar(content: Text('Restaurant updated successfully!')),
        );
      } catch (e) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  // ----------------------------------------------------------------
  // ADD
  void _openAddForm() {
    setState(() {
      _addName = '';
      _addFoodPreference = 'Indonesia';
      _addAveragePrice = 0;
      _addRating = 0.0;
      _addAtmosphere = 'Santai';
      _addFoodVariety = '';
      _isAddMode = true;
    });
  }

  void _closeAddForm() {
    setState(() => _isAddMode = false);
  }

  Future<void> _submitAddForm() async {
    if (!_formKeyAdd.currentState!.validate()) return;
    _formKeyAdd.currentState!.save();

    final messenger = ScaffoldMessenger.of(context);
    final String? baseUrl = dotenv.env['BASE_URL'];

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final response = await apiService.post(
        url: '$baseUrl/restaurant/add-restaurant/',
        body: {
          'name': _addName,
          'food_preference': _addFoodPreference,
          'average_price': _addAveragePrice.toString(),
          'rating': _addRating.toString(),
          'atmosphere': _addAtmosphere,
          'food_variety': _addFoodVariety,
        },
      );

      if (!mounted) return;
      if (response.statusCode == 201) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Restaurant added successfully')),
        );
        await _fetchRestaurants(); // refresh list
        _closeAddForm();
      } else {
        final responseData = response.body;
        messenger.showSnackBar(
          SnackBar(content: Text('Error: $responseData')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ----------------------------------------------------------------
  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedRestaurant != null
              ? 'Edit Restaurant'
              : _isAddMode
                  ? 'Add Restaurant'
                  : 'Manage Restaurants',
        ),
        backgroundColor: Color(0xFF313EBC), // Ganti warna AppBar menjadi biru tua
        leading: _selectedRestaurant != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _cancelEdit,
              )
            : null,
        actions: [
          if (!_isAddMode && _selectedRestaurant == null)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _openAddForm,
            ),
        ],
      ),
      drawer: const LeftDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF313EBC), // Warna biru tua
              Color(0xFFA6ADEF), // Warna biru muda
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF313EBC)),
                ),
              )
            : _selectedRestaurant != null
                ? _buildEditForm()
                : _isAddMode
                    ? _buildAddForm()
                    : _buildSearchAndList(),
      ),
    );
  }




  Widget _buildSearchAndList() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Tombol Add New Restaurant
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Add New Restaurant"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                ),
                onPressed: _openAddForm,
              ),
            ),
            const SizedBox(height: 16),
            // Search Bar
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
            const SizedBox(height: 16),
            // Daftar Restoran
            Expanded(
              child: _filteredRestaurants.isEmpty
                  ? const Center(
                      child: Text(
                        'No restaurants found.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredRestaurants.length,
                      itemBuilder: (context, index) {
                        final restaurant = _filteredRestaurants[index];
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFFFFFFF), // Putih
                                Color(0xFFFFBBDF), // Pink lembut
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(16), // Membulatkan sudut
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              )
                            ],
                          ),
                          margin: const EdgeInsets.only(bottom: 16.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            child: Row(
                              children: [
                                // Informasi Restoran
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        restaurant.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Rating: ${restaurant.rating} | '
                                        'Price: ${restaurant.averagePrice} | '
                                        'Food: ${restaurant.foodPreference} | '
                                        'Atmosphere: ${restaurant.atmosphere}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Aksi Edit & Delete
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      color: Colors.orange,
                                      onPressed: () => _selectForEdit(restaurant),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      color: Colors.red,
                                      onPressed: () => _confirmDelete(restaurant.id),
                                    ),
                                  ],
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
    );
  }


  Widget _buildAddForm() {
    return Form(
      key: _formKeyAdd,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (value) =>
                (value == null || value.isEmpty) ? 'Enter a name' : null,
            onSaved: (value) => _addName = value ?? '',
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Food Preference'),
            value: _addFoodPreference,
            items: foodPreferences
                .map((pref) => DropdownMenuItem(value: pref, child: Text(pref)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _addFoodPreference = value);
              }
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Average Price'),
            keyboardType: TextInputType.number,
            validator: (value) =>
                (value == null || value.isEmpty) ? 'Enter a price' : null,
            onSaved: (value) =>
                _addAveragePrice = int.tryParse(value ?? '0') ?? 0,
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Rating'),
            keyboardType: TextInputType.number,
            validator: (value) {
              final val = double.tryParse(value ?? '');
              if (val == null || val < 0 || val > 5) {
                return 'Enter a rating between 0 and 5';
              }
              return null;
            },
            onSaved: (value) => _addRating = double.tryParse(value ?? '0') ?? 0,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Atmosphere'),
            value: _addAtmosphere,
            items: atmospheres
                .map((atm) => DropdownMenuItem(value: atm, child: Text(atm)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _addAtmosphere = value);
              }
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Food Variety'),
            validator: (value) =>
                (value == null || value.isEmpty) ? 'Enter food variety' : null,
            onSaved: (value) => _addFoodVariety = value ?? '',
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitAddForm,
            child: const Text('Add Restaurant'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _closeAddForm,
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKeyEdit,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextFormField(
            initialValue: _editName,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (value) =>
                (value == null || value.isEmpty) ? 'Please enter a name' : null,
            onSaved: (value) => _editName = value ?? '',
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<FoodPreference>(
            decoration: const InputDecoration(labelText: 'Food Preference'),
            value: _editFoodPreference,
            items: FoodPreference.values.map((fp) {
              return DropdownMenuItem(
                value: fp,
                child: Text(fp.toString()),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _editFoodPreference = value);
              }
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _editAveragePrice.toString(),
            decoration: const InputDecoration(labelText: 'Average Price'),
            keyboardType: TextInputType.number,
            validator: (value) =>
                (value == null || value.isEmpty) ? 'Enter a price' : null,
            onSaved: (value) =>
                _editAveragePrice = int.tryParse(value ?? '0') ?? 0,
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _editRating.toString(),
            decoration: const InputDecoration(labelText: 'Rating'),
            keyboardType: TextInputType.number,
            validator: (value) {
              final val = double.tryParse(value ?? '');
              if (val == null || val < 0 || val > 5) {
                return 'Enter a rating between 0 and 5';
              }
              return null;
            },
            onSaved: (value) => _editRating = double.tryParse(value ?? '0') ?? 0,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<Atmosphere>(
            decoration: const InputDecoration(labelText: 'Atmosphere'),
            value: _editAtmosphere,
            items: Atmosphere.values.map((atm) {
              return DropdownMenuItem(
                value: atm,
                child: Text(atm.toString()),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _editAtmosphere = value);
              }
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _editFoodVariety,
            decoration: const InputDecoration(labelText: 'Food Variety'),
            validator: (value) => (value == null || value.isEmpty)
                ? 'Please enter the food variety'
                : null,
            onSaved: (value) => _editFoodVariety = value ?? '',
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_formKeyEdit.currentState!.validate()) {
                _saveEditChanges();
              }
            },
            child: const Text('Save Changes'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _cancelEdit,
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
