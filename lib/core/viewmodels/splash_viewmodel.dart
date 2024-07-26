import 'package:flutter/foundation.dart';

class SplashViewModel extends ChangeNotifier {
  Future<void> initialize() async {
    // Perform initialization tasks like checking user authentication
    // Example: await _authService.checkUserLoggedIn();
    notifyListeners(); // Notify listeners if needed
  }
}

