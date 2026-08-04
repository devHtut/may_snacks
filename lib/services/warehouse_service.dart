import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../models/batch.dart';
import '../models/order.dart';
import '../models/disposal.dart';
import '../models/physical_audit.dart';

abstract class WarehouseService {
  Future<List<Product>> fetchProducts();
  Future<List<StockBatch>> fetchBatches();
  Future<StockBatch> stockIn({
    required String productId,
    required String batchNumber,
    required int quantity,
    required DateTime expiryDate,
  });
  Future<List<Order>> fetchIncomingOrders();
  Future<void> fulfillOrderFEFO(String orderId);
  Future<List<DisposalRequest>> fetchDisposalRequests();
  Future<DisposalRequest> submitDisposalRequest({
    required String productId,
    required String batchId,
    required int quantity,
    required String reason,
  });
  Future<List<PhysicalAudit>> fetchPhysicalAudits();
  Future<PhysicalAudit> logPhysicalAudit({
    required String productId,
    required String batchId,
    required int systemQuantity,
    required int physicalQuantity,
    String? notes,
  });
  Future<Order> createOrder({
    required String customerName,
    required String salesStaffId,
    required List<OrderItem> items,
  });
}

class SupabaseWarehouseService implements WarehouseService {
  final SupabaseClient _client;

  SupabaseWarehouseService(this._client);

  @override
  Future<List<Product>> fetchProducts() async {
    final response = await _client
        .from('products')
        .select()
        .order('name', ascending: true);
    return (response as List).map((json) => Product.fromJson(json)).toList();
  }

  @override
  Future<List<StockBatch>> fetchBatches() async {
    final response = await _client
        .from('batches')
        .select()
        .order('expiry_date', ascending: true);
    return (response as List).map((json) => StockBatch.fromJson(json)).toList();
  }

  @override
  Future<StockBatch> stockIn({
    required String productId,
    required String batchNumber,
    required int quantity,
    required DateTime expiryDate,
  }) async {
    final response = await _client.from('batches').insert({
      'product_id': productId,
      'batch_number': batchNumber,
      'quantity': quantity,
      'initial_quantity': quantity,
      'expiry_date': expiryDate.toIso8601String().substring(0, 10),
      'received_date': DateTime.now().toIso8601String().substring(0, 10),
    }).select().single();
    
    return StockBatch.fromJson(response);
  }

  @override
  Future<List<Order>> fetchIncomingOrders() async {
    // Select orders with status = 'pending' and pre-fetch order items and products
    final response = await _client
        .from('orders')
        .select('*, order_items(*, products(*))')
        .eq('status', 'pending')
        .order('created_at', ascending: true);
        
    return (response as List).map((json) => Order.fromJson(json)).toList();
  }

  @override
  Future<void> fulfillOrderFEFO(String orderId) async {
    // 1. Fetch order details & items
    final orderResponse = await _client
        .from('orders')
        .select('*, order_items(*, products(*))')
        .eq('id', orderId)
        .single();
    
    final order = Order.fromJson(orderResponse);
    if (order.status != OrderStatus.pending) {
      throw Exception('Order is already fulfilled or processed.');
    }

    // Use a transaction helper or run batch updates. Since Supabase client doesn't expose
    // direct transaction objects in basic Flutter API, we will run the allocation logic client-side
    // and update the database. For enterprise robustness, we can execute this in a loop.
    final List<Map<String, dynamic>> batchUpdates = [];

    for (final item in order.items) {
      // 2. Fetch active batches for this product, ordered by expiry date (FEFO)
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final batchesResponse = await _client
          .from('batches')
          .select()
          .eq('product_id', item.productId)
          .gt('quantity', 0)
          .gte('expiry_date', todayStr)
          .order('expiry_date', ascending: true);

      final batches = (batchesResponse as List)
          .map((json) => StockBatch.fromJson(json))
          .toList();

      int remainingQty = item.quantity;
      for (final batch in batches) {
        if (remainingQty <= 0) break;

        if (batch.quantity >= remainingQty) {
          batchUpdates.add({
            'id': batch.id,
            'quantity': batch.quantity - remainingQty,
          });
          remainingQty = 0;
        } else {
          remainingQty -= batch.quantity;
          batchUpdates.add({
            'id': batch.id,
            'quantity': 0,
          });
        }
      }

      if (remainingQty > 0) {
        throw Exception(
            'Insufficient stock for product "${item.productName ?? 'Unknown'}" to fulfill this order. Missing: $remainingQty units.');
      }
    }

    // 3. Write updates back to DB
    for (final update in batchUpdates) {
      await _client
          .from('batches')
          .update({'quantity': update['quantity']})
          .eq('id', update['id']);
    }

    // 4. Mark order as packed
    await _client
        .from('orders')
        .update({'status': OrderStatus.packed.key})
        .eq('id', orderId);
  }

