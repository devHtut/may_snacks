import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:may_snacks/models/product.dart';
import 'package:may_snacks/models/customer.dart';
import 'package:may_snacks/services/location_service.dart';
import 'package:may_snacks/features/auth/controllers/auth_controller.dart';
import 'package:may_snacks/features/warehouse/controllers/warehouse_controller.dart';

class NewOrderTab extends StatefulWidget {
  const NewOrderTab({super.key});

  @override
  State<NewOrderTab> createState() => _NewOrderTabState();
}

class _NewOrderTabState extends State<NewOrderTab> {
  final _formKey = GlobalKey<FormState>();
  String _searchQuery = '';
  Customer? _selectedCustomer;
  Map<String, List<String>> _locationData = {};

  // New shop registration form controllers
  final _newShopNameController = TextEditingController();
  final _newShopAddressController = TextEditingController();
  final _newShopPhoneController = TextEditingController();
  final _registerFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    final data = await LocationService.loadLocationData();
    if (mounted) {
      setState(() {
        _locationData = data;
      });
    }
  }

  @override
  void dispose() {
    _newShopNameController.dispose();
    _newShopAddressController.dispose();
    _newShopPhoneController.dispose();
    super.dispose();
  }

  void _showRegisterShopDialog() {
    String? selectedRegion;
    String? selectedTownship;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final regions = LocationService.getRegions(_locationData);
            final townships = LocationService.getTownships(_locationData, selectedRegion);

            return AlertDialog(
              title: const Text('Register New Field Shop'),
              content: Form(
                key: _registerFormKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Submitting a new shop will send a request to Admin for approval to add to the official store dropdown list.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _newShopNameController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Please enter store name' : null,
                        decoration: const InputDecoration(
                          labelText: 'Store Name *',
                          hintText: 'e.g., Seiko Wholesale Mart',
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedRegion,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Region / State *'),
                        validator: (v) => v == null ? 'Please select Region / State' : null,
                        items: regions.map((r) {
                          return DropdownMenuItem(value: r, child: Text(r));
                        }).toList(),
                        onChanged: (val) {
                          setDialogState(() {
                            selectedRegion = val;
                            selectedTownship = null;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedTownship,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Township *'),
                        validator: (v) => v == null ? 'Please select Township' : null,
                        items: townships.map((t) {
                          return DropdownMenuItem(value: t, child: Text(t));
                        }).toList(),
                        onChanged: (val) {
                          setDialogState(() {
                            selectedTownship = val;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _newShopPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number *',
                          hintText: 'e.g., 09123456789',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Phone number is required';
                          }
                          final trimmed = v.trim();
                          if (!RegExp(r'^09\d{7,9}$').hasMatch(trimmed)) {
                            return 'Must start with 09, numbers only, & 9-11 digits long';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _newShopAddressController,
                        decoration: const InputDecoration(
                          labelText: 'Street Address (Optional)',
                          hintText: 'e.g., No. 45, Pyay Road',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_registerFormKey.currentState!.validate()) {
                      final warehouseController = context.read<WarehouseController>();
                      final authController = context.read<AuthController>();
                      final shopName = _newShopNameController.text.trim();

                      final success = await warehouseController.registerCustomer(
                        name: shopName,
                        region: selectedRegion!,
                        township: selectedTownship!,
                        address: _newShopAddressController.text.trim().isEmpty ? null : _newShopAddressController.text.trim(),
                        phone: _newShopPhoneController.text.trim(),
                        createdBy: authController.profile?.id ?? '',
                      );

                      if (success && mounted) {
                        Navigator.pop(context);
                        _newShopNameController.clear();
                        _newShopAddressController.clear();
                        _newShopPhoneController.clear();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Registration request for "$shopName" submitted! It will appear in the dropdown once Admin approves it.'),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Submit Request'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCartSheet() {
    final warehouseController = context.read<WarehouseController>();
    final authController = context.read<AuthController>();
    final products = warehouseController.products;
    final cart = warehouseController.cart;

    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty. Add products first.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final theme = Theme.of(context);
            final cartItems = cart.entries.toList();
            double grandTotal = 0;

            for (final entry in cartItems) {
              final product = products.firstWhere((p) => p.id == entry.key);
              grandTotal += entry.value * product.price;
            }

            final customerName = _selectedCustomer?.name ?? '';

            return Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Review Wholesale Order',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Customer: $customerName', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                  const Divider(height: 24),
                  if (cartItems.isEmpty)
                    const SizedBox(
                      height: 150,
                      child: Center(child: Text('All items removed from cart.')),
                    )
                  else ...[
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: cartItems.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final entry = cartItems[index];
                          final product = products.firstWhere((p) => p.id == entry.key);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text('Price: Ks ${NumberFormat('#,###').format(product.price)} each'),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.grey),
                                      onPressed: () {
                                        warehouseController.updateCartItem(product.id, entry.value - 1);
                                        setSheetState(() {});
                                        setState(() {});
                                      },
                                    ),
                                    Text(
                                      '${entry.value}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add_circle_outline_rounded, color: theme.primaryColor),
                                      onPressed: () {
                                        warehouseController.updateCartItem(product.id, entry.value + 1);
                                        setSheetState(() {});
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Ks ${NumberFormat('#,###').format(entry.value * product.price)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Grand Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          'Ks ${NumberFormat('#,###').format(grandTotal)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: warehouseController.isLoading
                            ? null
                            : () async {
                                final success = await warehouseController.submitOrder(
                                  customerName: customerName,
                                  customerId: _selectedCustomer?.id,
                                  salesStaffId: authController.profile?.id ?? '',
                                );

                                if (success && mounted) {
                                  Navigator.pop(context);
                                  setState(() {
                                    _selectedCustomer = null;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Wholesale order submitted successfully!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(warehouseController.errorMessage ?? 'Failed to submit order.'),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              },
                        child: warehouseController.isLoading
                            ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
                            : const Text('Submit Wholesale Order', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final warehouseController = context.watch<WarehouseController>();
    final products = warehouseController.products;
    final approvedCustomers = warehouseController.approvedCustomers;
    final cart = warehouseController.cart;

    final filteredProducts = products.where((p) {
      return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.sku.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Customer Store Selection Card
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Customer / Shop Store', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextButton.icon(
                          onPressed: _showRegisterShopDialog,
                          icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                          label: const Text('+ Register New Shop', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Customer>(
                      value: _selectedCustomer,
                      isExpanded: true,
                      hint: const Text('Select Approved Master Customer Store...'),
                      validator: (v) {
                        if (v == null) {
                          return 'Please select an approved customer store';
                        }
                        return null;
                      },
                      items: approvedCustomers.map((customer) {
                        return DropdownMenuItem<Customer>(
                          value: customer,
                          child: Text(
                            '${customer.name} (${customer.township}, ${customer.region})',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCustomer = val;
                        });
                      },
                      decoration: const InputDecoration(
                        isDense: true,
                        prefixIcon: Icon(Icons.storefront_rounded),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Search Input
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search products by name or SKU...',
                prefixIcon: Icon(Icons.search_rounded),
                isDense: true,
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
            const SizedBox(height: 16),
            // Products List
            Expanded(
              child: filteredProducts.isEmpty
                  ? const Center(child: Text('No products available.'))
                  : ListView.separated(
                      itemCount: filteredProducts.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        final qty = cart[product.id] ?? 0;

                        return Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                                  child: Icon(Icons.cookie_outlined, color: theme.primaryColor),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      Text('SKU: ${product.sku}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Ks ${NumberFormat('#,###').format(product.price)}',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor),
                                      ),
                                    ],
                                  ),
                                ),
                                // +/- Counter
                                Row(
                                  children: [
                                    if (qty > 0) ...[
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.grey),
                                        onPressed: () {
                                          warehouseController.updateCartItem(product.id, qty - 1);
                                          setState(() {});
                                        },
                                      ),
                                      Text(
                                        '$qty',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ],
                                    IconButton(
                                      icon: Icon(Icons.add_circle_outline_rounded, color: theme.primaryColor),
                                      onPressed: () {
                                        warehouseController.updateCartItem(product.id, qty + 1);
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: cart.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _showCartSheet();
                }
              },
              icon: const Icon(Icons.shopping_cart_checkout_rounded),
              label: Text('Review Cart (${warehouseController.cartItemCount})'),
            )
          : null,
    );
  }
}
