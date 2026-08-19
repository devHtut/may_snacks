import 'package:flutter/material.dart';
import '../../../common/utils/error_handler.dart';
import '../../../models/product.dart';
import '../../../models/batch.dart';
import '../../../models/order.dart';
import '../../../models/disposal.dart';
import '../../../models/physical_audit.dart';
import '../../../models/customer.dart';
import '../../../models/reserved_stock.dart';
import '../../../services/warehouse_service.dart';
import '../../../services/admin_service.dart';
import '../../../database/database.dart' show LocalDatabase, AppDatabase;
import '../../../services/sync_manager.dart';

class WarehouseController extends ChangeNotifier {
  final WarehouseService _service;
  final AdminService? _adminService;
  SyncManager? _syncManager;

  List<Product> _products = [];
  List<StockBatch> _batches = [];
  List<Order> _orders = [];
  List<DisposalRequest> _disposals = [];
  List<PhysicalAudit> _audits = [];
  List<Customer> _customers = [];
  List<ReservedStock> _reservedStocks = [];

  // Cart state for mobile sales ordering
  final Map<String, int> _cart = {};

  bool _isLoading = false;
  String? _errorMessage;

  int _pendingSyncCount = 0;
  int get pendingSyncCount => _pendingSyncCount;

  WarehouseController(this._service, [this._adminService]) {
    try {
      _syncManager = LocalDatabase.syncManager;
      _syncManager?.addListener(_onSyncChange);
      _updatePendingCount();
    } catch (_) {}
  }

  void _onSyncChange() {
    _updatePendingCount();
    loadAllWarehouseData();
  }

