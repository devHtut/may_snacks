import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:may_snacks/models/product.dart';
import 'package:may_snacks/models/batch.dart';
import 'package:may_snacks/models/customer.dart';
import 'package:may_snacks/models/order.dart';
import 'package:may_snacks/models/audit_log.dart';
import 'package:may_snacks/services/excel_export_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return Directory.systemTemp.path;
    });
  });

  group('ExcelExportService Tests', () {
    late List<Product> testProducts;
    late List<StockBatch> testBatches;
    late List<Customer> testCustomers;
    late List<Order> testOrders;
    late List<AuditLog> testLogs;

    setUp(() {
      testProducts = [
        Product(id: 'p-1', name: 'Crispy Crackers 100g', sku: 'CRK-100', price: 1500, createdAt: DateTime.now()),
        Product(id: 'p-2', name: 'Spicy Beans 50g', sku: 'SPB-50', price: 800, createdAt: DateTime.now()),
      ];

      testBatches = [
        StockBatch(
          id: 'b-1',
          productId: 'p-1',
          batchNumber: 'BAT-20260909-001',
          quantity: 100,
          initialQuantity: 100,
          expiryDate: DateTime(2026, 12, 31),
          receivedDate: DateTime(2026, 9, 1),
          createdAt: DateTime.now(),
        ),
        StockBatch(
          id: 'b-2',
          productId: 'p-2',
          batchNumber: 'BAT-20260909-002',
          quantity: 50,
          initialQuantity: 50,
          expiryDate: DateTime(2026, 10, 1),
          receivedDate: DateTime(2026, 9, 1),
          createdAt: DateTime.now(),
        ),
      ];

      testCustomers = [
        Customer(
          id: 'c-1',
          name: 'Super Mart Kamayut',
          region: 'Yangon Region',
          township: 'Kamayut',
          phone: '0912345678',
          status: CustomerStatus.approved,
          createdAt: DateTime(2026, 1, 1),
        ),
      ];

      testOrders = [
        Order(
          id: 'ord-12345',
          customerName: 'Super Mart Kamayut',
          status: OrderStatus.delivered,
          createdAt: DateTime(2026, 9, 9, 10, 0),
          items: [
            OrderItem(id: 'i-1', orderId: 'ord-12345', productId: 'p-1', quantity: 10, productName: 'Crispy Crackers 100g', productPrice: 1500),
          ],
        ),
      ];

      testLogs = [
        AuditLog(id: 'l-1', action: 'ORDER_SUBMITTED', description: 'Order submitted for Super Mart', createdAt: DateTime.now(), actorName: 'Sales Rep'),
      ];
    });

    test('exports Sales Analytics excel file path', () async {
      final path = await ExcelExportService.exportSalesAnalytics(
        analytics: {
          'totalRevenue': 15000.0,
          'ordersCount': 1,
          'salesByProduct': {'Crispy Crackers 100g': 15000.0},
          'salesByStaff': {'Sales Rep': 15000.0},
        },
        durationFilter: 'month',
        orders: testOrders,
      );
      expect(path, endsWith('.xlsx'));
      expect(File(path).existsSync(), isTrue);
    });

    test('exports Customers directory excel file path', () async {
      final path = await ExcelExportService.exportCustomers(customers: testCustomers);
      expect(path, endsWith('.xlsx'));
      expect(File(path).existsSync(), isTrue);
    });

    test('exports Order Audit excel file path', () async {
      final path = await ExcelExportService.exportOrderAudit(orders: testOrders);
      expect(path, endsWith('.xlsx'));
      expect(File(path).existsSync(), isTrue);
    });

    test('exports System Logs excel file path', () async {
      final path = await ExcelExportService.exportSystemLogs(logs: testLogs);
      expect(path, endsWith('.xlsx'));
      expect(File(path).existsSync(), isTrue);
    });

    test('exports Stock Balance excel file path', () async {
      final path = await ExcelExportService.exportStockBalance(products: testProducts, batches: testBatches);
      expect(path, endsWith('.xlsx'));
      expect(File(path).existsSync(), isTrue);
    });

    test('exports Expiry Report excel file path', () async {
      final path = await ExcelExportService.exportExpiryReport(batches: testBatches, products: testProducts);
      expect(path, endsWith('.xlsx'));
      expect(File(path).existsSync(), isTrue);
    });

    test('exports Stock In History excel file path', () async {
      final path = await ExcelExportService.exportStockInHistory(batches: testBatches, products: testProducts);
      expect(path, endsWith('.xlsx'));
      expect(File(path).existsSync(), isTrue);
    });

    test('exports Physical Audit Sheet excel file path', () async {
      final path = await ExcelExportService.exportPhysicalAuditSheet(products: testProducts, batches: testBatches);
      expect(path, endsWith('.xlsx'));
      expect(File(path).existsSync(), isTrue);
    });

    test('exports Sales Analytics with DateTimeRange filter', () async {
      final range = DateTimeRange(
        start: DateTime(2026, 9, 1),
        end: DateTime(2026, 9, 30, 23, 59, 59),
      );
      final path = await ExcelExportService.exportSalesAnalytics(
        analytics: {},
        durationFilter: 'custom',
        orders: testOrders,
        dateRange: range,
        durationLabel: '2026-09-01 to 2026-09-30',
      );
      expect(path, endsWith('.xlsx'));
      expect(File(path).existsSync(), isTrue);
    });

    test('exports Order Audit and Stock In with DateTimeRange filter', () async {
      final range = DateTimeRange(
        start: DateTime(2026, 9, 1),
        end: DateTime(2026, 9, 10, 23, 59, 59),
      );
      final orderPath = await ExcelExportService.exportOrderAudit(
        orders: testOrders,
        dateRange: range,
        durationLabel: '2026-09-01 to 2026-09-10',
      );
      expect(orderPath, endsWith('.xlsx'));
      expect(File(orderPath).existsSync(), isTrue);

      final stockInPath = await ExcelExportService.exportStockInHistory(
        batches: testBatches,
        products: testProducts,
        dateRange: range,
        durationLabel: '2026-09-01 to 2026-09-10',
      );
      expect(stockInPath, endsWith('.xlsx'));
      expect(File(stockInPath).existsSync(), isTrue);
    });
  });
}
