import 'package:flutter_test/flutter_test.dart';
import 'package:may_snacks/models/customer.dart';
import 'package:may_snacks/features/warehouse/controllers/warehouse_controller.dart';
import 'package:may_snacks/services/warehouse_service.dart';

void main() {
  group('Customer/Shop Master Data & Approval Flow Tests', () {
    late WarehouseController controller;

    setUp(() {
      MockWarehouseService.resetDatabase();
      controller = WarehouseController(MockWarehouseService());
    });

    test('Initial database loads approved and pending customer stores', () async {
      await controller.loadAllWarehouseData();
      expect(controller.customers.length, equals(4));
      expect(controller.approvedCustomers.length, equals(3));
      expect(controller.pendingCustomers.length, equals(1));
    });

    test('Sales staff registers a new shop request with pending status', () async {
      await controller.loadAllWarehouseData();
      final initialCount = controller.customers.length;

      final success = await controller.registerCustomer(
        name: 'Seiko Wholesale Mart',
        address: 'Hledan, Yangon',
        phone: '09-987654321',
        createdBy: 'sales-1',
      );

      expect(success, isTrue);
      expect(controller.customers.length, equals(initialCount + 1));
      
      final registered = controller.customers.last;
      expect(registered.name, equals('Seiko Wholesale Mart'));
      expect(registered.status, equals(CustomerStatus.pending));
    });

    test('Admin approves a pending customer request and adds it to master dropdown', () async {
      await controller.loadAllWarehouseData();
      final pendingCustomer = controller.pendingCustomers.first;

      final approveSuccess = await controller.approveCustomer(pendingCustomer.id);
      expect(approveSuccess, isTrue);

      final updatedCustomer = controller.customers.firstWhere((c) => c.id == pendingCustomer.id);
      expect(updatedCustomer.status, equals(CustomerStatus.approved));
      expect(controller.approvedCustomers.any((c) => c.id == pendingCustomer.id), isTrue);
    });

    test('Admin rejects a customer request', () async {
      await controller.loadAllWarehouseData();
      final pendingCustomer = controller.pendingCustomers.first;

      final rejectSuccess = await controller.rejectCustomer(pendingCustomer.id);
      expect(rejectSuccess, isTrue);

      final updatedCustomer = controller.customers.firstWhere((c) => c.id == pendingCustomer.id);
      expect(updatedCustomer.status, equals(CustomerStatus.rejected));
      expect(controller.approvedCustomers.any((c) => c.id == pendingCustomer.id), isFalse);
    });

    test('Admin creates an official customer store directly', () async {
      await controller.loadAllWarehouseData();

      final success = await controller.addCustomerDirect(
        name: 'Capital Hypermarket',
        address: 'Thaketa, Yangon',
      );

      expect(success, isTrue);
      final newStore = controller.customers.last;
      expect(newStore.name, equals('Capital Hypermarket'));
      expect(newStore.status, equals(CustomerStatus.approved));
    });
  });
}
