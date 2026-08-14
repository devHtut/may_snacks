import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import '../models/product.dart' as m;
import '../models/batch.dart' as m;
import '../models/order.dart' as m;
import '../models/disposal.dart' as m;
import '../models/physical_audit.dart' as m;
import '../models/customer.dart' as m;
import '../database/database.dart';
import 'sync_manager.dart';

abstract class WarehouseService {
  Future<List<m.Product>> fetchProducts();
  Future<List<m.StockBatch>> fetchBatches();
  Future<m.StockBatch> stockIn({
    required String productId,
    required String batchNumber,
    required int quantity,
    required DateTime expiryDate,
  });
  Future<List<m.Order>> fetchIncomingOrders();
  Future<void> fulfillOrderFEFO(String orderId);
  Future<List<m.DisposalRequest>> fetchDisposalRequests();
  Future<m.DisposalRequest> submitDisposalRequest({
    required String productId,
    required String batchId,
    required int quantity,
    required String reason,
  });
  Future<List<m.PhysicalAudit>> fetchPhysicalAudits();
  Future<m.PhysicalAudit> logPhysicalAudit({
    required String productId,
    required String batchId,
    required int systemQuantity,
    required int physicalQuantity,
    String? notes,
  });
  Future<m.Order> createOrder({
    required String customerName,
    String? customerId,
    required String salesStaffId,
    required List<m.OrderItem> items,
  });
  Future<void> cancelOrder(String orderId);
  Future<void> updateOrderStatus(String orderId, m.OrderStatus status);
  Future<List<m.Customer>> fetchCustomers();
  Future<m.Customer> registerCustomer({
    required String name,
    required String region,
    required String township,
    String? address,
    required String phone,
    required String createdBy,
  });
  Future<void> approveCustomer(String customerId);
  Future<void> rejectCustomer(String customerId);
  Future<m.Customer> createCustomerDirect({
    required String name,
    required String region,
    required String township,
    String? address,
    required String phone,
  });
  Future<void> deleteCustomer(String customerId);
}

class SupabaseWarehouseService implements WarehouseService {
  final SupabaseClient _client;
  final _uuid = const Uuid();

  SupabaseWarehouseService(this._client);

  AppDatabase get _db => LocalDatabase.instance;
  SyncManager get _sync => LocalDatabase.syncManager;

  // ---------------------------------------------------------------------------
  // SYNC HELPERS (Pull from Server to Local SQLite)
  // ---------------------------------------------------------------------------
  Future<void> _syncProductsDown() async {
    try {
      final response = await _client.from('products').select();
      await _db.transaction(() async {
        for (final row in response as List) {
          await _db.into(_db.products).insertOnConflictUpdate(ProductsCompanion.insert(
            id: row['id'],
            name: row['name'],
            sku: row['sku'],
            price: (row['price'] as num).toDouble(),
            createdAt: DateTime.parse(row['created_at']),
          ));
        }
      });
    } catch (e) {
      debugPrint('Error syncing products down: $e');
    }
  }

  Future<void> _syncCustomersDown() async {
    try {
      final response = await _client.from('customers').select();
      await _db.transaction(() async {
        for (final row in response as List) {
          await _db.into(_db.customers).insertOnConflictUpdate(CustomersCompanion.insert(
            id: row['id'],
            name: row['name'],
            region: row['region'] ?? '',
            township: row['township'] ?? '',
            address: drift.Value(row['address']),
            phone: row['phone'] ?? '',
            status: row['status'] ?? 'pending',
            createdBy: drift.Value(row['created_by']),
            createdAt: DateTime.parse(row['created_at']),
          ));
        }
      });
    } catch (e) {
      debugPrint('Error syncing customers down: $e');
    }
  }

