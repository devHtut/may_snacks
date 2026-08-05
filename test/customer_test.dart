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

    test('Initial database loads approved and pending customer stores with location', () async {
      await controller.loadAllWarehouseData();
      expect(controller.customers.length, equals(4));
      expect(controller.approvedCustomers.length, equals(3));
      expect(controller.pendingCustomers.length, equals(1));
      expect(controller.approvedCustomers.first.region, equals('Yangon Region'));
      expect(controller.approvedCustomers.first.township, equals('Pabedan'));
    });

    test('Sales staff registers a new shop request with location and phone number', () async {
      await controller.loadAllWarehouseData();
      final initialCount = controller.customers.length;

      final success = await controller.registerCustomer(
        name: 'Seiko Wholesale Mart',
        region: 'Mandalay Region',
        township: 'Chanayethazan',
        address: '78th Street, Mandalay',
        phone: '09987654321',
        createdBy: 'sales-1',
      );

      expect(success, isTrue);
      expect(controller.customers.length, equals(initialCount + 1));

      final registered = controller.customers.last;
      expect(registered.name, equals('Seiko Wholesale Mart'));
      expect(registered.region, equals('Mandalay Region'));
      expect(registered.township, equals('Chanayethazan'));
      expect(registered.phone, equals('09987654321'));
      expect(registered.status, equals(CustomerStatus.pending));

      // Verify pending store does NOT appear in approved master dropdown list for sales reps
      expect(controller.approvedCustomers.any((c) => c.name == 'Seiko Wholesale Mart'), isFalse);
    });

    test('Phone number validation rule tests', () {
      final phoneRegex = RegExp(r'^09\d{7,9}$');

      // Valid phone numbers (starts with 09, only numbers, length 9 to 11)
      expect(phoneRegex.hasMatch('091234567'), isTrue); // 9 digits
      expect(phoneRegex.hasMatch('0912345678'), isTrue); // 10 digits
      expect(phoneRegex.hasMatch('09123456789'), isTrue); // 11 digits

      // Invalid phone numbers
      expect(phoneRegex.hasMatch('09123456'), isFalse); // < 9 digits
      expect(phoneRegex.hasMatch('091234567890'), isFalse); // > 11 digits
      expect(phoneRegex.hasMatch('011234567'), isFalse); // Does not start with 09
      expect(phoneRegex.hasMatch('091234a67'), isFalse); // Contains non-digit
      expect(phoneRegex.hasMatch('09-1234567'), isFalse); // Contains hyphen
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

    test('Admin creates an official customer store directly with location and phone', () async {
      await controller.loadAllWarehouseData();

      final success = await controller.addCustomerDirect(
        name: 'Capital Hypermarket',
        region: 'Yangon Region',
        township: 'Thaketa',
        address: 'Thaketa, Yangon',
        phone: '09777666555',
      );

      expect(success, isTrue);
      final newStore = controller.customers.last;
      expect(newStore.name, equals('Capital Hypermarket'));
      expect(newStore.region, equals('Yangon Region'));
      expect(newStore.township, equals('Thaketa'));
      expect(newStore.phone, equals('09777666555'));
      expect(newStore.status, equals(CustomerStatus.approved));
    });

    test('Admin permanently deletes store with 0 orders and deactivates/reactivates store with orders', () async {
      await controller.loadAllWarehouseData();

      // Create store with 0 orders
      await controller.addCustomerDirect(
        name: 'Zero Order Store',
        region: 'Yangon Region',
        township: 'Kamayut',
        phone: '09111222333',
      );
      final zeroOrderStore = controller.customers.last;

      // Verify 0 orders exist for this store
      final orderCount = controller.orders.where((o) => o.customerId == zeroOrderStore.id || o.customerName == zeroOrderStore.name).length;
      expect(orderCount, equals(0));

      // Delete 0-order store permanently
      final deleteSuccess = await controller.deleteCustomer(zeroOrderStore.id);
      expect(deleteSuccess, isTrue);
      expect(controller.customers.any((c) => c.id == zeroOrderStore.id), isFalse);

      // Deactivate store with active orders
      final existingStore = controller.approvedCustomers.first;
      final deactivateSuccess = await controller.rejectCustomer(existingStore.id);
      expect(deactivateSuccess, isTrue);
      expect(controller.approvedCustomers.any((c) => c.id == existingStore.id), isFalse);

      // Reactivate store
      final reactivateSuccess = await controller.approveCustomer(existingStore.id);
      expect(reactivateSuccess, isTrue);
      expect(controller.approvedCustomers.any((c) => c.id == existingStore.id), isTrue);
    });
  });
}
