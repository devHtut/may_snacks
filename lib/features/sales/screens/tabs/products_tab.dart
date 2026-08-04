import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:may_snacks/features/warehouse/controllers/warehouse_controller.dart';

class ProductsTab extends StatefulWidget {
  const ProductsTab({super.key});

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final warehouseController = context.watch<WarehouseController>();
    final products = warehouseController.products;

    final filteredProducts = products.where((p) {
      return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.sku.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Products Wholesale Catalog',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
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
        Expanded(
          child: filteredProducts.isEmpty
              ? const Center(child: Text('No products available.'))
              : ListView.separated(
                  itemCount: filteredProducts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];

                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: theme.primaryColor.withOpacity(0.1),
                          child: Icon(Icons.cookie_outlined, color: theme.primaryColor),
                        ),
                        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('SKU: ${product.sku}'),
                        trailing: Text(
                          'Ks ${NumberFormat('#,###').format(product.price)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
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
