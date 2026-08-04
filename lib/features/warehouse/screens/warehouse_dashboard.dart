import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/controllers/auth_controller.dart';

class WarehouseDashboard extends StatelessWidget {
  const WarehouseDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProfile = context.watch<AuthController>().profile;

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
            onPressed: () => context.read<AuthController>().logout(),
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: const Icon(Icons.person, size: 36, color: Colors.blue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${userProfile?.displayName ?? 'Warehouse Manager'}',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Email: ${userProfile?.email ?? ''} | Role: Warehouse Manager',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            Text(
              'Daily Actions',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Responsive grid for warehouse features
            Expanded(
              child: GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.inventory_2_rounded,
                    title: 'Stock Entry\n(Stock In)',
                    color: Colors.teal,
                    desc: 'Record new stock batches arriving at the warehouse.',
                  ),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.local_shipping_rounded,
                    title: 'Order Dispatch\n(Fulfillment)',
                    color: Colors.blue,
                    desc: 'Prepare, pack, and mark orders as dispatched.',
                  ),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.hourglass_bottom_rounded,
                    title: 'Expiry Tracking\n(FEFO System)',
                    color: Colors.orange,
                    desc: 'Monitor batch expiry dates using First-Expired, First-Out.',
                  ),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.delete_sweep_rounded,
                    title: 'Damage / Expiry\n(Disposal Request)',
                    color: Colors.redAccent,
                    desc: 'Request admin approval for writing off damaged or expired stock.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required String desc,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title feature will be integrated soon.'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  desc,
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
