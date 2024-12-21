import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wanderscout/Davin/widgets/left_drawer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key}); // Updated to use super parameter 

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

  // Use FlutterSecureStorage to read the token saved during login
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _token;

  // Adjust this URL to match your Django server address
  final String baseUrl = "http://127.0.0.1:8000/authentication";

  @override
  void initState() {
    super.initState();
    _initTokenAndFetchProfile();
  }

  /// Read the token from secure storage, then fetch the profile
  Future<void> _initTokenAndFetchProfile() async {
    final storedToken = await _storage.read(key: 'auth_token');
    if (storedToken != null && storedToken.isNotEmpty) {
      _token = storedToken;
      await _fetchProfile();
    } else {

    }
  }

  /// Fetch the user profile from Django using the token
  Future<void> _fetchProfile() async {
    if (_token == null || _token!.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/flutter_profile/"),
        headers: {
          "Authorization": _token!,      // Send token here
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Update the user profile using the token
  Future<void> _updateProfile() async {
    // Validate that fields are not empty
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
        Uri.parse("$baseUrl/flutter_update_profile/"),
        headers: {
          "Authorization": _token!,          // Send token here
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildProfileRow(String label, String value, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 14 : 16,
              )),
          Text(value, style: TextStyle(fontSize: isSmallScreen ? 14 : 16)),
        ],
      ),
    );
  }

  Widget _buildEditableField(
      String label, TextEditingController controller, String hintText, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          labelStyle: TextStyle(fontSize: isSmallScreen ? 14 : 16),
          hintStyle: TextStyle(fontSize: isSmallScreen ? 12 : 14),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildProfileView(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileRow("Username", username, isSmallScreen),
        _buildProfileRow("Address", address, isSmallScreen),
        _buildProfileRow("Phone Number", phoneNumber, isSmallScreen),
        _buildProfileRow("Age", age, isSmallScreen),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => setState(() => _isEditMode = true),
          child: const Text("Edit Profile"),
        ),
      ],
    );
  }

  Widget _buildEditForm(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEditableField("Address", _addressController, "Enter your address", isSmallScreen),
        _buildEditableField("Phone Number", _phoneController, "Enter your phone number", isSmallScreen),
        _buildEditableField("Age", _ageController, "Enter your age", isSmallScreen),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: _updateProfile,
              child: const Text("Save Changes"),
            ),
            OutlinedButton(
              onPressed: () => setState(() => _isEditMode = false),
              child: const Text("Cancel"),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isSmallScreen = constraints.maxWidth < 600;

      return Scaffold(
        appBar: AppBar(
          title: Text(_isEditMode ? "Edit Profile" : "Profile"),
        ),
        drawer: const LeftDrawer(),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isEditMode
                    ? _buildEditForm(isSmallScreen)
                    : _buildProfileView(isSmallScreen),
              ),
      );
    });
  }
}
