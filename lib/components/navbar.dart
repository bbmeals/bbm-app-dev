import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 402,
      height: 72,
      padding: const EdgeInsets.fromLTRB(41, 6, 41, 13),
      color: const Color(0xFF009788), // Your teal color
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(Icons.home_outlined, true),
          _buildNavItem(Icons.description_outlined, false),
          _buildNavItem(Icons.star_outline, false),
          _buildNavItem(Icons.person_outline, false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isSelected) {
    return Icon(
      icon,
      color: Colors.white,
      size: 28, // Adjust size as needed
    );
  }
}