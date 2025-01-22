import 'package:flutter/material.dart';

class NavigationManager {
  // Singleton pattern to manage a single instance of NavigationManager
  NavigationManager._privateConstructor();
  static final NavigationManager instance = NavigationManager._privateConstructor();

  /// Navigate to a new screen and optionally replace the current screen
  void navigateTo(BuildContext context, Widget screen, {bool replace = false}) {
    if (replace) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }

  /// Navigate back to the previous screen
  void navigateBack(BuildContext context, {dynamic result}) {
    Navigator.pop(context, result);
  }

  /// Clear all screens and navigate to a specific screen (e.g., for logout)
  void navigateToAndClearStack(BuildContext context, Widget screen) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => screen),
          (route) => false,
    );
  }
}