  Future<void> _syncOrdersDown() async {
    try {
      final response = await _client.from('orders').select('*, order_items(*)');
      await _db.transaction(() async {
        for (final row in response as List) {
          await _db.into(_db.orders).insertOnConflictUpdate(OrdersCompanion.insert(
            id: row['id'],
            customerName: row['customer_name'],
            customerId: drift.Value(row['customer_id']),
            status: row['status'] ?? 'pending',
            salesStaffId: drift.Value(row['sales_staff_id']),
            createdAt: DateTime.parse(row['created_at']),
          ));
          final items = row['order_items'] as List?;
          if (items != null) {
            for (final item in items) {
              await _db.into(_db.orderItems).insertOnConflictUpdate(OrderItemsCompanion.insert(
                id: item['id'],
                orderId: item['order_id'],
                productId: item['product_id'],
                quantity: item['quantity'],
                productName: drift.Value(item['product_name']),
                productPrice: drift.Value((item['product_price'] as num?)?.toDouble()),
              ));
            }
          }
        }
      });
    } catch (e) {
      debugPrint('Error syncing orders down: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // IMPLEMENTATION
  // ---------------------------------------------------------------------------

  @override
  Future<List<m.Product>> fetchProducts() async {
    // 1. Trigger background sync
    _syncProductsDown();
    
    // 2. Return local data immediately
    final rows = await (_db.select(_db.products)..orderBy([(t) => drift.OrderingTerm.asc(t.name)])).get();
    return rows.map((r) => m.Product(
      id: r.id,
      name: r.name,
      sku: r.sku,
      price: r.price,
      createdAt: r.createdAt,
    )).toList();
  }

  @override
  Future<List<m.Customer>> fetchCustomers() async {
    _syncCustomersDown();
    
    final rows = await (_db.select(_db.customers)..orderBy([(t) => drift.OrderingTerm.asc(t.name)])).get();
    return rows.map((r) => m.Customer(
      id: r.id,
      name: r.name,
      region: r.region,
      township: r.township,
      address: r.address,
      phone: r.phone,
      status: m.CustomerStatus.fromKey(r.status),
      createdBy: r.createdBy,
      createdAt: r.createdAt,
    )).toList();
  }

  @override
  Future<List<m.Order>> fetchIncomingOrders() async {
    _syncOrdersDown();

    final orderRows = await (_db.select(_db.orders)..orderBy([(t) => drift.OrderingTerm.desc(t.createdAt)])).get();
    final List<m.Order> orders = [];

    for (final o in orderRows) {
      final itemRows = await (_db.select(_db.orderItems)..where((t) => t.orderId.equals(o.id))).get();
      final items = itemRows.map((i) => m.OrderItem(
        id: i.id,
        orderId: i.orderId,
        productId: i.productId,
        quantity: i.quantity,
        productName: i.productName,
        productPrice: i.productPrice,
      )).toList();

      orders.add(m.Order(
        id: o.id,
        customerName: o.customerName,
        customerId: o.customerId,
        status: m.OrderStatus.fromKey(o.status),
        salesStaffId: o.salesStaffId,
        createdAt: o.createdAt,
        items: items,
      ));
    }
    return orders;
  }

  @override
  Future<m.Order> createOrder({
    required String customerName,
    String? customerId,
    required String salesStaffId,
    required List<m.OrderItem> items,
  }) async {
    final orderId = _uuid.v4();
    final now = DateTime.now();

    // 1. Save to local SQLite
    await _db.into(_db.orders).insert(OrdersCompanion.insert(
      id: orderId,
      customerName: customerName,
      customerId: drift.Value(customerId),
      status: 'pending',
      salesStaffId: drift.Value(salesStaffId),
      createdAt: now,
    ));

    final List<m.OrderItem> populatedItems = [];
    for (final item in items) {
      final itemId = _uuid.v4();
      populatedItems.add(m.OrderItem(
        id: itemId,
        orderId: orderId,
        productId: item.productId,
        quantity: item.quantity,
        productName: item.productName,
        productPrice: item.productPrice,
      ));
      
      await _db.into(_db.orderItems).insert(OrderItemsCompanion.insert(
        id: itemId,
        orderId: orderId,
        productId: item.productId,
        quantity: item.quantity,
        productName: drift.Value(item.productName),
        productPrice: drift.Value(item.productPrice),
      ));
    }

    // 2. Queue Mutations for SyncManager
    await _sync.queueMutation(
      actionType: 'INSERT',
      tableName: 'orders',
      payload: {
        'id': orderId,
        'customer_name': customerName,
        'customer_id': customerId,
        'status': 'pending',
        'sales_staff_id': salesStaffId,
        'created_at': now.toIso8601String(),
      },
    );

    for (final item in populatedItems) {
      await _sync.queueMutation(
        actionType: 'INSERT',
        tableName: 'order_items',
        payload: {
          'id': item.id,
          'order_id': item.orderId,
          'product_id': item.productId,
          'quantity': item.quantity,
          'product_name': item.productName,
          'product_price': item.productPrice,
        },
      );
    }

    return m.Order(
      id: orderId,
      customerName: customerName,
      customerId: customerId,
      status: m.OrderStatus.pending,
      salesStaffId: salesStaffId,
      createdAt: now,
      items: populatedItems,
    );
  }

  @override
  Future<m.Customer> registerCustomer({
    required String name,
    required String region,
    required String township,
    String? address,
    required String phone,
    required String createdBy,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    await _db.into(_db.customers).insert(CustomersCompanion.insert(
      id: id,
      name: name,
      region: region,
      township: township,
      address: drift.Value(address),
      phone: phone,
      status: 'pending',
      createdBy: drift.Value(createdBy),
      createdAt: now,
    ));

    await _sync.queueMutation(
      actionType: 'INSERT',
      tableName: 'customers',
      payload: {
        'id': id,
        'name': name,
        'region': region,
        'township': township,
        'address': address,
        'phone': phone,
        'status': 'pending',
        'created_by': createdBy,
        'created_at': now.toIso8601String(),
      },
    );

    return m.Customer(
      id: id,
      name: name,
      region: region,
      township: township,
      address: address,
      phone: phone,
      status: m.CustomerStatus.pending,
      createdBy: createdBy,
      createdAt: now,
    );
  }

  @override
  Future<m.Customer> createCustomerDirect({
    required String name,
    required String region,
    required String township,
    String? address,
    required String phone,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    await _db.into(_db.customers).insert(CustomersCompanion.insert(
      id: id,
      name: name,
      region: region,
      township: township,
      address: drift.Value(address),
      phone: phone,
      status: 'approved',
      createdAt: now,
    ));

    await _sync.queueMutation(
      actionType: 'INSERT',
      tableName: 'customers',
      payload: {
        'id': id,
        'name': name,
        'region': region,
        'township': township,
        'address': address,
        'phone': phone,
        'status': 'approved',
        'created_at': now.toIso8601String(),
      },
    );

    return m.Customer(
      id: id,
      name: name,
      region: region,
      township: township,
      address: address,
      phone: phone,
      status: m.CustomerStatus.approved,
      createdAt: now,
    );
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    await (_db.delete(_db.orderItems)..where((t) => t.orderId.equals(orderId))).go();
    await (_db.delete(_db.orders)..where((t) => t.id.equals(orderId))).go();
    
    await _sync.queueMutation(
      actionType: 'DELETE',
      tableName: 'orders',
      payload: {'id': orderId},
    );
  }

  @override
  Future<void> updateOrderStatus(String orderId, m.OrderStatus status) async {
    await (_db.update(_db.orders)..where((t) => t.id.equals(orderId)))
        .write(OrdersCompanion(status: drift.Value(status.key)));

    await _sync.queueMutation(
      actionType: 'UPDATE',
      tableName: 'orders',
      payload: {
        'id': orderId,
        'status': status.key,
      },
    );
  }

  @override
  Future<void> approveCustomer(String customerId) async {
    await (_db.update(_db.customers)..where((t) => t.id.equals(customerId)))
        .write(const CustomersCompanion(status: drift.Value('approved')));

    await _sync.queueMutation(
      actionType: 'UPDATE',
      tableName: 'customers',
      payload: {
        'id': customerId,
        'status': 'approved',
      },
    );
  }

  @override
  Future<void> rejectCustomer(String customerId) async {
    await (_db.update(_db.customers)..where((t) => t.id.equals(customerId)))
        .write(const CustomersCompanion(status: drift.Value('rejected')));

    await _sync.queueMutation(
      actionType: 'UPDATE',
      tableName: 'customers',
      payload: {
        'id': customerId,
        'status': 'rejected',
      },
    );
  }

  @override
  Future<void> deleteCustomer(String customerId) async {
    await (_db.delete(_db.customers)..where((t) => t.id.equals(customerId))).go();

    await _sync.queueMutation(
      actionType: 'DELETE',
      tableName: 'customers',
      payload: {'id': customerId},
    );
  }

  // --- UNIMPLEMENTED FOR BREVITY, BUT MAINTAINING INTERFACE ---
  // (In a full migration, these would also be ported to Drift)

  @override
  Future<List<m.StockBatch>> fetchBatches() async {
    final response = await _client.from('batches').select().order('expiry_date', ascending: true);
    return (response as List).map((json) => m.StockBatch.fromJson(json)).toList();
  }

  @override
  Future<m.StockBatch> stockIn({
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
    return m.StockBatch.fromJson(response);
  }

  @override
  Future<void> fulfillOrderFEFO(String orderId) async {
    // Keep remote fulfillment logic as it relies on live batch deduction
    final orderResponse = await _client.from('orders').select('*, order_items(*, products(*))').eq('id', orderId).single();
    final order = m.Order.fromJson(orderResponse);
    if (order.status != m.OrderStatus.pending) throw Exception('Order is already fulfilled or processed.');

    final List<Map<String, dynamic>> batchUpdates = [];
    for (final item in order.items) {
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final batchesResponse = await _client.from('batches').select().eq('product_id', item.productId).gt('quantity', 0).gte('expiry_date', todayStr).order('expiry_date', ascending: true);
      final batches = (batchesResponse as List).map((json) => m.StockBatch.fromJson(json)).toList();
      int remainingQty = item.quantity;
      for (final batch in batches) {
        if (remainingQty <= 0) break;
        if (batch.quantity >= remainingQty) {
          batchUpdates.add({'id': batch.id, 'quantity': batch.quantity - remainingQty});
          remainingQty = 0;
        } else {
          remainingQty -= batch.quantity;
          batchUpdates.add({'id': batch.id, 'quantity': 0});
        }
      }
      if (remainingQty > 0) throw Exception('Insufficient stock for product.');
    }
    for (final update in batchUpdates) {
      await _client.from('batches').update({'quantity': update['quantity']}).eq('id', update['id']);
    }
    await _client.from('orders').update({'status': m.OrderStatus.packed.key}).eq('id', orderId);
  }

  @override
  Future<List<m.DisposalRequest>> fetchDisposalRequests() async {
    final response = await _client.from('disposals').select('*, products(*), batches(*), profiles(display_name)').order('created_at', ascending: false);
    return (response as List).map((json) => m.DisposalRequest.fromJson(json)).toList();
  }

  @override
  Future<m.DisposalRequest> submitDisposalRequest({
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
    return m.DisposalRequest.fromJson(response);
  }

  @override
  Future<List<m.PhysicalAudit>> fetchPhysicalAudits() async {
    final response = await _client.from('physical_audits').select('*, products(*), batches(*), profiles(display_name)').order('created_at', ascending: false);
    return (response as List).map((json) => m.PhysicalAudit.fromJson(json)).toList();
  }

  @override
  Future<m.PhysicalAudit> logPhysicalAudit({
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
    return m.PhysicalAudit.fromJson(response);
  }
}
