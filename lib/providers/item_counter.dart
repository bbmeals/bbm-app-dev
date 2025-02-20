import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';

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

class _AnimatedItemCounterState extends State<AnimatedItemCounter> with SingleTickerProviderStateMixin {
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
        final int quantity = cartProvider.getItemQuantity(widget.productId);
        final bool isInCart = quantity > 0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isInCart ? 85 : 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isInCart
              ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTapDown: _onTapDown,
                onTapUp: (_) {
                  _onTapUp(_);
                  widget.onRemove?.call();
                },
                onTapCancel: _onTapCancel,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.remove,
                          size: 16,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Text(
                '$quantity',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTapDown: _onTapDown,
                onTapUp: (_) {
                  _onTapUp(_);
                  widget.onAdd();
                },
                onTapCancel: _onTapCancel,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          )
              : GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: (_) {
              _onTapUp(_);
              widget.onAdd();
            },
            onTapCancel: _onTapCancel,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add,
                        size: 20,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}