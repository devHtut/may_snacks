import 'package:flutter_test/flutter_test.dart';
import 'package:may_snacks/models/order.dart';
import 'package:may_snacks/features/warehouse/controllers/warehouse_controller.dart';
import 'package:may_snacks/services/warehouse_service.dart';

void main() {
  group('Sales Staff Dashboard & Cart Operations Tests', () {
    late WarehouseController controller;

    setUp(() {
      MockWarehouseService.resetDatabase();
      controller = WarehouseController(MockWarehouseService());
    });

    test('Cart state management adds, updates, and clears items correctly', () async {
      await controller.loadAllWarehouseData();
      
      expect(controller.cart.isEmpty, isTrue);
      expect(controller.cartItemCount, equals(0));

      // Add item to cart
      controller.updateCartItem('p1', 5);
      expect(controller.cart['p1'], equals(5));
      expect(controller.cartItemCount, equals(5));

      // Update quantity
      controller.updateCartItem('p1', 8);
      expect(controller.cart['p1'], equals(8));

      // Remove item by setting quantity to 0
      controller.updateCartItem('p1', 0);
      expect(controller.cart.containsKey('p1'), isFalse);
      expect(controller.cartItemCount, equals(0));

      // Clear cart
      controller.updateCartItem('p1', 3);
      controller.updateCartItem('p2', 2);
      expect(controller.cartItemCount, equals(5));
      
      controller.clearCart();
      expect(controller.cart.isEmpty, isTrue);
      expect(controller.cartItemCount, equals(0));
    });

    test('Submitting wholesale order clears cart and updates salesperson logs', () async {
      await controller.loadAllWarehouseData();

      // Initial checks
      final initialOrdersCount = controller.orders.length;

      // Add p1 and p2 items to cart
      controller.updateCartItem('p1', 10); // Butter Bread (Ks 1500 each)
      controller.updateCartItem('p2', 5);  // Crispy Rusks (Ks 1200 each)

      // Submit order
      final success = await controller.submitOrder(
        customerName: 'Aung Supermarket',
        salesStaffId: 'mock-sales-id',
      );

      expect(success, isTrue);
      expect(controller.cart.isEmpty, isTrue);
      expect(controller.orders.length, equals(initialOrdersCount + 1));

      // Verify final placed order contents
      final newOrder = controller.orders.last;
      expect(newOrder.customerName, equals('Aung Supermarket'));
      expect(newOrder.salesStaffId, equals('mock-sales-id'));
      expect(newOrder.status, equals(OrderStatus.pending));
      expect(newOrder.items.length, equals(2));

      // Verify price calculations
      final p1Item = newOrder.items.firstWhere((i) => i.productId == 'p1');
      expect(p1Item.productPrice, equals(1500.0));
      expect(p1Item.quantity, equals(10));

      final p2Item = newOrder.items.firstWhere((i) => i.productId == 'p2');
      expect(p2Item.productPrice, equals(1200.0));
      expect(p2Item.quantity, equals(5));

      expect(newOrder.totalAmount, equals(10 * 1500.0 + 5 * 1200.0)); // Ks 21000
    });

    test('Canceling a pending order removes it from the list', () async {
      await controller.loadAllWarehouseData();
      final initialOrdersCount = controller.orders.length;

      // Add and submit
      controller.updateCartItem('p1', 2);
      await controller.submitOrder(customerName: 'Cancel Test Store', salesStaffId: 's1');
      expect(controller.orders.length, equals(initialOrdersCount + 1));

      final placedOrder = controller.orders.last;
      expect(placedOrder.status, equals(OrderStatus.pending));

      // Cancel order
      final cancelSuccess = await controller.cancelOrder(placedOrder.id);
      expect(cancelSuccess, isTrue);
      
      // The order should now be removed from the list
      expect(controller.orders.any((o) => o.id == placedOrder.id), isFalse);
    });

    test('Updating order status changes status correctly', () async {
      await controller.loadAllWarehouseData();

      // Create a pending order
      controller.updateCartItem('p2', 3);
      await controller.submitOrder(customerName: 'Status Test Store', salesStaffId: 's1');
      final order = controller.orders.last;

      // Fulfill to pack it
      await controller.fulfillOrder(order.id);
      expect(controller.orders.firstWhere((o) => o.id == order.id).status, equals(OrderStatus.packed));

      // Mark as delivered
      final updateSuccess = await controller.updateOrderStatus(order.id, OrderStatus.delivered);
      expect(updateSuccess, isTrue);
      expect(controller.orders.firstWhere((o) => o.id == order.id).status, equals(OrderStatus.delivered));
    });

    test('Bulk quantity entry sets large order quantities correctly', () async {
      await controller.loadAllWarehouseData();

      // Direct bulk quantity set within available stock
      const targetQty = 50;
      controller.updateCartItem('p1', targetQty);
      expect(controller.cart['p1'], equals(targetQty));
      expect(controller.cartItemCount, equals(targetQty));
    });

    test('Cart and Order Submission reject quantities exceeding available stock', () async {
      await controller.loadAllWarehouseData();

      final availableP1Stock = controller.getAvailableStock('p1');
      expect(availableP1Stock, greaterThan(0));

      // Attempt to add more than available stock
      final success = controller.updateCartItem('p1', availableP1Stock + 50);
      expect(success, isFalse);
      expect(controller.errorMessage, contains('cannot exceed available stock'));
      expect(controller.cart['p1'], equals(availableP1Stock)); // Capped at available stock

      // Verify submitOrder fails if cart quantity exceeds available stock
      controller.cart['p1'] = availableP1Stock + 10;
      final submitSuccess = await controller.submitOrder(
        customerName: 'Excess Stock Test Store',
        salesStaffId: 's1',
      );
      expect(submitSuccess, isFalse);
      expect(controller.errorMessage, contains('exceeds available stock'));
    });
  });
}