  @override
  Future<List<DisposalRequest>> fetchDisposalRequests() async {
    final response = await _client
        .from('disposals')
        .select('*, products(*), batches(*), profiles(display_name)')
        .order('created_at', ascending: false);
    return (response as List).map((json) => DisposalRequest.fromJson(json)).toList();
  }

  @override
  Future<DisposalRequest> submitDisposalRequest({
    required String productId,
    required String batchId,
    required int quantity,
    required String reason,
  }) async {
    final currentUser = _client.auth.currentUser;
    final response = await _client.from('disposals').insert({
      'product_id': productId,
      'batch_id': batchId,
      'quantity': quantity,
      'reason': reason,
      'requested_by': currentUser?.id,
      'status': 'pending',
    }).select('*, products(*), batches(*), profiles(display_name)').single();
    
    return DisposalRequest.fromJson(response);
  }

  @override
  Future<List<PhysicalAudit>> fetchPhysicalAudits() async {
    final response = await _client
        .from('physical_audits')
        .select('*, products(*), batches(*), profiles(display_name)')
        .order('created_at', ascending: false);
    return (response as List).map((json) => PhysicalAudit.fromJson(json)).toList();
  }

  @override
  Future<PhysicalAudit> logPhysicalAudit({
    required String productId,
    required String batchId,
    required int systemQuantity,
    required int physicalQuantity,
    String? notes,
  }) async {
    final currentUser = _client.auth.currentUser;
    final response = await _client.from('physical_audits').insert({
      'product_id': productId,
      'batch_id': batchId,
      'system_quantity': systemQuantity,
      'physical_quantity': physicalQuantity,
      'discrepancy': physicalQuantity - systemQuantity,
      'notes': notes,
      'audited_by': currentUser?.id,
    }).select('*, products(*), batches(*), profiles(display_name)').single();

    return PhysicalAudit.fromJson(response);
  }

  @override
  Future<Order> createOrder({
    required String customerName,
    required String salesStaffId,
    required List<OrderItem> items,
  }) async {
    // Insert order header
    final orderResponse = await _client.from('orders').insert({
      'customer_name': customerName,
      'status': 'pending',
      'sales_staff_id': salesStaffId,
    }).select().single();

    final orderId = orderResponse['id'] as String;

    // Insert order items
    final List<Map<String, dynamic>> itemsJson = items.map((item) => {
      'order_id': orderId,
      'product_id': item.productId,
      'quantity': item.quantity,
      'product_name': item.productName,
      'product_price': item.productPrice,
    }).toList();

    await _client.from('order_items').insert(itemsJson);

    // Fetch full order
    final response = await _client
        .from('orders')
        .select('*, order_items(*)')
        .eq('id', orderId)
        .single();
        
    return Order.fromJson(response);
  }
}

class MockWarehouseService implements WarehouseService {
  // In-memory mock database
  static List<Product> _products = [];
  static List<StockBatch> _batches = [];
  static List<Order> _orders = [];
  static List<DisposalRequest> _disposals = [];
  static List<PhysicalAudit> _audits = [];

  static List<Product> get productsList => _products;
  static List<StockBatch> get batchesList => _batches;
  static List<Order> get ordersList => _orders;
  static List<DisposalRequest> get disposalsList => _disposals;

