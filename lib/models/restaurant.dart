// import 'dart:convert';
//
// class Restaurant {
//   final String address;
//   final String name;
//   final String cuisine;
//   final String rating;
//   final List<MenuItem> menu;
//
//   Restaurant({
//     required this.address,
//     required this.name,
//     required this.cuisine,
//     required this.rating,
//     required this.menu,
//   });
//
//   factory Restaurant.fromJson(Map<String, dynamic> json) {
//     return Restaurant(
//       address: json['address'] ?? '',
//       name: json['name'] ?? '',
//       cuisine: json['cuisine'] ?? '',
//       rating: json['rating'] ?? '',
//       menu: (json['menu'] as List)
//           .map((item) => MenuItem.fromJson(item))
//           .toList(),
//     );
//   }
// }
//
// class MenuItem {
//   final bool availability;
//   final Map<String, String> nutrition;
//   final int calories;
//   final List<String> allergens;
//   final Map<String, String> ingredients;
//   final DateTime lastUpdated;
//   final String imageUrl;
//   final int price;
//   final String name;
//   final String description;
//   final String category;
//   final String id;
//
//   MenuItem({
//     required this.availability,
//     required this.nutrition,
//     required this.calories,
//     required this.allergens,
//     required this.ingredients,
//     required this.lastUpdated,
//     required this.imageUrl,
//     required this.price,
//     required this.name,
//     required this.description,
//     required this.category,
//     required this.id,
//   });
//
//   factory MenuItem.fromJson(Map<String, dynamic> json) {
//     return MenuItem(
//       availability: json['availability'] ?? false,
//       nutrition: json['nutrition'] != null
//           ? Map<String, String>.from(json['nutrition'])
//           : {},
//       calories: json['calories'] ?? 0,
//       allergens: json['allergens'] != null
//           ? List<String>.from(json['allergens'])
//           : [],
//       ingredients: json['ingredients'] != null
//           ? Map<String, String>.from(json['ingredients'])
//           : {},
//       lastUpdated: json['lastUpdated'] != null
//           ? DateTime.parse(json['lastUpdated'])
//           : DateTime.now(),
//       imageUrl: json['imageUrl'] ?? '',
//       price: json['price'] ?? 0,
//       name: json['name'] ?? '',
//       description: json['description'] ?? '',
//       category: json['category'] ?? '',
//       id: json['id'] ?? '',
//     );
//   }
// }
import 'dart:convert';

class Restaurant {
  final List<MenuItem> menu;

  Restaurant({
    required this.menu,
  });

  /// This factory accepts either a List or a Map.
  factory Restaurant.fromJson(dynamic json) {
    List<dynamic> jsonList;

    if (json is List) {
      print("List");
      jsonList = json;
    } else if (json is Map<String, dynamic>) {
      print("MAp");
      // If the map contains a key that holds the list, extract it.
      if (json.containsKey('menu')) {
        jsonList = json['menu'];
      } else if (json.containsKey('data')) {
        jsonList = json['data'];
      } else {
        // If no such key exists, wrap the map in a list.
        jsonList = [json];
      }
    } else {
      throw Exception('Invalid JSON structure');
    }


    // Directly parse each menu item without looking for a nested 'menu' key.
    List<MenuItem> menuItems = jsonList.map((item) {
      return MenuItem.fromJson(item);
    }).toList();

    return Restaurant(menu: menuItems);

    return Restaurant(menu: menuItems);
  }
}

class MenuItem {
  final bool availability;
  final Map<String, String> nutrition;
  final int calories;
  final List<String> allergens;
  final Map<String, String> ingredients;
  final DateTime lastUpdated;
  final String imageUrl;
  final int price;
  final String name;
  final String description;
  final String category;
  final String id;
  final bool recommended; // New field added

  MenuItem({
    required this.availability,
    required this.nutrition,
    required this.calories,
    required this.allergens,
    required this.ingredients,
    required this.lastUpdated,
    required this.imageUrl,
    required this.price,
    required this.name,
    required this.description,
    required this.category,
    required this.id,
    required this.recommended, // Included in constructor
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      availability: json['availability'] is bool
          ? json['availability']
          : (json['availability'].toString().toLowerCase() == 'true'),
      nutrition: json['nutrition'] != null
          ? Map<String, String>.from(json['nutrition'])
          : {},
      calories: json['calories'] ?? 0,
      allergens: json['allergens'] != null
          ? List<String>.from(json['allergens'])
          : [],
      ingredients: json['ingredients'] != null
          ? Map<String, String>.from(json['ingredients'])
          : {},
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'])
          : DateTime.now(),
      imageUrl: json['image_url'] ?? '',
      price: json['price'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      id: json['id'] ?? '',
      recommended: json['recommended'] is bool
          ? json['recommended']
          : (json['recommended'].toString().toLowerCase() == 'true'),
    );
  }
}
