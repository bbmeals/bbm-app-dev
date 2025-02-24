import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../providers/item_counter.dart';
import '../services/restaurant_service.dart';
import '../models/restaurant.dart';
import 'package:built_better_app/components/navbar.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String _activeFilter = 'All';
  late Future<Restaurant> restaurantFuture;

  @override
  void initState() {
    super.initState();
    restaurantFuture = fetchRestaurantData();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

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
        child: FutureBuilder<Restaurant>(
          future: restaurantFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final restaurant = snapshot.data!;
              // Example filter list; adjust or build dynamically if needed.
              List<String> filters = [
                'All',
                'Main Course',
                'Salad',
                'Wrap',
                'Soup',
                'Sandwich',
                'Rice Bowl',
                'Snack'
              ];
              // Filter the menu items based on the active filter.
              final filteredMenu = _activeFilter == 'All'
                  ? restaurant.menu
                  : restaurant.menu
                  .where((item) => item.category == _activeFilter)
                  .toList();

              // Build menu widgets from filtered items.
              final menuWidgets = filteredMenu
                  .map((item) => _buildMenuItem(item, cartProvider))
                  .toList();

              // Insert the promotional banner (Trust the Chef card) if there are enough items.
              if (filteredMenu.length > 2) {
                menuWidgets.insert(2, _buildTrustTheChefCard(cartProvider));
              }

              return Column(
                children: [
                  _buildFilterRow(filters),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: menuWidgets,
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food image
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
              'assets/images/placeholder.png', // Ensure this asset exists
              width: 130,
              height: 130,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          // Text information for the menu item
          Expanded(
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
                Row(
                  children: [
                    Flexible(
                      child: _buildInfoChip(
                          'Allergens: ${item.allergens.join(', ')}'),
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
          // Animated counter widget for adding/removing items
          AnimatedItemCounter(
            productId: item.name, // Consider using a unique identifier if available
            onAdd: () {
              cartProvider.addItem(
                productId: item.name,
                title: item.name,
                price: item.price.toDouble(),
                image: item.imageUrl,
                description: item.description,
                allergens: item.allergens.join(', '),
                nutritionInfo: item.nutrition.entries
                    .map((e) => '${e.key}: ${e.value}')
                    .join(', '),
              );
              if (cartProvider.getItemQuantity(item.name) == 1) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item.name} added to cart'),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            onRemove: () {
              cartProvider.decrementItem(item.name);
            },
          ),
        ],
      ),
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
                      cartProvider.addItem(
                        productId: chefSpecialId,
                        title: "Chef's Special",
                        price: 9.95,
                        image: 'assets/images/Food1.jpg',
                        description: "Chef's surprise creation of the day",
                        allergens: 'Ask server',
                        nutritionInfo: 'Ask server',
                      );
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
                    cartProvider.addItem(
                      productId: chefSpecialId,
                      title: "Chef's Special",
                      price: 9.95,
                      image: 'assets/images/Food1.jpg',
                      description: "Chef's surprise creation of the day",
                      allergens: 'Ask server',
                      nutritionInfo: 'Ask server',
                    );
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

// Sample AnimatedItemCounter widget.
// class AnimatedItemCounter extends StatelessWidget {
//   final String productId;
//   final VoidCallback onAdd;
//   final VoidCallback onRemove;
//
//   const AnimatedItemCounter({
//     Key? key,
//     required this.productId,
//     required this.onAdd,
//     required this.onRemove,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final cartProvider = Provider.of<CartProvider>(context);
//     final quantity = cartProvider.getItemQuantity(productId);
//
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.primary,
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           IconButton(
//             padding: const EdgeInsets.all(4),
//             icon: const Icon(Icons.remove, size: 16, color: Colors.white),
//             onPressed: onRemove,
//           ),
//           Text(
//             '$quantity',
//             style: const TextStyle(color: Colors.white, fontSize: 12),
//           ),
//           IconButton(
//             padding: const EdgeInsets.all(4),
//             icon: const Icon(Icons.add, size: 16, color: Colors.white),
//             onPressed: onAdd,
//           ),
//         ],
//       ),
//     );
//   }
// }