  static void resetDatabase() {
    _products = [
      Product(id: 'p1', name: 'Butter Bread', sku: 'MS-BUTTER-BREAD', price: 1500.0, createdAt: DateTime.now()),
      Product(id: 'p2', name: 'Crispy Rusks (Mini)', sku: 'MS-MINI-RUSK', price: 1200.0, createdAt: DateTime.now()),
      Product(id: 'p3', name: 'Chocolate Cake Slice', sku: 'MS-CHOCO-CAKE', price: 2000.0, createdAt: DateTime.now()),
      Product(id: 'p4', name: 'Vanilla Cookies Pack', sku: 'MS-VANILLA-COOKIE', price: 2500.0, createdAt: DateTime.now()),
    ];

    _batches = [
      StockBatch(
        id: 'b1',
        productId: 'p1',
        batchNumber: 'BAT-BB-001',
        quantity: 50,
        initialQuantity: 100,
        expiryDate: DateTime.now().add(const Duration(days: 5)),
        receivedDate: DateTime.now().subtract(const Duration(days: 2)),
        createdAt: DateTime.now(),
      ),
      StockBatch(
        id: 'b2',
        productId: 'p1',
        batchNumber: 'BAT-BB-002',
        quantity: 150,
        initialQuantity: 150,
        expiryDate: DateTime.now().add(const Duration(days: 45)),
        receivedDate: DateTime.now(),
        createdAt: DateTime.now(),
      ),
      StockBatch(
        id: 'b3',
        productId: 'p2',
        batchNumber: 'BAT-R-001',
        quantity: 80,
        initialQuantity: 80,
        expiryDate: DateTime.now().add(const Duration(days: 15)),
        receivedDate: DateTime.now().subtract(const Duration(days: 3)),
        createdAt: DateTime.now(),
      ),
      StockBatch(
        id: 'b4',
        productId: 'p3',
        batchNumber: 'BAT-CC-001',
        quantity: 0,
        initialQuantity: 40,
        expiryDate: DateTime.now().subtract(const Duration(days: 2)),
        receivedDate: DateTime.now().subtract(const Duration(days: 10)),
        createdAt: DateTime.now(),
      ),
    ];

    _orders = [
      Order(
        id: 'o1',
        customerName: 'City Mart Supermarket',
        status: OrderStatus.pending,
        salesStaffId: 's1',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        items: [
          OrderItem(id: 'oi1', orderId: 'o1', productId: 'p1', quantity: 60, productName: 'Butter Bread', productPrice: 1500.0),
          OrderItem(id: 'oi2', orderId: 'o1', productId: 'p2', quantity: 10, productName: 'Crispy Rusks (Mini)', productPrice: 1200.0),
        ],
      ),
      Order(
        id: 'o2',
        customerName: 'Family Snack Shop',
        status: OrderStatus.pending,
        salesStaffId: 's1',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        items: [
          OrderItem(id: 'oi3', orderId: 'o2', productId: 'p1', quantity: 20, productName: 'Butter Bread', productPrice: 1500.0),
        ],
      ),
    ];

    _disposals = [];
    _audits = [];
  }

