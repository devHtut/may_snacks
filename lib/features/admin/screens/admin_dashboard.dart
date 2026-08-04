import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/admin_controller.dart';
import 'tabs/user_management_tab.dart';
import 'tabs/product_catalog_tab.dart';
import 'tabs/order_audit_tab.dart';
import 'tabs/disposal_approvals_tab.dart';
import 'tabs/system_logs_tab.dart';
import 'tabs/sales_analytics_tab.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadAllAdminData();
    });
  }

  final List<Widget> _tabs = [
    const UserManagementTab(),
    const ProductCatalogTab(),
    const OrderAuditTab(),
    const DisposalApprovalsTab(),
    const SystemLogsTab(),
    const SalesAnalyticsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<AdminController>();
    final adminProfile = context.watch<AuthController>().profile;
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              'May Snacks - Admin Panel',
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: theme.primaryColor,
        actions: [
          IconButton(
            onPressed: () => context.read<AdminController>().loadAllAdminData(),
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
          // Sidebar rail
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
                icon: Icon(Icons.people_alt_outlined),
                selectedIcon: Icon(Icons.people_alt_rounded),
                label: Text('Staff Accounts'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book_rounded),
                label: Text('Products catalog'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history_rounded),
                label: Text('Orders Audit'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2_rounded),
                label: Text('Disposals Approvals'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long_rounded),
                label: Text('System Logs'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.trending_up_outlined),
                selectedIcon: Icon(Icons.trending_up_rounded),
                label: Text('Sales Analytics'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Content Area
          Expanded(
            child: controller.isLoading && controller.users.isEmpty
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
                                'Welcome, ${adminProfile?.displayName ?? 'Admin'}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Status: Super Administrator',
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
