import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/controllers/auth_controller.dart';

class SalesDashboard extends StatelessWidget {
  const SalesDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProfile = context.watch<AuthController>().profile;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.directions_bike_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              'Sales Panel (Field Operations)',
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
                      backgroundColor: Colors.teal.withOpacity(0.1),
                      child: const Icon(Icons.person, size: 36, color: Colors.teal),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${userProfile?.displayName ?? 'Sales Staff'}',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Email: ${userProfile?.email ?? ''} | Role: Sales Staff',
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
              'Field Actions',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Responsive grid for sales features
            Expanded(
              child: GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.add_shopping_cart_rounded,
                    title: 'Order Placement\n(Order Entry)',
                    color: Colors.orange,
                    desc: 'Record and place retail orders directly from the field.',
                  ),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.history_edu_rounded,
                    title: 'My Orders\n(& Dispatch Status)',
                    color: Colors.blue,
                    desc: 'Track status and updates of orders placed by you.',
                  ),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.category_rounded,
                    title: 'Product Catalog\n(& Prices)',
                    color: Colors.purple,
                    desc: 'Browse product lines, stock options, and active prices.',
                  ),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.analytics_outlined,
                    title: 'Sales Reports\n(& Performance)',
                    color: Colors.teal,
                    desc: 'Review transaction logs and personal sales analytics.',
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
