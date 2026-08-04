import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../warehouse/controllers/warehouse_controller.dart';
import 'tabs/new_order_tab.dart';
import 'tabs/my_orders_tab.dart';
import 'tabs/products_tab.dart';
import 'tabs/expiry_monitor_tab.dart';

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
    final userProfile = context.watch<AuthController>().profile;
    final warehouseController = context.watch<WarehouseController>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.directions_bike_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              'Sales Operations',
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: theme.primaryColor,
        actions: [
          IconButton(
            onPressed: () => warehouseController.loadAllWarehouseData(),
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh Data',
          ),
          IconButton(
            onPressed: () => context.read<AuthController>().logout(),
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: warehouseController.isLoading && warehouseController.products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: _tabs[_selectedIndex],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
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
