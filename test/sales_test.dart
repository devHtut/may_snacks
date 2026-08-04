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
  });
}
