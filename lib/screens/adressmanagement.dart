import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

class AddressManagementPage extends StatefulWidget {
  const AddressManagementPage({Key? key}) : super(key: key);

  @override
  State<AddressManagementPage> createState() => _AddressManagementPageState();
}

class _AddressManagementPageState extends State<AddressManagementPage> {
  // This will hold all the addresses fetched from the server.
  // Example structure (each item might look like:
  // { 'label': 'Home', 'apt': '', 'street': '123 Parker St', 'city': 'Roxbury', 'pin': '02120' } )
  List<Map<String, dynamic>> _allAddresses = [];

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final storedUserId = await storage.read(key: 'userId');
      if (storedUserId == null) {
        setState(() {
          _errorMessage = 'User not logged in.';
          _isLoading = false;
        });
        return;
      }

      // TODO: Replace this with your actual fetchAddressesFromServer() call:
      // final data = await fetchAddressesFromServer(storedUserId);
      // Suppose the data structure is something like:
      // { "addresses": {
      //    "home": {"apt": "", "street": "123 Parker St", "city": "Roxbury", "pin": "02120"},
      //    "work": {"apt": "Suite 100", "street": "456 Washington St", "city": "Brookline", "pin": "02446"},
      //    "other1": {"apt": "Apt 3B", "street": "789 Another Rd", "city": "Cambridge", "pin": "02139"}
      //  }}
      // For demonstration, we’ll hardcode some data:

      Map<String, dynamic> data = {
        "addresses": {
          "home": {
            "apt": "",
            "street": "683 Parker St",
            "city": "Roxbury Crossing",
            "pin": "02120"
          },
          "work": {
            "apt": "",
            "street": "724 Washington St",
            "city": "Brookline",
            "pin": "02446"
          },
          "other1": {
            "apt": "Apt 3B",
            "street": "12 Example Rd",
            "city": "Cambridge",
            "pin": "02139"
          },
        }
      };

      final addressesMap = data['addresses'] as Map<String, dynamic>? ?? {};
      final List<Map<String, dynamic>> fetchedList = [];

      addressesMap.forEach((key, value) {
        // Convert each address to a standard map
        final address = Map<String, dynamic>.from(value);
        // Attempt to interpret the key as the "label" if it's "home" or "work" or "other"
        String label = key; // e.g. "home", "work", "other1", etc.
        // You can rename them if you want
        if (label.toLowerCase() == 'home') {
          label = 'Home';
        } else if (label.toLowerCase() == 'work') {
          label = 'Work';
        } else {
          // if it's something else, we just keep it or rename it
          // or store as "Other" or "Custom"
          label = address['type'] ?? 'Other';
        }
        address['label'] = label;
        fetchedList.add(address);
      });

      setState(() {
        _allAddresses = fetchedList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching addresses: $e';
        _isLoading = false;
      });
    }
  }

  // This function will show a bottom sheet for adding a new address.
  void _showAddAddressBottomSheet() {
    final aptController = TextEditingController();
    final streetController = TextEditingController();
    final cityController = TextEditingController();
    final pinController = TextEditingController();
    final labelController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            // Ensure the bottom sheet is above the keyboard
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'Add a new address',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(
                    labelText: 'Label (e.g. Home, Work, etc.)',
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
                    labelText: 'Street Address',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pinController,
                  decoration: const InputDecoration(
                    labelText: 'PIN/Postal Code',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final label = labelController.text.trim();
                    final apt = aptController.text.trim();
                    final street = streetController.text.trim();
                    final city = cityController.text.trim();
                    final pin = pinController.text.trim();

                    if (street.isEmpty || city.isEmpty || pin.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill in all required fields.')),
                      );
                      return;
                    }

                    Navigator.pop(context); // Close bottom sheet

                    final storedUserId = await storage.read(key: 'userId');
                    if (storedUserId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User not logged in.')),
                      );
                      return;
                    }

                    // Call your API to add address on server:
                    // final result = await addAddressOnServer(
                    //   userId: storedUserId,
                    //   apt: apt,
                    //   street: street,
                    //   city: city,
                    //   pin: pin,
                    //   type: label.isNotEmpty ? label : 'Other',
                    // );

                    // For demo, we’ll pretend it worked and just add it locally:
                    setState(() {
                      _allAddresses.add({
                        'label': label.isNotEmpty ? label : 'Other',
                        'apt': apt,
                        'street': street,
                        'city': city,
                        'pin': pin,
                      });
                    });

                    // Show a success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Address added successfully.')),
                    );
                  },
                  child: const Text('Save Address'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper to decide which icon to show for each label
  IconData _getAddressIcon(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      default:
        return Icons.location_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedAddresses = _sortAddresses(_allAddresses);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Addresses'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : Column(
        children: [
          // "Add an address" tile at the top
          ListTile(
            leading: const Icon(Icons.add, color: Colors.black),
            title: const Text('Add an address'),
            onTap: _showAddAddressBottomSheet,
          ),
          const Divider(),

          // Show saved addresses (Home, Work, Others)
          Expanded(
            child: ListView.builder(
              itemCount: sortedAddresses.length,
              itemBuilder: (ctx, index) {
                final addr = sortedAddresses[index];
                final label = addr['label'] ?? 'Other';
                final apt = addr['apt'] ?? '';
                final street = addr['street'] ?? '';
                final city = addr['city'] ?? '';
                final pin = addr['pin'] ?? '';

                String addressLine = street;
                if (apt.isNotEmpty) {
                  addressLine = '$apt, $street';
                }
                final cityLine = '$city, $pin';

                return Column(
                  children: [
                    ListTile(
                      leading: Icon(_getAddressIcon(label), color: Colors.black),
                      title: Text(label),
                      subtitle: Text('$addressLine\n$cityLine'),
                      isThreeLine: true,
                      onTap: () {
                        // If you want to do something when user taps on an address, do it here.
                        // For example, pop back with this address as the selected address:
                        // Navigator.pop(context, addr);
                      },
                    ),
                    const Divider(height: 1),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Sort addresses so that Home and Work appear on top in that order,
  /// followed by all other addresses.
  List<Map<String, dynamic>> _sortAddresses(List<Map<String, dynamic>> addresses) {
    final homeIndex = addresses.indexWhere(
          (addr) => (addr['label'] ?? '').toString().toLowerCase() == 'home',
    );
    final workIndex = addresses.indexWhere(
          (addr) => (addr['label'] ?? '').toString().toLowerCase() == 'work',
    );

    // We'll separate home, work, and others
    Map<String, dynamic>? homeAddress;
    Map<String, dynamic>? workAddress;
    final otherAddresses = <Map<String, dynamic>>[];

    for (var addr in addresses) {
      final label = (addr['label'] ?? '').toString().toLowerCase();
      if (label == 'home') {
        homeAddress = addr;
      } else if (label == 'work') {
        workAddress = addr;
      } else {
        otherAddresses.add(addr);
      }
    }

    final sortedList = <Map<String, dynamic>>[];
    if (homeAddress != null) sortedList.add(homeAddress);
    if (workAddress != null) sortedList.add(workAddress);
    sortedList.addAll(otherAddresses);

    return sortedList;
  }
}
