import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:built_better_app/providers/cart_provider.dart';
import 'package:built_better_app/theme/app_theme.dart';
import '../services/order_service.dart';
import 'order_success.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? _selectedDeliveryOption = 'standard';
  String _promoCode = '';
  bool _promoApplied = false;
  double _promoDiscount = 0;
  // Start with empty strings so that the user enters these values.
  String _address = '';
  String _cityState = '';
  String _phone = '';

  // Validate phone number: expects +1 followed by 10 digits (optionally with a space).
  bool _isValidPhone(String phone) {
    final RegExp regex = RegExp(r'^\+1\s?\d{10}$');
    return regex.hasMatch(phone);
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final deliveryFee = 1.49;
    final tax = cartProvider.totalAmount * 0.08;
    final total = cartProvider.totalAmount + deliveryFee + tax - _promoDiscount;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Main scrollable content.
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Address section.
                  _buildInfoSection(
                    icon: Icons.location_on_outlined,
                    title: _address.isEmpty ? 'Enter street address' : _address,
                    subtitle: _cityState.isEmpty ? 'Enter city, state' : _cityState,
                    onTap: _editAddress,
                  ),
                  _buildDivider(),
                  // Phone section.
                  _buildInfoSection(
                    icon: Icons.phone_outlined,
                    title: _phone.isEmpty ? 'Enter phone number' : _phone,
                    onTap: _editPhone,
                  ),
                  _buildDivider(),
                  // Delivery options.
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildDeliveryOptions(),
                  ),
                  _buildDivider(),
                  // Order summary section including order items and promo code.
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Summary',
                          style: AppTextStyles.headline2,
                        ),
                        const SizedBox(height: 16),
                        _buildOrderItemsList(cartProvider),
                        const SizedBox(height: 16),
                        _buildPromoCodeSection(),
                      ],
                    ),
                  ),
                  _buildDivider(),
                  // Price breakdown.
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildPriceRow(
                          'Subtotal',
                          '\$${cartProvider.totalAmount.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 8),
                        _buildPriceRow(
                          'Delivery',
                          '\$${deliveryFee.toStringAsFixed(2)}',
                          showInfo: true,
                          infoMessage: 'This fee covers delivery costs',
                        ),
                        const SizedBox(height: 8),
                        _buildPriceRow(
                          'Tax',
                          '\$${tax.toStringAsFixed(2)}',
                          showInfo: true,
                          infoMessage: 'Includes local sales tax',
                        ),
                        const SizedBox(height: 16),
                        _buildPriceRow(
                          'Total',
                          '\$${total.toStringAsFixed(2)}',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // Fixed bottom button for placing the order.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
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
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              // Disable if cart is empty. Also validate that the address and phone have been entered.
              onPressed: cartProvider.items.isEmpty
                  ? null
                  : () async {
                if (_address.trim().isEmpty ||
                    _cityState.trim().isEmpty ||
                    _phone.trim().isEmpty ||
                    !_isValidPhone(_phone)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid address and phone number.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                // Show a loading indicator.
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                try {
                  // Retrieve the stored user ID from secure storage.
                  final storage = FlutterSecureStorage();
                  final storedUserId = await storage.read(key: 'userId');

                  if (storedUserId == null) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User ID not found, please log in again.'),
                      ),
                    );
                    return;
                  }

                  // Map each cart item into a map.
                  final orderItems = cartProvider.items.values.map((item) {
                    return {
                      'itemId': item.id,
                      'quantity': item.quantity,
                      'price': item.price,
                      'customization': parseCustomization(item.description) ?? '',
                    };
                  }).toList();

                  final orderResponse = await placeOrder(
                    userId: storedUserId, // Use the retrieved user ID.
                    items: orderItems,
                    total: total,
                    deliveryType: _selectedDeliveryOption ?? 'standard',
                    deliveryAddress: '$_address, $_cityState',
                    scheduledTime: _selectedDeliveryOption == 'schedule'
                        ? DateTime.now() // Replace with a scheduled time if applicable.
                        : null,
                  );

                  // Dismiss the loading indicator.
                  Navigator.pop(context);

                  // Clear the cart.
                  cartProvider.clear();

                  // Navigate to the order success page.
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OrderSuccessPage(orderId: orderResponse['id']),
                    ),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error placing order: $e')),
                  );
                }
              },
              child: const Text(
                'Place order',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String price,
      {bool showInfo = false, String? infoMessage, Color? textColor, bool isTotal = false}) {
    return Row(
      children: [
        Text(
          label,
          style: isTotal ? AppTextStyles.subtitle1 : AppTextStyles.body1,
        ),
        if (showInfo) ...[
          const SizedBox(width: 4),
          InkWell(
            onTap: () {
              if (infoMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(infoMessage),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Icon(Icons.info_outline, size: 16, color: Colors.grey),
          ),
        ],
        const Spacer(),
        Text(
          price,
          style: isTotal
              ? AppTextStyles.headline2.copyWith(color: AppColors.primary)
              : AppTextStyles.body1.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: AppColors.divider);
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.subtitle1),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTextStyles.body2),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryOptions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDeliveryOption(
                title: 'Standard',
                subtitle: '20-35 min',
                value: 'standard',
                icon: Icons.delivery_dining,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDeliveryOption(
                title: 'Schedule',
                subtitle: 'Choose a time',
                value: 'schedule',
                icon: Icons.schedule,
                onSelected: _showTimePickerDialog,
              ),
            ),
          ],
        ),
        if (_selectedDeliveryOption == 'subscription') ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subscription Delivery',
                  style: AppTypography.titleMedium.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose your weekly delivery schedule',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildDayChip('Mon', isSelected: true),
                    _buildDayChip('Wed'),
                    _buildDayChip('Fri', isSelected: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDeliveryOption({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    VoidCallback? onSelected,
  }) {
    final isSelected = _selectedDeliveryOption == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDeliveryOption = value;
        });
        if (onSelected != null) {
          onSelected();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? AppColors.primary : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.titleSmall.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.text,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayChip(String day, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey[300]!,
        ),
      ),
      child: Text(
        day,
        style: AppTypography.labelSmall.copyWith(
          color: isSelected ? Colors.white : AppColors.text,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  void _showTimePickerDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Delivery Time', style: AppTypography.headlineMedium),
              const SizedBox(height: 20),
              // Date selection.
              Text('Date', style: AppTypography.titleMedium),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(5, (index) {
                    final date = DateTime.now().add(Duration(days: index));
                    final isToday = index == 0;
                    final isTomorrow = index == 1;
                    String dayText;
                    if (isToday) {
                      dayText = 'Today';
                    } else if (isTomorrow) {
                      dayText = 'Tomorrow';
                    } else {
                      dayText = '${date.day}/${date.month}';
                    }
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: _buildDateOption(
                        dayText,
                        isSelected: index == 0,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),
              // Time selection.
              Text('Time', style: AppTypography.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildTimeOption('12:00 PM'),
                  _buildTimeOption('12:30 PM'),
                  _buildTimeOption('1:00 PM', isSelected: true),
                  _buildTimeOption('1:30 PM'),
                  _buildTimeOption('2:00 PM'),
                  _buildTimeOption('2:30 PM'),
                ],
              ),
              const SizedBox(height: 30),
              // Confirm button.
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Confirm',
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateOption(String text, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey[300]!,
        ),
      ),
      child: Text(
        text,
        style: AppTypography.labelMedium.copyWith(
          color: isSelected ? Colors.white : AppColors.text,
        ),
      ),
    );
  }

  Widget _buildTimeOption(String time, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey[300]!,
        ),
      ),
      child: Text(
        time,
        style: AppTypography.labelMedium.copyWith(
          color: isSelected ? Colors.white : AppColors.text,
        ),
      ),
    );
  }

  Widget _buildOrderItemsList(CartProvider cartProvider) {
    final items = cartProvider.items.values.toList();
    return InkWell(
      onTap: () {
        _showOrderDetailsDialog(items);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.shopping_bag_outlined),
            const SizedBox(width: 16),
            Text(
              '${cartProvider.itemCount} items',
              style: AppTextStyles.subtitle1,
            ),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCodeSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: _promoApplied
          ? _buildAppliedPromoCode()
          : InkWell(
        onTap: _showPromoCodeDialog,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.local_offer_outlined),
              const SizedBox(width: 16),
              Text('Add promo code', style: AppTextStyles.subtitle1),
              const Spacer(),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppliedPromoCode() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.green[50],
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1 promotion applied',
                  style: AppTextStyles.subtitle1.copyWith(
                    color: Colors.green[700],
                  ),
                ),
                Text(
                  '\$${_promoDiscount.toStringAsFixed(2)} off',
                  style: AppTextStyles.body2.copyWith(
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () {
              setState(() {
                _promoApplied = false;
                _promoDiscount = 0;
                _promoCode = '';
              });
            },
          ),
        ],
      ),
    );
  }

  void _editAddress() {
    final TextEditingController streetController = TextEditingController(text: _address);
    final TextEditingController cityStateController = TextEditingController(text: _cityState);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Address', style: AppTextStyles.headline2),
              const SizedBox(height: 16),
              TextField(
                controller: streetController,
                decoration: const InputDecoration(
                  labelText: 'Street address',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _address = value;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityStateController,
                decoration: const InputDecoration(
                  labelText: 'City, State',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _cityState = value;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _address = streetController.text;
                      _cityState = cityStateController.text;
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save Address'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _editPhone() {
    final TextEditingController phoneController = TextEditingController(
      text: _phone.startsWith('+1 ') ? _phone.substring(3) : _phone,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Phone Number', style: AppTextStyles.headline2),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixText: '+1 ',
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  _phone = '+1 $value';
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _phone = '+1 ${phoneController.text}';
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save Phone Number'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showPromoCodeDialog() {
    final TextEditingController controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Promo Code', style: AppTextStyles.headline2),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Enter promo code',
                  border: OutlineInputBorder(),
                  hintText: 'e.g. WELCOME20',
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Cancel: just dismiss the modal.
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final code = controller.text.trim().toUpperCase();
                        if (code.isNotEmpty) {
                          setState(() {
                            _promoCode = code;
                            _promoApplied = true;
                            _promoDiscount = 3.00;
                          });
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Promo code $code applied!'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.green[700],
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showOrderDetailsDialog(List cartItems) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Order Items', style: AppTextStyles.headline2),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      final orderId = 'ORDER${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
                      final cartProvider = Provider.of<CartProvider>(context, listen: false);
                      cartProvider.clear();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderSuccessPage(orderId: orderId),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: cartItems.length,
                  separatorBuilder: (context, index) => const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.image,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/Food1.jpg',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title, style: AppTextStyles.subtitle1),
                              if (item.description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text('No cheese', style: AppTextStyles.body2),
                              ],
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('\$${item.price.toStringAsFixed(2)}', style: AppTextStyles.subtitle1),
                            const SizedBox(height: 4),
                            Text('Qty: ${item.quantity}', style: AppTextStyles.body2),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper function to parse customization data from the description.
  String? parseCustomization(String description) {
    const marker = 'Customizations:';
    if (description.contains(marker)) {
      final parts = description.split(marker);
      if (parts.length > 1) {
        return parts.last.trim();
      }
    }
    return null;
  }
}
