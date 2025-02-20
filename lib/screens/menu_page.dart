import 'package:flutter/material.dart';
import 'package:built_better_app/components/navbar.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/item_counter.dart';
import '../theme/app_theme.dart';
import 'homepage.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

// Updated MenuPage
class _MenuPageState extends State<MenuPage> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All', 'Vegan', 'Low Carb', 'High Protein'];
  String _activeFilter = 'All';

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
        selectedIndex: 1, // Highlight the 'Orders' tab
        onItemTapped: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/');
          }
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilterRow(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildMenuSection('Main Dishes'),
                  ..._buildMenuItems().take(2),

                  _buildTrustTheChefCard(),

                  _buildMenuSection('Sides & Extras'),
                  ..._buildMenuItems().skip(2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
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
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilterIndex == index;

          return FilterChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedFilterIndex = index;
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

  Widget _buildMenuSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems() {
    // Sample menu items
    final List<Map<String, dynamic>> menuItems = [
      {
        'id': '1',
        'title': 'Roasted Salmon',
        'price': 7.95,
        'description': 'Roasted salmon with rice, vegetables and sauce.',
        'allergens': 'Dairy, Gluten',
        'nutrition': '450kcal, 38g protein, 45g fat',
        'image': 'assets/images/Food1.jpg',
        'tags': ['High Protein'],
      },
      {
        'id': '2',
        'title': 'Grilled Chicken',
        'price': 7.95,
        'description': 'Grilled chicken with seasonal vegetables and special sauce.',
        'allergens': 'Dairy',
        'nutrition': '380kcal, 42g protein, 22g fat',
        'image': 'assets/images/Food1.jpg',
        'tags': ['Low Carb', 'High Protein'],
      },
      {
        'id': '3',
        'title': 'Vegetable Stir Fry',
        'price': 6.95,
        'description': 'Fresh vegetables stir-fried with tofu and special sauce.',
        'allergens': 'Soy',
        'nutrition': '320kcal, 18g protein, 14g fat',
        'image': 'assets/images/Food1.jpg',
        'tags': ['Vegan', 'Low Carb'],
      },
      {
        'id': '4',
        'title': 'Quinoa Bowl',
        'price': 8.95,
        'description': 'Quinoa with roasted vegetables, avocado, and tahini dressing.',
        'allergens': 'Sesame',
        'nutrition': '420kcal, 15g protein, 22g fat',
        'image': 'assets/images/Food1.jpg',
        'tags': ['Vegan'],
      },
    ];

    // Filter items based on selected filter
    final filteredItems = _activeFilter == 'All'
        ? menuItems
        : menuItems.where((item) => item['tags'].contains(_activeFilter))
        .toList();

    return filteredItems.map((item) => _buildMenuItem(item)).toList();
  }

  Widget _buildMenuItem(Map<String, dynamic> item) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 130,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food Image with Add/Counter button
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  item['image'],
                  width: 130,
                  height: 130,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: AnimatedItemCounter(
                  productId: item['id'],
                  onAdd: () {
                    cartProvider.addItem(
                      productId: item['id'],
                      title: item['title'],
                      price: item['price'],
                      image: item['image'],
                      description: item['description'],
                      allergens: item['allergens'],
                      nutritionInfo: item['nutrition'],
                    );

                    // Show a snackbar only on the first add
                    if (cartProvider.getItemQuantity(item['id']) == 1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${item['title']} added to cart'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  onRemove: () {
                    cartProvider.decrementItem(item['id']);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Text info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '\$${item['price'].toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['description'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                const Spacer(),
                Row(
                  children: [
                    _buildInfoChip('Allergens: ${item['allergens']}'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Nutritional info: ${item['nutrition']}',
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

  Widget _buildQuantityButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildTrustTheChefCard() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
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