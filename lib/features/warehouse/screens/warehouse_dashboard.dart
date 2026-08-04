import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/warehouse_controller.dart';
import 'tabs/products_tab.dart';
import 'tabs/stock_in_tab.dart';
import 'tabs/order_fulfillment_tab.dart';
import 'tabs/expiry_tracking_tab.dart';
import 'tabs/disposal_requests_tab.dart';
import 'tabs/stock_audit_tab.dart';

class WarehouseDashboard extends StatefulWidget {
  const WarehouseDashboard({super.key});

  @override
  State<WarehouseDashboard> createState() => _WarehouseDashboardState();
}

class _WarehouseDashboardState extends State<WarehouseDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WarehouseController>().loadAllWarehouseData();
    });
  }

  final List<Widget> _tabs = [
    const ProductsTab(),
    const StockInTab(),
    const OrderFulfillmentTab(),
    const ExpiryTrackingTab(),
    const DisposalRequestsTab(),
    const StockAuditTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProfile = context.watch<AuthController>().profile;
    final controller = context.watch<WarehouseController>();
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.warehouse_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              'Warehouse Panel (Inventory & Operations)',
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: theme.primaryColor,
        actions: [
          IconButton(
            onPressed: () => context.read<WarehouseController>().loadAllWarehouseData(),
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh All Data',
          ),
          IconButton(
            onPressed: () => context.read<AuthController>().logout(),
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Row(
        children: [
          // Navigation Sidebar (Wide viewport) or Rail
          NavigationRail(
            extended: isWide,
            selectedIndex: _selectedIndex,
            backgroundColor: theme.cardColor,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: isWide ? NavigationRailLabelType.none : NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.category_outlined),
                selectedIcon: Icon(Icons.category_rounded),
                label: Text('Products & Stock'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.add_business_outlined),
                selectedIcon: Icon(Icons.add_business_rounded),
                label: Text('Stock In'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.assignment_outlined),
                selectedIcon: Icon(Icons.assignment_rounded),
                label: Text('Orders Queue'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.hourglass_empty_outlined),
                selectedIcon: Icon(Icons.hourglass_full_rounded),
                label: Text('Expiry Board'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.delete_sweep_outlined),
                selectedIcon: Icon(Icons.delete_sweep_rounded),
                label: Text('Disposals'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.fact_check_outlined),
                selectedIcon: Icon(Icons.fact_check_rounded),
                label: Text('Stock Audit'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Tab Content Area
          Expanded(
            child: controller.isLoading && controller.products.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quick welcome strip on top
                        if (_selectedIndex == 0) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Welcome back, ${userProfile?.displayName ?? 'Warehouse Manager'}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Status: Active (Warehouse Manager)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                        Expanded(
                          child: _tabs[_selectedIndex],
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
