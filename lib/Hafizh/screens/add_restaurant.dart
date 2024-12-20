// lib/hafizh/screens/add_restaurant.dart

import 'package:flutter/material.dart';
import 'package:wanderscout/davin/API/api_service.dart'; // Adjust the import path if necessary

class AddRestaurantScreen extends StatefulWidget {
  const AddRestaurantScreen({Key? key}) : super(key: key);

  @override
  _AddRestaurantScreenState createState() => _AddRestaurantScreenState();
}

class _AddRestaurantScreenState extends State<AddRestaurantScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String foodPreference = 'Indonesia';
  int averagePrice = 0;
  double rating = 0.0;
  String atmosphere = 'Santai';
  String foodVariety = '';
  bool _isLoading = false;

  List<String> foodPreferences = ['Indonesia', 'Chinese', 'Western', 'Japanese', 'Middle Eastern'];
  List<String> atmospheres = ['Santai', 'Formal'];

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final apiService = ApiService();
        final response = await apiService.post(
          url: 'http://127.0.0.1:8000/restaurant/add-restaurant/', // Adjust URL as needed
          body: {
            'name': name,
            'food_preference': foodPreference,
            'average_price': averagePrice.toString(),
            'rating': rating.toString(),
            'atmosphere': atmosphere,
            'food_variety': foodVariety,
          },
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Restaurant added successfully')),
          );
          Navigator.pop(context);
        } else {
          final responseData = response.body;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $responseData')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required Function(String) onChanged,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      onChanged: onChanged,
      validator: validator,
      keyboardType: keyboardType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Restaurant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildTextField(
                      label: 'Name',
                      onChanged: (value) => name = value,
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Enter a name' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Food Preference'),
                      value: foodPreference,
                      items: foodPreferences
                          .map((pref) => DropdownMenuItem(
                                value: pref,
                                child: Text(pref),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            foodPreference = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Average Price',
                      onChanged: (value) =>
                          averagePrice = int.tryParse(value) ?? 0,
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Enter a price' : null,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Rating',
                      onChanged: (value) =>
                          rating = double.tryParse(value) ?? 0.0,
                      validator: (value) => value == null ||
                              value.isEmpty ||
                              double.tryParse(value)! < 0 ||
                              double.tryParse(value)! > 5
                          ? 'Enter a rating between 0 and 5'
                          : null,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Atmosphere'),
                      value: atmosphere,
                      items: atmospheres
                          .map((atm) => DropdownMenuItem(
                                value: atm,
                                child: Text(atm),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            atmosphere = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Food Variety',
                      onChanged: (value) => foodVariety = value,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter food variety'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Add Restaurant'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
