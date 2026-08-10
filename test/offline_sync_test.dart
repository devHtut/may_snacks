import 'package:flutter_test/flutter_test.dart';
import 'package:may_snacks/models/order.dart';
import 'package:may_snacks/services/warehouse_service.dart';
import 'package:may_snacks/services/offline_sync_service.dart';
import 'package:may_snacks/features/warehouse/controllers/warehouse_controller.dart';

void main() {
  group('Seamless Offline-First & Sync Tests', () {
    late MockWarehouseService mockService;
    late WarehouseController controller;

    setUp(() {
      MockWarehouseService.resetDatabase();
      mockService = MockWarehouseService();
      controller = WarehouseController(mockService);
      OfflineSyncService.instance.setOnlineStatus(true);
      OfflineSyncService.instance.pendingQueue.clear();
    });

    test('OfflineSyncService tracks online and offline connection state', () {
      final syncService = OfflineSyncService.instance;
      syncService.setOnlineStatus(true);
      expect(syncService.isOnline, isTrue);
      expect(syncService.isOfflineMode, isFalse);

      syncService.setOnlineStatus(false);
      expect(syncService.isOnline, isFalse);
      expect(syncService.isOfflineMode, isTrue);

      // Reset back to online
      syncService.setOnlineStatus(true);
    });

    test('Order submitted in offline mode immediately appears in Warehouse Manager order list', () async {
      await controller.loadAllWarehouseData();
      final initialOrderCount = controller.orders.length;

      // Enable offline mode
      OfflineSyncService.instance.setOnlineStatus(false);

      // Sales Staff places order in offline mode
      controller.updateCartItem('p1', 10);
      final success = await controller.submitOrder(
        customerName: 'Offline Test Shop',
        salesStaffId: 's1',
      );

      expect(success, isTrue);
      // Verify local order list includes the new order immediately for Warehouse Manager
      expect(controller.orders.length, equals(initialOrderCount + 1));
      final newOrder = controller.orders.firstWhere((o) => o.customerName == 'Offline Test Shop');
      expect(newOrder.status, equals(OrderStatus.pending));

      // Warehouse Manager can fulfill/pack the offline order immediately
      final fulfillSuccess = await controller.fulfillOrder(newOrder.id);
      expect(fulfillSuccess, isTrue);
      final updatedOrder = controller.orders.firstWhere((o) => o.id == newOrder.id);
      expect(updatedOrder.status, equals(OrderStatus.packed));

      // Reset back to online
      OfflineSyncService.instance.setOnlineStatus(true);
    });

    test('Background sync uploads queued offline orders when connection comes back online', () async {
      await controller.loadAllWarehouseData();

      // Enable offline mode & enqueue an order
      OfflineSyncService.instance.setOnlineStatus(false);
      await OfflineSyncService.instance.enqueueOfflineOrder(
        customerName: 'Queued Offline Store',
        salesStaffId: 's1',
        items: [
          OrderItem(id: 'i1', orderId: '', productId: 'p1', quantity: 5, productName: 'Butter Bread', productPrice: 1500.0),
        ],
      );

      expect(OfflineSyncService.instance.pendingCount, greaterThanOrEqualTo(1));

      // Simulate coming back online & triggering background sync
      OfflineSyncService.instance.setOnlineStatus(true, warehouseService: mockService);
      final synced = await OfflineSyncService.instance.syncQueuedOrders(mockService);

      expect(synced, greaterThanOrEqualTo(1));
      expect(OfflineSyncService.instance.pendingCount, equals(0));
    });
  });
}
