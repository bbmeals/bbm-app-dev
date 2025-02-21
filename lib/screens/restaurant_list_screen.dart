import 'package:flutter/material.dart';
import '../services/restaurant_service.dart';
import 'package:bbm_backend_dev/models/restaurant.dart';

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({Key? key}) : super(key: key);

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  final RestaurantService _restaurantService = RestaurantService();
  List<Restaurant> _restaurants = [];
  bool _isLoading = false;

  Future<void> _loadRestaurants() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final restaurants = await _restaurantService.getRestaurants();
      setState(() {
        _restaurants = restaurants;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading restaurants: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _loadRestaurants,
            child: const Text('Load Restaurants'),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _restaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = _restaurants[index];
                      return ListTile(
                        title: Text(restaurant.name),
                        subtitle: Text(restaurant.cuisine),
                        trailing: Text('Rating: ${restaurant.rating}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
