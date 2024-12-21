import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wanderscout/Davin/widgets/left_drawer.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  bool _isEditMode = false;
  bool _isLoading = false;

  String username = "";
  String address = "";
  String phoneNumber = "";
  String age = "";

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _token;

  final String? baseUrl = dotenv.env['BASE_URL'];

  @override
  void initState() {
    super.initState();
    _initTokenAndFetchProfile();
  }

  Future<void> _initTokenAndFetchProfile() async {
    final storedToken = await _storage.read(key: 'auth_token');
    if (storedToken != null && storedToken.isNotEmpty) {
      _token = storedToken;
      await _fetchProfile();
    }
  }

  Future<void> _fetchProfile() async {
    
    if (_token == null || _token!.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse("${baseUrl}authentication/flutter_profile/"),
        headers: {
          "Authorization": _token!,
          "Content-Type": "application/json",
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          setState(() {
            username = data["profile"]["username"] ?? "";
            address = data["profile"]["address"] ?? "";
            phoneNumber = data["profile"]["phone_number"] ?? "";
            age = data["profile"]["age"]?.toString() ?? "";

            _addressController.text = address;
            _phoneController.text = phoneNumber;
            _ageController.text = age;
          });
        } else {
          throw Exception(data["error"] ?? "Failed to fetch profile.");
        }
      } else {
        throw Exception("Failed to fetch profile. Code: ${response.statusCode}");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (_addressController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _ageController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required.")),
      );
      return;
    }

    if (_token == null || _token!.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("${baseUrl}authentication/flutter_update_profile/"),
        headers: {
          "Authorization": _token!,
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "address": _addressController.text,
          "phone_number": _phoneController.text,
          "age": _ageController.text,
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully!")),
          );
          setState(() {
            address = _addressController.text;
            phoneNumber = _phoneController.text;
            age = _ageController.text;
            _isEditMode = false;
          });
        } else {
          throw Exception(data["error"] ?? "Failed to update profile.");
        }
      } else {
        throw Exception("Failed to update profile. Code: ${response.statusCode}");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        "$text:",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildDisplayField(String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Text(
        value,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildProfileView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Profile",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        _buildLabel("Username"),
        _buildDisplayField(username),
        _buildLabel("Address"),
        _buildDisplayField(address),
        _buildLabel("Age"),
        _buildDisplayField(age),
        _buildLabel("Phone Number"),
        _buildDisplayField(phoneNumber),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () => setState(() => _isEditMode = true),
            child: const Text("Edit Profile"),
          ),
        ),
      ],
    );
  }

  Widget _buildEditField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Edit Profile",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        // Username is not editable, so just display it
        _buildLabel("Username"),
        _buildDisplayField(username),
        _buildEditField("Address", _addressController),
        _buildEditField("Age", _ageController),
        _buildEditField("Phone Number", _phoneController),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text("Save Changes"),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () => setState(() => _isEditMode = false),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text("Cancel"),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Remove any forced background image or color so it inherits from the theme if needed
        Container(
          // For a plain background, we leave this empty
          decoration: const BoxDecoration(),
        ),
        Scaffold(
          // Let the main theme's scaffold background color show
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            // No explicit background color; inherits from theme in main.dart
            title: Text(_isEditMode ? "Edit Profile" : "Profile"),
          ),
          drawer: const LeftDrawer(),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: _isEditMode
                              ? _buildEditForm()
                              : _buildProfileView(),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