  @override
  Future<List<Product>> fetchProducts() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_products);
  }

  @override
  Future<List<StockBatch>> fetchBatches() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_batches);
  }

  @override
  Future<StockBatch> stockIn({
    required String productId,
    required String batchNumber,
    required int quantity,
    required DateTime expiryDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newBatch = StockBatch(
      id: 'b_${DateTime.now().millisecondsSinceEpoch}',
      productId: productId,
      batchNumber: batchNumber,
      quantity: quantity,
      initialQuantity: quantity,
      expiryDate: expiryDate,
      receivedDate: DateTime.now(),
      createdAt: DateTime.now(),
    );
    _batches.add(newBatch);
    return newBatch;
  }

  @override
  Future<List<Order>> fetchIncomingOrders() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _orders.where((o) => o.status == OrderStatus.pending).toList();
  }

  @override
  Future<void> fulfillOrderFEFO(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final orderIndex = _orders.indexWhere((o) => o.id == orderId);
    if (orderIndex == -1) throw Exception('Order not found');

    final order = _orders[orderIndex];
    if (order.status != OrderStatus.pending) {
      throw Exception('Order is already fulfilled.');
    }

    // Temporary copy of batches to roll back in case of stock allocation failure
    final List<StockBatch> updatedBatches = List.from(_batches);

    for (final item in order.items) {
      // Find batches of this product that are not expired and have quantity > 0
      final productBatches = updatedBatches.where((b) {
        return b.productId == item.productId && b.quantity > 0 && !b.isExpired;
      }).toList();

      // Sort according to FEFO: Oldest expiry first
      productBatches.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

      int remainingQty = item.quantity;
      for (final batch in productBatches) {
        if (remainingQty <= 0) break;

        final index = updatedBatches.indexWhere((b) => b.id == batch.id);
        final currentBatch = updatedBatches[index];

        if (currentBatch.quantity >= remainingQty) {
          updatedBatches[index] = currentBatch.copyWith(
            quantity: currentBatch.quantity - remainingQty,
          );
          remainingQty = 0;
        } else {
          remainingQty -= currentBatch.quantity;
          updatedBatches[index] = currentBatch.copyWith(quantity: 0);
        }
      }

      if (remainingQty > 0) {
        throw Exception(
            'Insufficient stock for product "${item.productName ?? 'Unknown'}" to fulfill this order. Missing: $remainingQty units.');
      }
    }

    // Apply batch updates
    _batches = updatedBatches;

    // Mark order status as packed
    _orders[orderIndex] = order.copyWith(status: OrderStatus.packed);
  }

  @override
  Future<List<DisposalRequest>> fetchDisposalRequests() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_disposals);
  }

  @override
  Future<DisposalRequest> submitDisposalRequest({
    required String productId,
    required String batchId,
    required int quantity,
    required String reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final product = _products.firstWhere((p) => p.id == productId);
    final batch = _batches.firstWhere((b) => b.id == batchId);

    final newDisposal = DisposalRequest(
      id: 'd_${DateTime.now().millisecondsSinceEpoch}',
      productId: productId,
      batchId: batchId,
      quantity: quantity,
      reason: reason,
      status: DisposalStatus.pending,
      createdAt: DateTime.now(),
      productName: product.name,
      batchNumber: batch.batchNumber,
      requesterName: 'Warehouse Manager',
    );
    _disposals.add(newDisposal);
    return newDisposal;
  }

  @override
  Future<List<PhysicalAudit>> fetchPhysicalAudits() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_audits);
  }

  @override
  Future<PhysicalAudit> logPhysicalAudit({
    required String productId,
    required String batchId,
    required int systemQuantity,
    required int physicalQuantity,
    String? notes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final product = _products.firstWhere((p) => p.id == productId);
    final batch = _batches.firstWhere((b) => b.id == batchId);

    final newAudit = PhysicalAudit(
      id: 'au_${DateTime.now().millisecondsSinceEpoch}',
      productId: productId,
      batchId: batchId,
      systemQuantity: systemQuantity,
      physicalQuantity: physicalQuantity,
      discrepancy: physicalQuantity - systemQuantity,
      notes: notes,
      createdAt: DateTime.now(),
      productName: product.name,
      batchNumber: batch.batchNumber,
      auditorName: 'Warehouse Manager',
    );
    _audits.add(newAudit);
    
    // Adjust batch quantity based on physical audit result
    final batchIndex = _batches.indexWhere((b) => b.id == batchId);
    if (batchIndex != -1) {
      _batches[batchIndex] = _batches[batchIndex].copyWith(quantity: physicalQuantity);
    }

    return newAudit;
  }

  @override
  Future<Order> createOrder({
    required String customerName,
    required String salesStaffId,
    required List<OrderItem> items,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final orderId = 'o_${DateTime.now().millisecondsSinceEpoch}';

    final populatedItems = items.map((item) {
      return OrderItem(
        id: 'oi_${DateTime.now().millisecondsSinceEpoch}_${item.productId}',
        orderId: orderId,
        productId: item.productId,
        quantity: item.quantity,
        productName: item.productName,
        productPrice: item.productPrice,
      );
    }).toList();

    final newOrder = Order(
      id: orderId,
      customerName: customerName,
      status: OrderStatus.pending,
      salesStaffId: salesStaffId,
      createdAt: DateTime.now(),
      items: populatedItems,
    );

    _orders.add(newOrder);
    return newOrder;
  }
}
