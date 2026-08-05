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
    final selectedDuration = controller.selectedDurationFilter;

    final double totalRevenue = (analytics['totalRevenue'] as num?)?.toDouble() ?? 0.0;
    final int ordersCount = (analytics['ordersCount'] as num?)?.toInt() ?? 0;
    final double avgOrderValue = ordersCount == 0 ? 0.0 : totalRevenue / ordersCount;

    final Map<dynamic, dynamic> salesByProduct = analytics['salesByProduct'] as Map? ?? {};
    final Map<dynamic, dynamic> salesByStaff = analytics['salesByStaff'] as Map? ?? {};
    final Map<dynamic, dynamic> staffOrderCounts = analytics['staffOrderCounts'] as Map? ?? {};
    final List<dynamic> rawTrendData = analytics['trendData'] as List? ?? [];

    final sortedProducts = salesByProduct.entries.toList()
      ..sort((a, b) => (b.value as num).compareTo(a.value as num));

    final sortedStaff = salesByStaff.entries.toList()
      ..sort((a, b) => (b.value as num).compareTo(a.value as num));

    final maxProductVal = sortedProducts.isEmpty ? 1.0 : (sortedProducts.first.value as num).toDouble();
    final maxStaffVal = sortedStaff.isEmpty ? 1.0 : (sortedStaff.first.value as num).toDouble();

    final currencyFormatter = NumberFormat.currency(symbol: 'Ks ', decimalDigits: 0);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Duration Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sales Analytics & Revenue Overview',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track revenue, staff performance, and sales trends across periods.',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
              // Duration Filter Pills
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDurationChip(context, controller, 'today', 'Today', selectedDuration),
                    _buildDurationChip(context, controller, 'week', 'This Week', selectedDuration),
                    _buildDurationChip(context, controller, 'month', 'This Month', selectedDuration),
                    _buildDurationChip(context, controller, 'all', 'All Time', selectedDuration),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Overview Metric Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 700;
              final cardWidth = isNarrow ? constraints.maxWidth : (constraints.maxWidth - 48) / 3;

              return Wrap(
                spacing: 24,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _buildMetricCard(
                      theme: theme,
                      title: 'Total Revenue',
                      value: currencyFormatter.format(totalRevenue),
                      icon: Icons.payments_outlined,
                      iconBgColor: theme.primaryColor.withValues(alpha: 0.1),
                      iconColor: theme.primaryColor,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _buildMetricCard(
                      theme: theme,
                      title: 'Processed Orders',
                      value: '$ordersCount Orders',
                      icon: Icons.shopping_bag_outlined,
                      iconBgColor: Colors.blue.withValues(alpha: 0.1),
                      iconColor: Colors.blue,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _buildMetricCard(
                      theme: theme,
                      title: 'Avg. Order Value',
                      value: currencyFormatter.format(avgOrderValue),
                      icon: Icons.analytics_outlined,
                      iconBgColor: Colors.purple.withValues(alpha: 0.1),
                      iconColor: Colors.purple,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          // Sales Trend Bar Chart Card
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.bar_chart_rounded, color: theme.primaryColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Revenue Trend Chart',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        _getFilterLabel(selectedDuration),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildTrendBarChart(context, theme, rawTrendData, currencyFormatter),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Split Section: Products Performance vs Staff Contribution
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 800;

              if (isNarrow) {
                return Column(
                  children: [
                    _buildProductSalesCard(theme, sortedProducts, totalRevenue, maxProductVal, currencyFormatter),
                    const SizedBox(height: 24),
                    _buildStaffSalesCard(theme, sortedStaff, staffOrderCounts, totalRevenue, maxStaffVal, currencyFormatter),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildProductSalesCard(theme, sortedProducts, totalRevenue, maxProductVal, currencyFormatter),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildStaffSalesCard(theme, sortedStaff, staffOrderCounts, totalRevenue, maxStaffVal, currencyFormatter),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDurationChip(
    BuildContext context,
    AdminController controller,
    String filterKey,
    String label,
    String currentSelection,
  ) {
    final isSelected = currentSelection == filterKey;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => controller.changeDurationFilter(filterKey),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required ThemeData theme,
    required String title,
    required String value,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendBarChart(
    BuildContext context,
    ThemeData theme,
    List<dynamic> trendData,
    NumberFormat currencyFormatter,
  ) {
    if (trendData.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('No trend data available for this duration.')),
      );
    }

    final double maxRevenue = trendData.fold<double>(
      0.0,
      (max, item) {
        final val = (item['revenue'] as num?)?.toDouble() ?? 0.0;
        return val > max ? val : max;
      },
    );

    final safeMax = maxRevenue == 0 ? 1.0 : maxRevenue;

    return SizedBox(
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: trendData.map<Widget>((item) {
          final label = (item['label'] as String?) ?? '';
          final revenue = (item['revenue'] as num?)?.toDouble() ?? 0.0;
          final ratio = (revenue / safeMax).clamp(0.05, 1.0);

          return Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Value tooltip text
                Text(
                  _formatShortCurrency(revenue),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                // Animated Bar
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: ratio,
                      child: Container(
                        width: 32,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              theme.primaryColor,
                              theme.primaryColor.withValues(alpha: 0.6),
                            ],
                          ),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // X-Axis Label
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductSalesCard(
    ThemeData theme,
    List<MapEntry<dynamic, dynamic>> sortedProducts,
    double totalRevenue,
    double maxProductVal,
    NumberFormat currencyFormatter,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.fastfood_outlined, color: Colors.orange, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Sales Performance by Product',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 32),
            if (sortedProducts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('No product sales recorded for this period.')),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedProducts.length,
                separatorBuilder: (context, index) => const SizedBox(height: 18),
                itemBuilder: (context, index) {
                  final entry = sortedProducts[index];
                  final productName = entry.key as String;
                  final val = (entry.value as num).toDouble();
                  final ratio = val / (maxProductVal == 0 ? 1.0 : maxProductVal);
                  final pct = totalRevenue == 0 ? 0.0 : (val / totalRevenue) * 100;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                                  child: Text(
                                    '#${index + 1}',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.primaryColor),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    productName,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(currencyFormatter.format(val), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text('${pct.toStringAsFixed(1)}%', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 8,
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
    );
  }

  Widget _buildStaffSalesCard(
    ThemeData theme,
    List<MapEntry<dynamic, dynamic>> sortedStaff,
    Map<dynamic, dynamic> staffOrderCounts,
    double totalRevenue,
    double maxStaffVal,
    NumberFormat currencyFormatter,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.people_alt_outlined, color: Colors.teal, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Sales Contribution by Staff',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 32),
            if (sortedStaff.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('No staff sales recorded for this period.')),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedStaff.length,
                separatorBuilder: (context, index) => const SizedBox(height: 18),
                itemBuilder: (context, index) {
                  final entry = sortedStaff[index];
                  final staffName = entry.key as String;
                  final val = (entry.value as num).toDouble();
                  final ratio = val / (maxStaffVal == 0 ? 1.0 : maxStaffVal);
                  final pct = totalRevenue == 0 ? 0.0 : (val / totalRevenue) * 100;
                  final orders = staffOrderCounts[staffName] ?? 0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.teal.withValues(alpha: 0.15),
                                  child: Text(
                                    _getStaffInitials(staffName),
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.teal),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        staffName,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (orders > 0)
                                        Text(
                                          '$orders orders processed',
                                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(currencyFormatter.format(val), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text('${pct.toStringAsFixed(1)}% contribution', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 8,
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
    );
  }

  String _getFilterLabel(String key) {
    switch (key) {
      case 'today':
        return 'Today\'s Hourly Breakdown';
      case 'week':
        return 'Daily Revenue (This Week)';
      case 'all':
        return 'Quarterly Revenue Breakdown';
      case 'month':
      default:
        return 'Weekly Breakdown (This Month)';
    }
  }

  String _formatShortCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }

  String _getStaffInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'ST';
  }
}
