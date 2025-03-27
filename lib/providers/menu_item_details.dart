import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/restaurant.dart'; // Ensure MenuItem is imported
import '../providers/cart_provider.dart';
import '../services/cart_services.dart';
import '../theme/app_theme.dart';

class MenuItemDetails {
  static void show({
    required BuildContext context,
    required MenuItem item,
    required CartProvider cartProvider,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final List<String> availableCustomizations = [
          'chicken',
          'shrimp',
          'cheese',
          'broccoli'
        ];
        List<String> selectedCustomizations = [];
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              maxChildSize: 0.9,
              minChildSize: 0.5,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with image and close button.
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(20)),
                                child: (item.imageUrl.isNotEmpty)
                                    ? Image.network(
                                  item.imageUrl,
                                  width: double.infinity,
                                  height: 250,
                                  fit: BoxFit.cover,
                                )
                                    : Image.asset(
                                  'assets/images/placeholder.png',
                                  width: double.infinity,
                                  height: 250,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 16,
                                right: 16,
                                child: GestureDetector(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close,
                                        color: Colors.black87),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Item title and price.
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                '\$${item.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item.description,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          // Existing details.
                          Text(
                            'Allergens: ${item.allergens.join(', ')}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nutritional Info: ${item.nutrition.entries.map((e) => '${e.key}: ${e.value}').join(', ')}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 16),
                          // Ingredient customization section.
                          const Text(
                            'Customize Ingredients',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Column(
                            children: availableCustomizations.map((option) {
                              bool isSelected =
                              selectedCustomizations.contains(option);
                              return CheckboxListTile(
                                title: Text(option),
                                value: isSelected,
                                onChanged: (bool? value) {
                                  setModalState(() {
                                    if (value == true) {
                                      selectedCustomizations.add(option);
                                    } else {
                                      selectedCustomizations.remove(option);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                          // Add to cart button with customizations.
                          ElevatedButton(
                            onPressed: () async {
                              String updatedDescription = item.description;
                              if (selectedCustomizations.isNotEmpty) {
                                updatedDescription +=
                                "\nCustomizations: ${selectedCustomizations.join(', ')}";
                              }

                              final storage = FlutterSecureStorage();
                              final storedUserId =
                              await storage.read(key: 'userId');

                              final documentId = await sendCartItemToServer(
                                userId: storedUserId!,
                                restaurantId: 'bbm',
                                itemId: item.id,
                                quantity: 1,
                                priceSnapshot: item.price.toDouble(),
                                customization: {
                                  'customizations':
                                  selectedCustomizations.join(', ')
                                },
                              );

                              cartProvider.addItem(
                                productId: item.name,
                                title: item.name,
                                price: item.price.toDouble(),
                                image: item.imageUrl,
                                description: updatedDescription,
                                allergens: item.allergens.join(', '),
                                nutritionInfo: item.nutrition.entries
                                    .map((e) => '${e.key}: ${e.value}')
                                    .join(', '),
                                docId: documentId,
                                menuItemId: item.id,
                                category: item.category
                              );

                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '${item.name} added to cart with customizations'),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: const Text('Add to Cart'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
