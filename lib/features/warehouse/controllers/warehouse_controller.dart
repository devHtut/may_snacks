import 'package:flutter/material.dart';
import '../../../models/product.dart';
import '../../../models/batch.dart';
import '../../../models/order.dart';
import '../../../models/disposal.dart';
import '../../../models/physical_audit.dart';
import '../../../models/customer.dart';
import '../../../services/warehouse_service.dart';

class WarehouseController extends ChangeNotifier {
  final WarehouseService _service;

  List<Product> _products = [];
  List<StockBatch> _batches = [];
  List<Order> _orders = [];
  List<DisposalRequest> _disposals = [];
  List<PhysicalAudit> _audits = [];
  List<Customer> _customers = [];

  // Cart state for mobile sales ordering
  final Map<String, int> _cart = {};

  bool _isLoading = false;
  String? _errorMessage;

  WarehouseController(this._service);

  List<Product> get products => _products;
  List<StockBatch> get batches => _batches;
  List<Order> get orders => _orders;
  List<DisposalRequest> get disposals => _disposals;
  List<PhysicalAudit> get audits => _audits;
  List<Customer> get customers => _customers;
  List<Customer> get approvedCustomers => _customers.where((c) => c.status == CustomerStatus.approved).toList();
  List<Customer> get pendingCustomers => _customers.where((c) => c.status == CustomerStatus.pending).toList();
  
  Map<String, int> get cart => _cart;
  int get cartItemCount => _cart.values.fold(0, (sum, qty) => sum + qty);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int getAvailableStock(String productId) {
    return _batches
        .where((b) => b.productId == productId && b.quantity > 0 && !b.isExpired)
        .fold(0, (sum, b) => sum + b.quantity);
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

      _cart.clear();
      await loadAllWarehouseData();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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
      ]);

      _products = results[0] as List<Product>;
      _batches = results[1] as List<StockBatch>;
      _orders = results[2] as List<Order>;
      _disposals = results[3] as List<DisposalRequest>;
      _audits = results[4] as List<PhysicalAudit>;
      _customers = results[5] as List<Customer>;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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
      // Reload batches and orders to get updated stock balances and status
      final updatedOrders = await _service.fetchIncomingOrders();
      final updatedBatches = await _service.fetchBatches();
      _orders = updatedOrders;
      _batches = updatedBatches;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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
      await loadAllWarehouseData();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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
      await loadAllWarehouseData();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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
      await loadAllWarehouseData();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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
      await loadAllWarehouseData();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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
      await loadAllWarehouseData();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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
      await loadAllWarehouseData();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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
      await loadAllWarehouseData();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
