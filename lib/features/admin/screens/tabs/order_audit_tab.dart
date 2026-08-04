import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:may_snacks/models/order.dart';
import 'package:may_snacks/features/warehouse/controllers/warehouse_controller.dart';

class OrderAuditTab extends StatefulWidget {
  const OrderAuditTab({super.key});

  @override
  State<OrderAuditTab> createState() => _OrderAuditTabState();
}

class _OrderAuditTabState extends State<OrderAuditTab> {
  String _searchQuery = '';
  OrderStatus? _statusFilter;
  Order? _selectedOrder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final warehouseController = context.watch<WarehouseController>();
    
    final allOrders = warehouseController.orders; 

    // Filter and Search logic
    final filteredOrders = allOrders.where((order) {
      final matchesSearch = order.customerName.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _statusFilter == null || order.status == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (_selectedOrder != null && !filteredOrders.any((o) => o.id == _selectedOrder!.id)) {
      _selectedOrder = null;
    }
    
    final activeSelectedOrder = _selectedOrder ?? (filteredOrders.isNotEmpty ? filteredOrders.first : null);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Order Queue
        Expanded(
          flex: 5,
          child: Column(
            children: [
              // Search & Filter Bar
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search by customer...',
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
                      DropdownButton<OrderStatus?>(
                        value: _statusFilter,
                        hint: const Text('All Status'),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Status')),
                          ...OrderStatus.values.map((status) {
                            return DropdownMenuItem(value: status, child: Text(status.displayName));
                          }),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _statusFilter = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Orders list
              Expanded(
                child: filteredOrders.isEmpty
                    ? const Card(child: Center(child: Text('No matching orders found.')))
                    : Card(
                        margin: EdgeInsets.zero,
                        child: ListView.separated(
                          itemCount: filteredOrders.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            final isSelected = order.id == activeSelectedOrder?.id;

                            Color statusColor = Colors.orange;
                            if (order.status == OrderStatus.packed) {
                              statusColor = Colors.blue;
                            } else if (order.status == OrderStatus.delivered) {
                              statusColor = Colors.green;
                            }

                            return ListTile(
                              selected: isSelected,
                              selectedTileColor: theme.primaryColor.withOpacity(0.05),
                              title: Text(
                                order.customerName,
                                style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                              ),
                              subtitle: Text('Items: ${order.items.length} | Revenue: ${NumberFormat.currency(symbol: 'Ks ', decimalDigits: 0).format(order.totalAmount)}'),
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
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Right Details Auditing panel
        Expanded(
          flex: 5,
          child: activeSelectedOrder == null
              ? const Card(child: Center(child: Text('Select an order to view details.')))
              : Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Details Audit',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Divider(height: 24),
                        Text('Customer: ${activeSelectedOrder.customerName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 6),
                        Text('Order ID: ${activeSelectedOrder.id}'),
                        Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(activeSelectedOrder.createdAt)}'),
                        Text('Fulfillment Status: ${activeSelectedOrder.status.displayName}'),
                        const Divider(height: 24),
                        Text('Ordered Items', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.separated(
                            itemCount: activeSelectedOrder.items.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = activeSelectedOrder.items[index];
                              
                              // Check total active stock balance for this product across all batches
                              final productBatches = warehouseController.batches.where((b) => b.productId == item.productId && !b.isExpired);
                              final availableStock = productBatches.fold<int>(0, (sum, b) => sum + b.quantity);

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(item.productName ?? 'Product'),
                                subtitle: Text('Qty Ordered: ${item.quantity} | Available Stock: $availableStock units'),
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
                            const Text('Grand Total Revenue', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              NumberFormat.currency(symbol: 'Ks ', decimalDigits: 0).format(activeSelectedOrder.totalAmount),
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor),
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
