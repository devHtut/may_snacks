import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:may_snacks/models/product.dart';
import 'package:may_snacks/models/batch.dart';
import 'package:may_snacks/models/customer.dart';
import 'package:may_snacks/models/order.dart';
import 'package:may_snacks/models/audit_log.dart';

class ExcelExportService {
  static const String _companyName = 'MAY SNACKS CO., LTD.';
  static const String _headerColor = '#1E3A8A'; // Navy Blue

  /// Save bytes to local file and offer to open/share it
  static Future<String> _saveAndLaunchFile(
    List<int> bytes,
    String fileName, {
    BuildContext? context,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/$fileName');
    await file.writeAsBytes(bytes, flush: true);

    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Excel exported: $fileName'),
          backgroundColor: const Color(0xFF0F766E),
          action: SnackBarAction(
            label: 'Share',
            textColor: Colors.white,
            onPressed: () {
              Share.shareXFiles(
                [XFile(file.path)],
                text: 'May Snacks Export: $fileName',
              );
            },
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }

    // Attempt to open the file in the default spreadsheet app (Excel / Numbers)
    try {
      await OpenFilex.open(file.path);
    } catch (_) {}

    return file.path;
  }

  /// Helper to apply banner styling at the top of a worksheet
  static void _addReportBanner(
    Worksheet sheet, {
    required String reportTitle,
    required String subtitle,
    required int columnSpan,
  }) {
    // Row 1: Company Name
    final Range range1 = sheet.getRangeByIndex(1, 1, 1, columnSpan);
    range1.merge();
    range1.setText(_companyName);
    range1.cellStyle.bold = true;
    range1.cellStyle.fontSize = 14;
    range1.cellStyle.fontColor = '#1E3A8A';
    range1.cellStyle.hAlign = HAlignType.left;

    // Row 2: Report Title
    final Range range2 = sheet.getRangeByIndex(2, 1, 2, columnSpan);
    range2.merge();
    range2.setText(reportTitle);
    range2.cellStyle.bold = true;
    range2.cellStyle.fontSize = 12;
    range2.cellStyle.fontColor = '#0F766E';
    range2.cellStyle.hAlign = HAlignType.left;

    // Row 3: Subtitle / Timestamp
    final Range range3 = sheet.getRangeByIndex(3, 1, 3, columnSpan);
    range3.merge();
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    range3.setText('$subtitle | Generated: $timestamp');
    range3.cellStyle.fontSize = 9;
    range3.cellStyle.fontColor = '#64748B';
    range3.cellStyle.italic = true;
    range3.cellStyle.hAlign = HAlignType.left;
  }

  /// Helper to style table header rows
  static void _styleHeaderRow(Worksheet sheet, int rowIndex, List<String> headers) {
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.getRangeByIndex(rowIndex, i + 1);
      cell.setText(headers[i]);
      cell.cellStyle.bold = true;
      cell.cellStyle.backColor = _headerColor;
      cell.cellStyle.fontColor = '#FFFFFF';
      cell.cellStyle.hAlign = HAlignType.center;
      cell.cellStyle.vAlign = VAlignType.center;
      cell.cellStyle.borders.all.lineStyle = LineStyle.thin;
      cell.cellStyle.borders.all.color = '#CBD5E1';
    }
  }

  // ==========================================
  // ADMIN EXPORTS
  // ==========================================

