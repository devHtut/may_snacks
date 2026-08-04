import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:may_snacks/models/product.dart';
import 'package:may_snacks/features/auth/controllers/auth_controller.dart';
import 'package:may_snacks/features/warehouse/controllers/warehouse_controller.dart';

class NewOrderTab extends StatefulWidget {
  const NewOrderTab({super.key});

  @override
  State<NewOrderTab> createState() => _NewOrderTabState();
}

class _NewOrderTabState extends State<NewOrderTab> {
  final _customerController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _searchQuery = '';

  @override
  void dispose() {
    _customerController.dispose();
    super.dispose();
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
            // Refresh counts inside sheet
            final cartItems = cart.entries.toList();
            double grandTotal = 0;

            for (final entry in cartItems) {
              final product = products.firstWhere((p) => p.id == entry.key);
              grandTotal += entry.value * product.price;
            }

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
                                        setState(() {}); // refresh floating button
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
                                  customerName: _customerController.text,
                                  salesStaffId: authController.profile?.id ?? '',
                                );

                                if (success && mounted) {
                                  Navigator.pop(context);
                                  _customerController.clear();
                                  setState(() {});
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
            // Customer Info Input Card
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Customer Store / Store Name', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _customerController,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Please enter customer store name' : null,
                      decoration: const InputDecoration(
                        hintText: 'e.g., Junction City Supermarket',
                        isDense: true,
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
