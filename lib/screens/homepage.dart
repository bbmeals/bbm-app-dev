import 'package:flutter/material.dart';
import 'menu_page.dart';
import 'package:built_better_app/components/navbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Track the number of items in the cart.
  int _cartItemCount = 0;

  // Figma color references
  static const Color orangeColor = Color(0xFFFF7043); // #FF7043
  static const Color tealColor = Color(0xFF009788);   // #009788
  static const Color grayColor = Color(0xFFD9D9D9);   // #D9D9D9

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const CustomBottomNavBar(),
      body: SingleChildScrollView(
        child: Center(
          // Center horizontally so the 402px-wide content is centered
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 61),

              // -- Top Row with Notifications (left) and Cart (right) --
              Container(
                width: 402,
                height: 33,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left: Notifications
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications),
                    ),

                    // Right: Cart with a badge showing how many items
                    Stack(
                      children: [
                        IconButton(
                          onPressed: () {
                            // Navigate to a cart page or show a modal, etc.
                          },
                          icon: const Icon(Icons.shopping_bag),
                        ),
                        if (_cartItemCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$_cartItemCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // -- Hero Image (approx. 362×177) --
              const SizedBox(
                width: 362,
                height: 177,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: grayColor,
                  ),
                  child: Center(
                    child: Text(
                      'Hero Image',
                      style: TextStyle(color: Colors.black45),
                    ),
                  ),
                ),
              ),

              // -- Promo Section --
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 8.0),
                child: Container(
                  width: 362,
                  height: 110,
                  decoration: BoxDecoration(
                    color: orangeColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13.0,
                          vertical: 13.0,
                        ),
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
                            const SizedBox(height: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed: () {},
                              child: const Text('Order now'),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 13,
                        right: 13,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          child: Text(
                            'M',
                            style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // -- "Our menu" row with "View all items"
              SizedBox(
                width: 362,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MenuPage()),
                          );
                        },
                        child: const Text('View all items'),
                      ),
                    ],
                  ),
                ),
              ),

              // -- Menu Items --
              _buildMenuItem(
                title: 'Roasted Salmon',
                price: '\$7.95',
                description:
                'Roasted salmon with rice, vegetables and sauce.\nAllergens: Dairy, Gluten\nNutritional info: 450kcal, 38g protein, 45g fat',
                imageAsset: 'assets/images/Food1.jpg',
              ),
              _buildMenuItem(
                title: 'Roasted Salmon',
                price: '\$7.95',
                description:
                'Roasted salmon with rice, vegetables and sauce.\nAllergens: Dairy, Gluten\nNutritional info: 450kcal, 38g protein, 45g fat',
                imageAsset: 'assets/images/Food1.jpg',
              ),
              _buildMenuItem(
                title: 'Roasted Salmon',
                price: '\$7.95',
                description:
                'Roasted salmon with rice, vegetables and sauce.\nAllergens: Dairy, Gluten\nNutritional info: 450kcal, 38g protein, 45g fat',
                imageAsset: 'assets/images/Food1.jpg',
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a menu item row where the "+" button is placed on the image itself
  Widget _buildMenuItem({
    required String title,
    required String price,
    required String description,
    required String imageAsset,
  }) {
    return SizedBox(
      width: 362,
      height: 128,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Image + the '+' icon on top of it
            SizedBox(
              width: 128,
              height: 128,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      imageAsset,
                      width: 128,
                      height: 128,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // White circular button with black "+" at bottom-right corner
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _cartItemCount++;
                        });
                      },
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: const Icon(
                          Icons.add,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Text info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$title',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      ' $price',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
