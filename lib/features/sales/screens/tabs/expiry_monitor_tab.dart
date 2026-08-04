import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:may_snacks/models/product.dart';
import 'package:may_snacks/features/warehouse/controllers/warehouse_controller.dart';

class ExpiryMonitorTab extends StatelessWidget {
  const ExpiryMonitorTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final warehouseController = context.watch<WarehouseController>();
    final batches = warehouseController.batches;
    final products = warehouseController.products;

    // Filter to active, non-empty stock batches, sorted by earliest expiry
    final activeBatches = batches.where((b) => b.quantity > 0).toList()
      ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Batch Expiry & Promotion Monitoring',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: activeBatches.isEmpty
              ? const Card(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No active stock batches found in inventory.'),
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: activeBatches.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final batch = activeBatches[index];
                    final product = products.firstWhere(
                      (p) => p.id == batch.productId,
                      orElse: () => Product(id: '', name: 'Unknown Product', sku: '', price: 0, createdAt: DateTime.now()),
                    );

                    final daysRemaining = batch.expiryDate.difference(DateTime.now()).inDays;
                    final isExpired = batch.isExpired;
                    final isExpiringSoon = batch.isExpiringSoon && !isExpired;

                    Color statusColor = Colors.green;
                    String statusText = 'Safe ($daysRemaining days left)';
                    if (isExpired) {
                      statusColor = Colors.red;
                      statusText = 'Expired';
                    } else if (isExpiringSoon) {
                      statusColor = Colors.orange;
                      statusText = 'Expiring Soon ($daysRemaining days left)';
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
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isExpired
                                    ? Icons.dangerous_rounded
                                    : isExpiringSoon
                                        ? Icons.warning_amber_rounded
                                        : Icons.gpp_good_outlined,
                                color: statusColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Batch: ${batch.batchNumber} | Quantity: ${batch.quantity} units',
                                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Expiry: ${DateFormat('yyyy-MM-dd').format(batch.expiryDate)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isExpired || isExpiringSoon ? statusColor : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.15),
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
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
