
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  bool _isAdmin = false;

  bool get isAdmin => _isAdmin;

  void setIsAdmin(bool value) {
    _isAdmin = value;
    notifyListeners();
  }

  void reset() {
    _isAdmin = false;
    notifyListeners();
  }
}
