import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:may_snacks/models/product.dart';
import 'package:may_snacks/features/warehouse/controllers/warehouse_controller.dart';

class ProductsTab extends StatefulWidget {
  const ProductsTab({super.key});

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  Product? _selectedProduct;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<WarehouseController>();
    final products = controller.products;
    final batches = controller.batches;

    if (products.isEmpty) {
      return const Center(child: Text('No products available in master catalog.'));
    }

    // Set first product as default selected
    _selectedProduct ??= products.first;

    final selectedProductBatches = batches
        .where((b) => b.productId == _selectedProduct?.id)
        .toList()
      ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

    final totalStock = selectedProductBatches.fold<int>(0, (sum, b) => sum + b.quantity);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product List (Left Panel)
        Expanded(
          flex: 4,
          child: Card(
            margin: EdgeInsets.zero,
            child: ListView.separated(
              itemCount: products.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final product = products[index];
                final isSelected = product.id == _selectedProduct?.id;
                
                final physicalStock = controller.getPhysicalStock(product.id);
                final reservedStock = controller.getReservedStock(product.id);
                final availableStock = controller.getAvailableStock(product.id);

                return ListTile(
                  selected: isSelected,
                  selectedTileColor: theme.primaryColor.withOpacity(0.05),
                  title: Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text('SKU: ${product.sku} | Physical: $physicalStock | Price: ${NumberFormat.currency(symbol: 'Ks ', decimalDigits: 0).format(product.price)}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: availableStock > 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$availableStock available',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: availableStock > 0 ? Colors.green[800] : Colors.red[800],
                          ),
                        ),
                      ),
                      if (reservedStock > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            '($reservedStock reserved)',
                            style: const TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      _selectedProduct = product;
                    });
                  },
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Batches visual ledger (Right Panel)
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                margin: EdgeInsets.zero,
                color: theme.primaryColor.withOpacity(0.02),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: theme.primaryColor.withOpacity(0.1),
                        child: Icon(Icons.inventory_2_rounded, color: theme.primaryColor, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedProduct?.name ?? '',
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text('SKU: ${_selectedProduct?.sku ?? ''} | Master Cost: ${NumberFormat.currency(symbol: 'Ks ', decimalDigits: 0).format(_selectedProduct?.price ?? 0)}'),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Physical: $totalStock | Reserved: ${controller.getReservedStock(_selectedProduct?.id ?? '')}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            '${controller.getAvailableStock(_selectedProduct?.id ?? '')} Available',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: controller.getAvailableStock(_selectedProduct?.id ?? '') > 0 ? theme.primaryColor : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Stock Batches (Sorted by Expiry - FEFO)',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: selectedProductBatches.isEmpty
                    ? const Card(
                        child: Center(
                          child: Text('No batches registered for this product yet. Use "Stock In" to add.'),
                        ),
                      )
                    : ListView.separated(
                        itemCount: selectedProductBatches.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final batch = selectedProductBatches[index];
                          
                          Color statusColor = Colors.green;
                          String statusText = 'Active';
                          IconData statusIcon = Icons.check_circle_outline_rounded;

                          if (batch.isExpired) {
                            statusColor = Colors.red;
                            statusText = 'Expired';
                            statusIcon = Icons.error_outline_rounded;
                          } else if (batch.daysUntilExpiry <= 30) {
                            statusColor = Colors.amber;
                            statusText = 'Expiring Soon (${batch.daysUntilExpiry}d)';
                            statusIcon = Icons.warning_amber_rounded;
                          }

                          return Card(
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(statusIcon, color: statusColor, size: 24),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              batch.batchNumber,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: statusColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                statusText,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: statusColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Expiry: ${DateFormat('yyyy-MM-dd').format(batch.expiryDate)} | Received: ${DateFormat('yyyy-MM-dd').format(batch.receivedDate)}',
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${batch.quantity} / ${batch.initialQuantity}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const Text('Available / Initial', style: TextStyle(fontSize: 10, color: Colors.grey)),
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
      ],
    );
  }
}
