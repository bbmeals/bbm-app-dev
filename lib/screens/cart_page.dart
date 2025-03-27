import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:built_better_app/providers/cart_provider.dart';
import 'package:built_better_app/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../services/cart_services.dart';
import '../services/order_service.dart'; // Import the order service with addOrderNote functionality
import '../utils/transition.dart';
import '../utils/utils.dart';
import 'checkout_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/restaurant.dart';
import '../services/restaurant_service.dart';
import '../providers/menu_provider.dart'; // Import your RestaurantProvider

/// Helper widget to load either a network image or asset image.
Widget loadImage(String imageUrl,
    {double? width, double? height, BoxFit fit = BoxFit.cover}) {
  if (imageUrl.startsWith('http')) {
    return Image.network(imageUrl, width: width, height: height, fit: fit);
  } else {
    return Image.asset(imageUrl, width: width, height: height, fit: fit);
  }
}

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String _orderNote = "";

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    // Convert the items map to a list of map entries to access both key and value.
    final cartItems = cartProvider.items.entries.toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Cart',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart(context)
          : Column(
        children: [
          // Cart items list
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 32,
                      color: AppColors.divider,
                    ),
                    itemBuilder: (context, index) {
                      final productId = cartItems[index].key;
                      final item = cartItems[index].value;
                      return _buildCartItem(context, productId, item);
                    },
                  ),
                  // Add note section
                  _buildAddNoteSection(context),
                  // Button to add more items
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context)
                            .pushReplacementNamed('/menu');
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add items'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        elevation: 0,
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                      ),
                    ),
                  ),
                  // Recommended items section (modified)
                  _buildRecommendedItems(context),
                ],
              ),
            ),
          ),
          // Wrap bottom order summary and checkout in a SafeArea
          SafeArea(
            top: false,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildOrderSummary(context, cartProvider),
                  _buildCheckoutButton(context, cartProvider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items from the menu to get started',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/menu');
            },
            child: const Text('Browse Menu'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, String productId, CartValue item) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Dismissible(
      key: Key(productId),
      background: Container(
        color: Colors.red[400],
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        cartProvider.removeItem(productId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.title} removed from cart'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                // Optionally implement undo logic.
              },
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Use loadImage helper to load asset or network image.
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: loadImage(
                item.image,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.subtitle1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: AppTextStyles.body2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Quantity controls
            Container(
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  _buildRoundedButton(
                    icon: Icons.remove,
                    onPressed: () async {
                      final storage = FlutterSecureStorage();
                      final storedUserId = await storage.read(key: 'userId');
                      if (storedUserId != null) {
                        cartProvider.updateQuantity(productId, item.quantity - 1);
                        await updateCartItemQuantity(
                          userId: storedUserId,
                          cartItemId: productId,
                          quantity: item.quantity - 1,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User ID not found')),
                        );
                      }
                    },
                  ),
                  Container(
                    width: 36,
                    alignment: Alignment.center,
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildRoundedButton(
                    icon: Icons.add,
                    onPressed: () async {
                      final storage = FlutterSecureStorage();
                      final storedUserId = await storage.read(key: 'userId');
                      if (storedUserId != null) {
                        cartProvider.updateQuantity(productId, item.quantity + 1);
                        await updateCartItemQuantity(
                          userId: storedUserId,
                          cartItemId: productId,
                          quantity: item.quantity + 1,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User ID not found')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundedButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildAddNoteSection(BuildContext context) {
    return InkWell(
      onTap: () {
        _showAddNoteDialog(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.divider),
            bottom: BorderSide(color: AppColors.divider),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.note_add_outlined, color: AppColors.textSecondary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                Provider.of<CartProvider>(context).orderNote.isEmpty
                    ? 'Add a note'
                    : Provider.of<CartProvider>(context).orderNote,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.text,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    final TextEditingController controller =
    TextEditingController(text: _orderNote);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add a note'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Special instructions for your order',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              final note = controller.text.trim();
              Navigator.of(ctx).pop(); // Close the dialog first.
              if (note.isNotEmpty) {
                // Retrieve user ID from secure storage.
                final storage = FlutterSecureStorage();
                final storedUserId = await storage.read(key: 'userId');
                if (storedUserId != null) {
                  try {
                    Provider.of<CartProvider>(context, listen: false)
                        .setOrderNote(note);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Note added to your order'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add note: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User ID not found')),
                  );
                }
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  /// Recommended items section (modified)
  Widget _buildRecommendedItems(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final Restaurant? restaurant = restaurantProvider.restaurant;

    if (restaurant == null) return const SizedBox.shrink();

    // Filter out recommendations that are already added to cart.
    final recommendedItems = restaurant.menu
        .where((menuItem) =>
    menuItem.recommended &&
        !cartProvider.getAllMenuItems().contains(menuItem.id))
        .toList();


    if (recommendedItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            'Recommended with',
            style: AppTextStyles.headline2,
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: recommendedItems.length,
            itemBuilder: (context, index) {
              final item = recommendedItems[index];
              return _buildRecommendedItemCard(context, item, cartProvider);
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  /// Recommended item card using provider data.
  Widget _buildRecommendedItemCard(
      BuildContext context, MenuItem item, CartProvider cartProvider) {
    return Container(
      width: 150,
      height: 150,
      margin: const EdgeInsets.only(right: 12, bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section with fixed height.
          SizedBox(
            height: 100,
            width: double.infinity,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
                  child: loadImage(
                    item.imageUrl,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      _showMenuItemDetails(item, cartProvider);
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Text content section.
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

  /// The same modal for customization as in your menu page.
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

  Widget _buildOrderSummary(
      BuildContext context, CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal'),
              Text(
                '\$${cartProvider.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Delivery fee'),
              Text(
                '\$${1.99.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tax'),
              Text(
                '\$${(cartProvider.totalAmount * 0.08).toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${(cartProvider.totalAmount + 1.99 + cartProvider.totalAmount * 0.08).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(
      BuildContext context, CartProvider cartProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: cartProvider.items.isEmpty
            ? null
            : () {
          Navigator.of(context)
              .push(SlideUpPageRoute(page: const CheckoutPage()));
        },
        child: const Text(
          'Go to checkout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