  Future<void> _updatePendingCount() async {
    if (_syncManager != null) {
      _pendingSyncCount = await _syncManager!.getPendingCount();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _syncManager?.removeListener(_onSyncChange);
    super.dispose();
  }

  List<Product> get products => _products;
  List<StockBatch> get batches => _batches;
  List<Order> get orders => _orders;
  List<DisposalRequest> get disposals => _disposals;
  List<PhysicalAudit> get audits => _audits;
  List<Customer> get customers => _customers;
  List<ReservedStock> get reservedStocks => _reservedStocks;
  List<Customer> get approvedCustomers => _customers.where((c) => c.status == CustomerStatus.approved).toList();
  List<Customer> get pendingCustomers => _customers.where((c) => c.status == CustomerStatus.pending).toList();
  
  Map<String, int> get cart => _cart;
  int get cartItemCount => _cart.values.fold(0, (sum, qty) => sum + qty);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isOffline => _syncManager?.isOffline ?? false;

  Future<int> syncOfflineOrders() async {
    final count = await _syncManager?.getPendingCount() ?? 0;
    await _syncManager?.processQueue();
    await loadAllWarehouseData();
    await _updatePendingCount();
    return count;
  }

  int getPhysicalStock(String productId) {
    return _batches
        .where((b) => b.productId == productId && b.quantity > 0 && !b.isExpired)
        .fold(0, (sum, b) => sum + b.quantity);
  }

  int getReservedStock(String productId) {
    return _reservedStocks
        .where((r) => r.productId == productId && r.isActive)
        .fold(0, (sum, r) => sum + r.quantity);
  }

  int getAvailableStock(String productId) {
    final physical = getPhysicalStock(productId);
    final reserved = getReservedStock(productId);
    final available = physical - reserved;
    return available > 0 ? available : 0;
  }

  bool updateCartItem(String productId, int quantity) {
    if (quantity <= 0) {
      _cart.remove(productId);
      _errorMessage = null;
      notifyListeners();
      return true;
    }

    final availableStock = getAvailableStock(productId);
    if (quantity > availableStock) {
      final product = _products.firstWhere((p) => p.id == productId, orElse: () => Product(id: productId, name: 'Product', sku: '', price: 0, createdAt: DateTime.now()));
      _errorMessage = 'Quantity for "${product.name}" cannot exceed available stock ($availableStock units).';
      if (availableStock > 0) {
        _cart[productId] = availableStock;
      } else {
        _cart.remove(productId);
      }
      notifyListeners();
      return false;
    }

    _cart[productId] = quantity;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  Future<bool> submitOrder({
    required String customerName,
    String? customerId,
    required String salesStaffId,
  }) async {
    if (_cart.isEmpty || customerName.trim().isEmpty) {
      _errorMessage = 'Customer name and order items cannot be empty.';
      notifyListeners();
      return false;
    }

    // Final Stock Guard check before creating order
    for (final entry in _cart.entries) {
      final availableStock = getAvailableStock(entry.key);
      if (entry.value > availableStock) {
        final product = _products.firstWhere((p) => p.id == entry.key, orElse: () => Product(id: entry.key, name: 'Product', sku: '', price: 0, createdAt: DateTime.now()));
        _errorMessage = 'Order quantity for "${product.name}" exceeds available stock ($availableStock units).';
        notifyListeners();
        return false;
      }
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<OrderItem> items = [];
      for (final entry in _cart.entries) {
        final product = _products.firstWhere((p) => p.id == entry.key);
        items.add(OrderItem(
          id: '',
          orderId: '',
          productId: entry.key,
          quantity: entry.value,
          productName: product.name,
          productPrice: product.price,
        ));
      }

      await _service.createOrder(
        customerName: customerName.trim(),
        customerId: customerId,
        salesStaffId: salesStaffId,
        items: items,
      );

      await _adminService?.logEvent(
        'ORDER_SUBMITTED',
        'Sales Staff submitted wholesale order for "$customerName" (${items.length} items).',
        actorName: 'Daw Hla (Sales Staff)',
      );

      _cart.clear();
      await loadAllWarehouseData();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.toUserFriendlyMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadAllWarehouseData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.fetchProducts(),
        _service.fetchBatches(),
        _service.fetchIncomingOrders(),
        _service.fetchDisposalRequests(),
        _service.fetchPhysicalAudits(),
        _service.fetchCustomers(),
        _service.fetchReservedStocks(),
      ]);

      _products = results[0] as List<Product>;
      _batches = results[1] as List<StockBatch>;
      _orders = results[2] as List<Order>;
      _disposals = results[3] as List<DisposalRequest>;
      _audits = results[4] as List<PhysicalAudit>;
      _customers = results[5] as List<Customer>;
      _reservedStocks = results[6] as List<ReservedStock>;
    } catch (e) {
      _errorMessage = ErrorHandler.toUserFriendlyMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> stockIn({
    required String productId,
    required String batchNumber,
    required int quantity,
    required DateTime expiryDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newBatch = await _service.stockIn(
        productId: productId,
        batchNumber: batchNumber,
        quantity: quantity,
        expiryDate: expiryDate,
      );
      _batches.add(newBatch);
      await _adminService?.logEvent(
        'STOCK_IN',
        'Warehouse Manager recorded Stock-In for batch #$batchNumber (Qty: $quantity pcs, Expiry: ${expiryDate.toIso8601String().substring(0, 10)}).',
        actorName: 'U Mg Mg (Warehouse Manager)',
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.toUserFriendlyMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> fulfillOrder(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.fulfillOrderFEFO(orderId);
      await loadAllWarehouseData();

      await _adminService?.logEvent(
        'ORDER_FULFILLED',
        'Warehouse Manager packed order (ID: $orderId) using FEFO stock allocation.',
        actorName: 'U Mg Mg (Warehouse Manager)',
      );

      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.toUserFriendlyMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitDisposal({
    required String productId,
    required String batchId,
    required int quantity,
    required String reason,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newDisposal = await _service.submitDisposalRequest(
        productId: productId,
        batchId: batchId,
        quantity: quantity,
        reason: reason,
      );
      _disposals.insert(0, newDisposal);
      await _adminService?.logEvent(
        'DISPOSAL_REQUESTED',
        'Warehouse Manager submitted disposal request for $quantity pcs (Reason: $reason).',
        actorName: 'U Mg Mg (Warehouse Manager)',
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.toUserFriendlyMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> logPhysicalAudit({
    required String productId,
    required String batchId,
    required int systemQuantity,
    required int physicalQuantity,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newAudit = await _service.logPhysicalAudit(
        productId: productId,
        batchId: batchId,
        systemQuantity: systemQuantity,
        physicalQuantity: physicalQuantity,
        notes: notes,
      );
      _audits.insert(0, newAudit);
      // Reload batches as stock might be adjusted by the audit
      final updatedBatches = await _service.fetchBatches();
      _batches = updatedBatches;

      await _adminService?.logEvent(
        'PHYSICAL_AUDIT',
        'Warehouse Manager logged physical stock audit (System Qty: $systemQuantity, Physical Qty: $physicalQuantity).',
        actorName: 'U Mg Mg (Warehouse Manager)',
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.toUserFriendlyMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.cancelOrder(orderId);
      await _adminService?.logEvent(
        'ORDER_CANCELLED',
        'Sales Staff cancelled pending order (ID: $orderId).',
        actorName: 'Daw Hla (Sales Staff)',
      );
      await loadAllWarehouseData();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.toUserFriendlyMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.updateOrderStatus(orderId, status);
      await _adminService?.logEvent(
        'ORDER_STATUS_CHANGED',
        'Warehouse Manager updated order (ID: $orderId) status to ${status.displayName}.',
        actorName: 'U Mg Mg (Warehouse Manager)',
      );
      await loadAllWarehouseData();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.toUserFriendlyMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerCustomer({
    required String name,
    required String region,
    required String township,
    String? address,
    required String phone,
    required String createdBy,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.registerCustomer(
        name: name,
        region: region,
        township: township,
        address: address,
        phone: phone,
        createdBy: createdBy,
      );
      await _adminService?.logEvent(
        'SHOP_REGISTERED',
        'Sales Staff requested field store registration for "$name" in $township, $region.',
        actorName: 'Daw Hla (Sales Staff)',
      );
      await loadAllWarehouseData();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.toUserFriendlyMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> approveCustomer(String customerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.approveCustomer(customerId);
      await _adminService?.logEvent(
        'STORE_APPROVED',
        'Admin approved field customer store into official master dropdown.',
        actorName: 'Ko Myo (Admin)',
      );
      await loadAllWarehouseData();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.toUserFriendlyMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectCustomer(String customerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.rejectCustomer(customerId);
      await _adminService?.logEvent(
        'STORE_DEACTIVATED',
        'Admin deactivated customer store from master dropdown.',
        actorName: 'Ko Myo (Admin)',
      );
      await loadAllWarehouseData();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.toUserFriendlyMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addCustomerDirect({
    required String name,
    required String region,
    required String township,
    String? address,
    required String phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.createCustomerDirect(
        name: name,
        region: region,
        township: township,
        address: address,
        phone: phone,
      );
      await _adminService?.logEvent(
        'STORE_APPROVED',
        'Admin created official customer store "$name" in $township, $region.',
        actorName: 'Ko Myo (Admin)',
      );
      await loadAllWarehouseData();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.toUserFriendlyMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCustomer(String customerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.deleteCustomer(customerId);
      await _adminService?.logEvent(
        'STORE_DELETED',
        'Admin permanently deleted 0-order customer store.',
        actorName: 'Ko Myo (Admin)',
      );
      await loadAllWarehouseData();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.toUserFriendlyMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> clearSyncQueue() async {
    await _syncManager?.clearPendingQueue();
    await _updatePendingCount();
  }
}
