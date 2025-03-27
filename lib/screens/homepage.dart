import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/menu_provider.dart';
import '../providers/item_counter.dart';
import '../theme/app_theme.dart';
import 'package:built_better_app/components/navbar.dart';
import '../models/restaurant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/cart_services.dart';
import '../providers/menu_item_details.dart'; // The shared modal customization logic

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  void _initializeUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      print(currentUser);
      print('HELLO');
      // User is logged in. Use currentUser.uid as needed.
    }
    final storage = FlutterSecureStorage();
    final storedUserId = await storage.read(key: 'userId');
    if (storedUserId != null) {
      Provider.of<CartProvider>(context, listen: false).loadCartItems(storedUserId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final restaurantProvider = Provider.of<RestaurantProvider>(context);

    // Access the restaurant data from the provider.
    final Restaurant? restaurant = restaurantProvider.restaurant;
    final bool isLoading = restaurantProvider.isLoading;
    final String? error = restaurantProvider.error;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        toolbarHeight: 60,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
            CartBadge(
              value: cartProvider.itemCount.toString(),
              child: IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                onPressed: () {
                  Navigator.pushNamed(context, '/cart');
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _currentNavIndex,
        onItemTapped: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
            ? Center(child: Text('Error: $error'))
            : restaurant != null
            ? SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroBanner(),
              _buildPromoCard(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Our menu',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/menu');
                      },
                      child: Row(
                        children: const [
                          Text('View all items'),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: restaurant.menu.length > 3
                    ? 3
                    : restaurant.menu.length,
                itemBuilder: (context, index) {
                  final item = restaurant.menu[index];
                  return _buildMenuItem(item);
                },
              ),
            ],
          ),
        )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.disabled,
          borderRadius: BorderRadius.circular(12),
          image: const DecorationImage(
            image: AssetImage('assets/images/promotion1.webp'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildPromoCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your first order is on us!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ends 1/31.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {},
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
                ],
              ),
            ),
          ),
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      height: 130,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food image and AnimatedItemCounter.
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
              Positioned(
                bottom: 8,
                right: 8,
                child: AnimatedItemCounter(
                  productId: item.name,
                  onAdd: () {
                    // Instead of directly adding, open the modal with customization.
                    MenuItemDetails.show(
                      context: context,
                      item: item,
                      cartProvider: cartProvider,
                    );
                  },
                  onRemove: () {
                    cartProvider.decrementItem(item.name);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Food item information.
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
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey[800],
        ),
      ),
    );
  }
}

// Custom CartBadge widget.
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
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