  /// 1. Admin: Sales Analytics & Performance
  static Future<String> exportSalesAnalytics({
    required Map<String, dynamic> analytics,
    required String durationFilter,
    required List<Order> orders,
    DateTimeRange? dateRange,
    String? durationLabel,
    BuildContext? context,
  }) async {
    final Workbook workbook = Workbook();

    final filteredOrders = dateRange == null
        ? orders
        : orders.where((o) =>
            o.createdAt.isAfter(dateRange.start.subtract(const Duration(seconds: 1))) &&
            o.createdAt.isBefore(dateRange.end.add(const Duration(seconds: 1)))).toList();

    final activeDuration = durationLabel ?? durationFilter;

    // Recalculate metrics for filtered orders if dateRange is supplied
    double totalRevenue = (analytics['totalRevenue'] as num?)?.toDouble() ?? 0.0;
    int ordersCount = (analytics['ordersCount'] as num?)?.toInt() ?? 0;
    Map<dynamic, dynamic> salesByProduct = analytics['salesByProduct'] as Map? ?? {};
    Map<dynamic, dynamic> salesByStaff = analytics['salesByStaff'] as Map? ?? {};

    if (dateRange != null) {
      totalRevenue = filteredOrders.fold(0.0, (sum, o) => sum + o.totalAmount);
      ordersCount = filteredOrders.length;
      final pMap = <String, double>{};
      final sMap = <String, double>{};
      for (final o in filteredOrders) {
        for (final item in o.items) {
          final pName = item.productName ?? 'Product';
          pMap[pName] = (pMap[pName] ?? 0.0) + (item.quantity * (item.productPrice ?? 0.0));
        }
        final staff = o.salesStaffId ?? 'General Sales';
        sMap[staff] = (sMap[staff] ?? 0.0) + o.totalAmount;
      }
      salesByProduct = pMap;
      salesByStaff = sMap;
    }

    final double avgOrderValue = ordersCount == 0 ? 0.0 : totalRevenue / ordersCount;

    // --- Sheet 1: Executive Summary ---
    final Worksheet summarySheet = workbook.worksheets[0];
    summarySheet.name = 'Sales Summary';

    _addReportBanner(
      summarySheet,
      reportTitle: 'Sales Performance Analytics ($activeDuration)',
      subtitle: 'Overview KPIs & Staff Performance (Period: $activeDuration)',
      columnSpan: 5,
    );

    // KPI Box
    summarySheet.getRangeByIndex(5, 1).setText('KPI Metric');
    summarySheet.getRangeByIndex(5, 2).setText('Value');
    _styleHeaderRow(summarySheet, 5, ['KPI Metric', 'Value']);

    final kpis = [
      ['Total Revenue (Ks)', totalRevenue],
      ['Total Wholesale Orders', ordersCount],
      ['Average Order Value (Ks)', avgOrderValue],
      ['Reporting Period', activeDuration.toUpperCase()],
    ];

    for (int r = 0; r < kpis.length; r++) {
      final rowIdx = 6 + r;
      summarySheet.getRangeByIndex(rowIdx, 1).setText(kpis[r][0].toString());
      final valCell = summarySheet.getRangeByIndex(rowIdx, 2);
      if (kpis[r][1] is num) {
        valCell.setNumber((kpis[r][1] as num).toDouble());
        valCell.numberFormat = '#,##0';
      } else {
        valCell.setText(kpis[r][1].toString());
      }
      summarySheet.getRangeByIndex(rowIdx, 1, rowIdx, 2).cellStyle.borders.all.lineStyle = LineStyle.thin;
    }

    // Top Products Table
    final sortedProducts = salesByProduct.entries.toList()
      ..sort((a, b) => (b.value as num).compareTo(a.value as num));

    int prodStartRow = 12;
    summarySheet.getRangeByIndex(prodStartRow - 1, 1).setText('TOP SELLING PRODUCTS');
    summarySheet.getRangeByIndex(prodStartRow - 1, 1).cellStyle.bold = true;

    _styleHeaderRow(summarySheet, prodStartRow, ['Rank', 'Product Name', 'Total Sales (Ks)']);
    for (int i = 0; i < sortedProducts.length; i++) {
      final r = prodStartRow + 1 + i;
      summarySheet.getRangeByIndex(r, 1).setNumber((i + 1).toDouble());
      summarySheet.getRangeByIndex(r, 2).setText(sortedProducts[i].key.toString());
      final revCell = summarySheet.getRangeByIndex(r, 3);
      revCell.setNumber((sortedProducts[i].value as num).toDouble());
      revCell.numberFormat = '#,##0';
      summarySheet.getRangeByIndex(r, 1, r, 3).cellStyle.borders.all.lineStyle = LineStyle.thin;
    }

    // Sales By Staff Table
    final sortedStaff = salesByStaff.entries.toList()
      ..sort((a, b) => (b.value as num).compareTo(a.value as num));

    int staffStartRow = prodStartRow + sortedProducts.length + 3;
    summarySheet.getRangeByIndex(staffStartRow - 1, 1).setText('SALES BY SALES REPRESENTATIVE');
    summarySheet.getRangeByIndex(staffStartRow - 1, 1).cellStyle.bold = true;

    _styleHeaderRow(summarySheet, staffStartRow, ['Rank', 'Sales Staff', 'Total Revenue (Ks)']);
    for (int i = 0; i < sortedStaff.length; i++) {
      final r = staffStartRow + 1 + i;
      summarySheet.getRangeByIndex(r, 1).setNumber((i + 1).toDouble());
      summarySheet.getRangeByIndex(r, 2).setText(sortedStaff[i].key.toString());
      final revCell = summarySheet.getRangeByIndex(r, 3);
      revCell.setNumber((sortedStaff[i].value as num).toDouble());
      revCell.numberFormat = '#,##0';
      summarySheet.getRangeByIndex(r, 1, r, 3).cellStyle.borders.all.lineStyle = LineStyle.thin;
    }

    summarySheet.autoFitColumn(1);
    summarySheet.autoFitColumn(2);
    summarySheet.autoFitColumn(3);

    // --- Sheet 2: Order Transactions Log ---
    final Worksheet ordersSheet = workbook.worksheets.addWithName('Order Logs');

    _addReportBanner(
      ordersSheet,
      reportTitle: 'Wholesale Order Transactions',
      subtitle: 'Period: $activeDuration | Total Orders: ${filteredOrders.length}',
      columnSpan: 7,
    );

    final orderHeaders = ['Invoice #', 'Date & Time', 'Customer Name', 'Items Count', 'Status', 'Total Amount (Ks)'];
    _styleHeaderRow(ordersSheet, 5, orderHeaders);

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    for (int i = 0; i < filteredOrders.length; i++) {
      final order = filteredOrders[i];
      final r = 6 + i;
      final shortId = order.id.length > 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase();

      ordersSheet.getRangeByIndex(r, 1).setText(shortId);
      ordersSheet.getRangeByIndex(r, 2).setText(dateFormat.format(order.createdAt));
      ordersSheet.getRangeByIndex(r, 3).setText(order.customerName);
      ordersSheet.getRangeByIndex(r, 4).setNumber(order.items.length.toDouble());
      ordersSheet.getRangeByIndex(r, 5).setText(order.status.displayName);
      final amtCell = ordersSheet.getRangeByIndex(r, 6);
      amtCell.setNumber(order.totalAmount);
      amtCell.numberFormat = '#,##0';

      ordersSheet.getRangeByIndex(r, 1, r, 6).cellStyle.borders.all.lineStyle = LineStyle.thin;
    }

    for (int c = 1; c <= 6; c++) {
      ordersSheet.autoFitColumn(c);
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    return _saveAndLaunchFile(bytes, 'MaySnacks_Sales_Analytics_$timestamp.xlsx', context: context);
  }

  /// 2. Admin: Customers Directory & Balances
  static Future<String> exportCustomers({
    required List<Customer> customers,
    BuildContext? context,
  }) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'Customers Directory';

    _addReportBanner(
      sheet,
      reportTitle: 'Customer Stores Directory',
      subtitle: 'Total Registered Customers: ${customers.length}',
      columnSpan: 7,
    );

    final headers = ['No.', 'Store Name', 'Region / State', 'Township', 'Phone Number', 'Status', 'Registered Date'];
    _styleHeaderRow(sheet, 5, headers);

    final dateFormat = DateFormat('yyyy-MM-dd');
    for (int i = 0; i < customers.length; i++) {
      final c = customers[i];
      final r = 6 + i;

      sheet.getRangeByIndex(r, 1).setNumber((i + 1).toDouble());
      sheet.getRangeByIndex(r, 2).setText(c.name);
      sheet.getRangeByIndex(r, 3).setText(c.region);
      sheet.getRangeByIndex(r, 4).setText(c.township);
      sheet.getRangeByIndex(r, 5).setText(c.phone);
      sheet.getRangeByIndex(r, 6).setText(c.status.displayName);
      sheet.getRangeByIndex(r, 7).setText(dateFormat.format(c.createdAt));

      sheet.getRangeByIndex(r, 1, r, 7).cellStyle.borders.all.lineStyle = LineStyle.thin;
    }

    for (int col = 1; col <= 7; col++) {
      sheet.autoFitColumn(col);
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    return _saveAndLaunchFile(bytes, 'MaySnacks_Customers_$timestamp.xlsx', context: context);
  }

  /// 3. Admin: Order Audit Logs
  static Future<String> exportOrderAudit({
    required List<Order> orders,
    DateTimeRange? dateRange,
    String? durationLabel,
    BuildContext? context,
  }) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'Order Audit';

    final filteredOrders = dateRange == null
        ? orders
        : orders.where((o) =>
            o.createdAt.isAfter(dateRange.start.subtract(const Duration(seconds: 1))) &&
            o.createdAt.isBefore(dateRange.end.add(const Duration(seconds: 1)))).toList();

    final activeDuration = durationLabel ?? (dateRange != null ? '${DateFormat('yyyy-MM-dd').format(dateRange.start)} to ${DateFormat('yyyy-MM-dd').format(dateRange.end)}' : 'All Time');

    _addReportBanner(
      sheet,
      reportTitle: 'Wholesale Order Audit Log',
      subtitle: 'Period: $activeDuration | Total Audited Orders: ${filteredOrders.length}',
      columnSpan: 6,
    );

    final headers = ['Invoice ID', 'Order Date', 'Customer Name', 'Total Items', 'Status', 'Total Amount (Ks)'];
    _styleHeaderRow(sheet, 5, headers);

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    double grandTotal = 0;

    for (int i = 0; i < filteredOrders.length; i++) {
      final order = filteredOrders[i];
      final r = 6 + i;
      grandTotal += order.totalAmount;

      sheet.getRangeByIndex(r, 1).setText(order.id);
      sheet.getRangeByIndex(r, 2).setText(dateFormat.format(order.createdAt));
      sheet.getRangeByIndex(r, 3).setText(order.customerName);
      sheet.getRangeByIndex(r, 4).setNumber(order.items.length.toDouble());
      sheet.getRangeByIndex(r, 5).setText(order.status.displayName);
      final amtCell = sheet.getRangeByIndex(r, 6);
      amtCell.setNumber(order.totalAmount);
      amtCell.numberFormat = '#,##0';

      sheet.getRangeByIndex(r, 1, r, 6).cellStyle.borders.all.lineStyle = LineStyle.thin;
    }

    // Grand Total Row
    final totalRowIdx = 6 + filteredOrders.length;
    final summaryCell = sheet.getRangeByIndex(totalRowIdx, 1, totalRowIdx, 5);
    summaryCell.merge();
    summaryCell.setText('GRAND TOTAL:');
    summaryCell.cellStyle.bold = true;
    summaryCell.cellStyle.hAlign = HAlignType.right;

    final totalAmtCell = sheet.getRangeByIndex(totalRowIdx, 6);
    totalAmtCell.setNumber(grandTotal);
    totalAmtCell.numberFormat = '#,##0';
    totalAmtCell.cellStyle.bold = true;
    sheet.getRangeByIndex(totalRowIdx, 1, totalRowIdx, 6).cellStyle.borders.top.lineStyle = LineStyle.thin;
    sheet.getRangeByIndex(totalRowIdx, 1, totalRowIdx, 6).cellStyle.borders.bottom.lineStyle = LineStyle.double;

    for (int col = 1; col <= 6; col++) {
      sheet.autoFitColumn(col);
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    return _saveAndLaunchFile(bytes, 'MaySnacks_Order_Audit_$timestamp.xlsx', context: context);
  }

  /// 4. Admin: System Activity Logs
  static Future<String> exportSystemLogs({
    required List<AuditLog> logs,
    DateTimeRange? dateRange,
    String? durationLabel,
    BuildContext? context,
  }) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'Activity Logs';

    final filteredLogs = dateRange == null
        ? logs
        : logs.where((l) =>
            l.createdAt.isAfter(dateRange.start.subtract(const Duration(seconds: 1))) &&
            l.createdAt.isBefore(dateRange.end.add(const Duration(seconds: 1)))).toList();

    final activeDuration = durationLabel ?? (dateRange != null ? '${DateFormat('yyyy-MM-dd').format(dateRange.start)} to ${DateFormat('yyyy-MM-dd').format(dateRange.end)}' : 'All Time');

    _addReportBanner(
      sheet,
      reportTitle: 'System Audit & Activity Logs',
      subtitle: 'Period: $activeDuration | Total Recorded Logs: ${filteredLogs.length}',
      columnSpan: 5,
    );

    final headers = ['Log ID', 'Timestamp', 'Event Type', 'Description', 'Actor'];
    _styleHeaderRow(sheet, 5, headers);

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    for (int i = 0; i < filteredLogs.length; i++) {
      final log = filteredLogs[i];
      final r = 6 + i;

      sheet.getRangeByIndex(r, 1).setText(log.id);
      sheet.getRangeByIndex(r, 2).setText(dateFormat.format(log.createdAt));
      sheet.getRangeByIndex(r, 3).setText(log.action);
      sheet.getRangeByIndex(r, 4).setText(log.description);
      sheet.getRangeByIndex(r, 5).setText(log.actorName ?? 'System');

      sheet.getRangeByIndex(r, 1, r, 5).cellStyle.borders.all.lineStyle = LineStyle.thin;
    }

    for (int col = 1; col <= 5; col++) {
      sheet.autoFitColumn(col);
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    return _saveAndLaunchFile(bytes, 'MaySnacks_System_Logs_$timestamp.xlsx', context: context);
  }

  // ==========================================
  // WAREHOUSE EXPORTS
  // ==========================================

  /// 5. Warehouse: Stock Balance & Inventory Valuation
  static Future<String> exportStockBalance({
    required List<Product> products,
    required List<StockBatch> batches,
    BuildContext? context,
  }) async {
    final Workbook workbook = Workbook();

    // Sheet 1: Product Summary
    final Worksheet prodSheet = workbook.worksheets[0];
    prodSheet.name = 'Stock Summary';

    _addReportBanner(
      prodSheet,
      reportTitle: 'Warehouse Inventory & Stock Balance',
      subtitle: 'Current live inventory levels across all products',
      columnSpan: 6,
    );

    final prodHeaders = ['SKU', 'Product Name', 'Unit Price (Ks)', 'Available Stock', 'Active Batches', 'Total Valuation (Ks)'];
    _styleHeaderRow(prodSheet, 5, prodHeaders);

    double totalValuation = 0;
    int totalUnits = 0;

    for (int i = 0; i < products.length; i++) {
      final p = products[i];
      final r = 6 + i;

      final prodBatches = batches.where((b) => b.productId == p.id && !b.isExpired && b.quantity > 0).toList();
      final availableQty = prodBatches.fold<int>(0, (sum, b) => sum + b.quantity);
      final valuation = availableQty * p.price;

      totalUnits += availableQty;
      totalValuation += valuation;

      prodSheet.getRangeByIndex(r, 1).setText(p.sku);
      prodSheet.getRangeByIndex(r, 2).setText(p.name);
      final priceCell = prodSheet.getRangeByIndex(r, 3);
      priceCell.setNumber(p.price);
      priceCell.numberFormat = '#,##0';

      final qtyCell = prodSheet.getRangeByIndex(r, 4);
      qtyCell.setNumber(availableQty.toDouble());
      qtyCell.numberFormat = '#,##0';

      prodSheet.getRangeByIndex(r, 5).setNumber(prodBatches.length.toDouble());

      final valCell = prodSheet.getRangeByIndex(r, 6);
      valCell.setNumber(valuation);
      valCell.numberFormat = '#,##0';

      prodSheet.getRangeByIndex(r, 1, r, 6).cellStyle.borders.all.lineStyle = LineStyle.thin;
    }

    // Valuation Grand Total
    final valRow = 6 + products.length;
    final labelCell = prodSheet.getRangeByIndex(valRow, 1, valRow, 3);
    labelCell.merge();
    labelCell.setText('TOTAL INVENTORY:');
    labelCell.cellStyle.bold = true;
    labelCell.cellStyle.hAlign = HAlignType.right;

    final totQtyCell = prodSheet.getRangeByIndex(valRow, 4);
    totQtyCell.setNumber(totalUnits.toDouble());
    totQtyCell.numberFormat = '#,##0';
    totQtyCell.cellStyle.bold = true;

    final totValCell = prodSheet.getRangeByIndex(valRow, 6);
    totValCell.setNumber(totalValuation);
    totValCell.numberFormat = '#,##0';
    totValCell.cellStyle.bold = true;

    prodSheet.getRangeByIndex(valRow, 1, valRow, 6).cellStyle.borders.top.lineStyle = LineStyle.thin;
    prodSheet.getRangeByIndex(valRow, 1, valRow, 6).cellStyle.borders.bottom.lineStyle = LineStyle.double;

    for (int c = 1; c <= 6; c++) {
      prodSheet.autoFitColumn(c);
    }

    // Sheet 2: Batch Details
    final Worksheet batchSheet = workbook.worksheets.addWithName('Batch Details');

    _addReportBanner(
      batchSheet,
      reportTitle: 'Detailed Batches Inventory',
      subtitle: 'Complete list of all product batches with expiration status',
      columnSpan: 8,
    );

    final batchHeaders = ['Batch #', 'Product Name', 'Available Qty', 'Initial Qty', 'Received Date', 'Expiry Date', 'Days Left', 'Status'];
    _styleHeaderRow(batchSheet, 5, batchHeaders);

    final dateFormat = DateFormat('yyyy-MM-dd');
    for (int i = 0; i < batches.length; i++) {
      final b = batches[i];
      final r = 6 + i;
      final product = products.firstWhere((p) => p.id == b.productId, orElse: () => Product(id: b.productId, name: 'Unknown', sku: '', price: 0, createdAt: DateTime.now()));

      String status = 'Active';
      if (b.isExpired) {
        status = 'Expired';
      } else if (b.quantity == 0) {
        status = 'Depleted';
      } else if (b.daysUntilExpiry <= 30) {
        status = 'Expiring Soon';
      }

      batchSheet.getRangeByIndex(r, 1).setText(b.batchNumber);
      batchSheet.getRangeByIndex(r, 2).setText(product.name);
      batchSheet.getRangeByIndex(r, 3).setNumber(b.quantity.toDouble());
      batchSheet.getRangeByIndex(r, 4).setNumber(b.initialQuantity.toDouble());
      batchSheet.getRangeByIndex(r, 5).setText(dateFormat.format(b.receivedDate));
      batchSheet.getRangeByIndex(r, 6).setText(dateFormat.format(b.expiryDate));
      batchSheet.getRangeByIndex(r, 7).setNumber(b.daysUntilExpiry.toDouble());
      batchSheet.getRangeByIndex(r, 8).setText(status);

      batchSheet.getRangeByIndex(r, 1, r, 8).cellStyle.borders.all.lineStyle = LineStyle.thin;
    }

    for (int c = 1; c <= 8; c++) {
      batchSheet.autoFitColumn(c);
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    return _saveAndLaunchFile(bytes, 'MaySnacks_Stock_Balance_$timestamp.xlsx', context: context);
  }

  /// 6. Warehouse: Expiry Monitoring & FEFO Tracking Report
  static Future<String> exportExpiryReport({
    required List<StockBatch> batches,
    required List<Product> products,
    BuildContext? context,
  }) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'Expiry Tracking';


    _addReportBanner(
      sheet,
      reportTitle: 'FEFO Expiry Tracking & Risk Report',
      subtitle: 'Batches sorted by earliest expiration date first',
      columnSpan: 8,
    );

    final sortedBatches = List<StockBatch>.from(batches)
      ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

    final headers = ['Batch #', 'Product Name', 'Available Qty', 'Initial Qty', 'Expiry Date', 'Days Remaining', 'Risk Level', 'Action Recommendation'];
    _styleHeaderRow(sheet, 5, headers);

    final dateFormat = DateFormat('yyyy-MM-dd');
    for (int i = 0; i < sortedBatches.length; i++) {
      final b = sortedBatches[i];
      final r = 6 + i;
      final product = products.firstWhere((p) => p.id == b.productId, orElse: () => Product(id: b.productId, name: 'Unknown', sku: '', price: 0, createdAt: DateTime.now()));

      String risk = 'Normal';
      String recommendation = 'Standard Sales';
      if (b.isExpired) {
        risk = 'EXPIRED';
        recommendation = 'Request Disposal Approval';
      } else if (b.daysUntilExpiry <= 30) {
        risk = 'CRITICAL (<30 days)';
        recommendation = 'Flash Sale / Priority Clearance';
      } else if (b.daysUntilExpiry <= 60) {
        risk = 'WARNING (<60 days)';
        recommendation = 'First to Pick (FEFO)';
      }

      sheet.getRangeByIndex(r, 1).setText(b.batchNumber);
      sheet.getRangeByIndex(r, 2).setText(product.name);
      sheet.getRangeByIndex(r, 3).setNumber(b.quantity.toDouble());
      sheet.getRangeByIndex(r, 4).setNumber(b.initialQuantity.toDouble());
      sheet.getRangeByIndex(r, 5).setText(dateFormat.format(b.expiryDate));
      sheet.getRangeByIndex(r, 6).setNumber(b.daysUntilExpiry.toDouble());
      sheet.getRangeByIndex(r, 7).setText(risk);
      sheet.getRangeByIndex(r, 8).setText(recommendation);

      sheet.getRangeByIndex(r, 1, r, 8).cellStyle.borders.all.lineStyle = LineStyle.thin;
    }

    for (int c = 1; c <= 8; c++) {
      sheet.autoFitColumn(c);
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    return _saveAndLaunchFile(bytes, 'MaySnacks_Expiry_Report_$timestamp.xlsx', context: context);
  }

  /// 7. Warehouse: Stock In / Receiving Logs
  static Future<String> exportStockInHistory({
    required List<StockBatch> batches,
    required List<Product> products,
    DateTimeRange? dateRange,
    String? durationLabel,
    BuildContext? context,
  }) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'Stock In History';

    final filteredBatches = dateRange == null
        ? batches
        : batches.where((b) =>
            b.receivedDate.isAfter(dateRange.start.subtract(const Duration(seconds: 1))) &&
            b.receivedDate.isBefore(dateRange.end.add(const Duration(seconds: 1)))).toList();

    final activeDuration = durationLabel ?? (dateRange != null ? '${DateFormat('yyyy-MM-dd').format(dateRange.start)} to ${DateFormat('yyyy-MM-dd').format(dateRange.end)}' : 'All Time');

    _addReportBanner(
      sheet,
      reportTitle: 'Stock In & Inbound Receiving Log',
      subtitle: 'Period: $activeDuration | Total Inbound Batches: ${filteredBatches.length}',
      columnSpan: 6,
    );

    final sortedBatches = List<StockBatch>.from(filteredBatches)
      ..sort((a, b) => b.receivedDate.compareTo(a.receivedDate));

    final headers = ['Batch #', 'Product Name', 'Received Qty', 'Received Date', 'Expiry Date', 'Remaining Qty'];
    _styleHeaderRow(sheet, 5, headers);

    final dateFormat = DateFormat('yyyy-MM-dd');
    for (int i = 0; i < sortedBatches.length; i++) {
      final b = sortedBatches[i];
      final r = 6 + i;
      final product = products.firstWhere((p) => p.id == b.productId, orElse: () => Product(id: b.productId, name: 'Unknown', sku: '', price: 0, createdAt: DateTime.now()));

      sheet.getRangeByIndex(r, 1).setText(b.batchNumber);
      sheet.getRangeByIndex(r, 2).setText(product.name);
      sheet.getRangeByIndex(r, 3).setNumber(b.initialQuantity.toDouble());
      sheet.getRangeByIndex(r, 4).setText(dateFormat.format(b.receivedDate));
      sheet.getRangeByIndex(r, 5).setText(dateFormat.format(b.expiryDate));
      sheet.getRangeByIndex(r, 6).setNumber(b.quantity.toDouble());

      sheet.getRangeByIndex(r, 1, r, 6).cellStyle.borders.all.lineStyle = LineStyle.thin;
    }

    for (int c = 1; c <= 6; c++) {
      sheet.autoFitColumn(c);
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    return _saveAndLaunchFile(bytes, 'MaySnacks_Stock_In_Log_$timestamp.xlsx', context: context);
  }

  /// 8. Warehouse: Physical Stock Audit Sheet (for manual counting and verification)
  static Future<String> exportPhysicalAuditSheet({
    required List<Product> products,
    required List<StockBatch> batches,
    BuildContext? context,
  }) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'Audit Count Sheet';


    _addReportBanner(
      sheet,
      reportTitle: 'Physical Inventory Audit Sheet',
      subtitle: 'Use this sheet for physical stock counting & reconciliation',
      columnSpan: 7,
    );

    final headers = ['SKU', 'Product Name', 'Batch #', 'System Stock (Qty)', 'Physical Count (Qty)', 'Discrepancy (+/-)', 'Auditor Signature / Notes'];
    _styleHeaderRow(sheet, 5, headers);

    final activeBatches = batches.where((b) => b.quantity > 0).toList()
      ..sort((a, b) => a.productId.compareTo(b.productId));

    for (int i = 0; i < activeBatches.length; i++) {
      final b = activeBatches[i];
      final r = 6 + i;
      final product = products.firstWhere((p) => p.id == b.productId, orElse: () => Product(id: b.productId, name: 'Unknown', sku: '', price: 0, createdAt: DateTime.now()));

      sheet.getRangeByIndex(r, 1).setText(product.sku);
      sheet.getRangeByIndex(r, 2).setText(product.name);
      sheet.getRangeByIndex(r, 3).setText(b.batchNumber);
      sheet.getRangeByIndex(r, 4).setNumber(b.quantity.toDouble());
      sheet.getRangeByIndex(r, 5).setText(''); // Blank for physical writing/entry
      sheet.getRangeByIndex(r, 6).setFormula('=E$r-D$r'); // Discrepancy formula
      sheet.getRangeByIndex(r, 7).setText('');

      sheet.getRangeByIndex(r, 1, r, 7).cellStyle.borders.all.lineStyle = LineStyle.thin;
    }

    for (int c = 1; c <= 7; c++) {
      sheet.autoFitColumn(c);
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    return _saveAndLaunchFile(bytes, 'MaySnacks_Physical_Audit_Sheet_$timestamp.xlsx', context: context);
  }
}
