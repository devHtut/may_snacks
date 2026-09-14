import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/admin_controller.dart';
import '../../../../services/excel_export_service.dart';
import '../../../../common/widgets/excel_date_filter_dialog.dart';
import '../../../warehouse/controllers/warehouse_controller.dart';

class SalesAnalyticsTab extends StatefulWidget {
  const SalesAnalyticsTab({super.key});

  @override
  State<SalesAnalyticsTab> createState() => _SalesAnalyticsTabState();
}

class _SalesAnalyticsTabState extends State<SalesAnalyticsTab> {
  String _selectedChartType = 'line'; // 'line', 'bar', 'pie'

  final List<Color> _chartColors = const [
    Color(0xFF2563EB), // Royal Blue
    Color(0xFF0D9488), // Teal
    Color(0xFFD97706), // Amber
    Color(0xFF7C3AED), // Purple
    Color(0xFFE11D48), // Rose
    Color(0xFF059669), // Emerald
    Color(0xFFEA580C), // Orange
  ];

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
    final List<dynamic> categoryData = analytics['categoryData'] as List? ?? [];

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
                    'Sales Analytics & Dynamic Insights',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Real-time revenue metrics calculated directly from active order records.',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
              // Action Controls (Duration Filter & Excel Export)
              Wrap(
                spacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
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
                  ElevatedButton.icon(
                    onPressed: () {
                      final warehouseController = context.read<WarehouseController>();
                      ExcelDateFilterDialog.show(
                        context,
                        title: 'Sales Analytics Export',
                        reportSubtitle: 'Performance KPIs, top selling products, and staff breakdown',
                        onExport: (dateRange, durationLabel) async {
                          await ExcelExportService.exportSalesAnalytics(
                            analytics: controller.analytics,
                            durationFilter: selectedDuration,
                            orders: warehouseController.orders,
                            dateRange: dateRange,
                            durationLabel: durationLabel,
                            context: context,
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.table_chart_rounded, size: 18),
                    label: const Text('Export Excel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
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

          // Main Interactive Chart Card (Line Chart, Bar Chart, Donut/Pie Chart Switcher)
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
                  // Chart Control Header
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
                            child: Icon(
                              _selectedChartType == 'line'
                                  ? Icons.show_chart_rounded
                                  : _selectedChartType == 'bar'
                                      ? Icons.bar_chart_rounded
                                      : Icons.pie_chart_outline_rounded,
                              color: theme.primaryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedChartType == 'pie' ? 'Product Revenue Distribution' : 'Revenue Trend Chart',
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                _getFilterLabel(selectedDuration),
                                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Chart Type Selector
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(3),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildChartTypeButton('line', Icons.show_chart_rounded, 'Line Chart'),
                            _buildChartTypeButton('bar', Icons.bar_chart_rounded, 'Bar Chart'),
                            _buildChartTypeButton('pie', Icons.pie_chart_outline_rounded, 'Pie Chart'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Render Chart Body based on selection
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: KeyedSubtree(
                      key: ValueKey('chart_$_selectedChartType'),
                      child: _selectedChartType == 'line'
                          ? _buildLineChart(theme, rawTrendData, currencyFormatter)
                          : _selectedChartType == 'bar'
                              ? _buildTrendBarChart(theme, rawTrendData, currencyFormatter)
                              : _buildDonutPieChart(theme, categoryData, currencyFormatter),
                    ),
                  ),
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

  Widget _buildChartTypeButton(String typeKey, IconData icon, String tooltip) {
    final isSelected = _selectedChartType == typeKey;
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedChartType = typeKey;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? theme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              const SizedBox(width: 6),
              Text(
                typeKey == 'line' ? 'Line' : typeKey == 'bar' ? 'Bar' : 'Pie',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildLineChart(
    ThemeData theme,
    List<dynamic> trendData,
    NumberFormat currencyFormatter,
  ) {
    if (trendData.isEmpty) {
      return const SizedBox(
        height: 220,
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

    return SizedBox(
      height: 220,
      child: CustomPaint(
        size: Size.infinite,
        painter: _LineChartPainter(
          trendData: trendData,
          maxRevenue: maxRevenue == 0 ? 1.0 : maxRevenue,
          lineColor: theme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildTrendBarChart(
    ThemeData theme,
    List<dynamic> trendData,
    NumberFormat currencyFormatter,
  ) {
    if (trendData.isEmpty) {
      return const SizedBox(
        height: 220,
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
      height: 220,
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
                Text(
                  _formatShortCurrency(revenue),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: ratio,
                      child: Container(
                        width: 34,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              theme.primaryColor,
                              theme.primaryColor.withValues(alpha: 0.65),
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

  Widget _buildDonutPieChart(
    ThemeData theme,
    List<dynamic> categoryData,
    NumberFormat currencyFormatter,
  ) {
    if (categoryData.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('No category data available for this duration.')),
      );
    }

    final double totalValue = categoryData.fold(
      0.0,
      (sum, item) => sum + ((item['value'] as num?)?.toDouble() ?? 0.0),
    );

    return SizedBox(
      height: 220,
      child: Row(
        children: [
          // Donut Chart Graphic
          Expanded(
            flex: 2,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(180, 180),
                  painter: _DonutChartPainter(
                    categoryData: categoryData,
                    totalValue: totalValue == 0 ? 1.0 : totalValue,
                    colors: _chartColors,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Total Revenue', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 2),
                    Text(
                      _formatShortCurrency(totalValue),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Interactive Legend List
          Expanded(
            flex: 3,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: categoryData.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = categoryData[index];
                final name = (item['name'] as String?) ?? '';
                final value = (item['value'] as num?)?.toDouble() ?? 0.0;
                final percentage = (item['percentage'] as num?)?.toDouble() ?? 0.0;
                final color = _chartColors[index % _chartColors.length];

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          currencyFormatter.format(value),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${percentage.toStringAsFixed(1)}%)',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
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
                  final itemColor = _chartColors[index % _chartColors.length];

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
                                  backgroundColor: itemColor.withValues(alpha: 0.15),
                                  child: Text(
                                    '#${index + 1}',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: itemColor),
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
                          valueColor: AlwaysStoppedAnimation<Color>(itemColor),
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
        return 'Today\'s Hourly Dynamic Breakdown';
      case 'week':
        return 'Daily Revenue (This Week)';
      case 'all':
        return 'Monthly/Quarterly Dynamic Breakdown';
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

class _LineChartPainter extends CustomPainter {
  final List<dynamic> trendData;
  final double maxRevenue;
  final Color lineColor;

  _LineChartPainter({
    required this.trendData,
    required this.maxRevenue,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (trendData.isEmpty) return;

    final double paddingBottom = 30.0;
    final double paddingTop = 25.0;
    final double chartHeight = size.height - paddingBottom - paddingTop;
    final double stepX = size.width / (trendData.length > 1 ? trendData.length - 1 : 1);

    final List<Offset> points = [];

    for (int i = 0; i < trendData.length; i++) {
      final item = trendData[i];
      final revenue = (item['revenue'] as num?)?.toDouble() ?? 0.0;
      final x = i * stepX;
      final y = size.height - paddingBottom - ((revenue / maxRevenue) * chartHeight);
      points.add(Offset(x, y));
    }

    // Gradient fill under the curved line
    final fillPath = Path();
    fillPath.moveTo(points.first.dx, size.height - paddingBottom);
    fillPath.lineTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      fillPath.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p2.dx, p2.dy);
    }

    fillPath.lineTo(points.last.dx, size.height - paddingBottom);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.35),
          lineColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Line Path
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      linePath.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p2.dx, p2.dy);
    }

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(linePath, linePaint);

    // Points and Text Labels
    final dotPaint = Paint()..color = Colors.white;
    final dotBorderPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);

    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      final item = trendData[i];
      final label = (item['label'] as String?) ?? '';
      final revenue = (item['revenue'] as num?)?.toDouble() ?? 0.0;

      // Draw glowing dot
      canvas.drawCircle(pt, 5, dotPaint);
      canvas.drawCircle(pt, 5, dotBorderPaint);

      // Draw X-axis label
      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(pt.dx - textPainter.width / 2, size.height - 20));

      // Draw Value text above dot
      if (revenue > 0) {
        textPainter.text = TextSpan(
          text: _formatShortCurrency(revenue),
          style: TextStyle(fontSize: 10, color: lineColor, fontWeight: FontWeight.bold),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(pt.dx - textPainter.width / 2, pt.dy - 18));
      }
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

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.trendData != trendData || oldDelegate.maxRevenue != maxRevenue;
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<dynamic> categoryData;
  final double totalValue;
  final List<Color> colors;

  _DonutChartPainter({
    required this.categoryData,
    required this.totalValue,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 10;
    final strokeWidth = 28.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -pi / 2;

    for (int i = 0; i < categoryData.length; i++) {
      final item = categoryData[i];
      final val = (item['value'] as num?)?.toDouble() ?? 0.0;
      final sweepAngle = (val / totalValue) * 2 * pi;

      paint.color = colors[i % colors.length];

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle - 0.04, // slight gap between slices
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.categoryData != categoryData || oldDelegate.totalValue != totalValue;
  }
}
