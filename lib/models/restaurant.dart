import 'dart:convert';

class Restaurant {
  final String address;
  final String name;
  final String cuisine;
  final String rating;
  final List<MenuItem> menu;

  Restaurant({
    required this.address,
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.menu,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      address: json['address']['stringValue'] ?? '',
      name: json['name']['stringValue'] ?? '',
      cuisine: json['cuisine']['stringValue'] ?? '',
      rating: json['rating']['stringValue'] ?? '',
      menu: (json['menu'] as List)
          .map((item) => MenuItem.fromJson(item))
          .toList(),
    );
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
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    // Helper function to extract a boolean from various key styles.
    bool parseAvailability(Map<String, dynamic> data, String key) {
      if (data.containsKey(key)) {
        final value = data[key];
        if (value.containsKey('booleanValue')) {
          return value['booleanValue'];
        } else if (value.containsKey('stringValue')) {
          return value['stringValue'].toLowerCase() == 'true';
        }
      }
      return false;
    }

    // Helper for image url (different key names in your JSON)
    String parseImageUrl(Map<String, dynamic> data) {
      if (data.containsKey("image_url")) {
        return data["image_url"]["stringValue"] ?? "";
      } else if (data.containsKey("Image _ url")) {
        return data["Image _ url"]["stringValue"] ?? "";
      } else if (data.containsKey("Image _ url\"")) {
        return data["Image _ url\""]["stringValue"] ?? "";
      }
      return "";
    }

    // Price might be under different keys.
    int parsePrice(Map<String, dynamic> data) {
      if (data.containsKey("price")) {
        return int.tryParse(data["price"]["integerValue"].toString()) ?? 0;
      } else if (data.containsKey("Price")) {
        return int.tryParse(data["Price"]["integerValue"].toString()) ?? 0;
      }
      return 0;
    }

    // Similar helpers can be built for Name, Description, Category, etc.
    String parseString(Map<String, dynamic> data, List<String> keys) {
      for (final key in keys) {
        if (data.containsKey(key)) {
          return data[key]["stringValue"] ?? "";
        }
      }
      return "";
    }

    // For nutrition, extract each field from the nested map.
    Map<String, String> parseNutrition(Map<String, dynamic> data) {
      Map<String, String> nutrition = {};
      if (data.containsKey("nutrition")) {
        final fields = data["nutrition"]["mapValue"]["fields"];
        fields.forEach((k, v) {
          nutrition[k] = v["stringValue"] ?? "";
        });
      }
      return nutrition;
    }

    // For allergens: extract the list from the array.
    List<String> parseAllergens(Map<String, dynamic> data) {
      List<String> allergens = [];
      if (data.containsKey("allergens")) {
        final arr = data["allergens"]["arrayValue"]["values"] as List;
        allergens = arr.map((e) => e["stringValue"].toString()).toList();
      } else if (data.containsKey("Allergens")) {
        final arr = data["Allergens"]["arrayValue"]["values"] as List;
        allergens = arr.map((e) => e["stringValue"].toString()).toList();
      }
      return allergens;
    }

    // For ingredients.
    Map<String, String> parseIngredients(Map<String, dynamic> data) {
      Map<String, String> ingredients = {};
      if (data.containsKey("ingredients")) {
        final fields = data["ingredients"]["mapValue"]["fields"];
        fields.forEach((k, v) {
          ingredients[k] = v["stringValue"] ?? "";
        });
      } else if (data.containsKey("Ingredients")) {
        final fields = data["Ingredients"]["mapValue"]["fields"];
        fields.forEach((k, v) {
          ingredients[k] = v["stringValue"] ?? "";
        });
      }
      return ingredients;
    }

    // For calories (which might be a number or string).
    int parseCalories(Map<String, dynamic> data) {
      if (data.containsKey("calories")) {
        return int.tryParse(data["calories"]["integerValue"].toString()) ?? 0;
      } else if (data.containsKey("Calories")) {
        return int.tryParse(
            data["Calories"]["integerValue"]?.toString() ?? "0") ??
            0;
      }
      return 0;
    }

    // For last updated, try different keys.
    DateTime parseLastUpdated(Map<String, dynamic> data) {
      String? timestamp;
      if (data.containsKey("last_updated")) {
        timestamp = data["last_updated"]["timestampValue"];
      } else if (data.containsKey("Last _ updated")) {
        timestamp = data["Last _ updated"]["timestampValue"];
      } else if (data.containsKey("Last _ updated\"")) {
        timestamp = data["Last _ updated\""]["timestampValue"];
      }
      return timestamp != null ? DateTime.parse(timestamp) : DateTime.now();
    }

    return MenuItem(
      availability: parseAvailability(json, "availability") ||
          parseAvailability(json, "Availability"),
      nutrition: parseNutrition(json),
      calories: parseCalories(json),
      allergens: parseAllergens(json),
      ingredients: parseIngredients(json),
      lastUpdated: parseLastUpdated(json),
      imageUrl: parseImageUrl(json),
      price: parsePrice(json),
      name: parseString(json, ["name", "Name"]),
      description: parseString(json, ["description", "Description"]),
      category: parseString(json, ["category", "Category"]),
    );
  }
}
