import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/menu_provider.dart';
import '../theme/app_theme.dart';
import '../services/cart_services.dart';
import '../providers/item_counter.dart';
import '../models/restaurant.dart';
import 'package:built_better_app/components/navbar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String _activeFilter = 'All';

  @override
  void initState() {
    super.initState();
    // Removed: restaurantFuture = fetchRestaurantData();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final Restaurant? restaurant = restaurantProvider.restaurant;
    final bool isLoading = restaurantProvider.isLoading;
    final String? error = restaurantProvider.error;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Menu',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          CartBadge(
            value: cartProvider.itemCount.toString(),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () {
                Navigator.pushNamed(context, '/cart');
              },
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 1, // Highlight the correct tab.
        onItemTapped: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/');
          }
        },
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
            ? Center(child: Text('Error: $error'))
            : restaurant != null
            ? Column(
          children: [
            _buildFilterRow(
              ['All']..addAll(restaurant.menu.map((item) => item.category).toSet().toList()),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: _buildMenuWidgets(restaurant, cartProvider),
              ),
            ),
          ],
        )
            : const SizedBox.shrink(),
      ),
    );
  }

  List<Widget> _buildMenuWidgets(Restaurant restaurant, CartProvider cartProvider) {
    // Dynamically generate filters based on menu categories.
    final List<String> filters = ['All'];
    filters.addAll(restaurant.menu.map((item) => item.category).toSet().toList());

    // Filter menu items based on the active filter.
    final filteredMenu = _activeFilter == 'All'
        ? restaurant.menu
        : restaurant.menu.where((item) => item.category == _activeFilter).toList();

    // Build menu item widgets.
    final menuWidgets = filteredMenu.map((item) => _buildMenuItem(item, cartProvider)).toList();

    // Insert the promotional banner if there are enough items.
    if (filteredMenu.length > 2) {
      menuWidgets.insert(2, _buildTrustTheChefCard(cartProvider));
    }
    return menuWidgets;
  }

  Widget _buildFilterRow(List<String> filters) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _activeFilter == filter;
          return FilterChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _activeFilter = filter;
              });
            },
            backgroundColor: Colors.grey[200],
            selectedColor: AppColors.primary,
            checkmarkColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(MenuItem item, CartProvider cartProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 130, // Fixed height for bounded vertical constraints.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food image and counter.
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: (item.imageUrl.isNotEmpty)
                    ? Image.network(
                  item.imageUrl,
                  width: 130,
                  height: 130,
                  fit: BoxFit.cover,
                )
                    : Image.asset(
                  'assets/images/placeholder.png',
                  width: 130,
                  height: 130,
                  fit: BoxFit.cover,
                ),
              ),
              // Animated counter for quick add/remove.
              Positioned(
                bottom: 8,
                right: 8,
                child: AnimatedItemCounter(
                  productId: item.id,
                  onAdd: () {
                    // Instead of directly adding, open the customization modal.
                    _showMenuItemDetails(item, cartProvider);
                  },
                  onRemove: () {
                    cartProvider.decrementItem(item.name);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Text area wrapped in an InkWell to open detail modal with customization.
          Expanded(
            child: InkWell(
              onTap: () {
                _showMenuItemDetails(item, cartProvider);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Flexible(
                        child: _buildInfoChip(
                          'Allergens: ${item.allergens.join(', ')}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nutritional info: ${item.nutrition.entries.map((e) => '${e.key}: ${e.value}').join(', ')}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black45,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Detail modal with ingredient customization.
  void _showMenuItemDetails(MenuItem item, CartProvider cartProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // Example list of available customizations.
        final List<String> availableCustomizations = [
          'chicken',
          'shrimp',
          'cheese',
          'broccoli'
        ];
        // Selected customizations (initially empty).
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${item.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
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

                              // First, call the server and await the returned document id.
                              final documentId = await sendCartItemToServer(
                                userId: storedUserId!, // Replace with your actual user id if needed.
                                restaurantId: 'bbm', // Supply the appropriate restaurant id.
                                itemId: item.id,
                                quantity: 1,
                                priceSnapshot: item.price.toDouble(),
                                customization: {
                                  'customizations':
                                  selectedCustomizations.join(', ')
                                },
                              );

                              // Now add the item using the returned document id.
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
                                category: item.category,
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

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, color: Colors.grey[800]),
      ),
    );
  }

  // Promotional banner: "Trust the Chef" card.
  Widget _buildTrustTheChefCard(CartProvider cartProvider) {
    const chefSpecialId = 'chef-special';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Trust the Chef',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Special',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'A surprise creation made with passion and the finest ingredients of the day!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.secondary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Chef's Special added to cart"),
                          duration: Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('Order now'),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ),
                AnimatedItemCounter(
                  productId: chefSpecialId,
                  onAdd: () {
                    // You can add logic for the chef special here if needed.
                  },
                  onRemove: () {
                    cartProvider.decrementItem(chefSpecialId);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Definition of CartBadge widget.
class CartBadge extends StatelessWidget {
  final Widget child;
  final String value;
  final Color? color;

  const CartBadge({
    Key? key,
    required this.child,
    required this.value,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        if (value != '0')
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: color ?? Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
