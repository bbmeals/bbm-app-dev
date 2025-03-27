import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../services/restaurant_service.dart'; // This file includes your fetchRestaurantData()

class RestaurantProvider with ChangeNotifier {
  Restaurant? _restaurant;
  bool _isLoading = false;
  String? _error;

  Restaurant? get restaurant => _restaurant;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRestaurantData() async {
    _isLoading = true;
    notifyListeners();
    try {
      // Use your existing fetchRestaurantData() function.
      _restaurant = await fetchRestaurantData();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
