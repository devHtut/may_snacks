import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/admin_controller.dart';

class SalesAnalyticsTab extends StatelessWidget {
  const SalesAnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<AdminController>();
    final analytics = controller.analytics;

    final double totalRevenue = (analytics['totalRevenue'] as num?)?.toDouble() ?? 0.0;
    final int ordersCount = (analytics['ordersCount'] as num?)?.toInt() ?? 0;
    final Map<dynamic, dynamic> salesByProduct = analytics['salesByProduct'] as Map? ?? {};
    final Map<dynamic, dynamic> salesByStaff = analytics['salesByStaff'] as Map? ?? {};

    // Sort product sales to find highest selling products
    final sortedProducts = salesByProduct.entries.toList()
      ..sort((a, b) => (b.value as num).compareTo(a.value as num));

    // Sort staff sales
    final sortedStaff = salesByStaff.entries.toList()
      ..sort((a, b) => (b.value as num).compareTo(a.value as num));

    final maxProductVal = sortedProducts.isEmpty ? 1.0 : (sortedProducts.first.value as num).toDouble();
    final maxStaffVal = sortedStaff.isEmpty ? 1.0 : (sortedStaff.first.value as num).toDouble();

    final currencyFormatter = NumberFormat.currency(symbol: 'Ks ', decimalDigits: 0);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sales Analytics & Revenue Overview',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          // Cards Row
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Revenue Generated', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text(
                          currencyFormatter.format(totalRevenue),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Processed Orders', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text(
                          '$ordersCount Orders',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Split Views (Product vs Staff performance)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Sales Mapped Performance
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sales Performance by Product',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Divider(height: 32),
                        if (sortedProducts.isEmpty)
                          const Center(child: Text('No product sales recorded yet.'))
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: sortedProducts.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 20),
                            itemBuilder: (context, index) {
                              final entry = sortedProducts[index];
                              final productName = entry.key as String;
                              final val = (entry.value as num).toDouble();
                              final ratio = val / (maxProductVal == 0 ? 1.0 : maxProductVal);

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                      Text(currencyFormatter.format(val), style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: ratio,
                                      minHeight: 10,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Staff Sales Performance
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sales Contribution by Staff',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Divider(height: 32),
                        if (sortedStaff.isEmpty)
                          const Center(child: Text('No staff sales contribution recorded yet.'))
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: sortedStaff.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 20),
                            itemBuilder: (context, index) {
                              final entry = sortedStaff[index];
                              final staffName = entry.key as String;
                              final val = (entry.value as num).toDouble();
                              final ratio = val / (maxStaffVal == 0 ? 1.0 : maxStaffVal);

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(staffName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                      Text(currencyFormatter.format(val), style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: ratio,
                                      minHeight: 10,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
