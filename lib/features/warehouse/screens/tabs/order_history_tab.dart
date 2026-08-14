import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:may_snacks/models/order.dart';
import 'package:may_snacks/features/warehouse/controllers/warehouse_controller.dart';

class OrderHistoryTab extends StatefulWidget {
  const OrderHistoryTab({super.key});

  @override
  State<OrderHistoryTab> createState() => _OrderHistoryTabState();
}

class _OrderHistoryTabState extends State<OrderHistoryTab> {
  String _filter = 'all'; // 'all', 'packed', 'delivered'
  String _searchQuery = '';

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
    final controller = context.watch<WarehouseController>();
    final allOrders = controller.orders;

    // Filter out 'pending' orders since they belong in the fulfillment tab queue
    final processedOrders = allOrders.where((o) => o.status != OrderStatus.pending).toList();

    // Apply status filter
    var filteredOrders = processedOrders;
    if (_filter == 'packed') {
      filteredOrders = processedOrders.where((o) => o.status == OrderStatus.packed).toList();
    } else if (_filter == 'delivered') {
      filteredOrders = processedOrders.where((o) => o.status == OrderStatus.delivered).toList();
    }

    // Apply search filter
    if (_searchQuery.trim().isNotEmpty) {
      filteredOrders = filteredOrders
          .where((o) => o.customerName.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Sort: Newest first
    filteredOrders.sort((Order a, Order b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Wholesale Order History',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            // Refresh indicator / status
            if (controller.isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 16),
        // Search and Filter Row
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search by customer name...',
                  prefixIcon: Icon(Icons.search_rounded),
                  isDense: true,
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            // Filter chips
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All Processed'),
                  selected: _filter == 'all',
                  onSelected: (selected) {
                    setState(() => _filter = 'all');
                  },
                ),
                FilterChip(
                  label: const Text('Packed'),
                  selected: _filter == 'packed',
                  onSelected: (selected) {
                    setState(() => _filter = 'packed');
                  },
                ),
                FilterChip(
                  label: const Text('Delivered'),
                  selected: _filter == 'delivered',
                  onSelected: (selected) {
                    setState(() => _filter = 'delivered');
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: filteredOrders.isEmpty
              ? Card(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _searchQuery.isNotEmpty
                            ? 'No orders matching your search.'
                            : 'No processed orders found in this category.',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: filteredOrders.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];

                    Color statusColor = Colors.blue;
                    if (order.status == OrderStatus.delivered) {
                      statusColor = Colors.green;
                    }

                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        onTap: () => _showOrderDetailsDialog(context, order),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          order.customerName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                order.status.displayName,
                                style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (order.status == OrderStatus.packed) ...[
                              const SizedBox(width: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  visualDensity: VisualDensity.compact,
                                ),
                                onPressed: () async {
                                  final success = await controller.updateOrderStatus(order.id, OrderStatus.delivered);
                                  if (success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Order marked as Delivered successfully!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Mark Delivered', style: TextStyle(fontSize: 12)),
                              ),
                            ],
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
