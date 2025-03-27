import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // For iOS-style date picker.
import 'package:intl/intl.dart'; // For date formatting.
import 'package:provider/provider.dart';
import 'package:built_better_app/providers/cart_provider.dart';
import 'package:built_better_app/theme/app_theme.dart';
import '../services/order_service.dart';
import '../services/user_service.dart'; // Contains your API calls.
import 'order_success.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

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

  // Address display variables.
  String _address = '';
  String _cityState = '';
  String _selectedAddressLabel = ''; // Stores selected label.

  // New state variables for scheduled delivery.
  DateTime? _selectedScheduledTime;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

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
                    title: 'Select Address',
                    subtitle: 'Tap to choose or add address',
                    onTap: _editAddress,
                  ),
                  _buildDivider(),
                  // Delivery options.
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildDeliveryOptions(),
                  ),
                  _buildDivider(),
                  // Order summary section.
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order Summary', style: AppTextStyles.headline2),
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
              onPressed: cartProvider.items.isEmpty
                  ? null
                  : () async {
                // Ensure an address is selected.
                if (_address.trim().isEmpty || _cityState.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select or add a valid address.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                // Show loading indicator.
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                  const Center(child: CircularProgressIndicator()),
                );

                try {
                  final storedUserId = await storage.read(key: 'userId');
                  if (storedUserId == null) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('User ID not found, please log in again.')),
                    );
                    return;
                  }

                  final orderItems =
                  cartProvider.items.entries.map((entry) {
                    final item = entry.value;
                    return {
                      'itemId': item.menuItemId,
                      'itemName': item.title,
                      'quantity': item.quantity,
                      'price': item.price,
                      'customization': parseCustomization(item.description) ?? '',
                    };
                  }).toList();

                  final orderResponse = await placeOrder(
                    userId: storedUserId,
                    items: orderItems,
                    total: total,
                    deliveryType: _selectedDeliveryOption ?? 'standard',
                    deliveryAddress: '$_address, $_cityState',
                    note: cartProvider.orderNote,
                    restaurantId: 'bbm',
                    payment_id: "",
                    scheduledTime: _selectedDeliveryOption == 'standard'
                        ? DateTime.now().add(const Duration(minutes: 30))
                        : _selectedScheduledTime,
                  );

                  Navigator.pop(context); // Dismiss loading.
                  cartProvider.clear();

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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Price row widget.
  Widget _buildPriceRow(
      String label,
      String price, {
        bool showInfo = false,
        String? infoMessage,
        Color? textColor,
        bool isTotal = false,
      }) {
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
              color: textColor, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: AppColors.divider);
  }

  // Info section widget for displaying selected address details.
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
        child: _selectedAddressLabel.isNotEmpty || _address.isNotEmpty
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedAddressLabel.isNotEmpty &&
                _selectedAddressLabel.toLowerCase() != 'other')
              Row(
                children: [
                  Icon(_getAddressIcon(_selectedAddressLabel),
                      color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    _selectedAddressLabel,
                    style: AppTextStyles.subtitle1
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            const SizedBox(height: 4),
            Text('$_address, $_cityState', style: AppTextStyles.body2),
          ],
        )
            : Row(
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

  // Delivery options widget.
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
              border:
              Border.all(color: AppColors.primary.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subscription Delivery',
                  style: AppTypography.titleMedium
                      .copyWith(color: AppColors.secondary),
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

  // Delivery option widget.
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
                      fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
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
        color: isSelected ? AppColors.secondary : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.secondary : Colors.grey[300]!,
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

  // Updated time picker dialog.
  // Now shows a horizontal day picture selector for the next 7 days and an iOS-like time picker.
  void _showTimePickerDialog() {
    // Initialize default date and time if not already set.
    _selectedDate ??= DateTime.now();
    _selectedTime ??= TimeOfDay.now();

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
            children: [
              Text('Select Delivery Time', style: AppTypography.headlineMedium),
              const SizedBox(height: 20),
              // Horizontal day selector (from today for 7 days).
              SizedBox(
                height: 100,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,

                  child: Row(

                    children: List.generate(7, (index) {
                      final date = DateTime.now().add(Duration(days: index));
                      final dayAbbr = DateFormat('EEE').format(date);
                      bool isSelected = _selectedDate != null &&
                          date.year == _selectedDate!.year &&
                          date.month == _selectedDate!.month &&
                          date.day == _selectedDate!.day;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    dayAbbr,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('d').format(date),
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Cupertino (iOS-like) time picker.
              Container(
                height: 200,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: DateTime(
                    0,
                    1,
                    1,
                    _selectedTime?.hour ?? TimeOfDay.now().hour,
                    _selectedTime?.minute ?? TimeOfDay.now().minute,
                  ),
                  use24hFormat: false,
                  onDateTimeChanged: (DateTime newTime) {
                    setState(() {
                      _selectedTime = TimeOfDay.fromDateTime(newTime);
                    });
                  },
                ),
              ),
              const SizedBox(height: 30),
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
                    if (_selectedDate != null && _selectedTime != null) {
                      final combinedDateTime = DateTime(
                        _selectedDate!.year,
                        _selectedDate!.month,
                        _selectedDate!.day,
                        _selectedTime!.hour,
                        _selectedTime!.minute,
                      );
                      setState(() {
                        _selectedScheduledTime = combinedDateTime;
                      });
                    }
                    Navigator.pop(context);
                  },
                  child: Text('Confirm', style: AppTypography.labelLarge.copyWith(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
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
            Text('${cartProvider.itemCount} items', style: AppTextStyles.subtitle1),
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
                Text('1 promotion applied',
                    style: AppTextStyles.subtitle1.copyWith(color: Colors.green[700])),
                Text('\$${_promoDiscount.toStringAsFixed(2)} off',
                    style: AppTextStyles.body2.copyWith(color: Colors.green[700])),
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

  // Called when user taps the address section.
  void _editAddress() {
    _showAddressSelectionDialog();
  }

  // Displays the bottom sheet to select or add addresses.
  void _showAddressSelectionDialog() async {
    final storedUserId = await storage.read(key: 'userId');
    if (storedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape:
      const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return FutureBuilder<Map<String, dynamic>?>(
          future: fetchAddressesFromServer(storedUserId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
            }
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error fetching addresses: ${snapshot.error}'),
              );
            }

            final addressesMap = (snapshot.data?['addresses'] ?? {}) as Map<String, dynamic>;
            List<Map<String, dynamic>> addressList = [];

            addressesMap.forEach((key, value) {
              final Map<String, dynamic> addr = Map<String, dynamic>.from(value);
              String label = '';
              if (key.toLowerCase() == 'home') {
                label = 'Home';
              } else if (key.toLowerCase() == 'work') {
                label = 'Work';
              } else {
                label = (addr['type'] as String?)?.trim() ?? '';
                if (label.isEmpty) {
                  label = 'other';
                }
              }
              addr['label'] = label;
              addressList.add(addr);
            });

            // Sort addresses so Home and Work come first.
            addressList = _sortAddresses(addressList);

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Select Address',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Add an address'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showAddNewAddressDialog();
                    },
                  ),
                  const Divider(),
                  Expanded(
                    child: addressList.isEmpty
                        ? const Center(child: Text('No saved addresses.'))
                        : ListView.separated(
                      itemCount: addressList.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final addr = addressList[index];
                        final String label = addr['label'] ?? '';
                        final String apt = addr['apt'] ?? '';
                        final String street = addr['street'] ?? '';
                        final String city = addr['city'] ?? '';
                        final String pin = addr['pin'] ?? '';

                        final addressLine = (apt.isNotEmpty ? '$apt, ' : '') + street;
                        final cityState = '$city, $pin';

                        return ListTile(
                          leading: (label.toLowerCase() != 'other' && label.isNotEmpty)
                              ? Icon(_getAddressIcon(label), color: AppColors.primary)
                              : null,
                          title: (label.toLowerCase() != 'other' && label.isNotEmpty)
                              ? Text(label, style: AppTextStyles.subtitle1)
                              : Text(addressLine, style: AppTextStyles.subtitle1),
                          subtitle: (label.toLowerCase() != 'other' && label.isNotEmpty)
                              ? Text('$addressLine\n$cityState', style: AppTextStyles.body2)
                              : Text(cityState, style: AppTextStyles.body2),
                          isThreeLine: (label.toLowerCase() != 'other' && label.isNotEmpty),
                          onTap: () {
                            setState(() {
                              _selectedAddressLabel = (label.toLowerCase() != 'other') ? label : '';
                              _address = addressLine;
                              _cityState = cityState;
                            });
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Sort addresses so that Home and Work come first.
  List<Map<String, dynamic>> _sortAddresses(List<Map<String, dynamic>> addresses) {
    Map<String, dynamic>? home;
    Map<String, dynamic>? work;
    final others = <Map<String, dynamic>>[];

    for (var addr in addresses) {
      final label = (addr['label'] ?? '').toString().toLowerCase();
      if (label == 'home') {
        home = addr;
      } else if (label == 'work') {
        work = addr;
      } else {
        others.add(addr);
      }
    }

    final sorted = <Map<String, dynamic>>[];
    if (home != null) sorted.add(home);
    if (work != null) sorted.add(work);
    sorted.addAll(others);

    return sorted;
  }

  // Helper function to return the appropriate icon based on the label.
  IconData _getAddressIcon(String label) {
    if (label.toLowerCase() == 'home') {
      return Icons.home;
    } else if (label.toLowerCase() == 'work') {
      return Icons.work;
    } else if (label.isNotEmpty) {
      return Icons.location_on;
    }
    return Icons.location_on; // Default icon.
  }

  // Displays a bottom sheet with a form to add a new address.
  void _showAddNewAddressDialog() {
    final parentContext = context;
    final TextEditingController aptController = TextEditingController();
    final TextEditingController streetController = TextEditingController();
    final TextEditingController cityController = TextEditingController();
    final TextEditingController pinController = TextEditingController();
    final TextEditingController labelController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape:
      const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add New Address',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(
                    labelText: 'Label (e.g. Home, Work) - optional',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: aptController,
                  decoration: const InputDecoration(
                    labelText: 'Apartment/Suite (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: streetController,
                  decoration: const InputDecoration(
                    labelText: 'Street Address *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: 'City *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pinController,
                  decoration: const InputDecoration(
                    labelText: 'PIN/Postal Code *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      String apt = aptController.text.trim();
                      String street = streetController.text.trim();
                      String city = cityController.text.trim();
                      String pin = pinController.text.trim();
                      final String label = labelController.text.trim();
                      final String effectiveLabel = label.isEmpty ? "other" : label;

                      if (street.isEmpty || city.isEmpty || pin.isEmpty) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(parentContext).showSnackBar(
                          const SnackBar(content: Text('Please fill in all required fields.')),
                        );
                        return;
                      }

                      final storedUserId = await storage.read(key: 'userId');
                      if (storedUserId == null) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(parentContext).showSnackBar(
                          const SnackBar(content: Text('User not logged in.')),
                        );
                        return;
                      }

                      final result = await addAddressOnServer(
                        userId: storedUserId,
                        apt: apt.isNotEmpty ? apt : null,
                        street: street,
                        city: city,
                        pin: pin,
                        type: effectiveLabel,
                      );

                      if (result != null) {
                        Navigator.of(context).pop();
                        _showAddressSelectionDialog();
                        ScaffoldMessenger.of(parentContext).showSnackBar(
                          const SnackBar(content: Text('Address added successfully.')),
                        );
                      } else {
                        ScaffoldMessenger.of(parentContext).showSnackBar(
                          const SnackBar(content: Text('Failed to add address.')),
                        );
                      }
                    },
                    child: const Text('Save Address'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
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
      shape:
      const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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
                            _promoDiscount = 3.00; // Example discount.
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
      shape:
      const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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
                      Navigator.pop(context);
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
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
