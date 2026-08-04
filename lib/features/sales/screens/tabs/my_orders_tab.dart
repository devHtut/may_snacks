import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:may_snacks/models/order.dart';
import 'package:may_snacks/features/auth/controllers/auth_controller.dart';
import 'package:may_snacks/features/warehouse/controllers/warehouse_controller.dart';

class MyOrdersTab extends StatelessWidget {
  const MyOrdersTab({super.key});

  void _showOrderDetailsDialog(BuildContext context, Order order) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(order.customerName),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order ID: ${order.id}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(order.createdAt)}'),
                Text('Status: ${order.status.displayName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const Divider(height: 24),
                const Text('Items Ordered', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Column(
                  children: order.items.map((item) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.productName ?? 'Product'),
                      subtitle: Text('Qty: ${item.quantity} x Ks ${NumberFormat('#,###').format(item.productPrice ?? 0)}'),
                      trailing: Text(
                        'Ks ${NumberFormat('#,###').format(item.quantity * (item.productPrice ?? 0))}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      'Ks ${NumberFormat('#,###').format(order.totalAmount)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authController = context.watch<AuthController>();
    final warehouseController = context.watch<WarehouseController>();

    final currentUserId = authController.profile?.id;
    final allOrders = warehouseController.orders;

    // Filter to only show orders taken by the current sales staff
    final myOrders = allOrders.where((o) => o.salesStaffId == currentUserId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Wholesale Orders History',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: myOrders.isEmpty
              ? const Card(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'You have not taken any wholesale orders yet. Open the "New Order" tab to begin.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: myOrders.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final order = myOrders[index];

                    Color statusColor = Colors.orange;
                    if (order.status == OrderStatus.packed) {
                      statusColor = Colors.blue;
                    } else if (order.status == OrderStatus.delivered) {
                      statusColor = Colors.green;
                    }

                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        onTap: () => _showOrderDetailsDialog(context, order),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(order.createdAt)}'),
                            const SizedBox(height: 4),
                            Text(
                              'Ks ${NumberFormat('#,###').format(order.totalAmount)}',
                              style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            order.status.displayName,
                            style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold),
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
