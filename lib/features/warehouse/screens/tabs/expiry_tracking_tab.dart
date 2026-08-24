import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:may_snacks/models/product.dart';
import 'package:may_snacks/features/warehouse/controllers/warehouse_controller.dart';

class ExpiryTrackingTab extends StatelessWidget {
  const ExpiryTrackingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<WarehouseController>();
    final activeBatches = controller.batches.where((b) => b.quantity > 0).toList();
    final products = controller.products;

    final expiredBatches = activeBatches.where((b) => b.isExpired).toList()
      ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

    final expiringSoonBatches = activeBatches.where((b) => !b.isExpired && b.daysUntilExpiry <= 30).toList()
      ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

    final safeBatchesCount = activeBatches.length - expiredBatches.length - expiringSoonBatches.length;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row of Overview Stats cards
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Expired Batches',
                  count: expiredBatches.length,
                  icon: Icons.error_rounded,
                  color: Colors.red,
                  context: context,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  title: 'Expiring Soon (< 30d)',
                  count: expiringSoonBatches.length,
                  icon: Icons.warning_amber_rounded,
                  color: Colors.amber,
                  context: context,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  title: 'Safe Batches (> 30d)',
                  count: safeBatchesCount,
                  icon: Icons.check_circle_rounded,
                  color: Colors.green,
                  context: context,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Expired Batches Section
          Text(
            'Expired Batches (Action Required - Submit Disposal)',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.red[900]),
          ),
          const SizedBox(height: 12),
          if (expiredBatches.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('No expired batches in the warehouse. Great!')),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: expiredBatches.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final batch = expiredBatches[index];
                final product = products.firstWhere((p) => p.id == batch.productId, orElse: () => Product(id: '', name: 'Unknown Product', sku: '', price: 0, createdAt: DateTime.now()));

                return Card(
                  color: Colors.red[50],
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Icon(Icons.error_outline_rounded, color: Colors.white),
                    ),
                    title: Text(
                      '${product.name} (Batch: ${batch.batchNumber})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Expired on: ${DateFormat('yyyy-MM-dd').format(batch.expiryDate)} (${-batch.daysUntilExpiry} days ago)'),
                    trailing: Text(
                      'Qty: ${batch.quantity}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
                    ),
                  ),
                );
              },
            ),
          
          const SizedBox(height: 32),

          // Expiring Soon Section
          Text(
            'Expiring Soon Batches (Prioritize in Orders - FEFO)',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.amber[900]),
          ),
          const SizedBox(height: 12),
          if (expiringSoonBatches.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('No batches expiring in the next 30 days.')),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: expiringSoonBatches.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final batch = expiringSoonBatches[index];
                final product = products.firstWhere((p) => p.id == batch.productId, orElse: () => Product(id: '', name: 'Unknown Product', sku: '', price: 0, createdAt: DateTime.now()));

                return Card(
                  color: Colors.amber[50],
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.amber[700],
                      child: const Icon(Icons.warning_amber_rounded, color: Colors.white),
                    ),
                    title: Text(
                      '${product.name} (Batch: ${batch.batchNumber})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Expires on: ${DateFormat('yyyy-MM-dd').format(batch.expiryDate)} (${batch.daysUntilExpiry} days left)'),
                    trailing: Text(
                      'Qty: ${batch.quantity}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber[900]),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count batches',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
