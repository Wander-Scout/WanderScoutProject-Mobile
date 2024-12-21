import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:wanderscout/Davin/widgets/left_drawer.dart';

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

  // Adjust this URL to your server
  final String baseUrl = "http://127.0.0.1:8000/authentication";

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/flutter_profile/"),
        headers: {"Content-Type": "application/json"},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"]) {
          setState(() {
            username = data["profile"]["username"];
            address = data["profile"]["address"] ?? "";
            phoneNumber = data["profile"]["phone_number"] ?? "";
            age = data["profile"]["age"]?.toString() ?? "";
            _addressController.text = address;
            _phoneController.text = phoneNumber;
            _ageController.text = age.toString();
          });
        } else {
          throw Exception(data["error"] ?? "Failed to fetch profile.");
        }
      } else {
        throw Exception("Failed to fetch profile.");
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

  Future<void> _updateProfile() async {
    if (_addressController.text.isEmpty || _phoneController.text.isEmpty || _ageController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("All fields are required.")),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/flutter_update_profile/"),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization": "<your_token_here>"
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
        if (data["success"]) {
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
        throw Exception("Failed to update profile.");
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
                  fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 14 : 16)),
          Text(value, style: TextStyle(fontSize: isSmallScreen ? 14 : 16)),
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, String hintText, bool isSmallScreen) {
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
        _buildProfileRow("Age", age.toString(), isSmallScreen),
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
                child: _isEditMode ? _buildEditForm(isSmallScreen) : _buildProfileView(isSmallScreen),
              ),
      );
    });
  }
}
