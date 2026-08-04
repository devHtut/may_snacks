import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:may_snacks/models/product.dart';
import 'package:may_snacks/features/warehouse/controllers/warehouse_controller.dart';
import '../../controllers/admin_controller.dart';

class ProductCatalogTab extends StatefulWidget {
  const ProductCatalogTab({super.key});

  @override
  State<ProductCatalogTab> createState() => _ProductCatalogTabState();
}

class _ProductCatalogTabState extends State<ProductCatalogTab> {
  void _showAddProductDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final skuController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Product'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Product Name', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: nameController,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter product name' : null,
                    decoration: const InputDecoration(hintText: 'e.g., Strawberry Muffin'),
                  ),
                  const SizedBox(height: 16),

                  const Text('SKU (Unique Code)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: skuController,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter SKU code' : null,
                    decoration: const InputDecoration(hintText: 'e.g., MS-STRAW-MUFFIN'),
                  ),
                  const SizedBox(height: 16),

                  const Text('Wholesale Price (Ks)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter price';
                      final price = double.tryParse(v);
                      if (price == null || price < 0) return 'Must be zero or positive';
                      return null;
                    },
                    decoration: const InputDecoration(hintText: 'e.g., 1800'),
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
                if (!formKey.currentState!.validate()) return;
                
                final controller = context.read<AdminController>();
                final warehouseController = context.read<WarehouseController>();

                final success = await controller.addProduct(
                  name: nameController.text.trim(),
                  sku: skuController.text.trim().toUpperCase(),
                  price: double.parse(priceController.text),
                );

                if (success && mounted) {
                  Navigator.pop(context);
                  // Reload catalogs in both controllers to sync lists
                  await warehouseController.loadAllWarehouseData();
                  await controller.loadAllAdminData();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product added successfully to catalog.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(controller.errorMessage ?? 'Failed to add product.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              child: const Text('Add Product'),
            ),
          ],
        );
      },
    );
  }

  void _showEditPriceDialog(Product product) {
    final formKey = GlobalKey<FormState>();
    final priceController = TextEditingController(text: product.price.toStringAsFixed(0));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Wholesale Price for ${product.name}'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current SKU: ${product.sku}'),
                const SizedBox(height: 16),
                const Text('New Wholesale Price (Ks)', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter price';
                    final price = double.tryParse(v);
                    if (price == null || price < 0) return 'Must be zero or positive';
                    return null;
                  },
                  decoration: const InputDecoration(hintText: 'e.g., 2000'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final controller = context.read<AdminController>();
                final warehouseController = context.read<WarehouseController>();
                final newPrice = double.parse(priceController.text);

                final success = await controller.updateProductPrice(product.id, newPrice);

                if (success && mounted) {
                  Navigator.pop(context);
                  await warehouseController.loadAllWarehouseData();
                  await controller.loadAllAdminData();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Wholesale price updated successfully.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(controller.errorMessage ?? 'Failed to update price.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              child: const Text('Update Price'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final warehouseController = context.watch<WarehouseController>();
    final products = warehouseController.products;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Master Product Catalog & Wholesale Prices',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: _showAddProductDialog,
              icon: const Icon(Icons.add_box_rounded),
              label: const Text('Add Product'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: products.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  itemCount: products.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        leading: CircleAvatar(
                          backgroundColor: theme.primaryColor.withOpacity(0.1),
                          child: Icon(Icons.cookie_outlined, color: theme.primaryColor),
                        ),
                        title: Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text('SKU: ${product.sku} | Registered: ${DateFormat('yyyy-MM-dd').format(product.createdAt)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              NumberFormat.currency(symbol: 'Ks ', decimalDigits: 0).format(product.price),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.edit_note_rounded, size: 24),
                              tooltip: 'Edit Price',
                              onPressed: () => _showEditPriceDialog(product),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
