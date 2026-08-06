import 'package:flutter/foundation.dart';
import '../models/order.dart';
import 'offline_storage_service.dart';
import 'warehouse_service.dart';

class OfflineSyncService extends ChangeNotifier {
  static final OfflineSyncService instance = OfflineSyncService._internal();

  OfflineSyncService._internal() {
    _init();
  }

  final OfflineStorageService _storage = OfflineStorageService.instance;
  List<Order> _pendingQueue = [];
  bool _isOfflineMode = false;
  bool _isSyncing = false;

  List<Order> get pendingQueue => _pendingQueue;
  int get pendingCount => _pendingQueue.length;
  bool get isOfflineMode => _isOfflineMode;
  bool get isSyncing => _isSyncing;

  Future<void> _init() async {
    _pendingQueue = await _storage.loadOfflineOrdersQueue();
    notifyListeners();
  }

  void toggleOfflineMode(bool enableOffline) {
    _isOfflineMode = enableOffline;
    notifyListeners();
  }

  Future<Order> enqueueOfflineOrder({
    required String customerName,
    String? customerId,
    required String salesStaffId,
    required List<OrderItem> items,
  }) async {
    final offlineOrder = Order(
      id: 'off_${DateTime.now().millisecondsSinceEpoch}',
      customerName: customerName,
      customerId: customerId,
      status: OrderStatus.pending,
      salesStaffId: salesStaffId,
      createdAt: DateTime.now(),
      items: items,
    );

    _pendingQueue.add(offlineOrder);
    await _storage.saveOfflineOrdersQueue(_pendingQueue);
    notifyListeners();
    return offlineOrder;
  }

  Future<int> syncQueuedOrders(WarehouseService warehouseService) async {
    if (_pendingQueue.isEmpty || _isSyncing) return 0;

    _isSyncing = true;
    notifyListeners();

    int syncedCount = 0;
    final List<Order> remainingQueue = List.from(_pendingQueue);

    for (final order in List<Order>.from(_pendingQueue)) {
      try {
        await warehouseService.createOrder(
          customerName: order.customerName,
          customerId: order.customerId,
          salesStaffId: order.salesStaffId ?? 'field_sales',
          items: order.items,
        );
        remainingQueue.removeWhere((o) => o.id == order.id);
        syncedCount++;
      } catch (e) {
        debugPrint('Failed to sync offline order ${order.id}: $e');
        break; // stop FCFS sync loop on first error to preserve sequence
      }
    }

    _pendingQueue = remainingQueue;
    await _storage.saveOfflineOrdersQueue(_pendingQueue);

    _isSyncing = false;
    notifyListeners();
    return syncedCount;
  }
}
