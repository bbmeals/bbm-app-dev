import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class AnimatedItemCounter extends StatefulWidget {
  final String productId;
  final VoidCallback onAdd;
  final VoidCallback? onRemove;

  const AnimatedItemCounter({
    Key? key,
    required this.productId,
    required this.onAdd,
    this.onRemove,
  }) : super(key: key);

  @override
  State<AnimatedItemCounter> createState() => _AnimatedItemCounterState();
}

class _AnimatedItemCounterState extends State<AnimatedItemCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final int quantity = cartProvider.getTotalQuantityByMenuItemId(widget.productId);
        final bool isInCart = quantity > 0;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: child,
          ),
          child: isInCart
          // 1. If in cart, show a circle with the quantity.
              ? GestureDetector(
            key: const ValueKey('inCart'),
            onTapDown: _onTapDown,
            onTapUp: (_) {
              _onTapUp(_);
              widget.onAdd(); // tapping increments
            },
            onTapCancel: _onTapCancel,
            child: Container(
              width: 36,
              height: 36,
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
              child: Center(
                child: Text(
                  '$quantity',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          )
          // 2. If not in cart, show a circle with a plus icon.
              : GestureDetector(
            key: const ValueKey('notInCart'),
            onTapDown: _onTapDown,
            onTapUp: (_) {
              _onTapUp(_);
              widget.onAdd();
            },
            onTapCancel: _onTapCancel,
            child: Container(
              width: 36,
              height: 36,
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
                size: 20,
                color: Colors.black87,
              ),
            ),
          ),
        );
      },
    );
  }
}
