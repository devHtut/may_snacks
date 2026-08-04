import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:may_snacks/models/order.dart';
import 'package:may_snacks/features/warehouse/controllers/warehouse_controller.dart';

class OrderFulfillmentTab extends StatefulWidget {
  const OrderFulfillmentTab({super.key});

  @override
  State<OrderFulfillmentTab> createState() => _OrderFulfillmentTabState();
}

class _OrderFulfillmentTabState extends State<OrderFulfillmentTab> {
  Order? _selectedOrder;

  Future<void> _handleFulfill(String orderId) async {
    final controller = context.read<WarehouseController>();
    final success = await controller.fulfillOrder(orderId);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order successfully fulfilled and packed.'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _selectedOrder = null;
      });
    } else if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('Fulfillment Failed'),
            ],
          ),
          content: Text(controller.errorMessage ?? 'An error occurred during FEFO allocation.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<WarehouseController>();
    final pendingOrders = controller.orders;
    final isLoading = controller.isLoading;

    if (pendingOrders.isEmpty) {
      return const Card(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.playlist_add_check_rounded, size: 64, color: Colors.green),
              SizedBox(height: 16),
              Text(
                'All orders packed! No pending orders.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // Set first pending order as default selected
    _selectedOrder ??= pendingOrders.first;

    // Refresh selected order object reference to avoid stale items
    final activeSelectedOrder = pendingOrders.firstWhere(
      (o) => o.id == _selectedOrder?.id,
      orElse: () => pendingOrders.first,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pending Orders Queue (Left Panel)
        Expanded(
          flex: 4,
          child: Card(
            margin: EdgeInsets.zero,
            child: ListView.separated(
              itemCount: pendingOrders.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final order = pendingOrders[index];
                final isSelected = order.id == activeSelectedOrder.id;

                return ListTile(
                  selected: isSelected,
                  selectedTileColor: theme.primaryColor.withOpacity(0.05),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          order.customerName,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      Text(
                        'Pending',
                        style: TextStyle(fontSize: 11, color: Colors.orange[800], fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  subtitle: Text('Items Count: ${order.items.length} | Total: ${NumberFormat.currency(symbol: 'Ks ', decimalDigits: 0).format(order.totalAmount)}'),
                  onTap: () {
                    setState(() {
                      _selectedOrder = order;
                    });
                  },
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Fulfill Action Details (Right Panel)
        Expanded(
          flex: 6,
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: theme.primaryColor.withOpacity(0.1),
                        child: Icon(Icons.assignment_rounded, color: theme.primaryColor),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeSelectedOrder.customerName,
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text('Order Date: ${DateFormat('yyyy-MM-dd HH:mm').format(activeSelectedOrder.createdAt)}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(
                    'Requested Items list',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: activeSelectedOrder.items.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = activeSelectedOrder.items[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item.productName ?? 'Unknown Product'),
                          subtitle: Text('Quantity Ordered: ${item.quantity}'),
                          trailing: Text(
                            NumberFormat.currency(symbol: 'Ks ', decimalDigits: 0).format((item.productPrice ?? 0) * item.quantity),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Grand Total Cost', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            NumberFormat.currency(symbol: 'Ks ', decimalDigits: 0).format(activeSelectedOrder.totalAmount),
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: isLoading ? null : () => _handleFulfill(activeSelectedOrder.id),
                        icon: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                              )
                            : const Icon(Icons.inventory_2_rounded),
                        label: const Text('Fulfill & Pack Order (FEFO)'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
