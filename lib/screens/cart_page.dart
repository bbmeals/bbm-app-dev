import 'package:flutter/material.dart';
import 'package:built_better_app/providers/cart_provider.dart';
import 'package:built_better_app/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../services/cart_services.dart';

import '../utils/transition.dart';
import '../utils/utils.dart';
import 'checkout_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Helper widget to load either a network image or asset image.
Widget loadImage(String imageUrl,
    {double? width, double? height, BoxFit fit = BoxFit.cover}) {
  if (imageUrl.startsWith('http')) {
    return Image.network(imageUrl, width: width, height: height, fit: fit);
  } else {
    return Image.asset(imageUrl, width: width, height: height, fit: fit);
  }
}

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.items.values.toList();

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
                    itemBuilder: (context, index) =>
                        _buildCartItem(context, cartItems[index]),
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
                  // Recommended items section
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

  Widget _buildCartItem(BuildContext context, CartItem item) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Dismissible(
      key: Key(item.id),
      background: Container(
        color: Colors.red[400],
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        cartProvider.removeItem(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.title} removed from cart'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                // cartProvider.addItem(
                //   productId: item.id,
                //   title: item.title,
                //   price: item.price,
                //   image: item.image,
                //   description: item.description,
                //   allergens: item.allergens,
                //   nutritionInfo: item.nutritionInfo,
                // );
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
                        cartProvider.updateQuantity(item.id, item.quantity - 1);
                        await updateCartItemQuantity(
                          userId: storedUserId,
                          cartItemId: item.id,
                          quantity: item.quantity - 1,
                        );
                      } else {
                        // Handle the case where the user ID is not found.
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
                  // For the add button:
                  _buildRoundedButton(
                    icon: Icons.add,
                    onPressed: () async {
                      final storage = FlutterSecureStorage();
                      final storedUserId = await storage.read(key: 'userId');
                      if (storedUserId != null) {
                        cartProvider.updateQuantity(item.id, item.quantity + 1);
                        await updateCartItemQuantity(
                          userId: storedUserId,
                          cartItemId: item.id,
                          quantity: item.quantity + 1,
                        );
                      } else {
                        // Handle error if userId isn't found.
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
            const Icon(Icons.note_add_outlined,
                color: AppColors.textSecondary),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Add a note',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.text,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

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
            onPressed: () {
              // Save note logic here
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Note added to your order'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedItems(BuildContext context) {
    // Sample recommended items.
    final List<Map<String, dynamic>> recommendedItems = [
      {
        'id': '5',
        'title': 'Roasted Salmon',
        'price': 7.95,
        'description':
        'Roasted salmon with rice, vegetables and sauce.',
        'allergens': 'Dairy, Gluten',
        'nutrition': '450kcal, 38g protein, 45g fat',
        'image': 'assets/images/Food1.jpg',
      },
      {
        'id': '6',
        'title': 'Garden Salad',
        'price': 5.95,
        'description': 'Fresh garden salad with vinaigrette.',
        'allergens': 'None',
        'nutrition': '180kcal, 5g protein, 9g fat',
        'image': 'assets/images/Food1.jpg',
      },
      {
        'id': '7',
        'title': 'Chocolate Mousse',
        'price': 4.95,
        'description': 'Rich chocolate mousse dessert.',
        'allergens': 'Dairy, Eggs',
        'nutrition': '350kcal, 5g protein, 22g fat',
        'image': 'assets/images/Food1.jpg',
      },
    ];

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
              return _buildRecommendedItemCard(context, item);
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildRecommendedItemCard(
      BuildContext context, Map<String, dynamic> item) {
    final cartProvider = Provider.of<CartProvider>(context);

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
          // Image section with fixed height
          SizedBox(
            height: 100,
            width: double.infinity,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
                  child: loadImage(
                    item['image'],
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: GestureDetector(
                    // onTap: () {
                    //   cartProvider.addItem(
                    //     productId: item['id'],
                    //     title: item['title'],
                    //     price: item['price'],
                    //     image: item['image'],
                    //     description: item['description'],
                    //     allergens: item['allergens'],
                    //     nutritionInfo: item['nutrition'],
                    //   );
                    //   showSuccessToast(
                    //       context, '${item['title']} added to cart');
                    // },
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
          // Text content section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item['title'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${item['price'].toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
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
          Navigator.of(context).push(
              SlideUpPageRoute(page: const CheckoutPage()));
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
