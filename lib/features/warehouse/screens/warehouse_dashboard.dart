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
              'Warehouse Panel (ဂိုဒေါင် စီမံခန့်ခွဲမှု)',
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: theme.primaryColor,
        actions: [
          IconButton(
            onPressed: () => context.read<AuthController>().logout(),
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'အကောင့်ထွက်မည်',
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
                            'မင်္ဂလာပါ၊ ${userProfile?.displayName ?? 'Warehouse Manager'}',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'အီးမေးလ်: ${userProfile?.email ?? ''} | ရာထူး: Warehouse Manager (ဂိုဒေါင်မှူး)',
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
              'နေ့စဉ် လုပ်ဆောင်ချက်များ (Daily Actions)',
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
                    title: 'ကုန်ဝင်စာရင်းသွင်းခြင်း\n(Stock In)',
                    color: Colors.teal,
                    desc: 'ဂိုဒေါင်သို့ ပစ္စည်းအသစ် ရောက်ရှိလာပါက စာရင်းသွင်းရန်။',
                  ),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.local_shipping_rounded,
                    title: 'အော်ဒါထုတ်ပေးခြင်း\n(Order Fulfillment)',
                    color: Colors.blue,
                    desc: 'အော်ဒါများကို ပြင်ဆင်ထုပ်ပိုးပြီး Status ပြောင်းလဲရန်။',
                  ),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.hourglass_bottom_rounded,
                    title: 'သက်တမ်းကုန်ရက် ခြေရာခံခြင်း\n(Expiry FEFO Tracking)',
                    color: Colors.orange,
                    desc: 'FEFO စနစ်ဖြင့် သက်တမ်းကုန်မည့်ရက်များကို စောင့်ကြည့်ရန်။',
                  ),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.delete_sweep_rounded,
                    title: 'ပျက်စီးစာရင်း ပယ်ဖျက်ရန် တင်ပြခြင်း\n(Disposal Request)',
                    color: Colors.redAccent,
                    desc: 'ကုန်ပစ္စည်းပျက်စီး/သက်တမ်းကုန်များ စာရင်းပယ်ဖျက်ရန် Admin ထံ တင်ပြရန်။',
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
              content: Text('$title လုပ်ဆောင်ချက်ကို မကြာမီ ဖြည့်စွက်ပါမည်။'),
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
