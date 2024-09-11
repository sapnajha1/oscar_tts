import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  Future<void> loginWithGoogle() async {
    notifyListeners();
  }
}
