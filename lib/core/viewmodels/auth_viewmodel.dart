import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  // Add authentication logic here, e.g., Google Sign-In
  Future<void> loginWithGoogle() async {
    // Implement Google Sign-In logic here
    notifyListeners();
  }
}
