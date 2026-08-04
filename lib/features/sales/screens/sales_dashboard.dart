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
              'Sales Staff Panel (အရောင်း ကိုယ်စားလှယ်)',
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
                      backgroundColor: Colors.teal.withOpacity(0.1),
                      child: const Icon(Icons.person, size: 36, color: Colors.teal),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'မင်္ဂလာပါ၊ ${userProfile?.displayName ?? 'Sales Staff'}',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'အီးမေးလ်: ${userProfile?.email ?? ''} | ရာထူး: Sales Staff (အရောင်းဝန်ထမ်း)',
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
              'နေ့စဉ် လုပ်ဆောင်ချက်များ (Field Actions)',
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
                    title: 'အော်ဒါကောက်ယူခြင်း\n(Order Entry)',
                    color: Colors.orange,
                    desc: 'ဆိုင်များတွင် ကိုယ်တိုင် အော်ဒါကောက်ယူရန်။',
                  ),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.history_edu_rounded,
                    title: 'မိမိအော်ဒါများ စောင့်ကြည့်ရန်\n(My Orders & Status)',
                    color: Colors.blue,
                    desc: 'မိမိကောက်ယူထားသော အော်ဒါများ၏ Status (Packed စသည်) ကို ခြေရာခံရန်။',
                  ),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.category_rounded,
                    title: 'ပစ္စည်းနှင့် ဈေးနှုန်းဇယား\n(Products & Master Prices)',
                    color: Colors.purple,
                    desc: 'မုန့်အမျိုးအစားများနှင့် သတ်မှတ်ထားသော ဈေးနှုန်းများကို ကြည့်ရှုရန်။',
                  ),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.analytics_outlined,
                    title: 'အရောင်းမှတ်တမ်းများ\n(My Sales Reports)',
                    color: Colors.teal,
                    desc: 'မိမိတာဝန်ယူထားသော ဆိုင်များ၏ အရောင်းစာရင်းနှင့် အစီရင်ခံစာများ ကြည့်ရှုရန်။',
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
