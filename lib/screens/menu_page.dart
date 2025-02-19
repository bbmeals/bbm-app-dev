import 'package:flutter/material.dart';
import 'package:built_better_app/components/navbar.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  // Track selected filter
  int _selectedFilterIndex = 0;

  // Sample filters
  final List<String> _filters = ['Vegan', 'Low Carb', 'Order now'];

  // List of menu items
  List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'Roasted Salmon',
      'price': 7.95,
      'description': 'Roasted salmon with rice, vegetables and sauce.',
      'allergens': 'Dairy, Gluten',
      'nutrition': '450kcal, 38g protein, 45g fat',
      'image': 'assets/images/Food1.jpg',
      'quantity': 0,
    },
    {
      'title': 'Roasted Salmon',
      'price': 7.95,
      'description': 'Roasted salmon with rice, vegetables and sauce.',
      'allergens': 'Dairy, Gluten',
      'nutrition': '450kcal, 38g protein, 45g fat',
      'image': 'assets/images/Food1.jpg',
      'quantity': 0,
    },
    // "Trust the Chef" special item
    {
      'title': 'Trust the Chef',
      'price': 0.0,
      'description': 'A surprise creation made with passion and the finest ingredients of the day!',
      'allergens': 'Varies',
      'nutrition': 'Varies',
      'image': 'assets/images/Food1.jpg', // or any placeholder image
      'quantity': 0,
      'isChefSpecial': true,
    },
    {
      'title': 'Roasted Salmon',
      'price': 7.95,
      'description': 'Roasted salmon with rice, vegetables and sauce.',
      'allergens': 'Dairy, Gluten',
      'nutrition': '450kcal, 38g protein, 45g fat',
      'image': 'assets/images/Food1.jpg',
      'quantity': 0,
    },
  ];

  // Calculate total items in cart
  int get cartCount {
    int total = 0;
    for (var item in _menuItems) {
      total += item['quantity'] as int;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Custom AppBar
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Menu'),
        actions: [
          // Cart icon with count
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.shopping_basket_outlined, size: 28),
              // Only show count if > 0
              if (cartCount > 0)
                Positioned(
                  right: 0,
                  top: 5,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$cartCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 16),
        ],
      ),

      // Bottom Navigation Bar - highlight "Orders" or second item, etc.
      bottomNavigationBar: const CustomBottomNavBar(),

      body: SafeArea(
        child: Column(
          children: [
            // Filter row (static)
            _buildFilterRow(),
            // Menu items (scrollable)
            Expanded(
              child: ListView.builder(
                itemCount: _menuItems.length,
                itemBuilder: (context, index) {
                  final item = _menuItems[index];
                  return _buildMenuItem(item, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build the row of filters at the top
  Widget _buildFilterRow() {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (context, index) => SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedFilterIndex == index;
          return ChoiceChip(
            label: Text(_filters[index]),
            selected: isSelected,
            onSelected: (_) {
              setState(() {
                _selectedFilterIndex = index;
              });
              // Filter logic if needed
            },
            selectedColor: Colors.teal,
            backgroundColor: Colors.grey[200],
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
            ),
          );
        },
      ),
    );
  }

  // Build individual menu item card
  Widget _buildMenuItem(Map<String, dynamic> item, int index) {
    bool isChefSpecial = item['isChefSpecial'] == true;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: isChefSpecial
            ? _buildChefSpecial(item, index)
            : _buildRegularItem(item, index),
      ),
    );
  }

  // Layout for the "Trust the Chef" special
  Widget _buildChefSpecial(Map<String, dynamic> item, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trust the Chef',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          item['description'],
          style: TextStyle(color: Colors.grey[600]),
        ),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            // Example: add 1 item to cart
            setState(() {
              item['quantity'] = item['quantity'] + 1;
            });
          },
          child: Text('Order now'),
        ),
      ],
    );
  }

  // Layout for a regular menu item
  Widget _buildRegularItem(Map<String, dynamic> item, int index) {
    return Row(
      children: [
        // Item image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            item['image'],
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(width: 16),
        // Item info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['title'],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text('\$${item['price'].toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey[700])),
              SizedBox(height: 4),
              Text(
                item['description'],
                style: TextStyle(color: Colors.grey[600]),
                softWrap: true,
              ),
              SizedBox(height: 4),
              Text(
                'Allergens: ${item['allergens']}',
                style: TextStyle(color: Colors.grey[500]),
                softWrap: true,
              ),
              Text(
                'Nutritional info: ${item['nutrition']}',
                style: TextStyle(color: Colors.grey[500]),
                softWrap: true,
              ),
              SizedBox(height: 8),
              // Add/Remove row
              Row(
                children: [
                  _buildQuantityButton(
                    icon: Icons.remove,
                    onPressed: () {
                      setState(() {
                        if (item['quantity'] > 0) {
                          item['quantity'] = item['quantity'] - 1;
                        }
                      });
                    },
                  ),
                  SizedBox(width: 8),
                  Text('${item['quantity']}'),
                  SizedBox(width: 8),
                  _buildQuantityButton(
                    icon: Icons.add,
                    onPressed: () {
                      setState(() {
                        item['quantity'] = item['quantity'] + 1;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper for + / - quantity buttons
  Widget _buildQuantityButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  }
}
