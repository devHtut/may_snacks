import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../warehouse/controllers/warehouse_controller.dart';
import 'tabs/new_order_tab.dart';
import 'tabs/my_orders_tab.dart';
import 'tabs/products_tab.dart';
import 'tabs/expiry_monitor_tab.dart';
import '../../../common/widgets/connection_status_badge.dart';

class SalesDashboard extends StatefulWidget {
  const SalesDashboard({super.key});

  @override
  State<SalesDashboard> createState() => _SalesDashboardState();
}

class _SalesDashboardState extends State<SalesDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WarehouseController>().loadAllWarehouseData();
    });
  }

  final List<Widget> _tabs = [
    const NewOrderTab(),
    const MyOrdersTab(),
    const ProductsTab(),
    const ExpiryMonitorTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final warehouseController = context.watch<WarehouseController>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.directions_bike_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Sales Operations',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: theme.primaryColor,
        actions: [
          const ConnectionStatusBadge(),
          IconButton(
            onPressed: () => warehouseController.loadAllWarehouseData(),
            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
            tooltip: 'Refresh Data',
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: () => context.read<AuthController>().logout(),
            icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
            tooltip: 'Logout',
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Offline Mode Banner
          if (warehouseController.isOffline || warehouseController.pendingSyncCount > 0)
            Container(
              color: warehouseController.isOffline ? Colors.amber[800] : Colors.blue[700],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    warehouseController.isOffline ? Icons.wifi_off_rounded : Icons.sync_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      warehouseController.isOffline
                          ? 'Offline Mode Active (${warehouseController.pendingSyncCount} orders queued for sync)'
                          : '${warehouseController.pendingSyncCount} pending offline orders ready to sync',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (warehouseController.pendingSyncCount > 0)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () async {
                            final synced = await warehouseController.syncOfflineOrders();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Synced $synced pending operations!'),
                                  backgroundColor: Colors.green[800],
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.cloud_upload_rounded, size: 14),
                          label: const Text('Sync Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cleaning_services_rounded, color: Colors.white, size: 18),
                          tooltip: 'Clear Stale Queue',
                          onPressed: () async {
                            await warehouseController.clearSyncQueue();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Stale sync queue cleared.')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
          Expanded(
            child: warehouseController.isLoading && warehouseController.products.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: _tabs[_selectedIndex],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
          context.read<WarehouseController>().loadAllWarehouseData();
        },
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_shopping_cart_rounded),
            label: 'New Order',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'My Orders',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.cookie_outlined),
            activeIcon: Icon(Icons.cookie_rounded),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text(
                '${warehouseController.batches.where((b) => b.isExpiringSoon && b.quantity > 0).length}',
              ),
              isLabelVisible: warehouseController.batches.any((b) => b.isExpiringSoon && b.quantity > 0),
              child: const Icon(Icons.event_busy_rounded),
            ),
            label: 'Expiry Monitor',
          ),
        ],
      ),
    );
  }
}
