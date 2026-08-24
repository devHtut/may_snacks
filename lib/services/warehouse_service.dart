import 'dart:convert';
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
import '../models/reserved_stock.dart' as m;
import '../database/database.dart';
import 'sync_manager.dart';

abstract class WarehouseService {
  Future<List<m.Product>> fetchProducts();
  Future<List<m.ReservedStock>> fetchReservedStocks();
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
      final pendingMutations = await _db.select(_db.mutations).get();
      final Set<String> pendingCustomerIds = {};
      for (final m in pendingMutations) {
        if (m.remoteTable == 'customers') {
          try {
            final payload = jsonDecode(m.payload) as Map<String, dynamic>;
            if (payload['id'] != null) {
              pendingCustomerIds.add(payload['id'].toString());
            }
          } catch (_) {}
        }
      }

      await _db.transaction(() async {
        for (final row in response as List) {
          final id = row['id'].toString();
          if (pendingCustomerIds.contains(id)) continue;

          await _db.into(_db.customers).insertOnConflictUpdate(CustomersCompanion.insert(
            id: id,
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
      final pendingMutations = await _db.select(_db.mutations).get();
      final Set<String> pendingOrderIds = {};
      for (final m in pendingMutations) {
        if (m.remoteTable == 'orders') {
          try {
            final payload = jsonDecode(m.payload) as Map<String, dynamic>;
            if (payload['id'] != null) {
              pendingOrderIds.add(payload['id'].toString());
            }
          } catch (_) {}
        }
      }

      await _db.transaction(() async {
        for (final row in response as List) {
          final id = row['id'].toString();
          if (pendingOrderIds.contains(id)) continue;

          await _db.into(_db.orders).insertOnConflictUpdate(OrdersCompanion.insert(
            id: id,
            customerName: row['customer_name'],
            customerId: drift.Value(row['customer_id']),
            status: row['status'] ?? 'pending',
            salesStaffId: drift.Value(row['sales_staff_id']),
            createdAt: DateTime.parse(row['created_at']).toUtc(),
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

  Future<void> _syncReservedStocksDown() async {
    try {
      final response = await _client.from('reserved_stocks').select();
      final List responseList = response as List;
      final Set<String> serverIds = responseList.map((row) => row['id'].toString()).toSet();

      final pendingMutations = await _db.select(_db.mutations).get();
      final Set<String> pendingReservedIds = {};
      for (final m in pendingMutations) {
        if (m.remoteTable == 'reserved_stocks') {
          try {
            final payload = jsonDecode(m.payload) as Map<String, dynamic>;
            if (payload['id'] != null) {
              pendingReservedIds.add(payload['id'].toString());
            }
          } catch (_) {}
        }
      }

      final Set<String> validIds = {...serverIds, ...pendingReservedIds};

      await _db.transaction(() async {
        for (final row in responseList) {
          await _db.into(_db.reservedStocks).insertOnConflictUpdate(ReservedStocksCompanion.insert(
            id: row['id'],
            orderId: row['order_id'],
            productId: row['product_id'],
            batchId: drift.Value(row['batch_id']),
            quantity: row['quantity'],
            status: row['status'] ?? 'active',
            createdAt: DateTime.parse(row['created_at']),
          ));
        }

        if (validIds.isNotEmpty) {
          await (_db.delete(_db.reservedStocks)..where((t) => t.id.isNotIn(validIds))).go();
        }
      });
    } on PostgrestException catch (e) {
      debugPrint('[WarehouseService] Supabase reserved_stocks table missing/sync pending: ${e.message}');
    } catch (e) {
      debugPrint('Error syncing reserved_stocks down: $e');
    }
  }

  Future<void> _syncBatchesDown() async {
    try {
      final response = await _client.from('batches').select();
      await _db.transaction(() async {
        for (final row in response as List) {
          await _db.into(_db.batches).insertOnConflictUpdate(BatchesCompanion.insert(
            id: row['id'],
            productId: row['product_id'],
            batchNumber: row['batch_number'],
            quantity: row['quantity'],
            initialQuantity: row['initial_quantity'],
            expiryDate: DateTime.parse(row['expiry_date']),
            receivedDate: DateTime.parse(row['received_date']),
            createdAt: DateTime.parse(row['created_at']),
          ));
        }
      });
    } catch (e) {
      debugPrint('[WarehouseService] Error syncing batches down: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // IMPLEMENTATION
  // ---------------------------------------------------------------------------

  @override
  Future<List<m.ReservedStock>> fetchReservedStocks() async {
    _syncReservedStocksDown();

    try {
      final rows = await (_db.select(_db.reservedStocks)..orderBy([(t) => drift.OrderingTerm.desc(t.createdAt)])).get();
      return rows.map((r) => m.ReservedStock(
        id: r.id,
        orderId: r.orderId,
        productId: r.productId,
        batchId: r.batchId,
        quantity: r.quantity,
        status: r.status,
        createdAt: r.createdAt,
      )).toList();
    } catch (e) {
      debugPrint('[WarehouseService] Error reading local reservedStocks: $e');
      return [];
    }
  }

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
    final now = DateTime.now().toUtc();

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

    final List<Map<String, dynamic>> reservedStockPayloads = [];

    for (final item in populatedItems) {
      final reservedId = _uuid.v4();
      await _db.into(_db.reservedStocks).insert(ReservedStocksCompanion.insert(
        id: reservedId,
        orderId: orderId,
        productId: item.productId,
        quantity: item.quantity,
        status: 'active',
        createdAt: now,
      ));

      reservedStockPayloads.add({
        'id': reservedId,
        'order_id': orderId,
        'product_id': item.productId,
        'quantity': item.quantity,
        'status': 'active',
        'created_at': now.toIso8601String(),
      });
    }

    // 1. Queue Parent 'orders' mutation FIRST (so FK exists on Supabase when child tables sync)
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

    // 2. Queue Child 'order_items' mutation SECOND
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

    // 3. Queue Child 'reserved_stocks' mutation THIRD (after parent orders exists on Supabase)
    for (final payload in reservedStockPayloads) {
      await _sync.queueMutation(
        actionType: 'INSERT',
        tableName: 'reserved_stocks',
        payload: payload,
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
    final reservedRows = await (_db.select(_db.reservedStocks)..where((t) => t.orderId.equals(orderId))).get();
    await (_db.update(_db.reservedStocks)..where((t) => t.orderId.equals(orderId)))
        .write(const ReservedStocksCompanion(status: drift.Value('released')));
    await (_db.update(_db.orders)..where((t) => t.id.equals(orderId)))
        .write(const OrdersCompanion(status: drift.Value('cancelled')));

    await _sync.queueMutation(
      actionType: 'UPDATE',
      tableName: 'orders',
      payload: {'id': orderId, 'status': 'cancelled'},
    );

    for (final r in reservedRows) {
      await _sync.queueMutation(
        actionType: 'UPDATE',
        tableName: 'reserved_stocks',
        payload: {'id': r.id, 'status': 'released'},
      );
    }
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
    _syncBatchesDown();

    try {
      final rows = await (_db.select(_db.batches)..orderBy([(t) => drift.OrderingTerm.asc(t.expiryDate)])).get();
      return rows.map((r) => m.StockBatch(
        id: r.id,
        productId: r.productId,
        batchNumber: r.batchNumber,
        quantity: r.quantity,
        initialQuantity: r.initialQuantity,
        expiryDate: r.expiryDate,
        receivedDate: r.receivedDate,
        createdAt: r.createdAt,
      )).toList();
    } catch (e) {
      debugPrint('[WarehouseService] Error reading local batches: $e');
      return [];
    }
  }

  @override
  Future<m.StockBatch> stockIn({
    required String productId,
    required String batchNumber,
    required int quantity,
    required DateTime expiryDate,
  }) async {
    final batchId = _uuid.v4();
    final now = DateTime.now();

    await _db.into(_db.batches).insert(BatchesCompanion.insert(
      id: batchId,
      productId: productId,
      batchNumber: batchNumber,
      quantity: quantity,
      initialQuantity: quantity,
      expiryDate: expiryDate,
      receivedDate: now,
      createdAt: now,
    ));

    await _sync.queueMutation(
      actionType: 'INSERT',
      tableName: 'batches',
      payload: {
        'id': batchId,
        'product_id': productId,
        'batch_number': batchNumber,
        'quantity': quantity,
        'initial_quantity': quantity,
        'expiry_date': expiryDate.toIso8601String().substring(0, 10),
        'received_date': now.toIso8601String().substring(0, 10),
      },
    );

    return m.StockBatch(
      id: batchId,
      productId: productId,
      batchNumber: batchNumber,
      quantity: quantity,
      initialQuantity: quantity,
      expiryDate: expiryDate,
      receivedDate: now,
      createdAt: now,
    );
  }

  @override
  Future<void> fulfillOrderFEFO(String orderId) async {
    final orderRow = await (_db.select(_db.orders)..where((t) => t.id.equals(orderId))).getSingleOrNull();
    if (orderRow == null) throw Exception('Order not found in local database.');
    if (orderRow.status != m.OrderStatus.pending.key) throw Exception('Order is already fulfilled or processed.');

    final itemRows = await (_db.select(_db.orderItems)..where((t) => t.orderId.equals(orderId))).get();
    if (itemRows.isEmpty) throw Exception('Order contains no items.');

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    await _db.transaction(() async {
      for (final item in itemRows) {
        final batchRows = await (_db.select(_db.batches)
              ..where((t) => t.productId.equals(item.productId) & t.quantity.isBiggerThanValue(0) & t.expiryDate.isBiggerOrEqualValue(today))
              ..orderBy([(t) => drift.OrderingTerm.asc(t.expiryDate)]))
            .get();

        int remainingQty = item.quantity;
        for (final batch in batchRows) {
          if (remainingQty <= 0) break;
          if (batch.quantity >= remainingQty) {
            final newQty = batch.quantity - remainingQty;
            await (_db.update(_db.batches)..where((t) => t.id.equals(batch.id)))
                .write(BatchesCompanion(quantity: drift.Value(newQty)));
            remainingQty = 0;
            try {
              await _client.from('batches').update({'quantity': newQty}).eq('id', batch.id);
            } catch (_) {}
          } else {
            remainingQty -= batch.quantity;
            await (_db.update(_db.batches)..where((t) => t.id.equals(batch.id)))
                .write(const BatchesCompanion(quantity: drift.Value(0)));
            try {
              await _client.from('batches').update({'quantity': 0}).eq('id', batch.id);
            } catch (_) {}
          }
        }

        if (remainingQty > 0) {
          throw Exception('Insufficient stock for product in warehouse batches.');
        }
      }

      await (_db.update(_db.orders)..where((t) => t.id.equals(orderId)))
          .write(OrdersCompanion(status: drift.Value(m.OrderStatus.packed.key)));
      try {
        await _client.from('orders').update({'status': m.OrderStatus.packed.key}).eq('id', orderId);
      } catch (_) {}

      await (_db.update(_db.reservedStocks)..where((t) => t.orderId.equals(orderId)))
          .write(const ReservedStocksCompanion(status: drift.Value('fulfilled')));
      try {
        await _client.from('reserved_stocks').update({'status': 'fulfilled'}).eq('order_id', orderId);
      } catch (_) {}
    });
  }

  Future<void> _syncDisposalsDown() async {
    try {
      final response = await _client.from('disposals').select();
      await _db.transaction(() async {
        for (final row in response as List) {
          await _db.into(_db.disposals).insertOnConflictUpdate(DisposalsCompanion.insert(
            id: row['id'],
            productId: row['product_id'],
            batchId: row['batch_id'],
            quantity: row['quantity'],
            reason: row['reason'] ?? '',
            status: row['status'] ?? 'pending',
            requestedBy: drift.Value(row['requested_by']),
            createdAt: DateTime.parse(row['created_at']),
          ));
        }
      });
    } catch (e) {
      debugPrint('[WarehouseService] Error syncing disposals down: $e');
    }
  }

  Future<void> _syncPhysicalAuditsDown() async {
    try {
      final response = await _client.from('physical_audits').select();
      await _db.transaction(() async {
        for (final row in response as List) {
          await _db.into(_db.physicalAudits).insertOnConflictUpdate(PhysicalAuditsCompanion.insert(
            id: row['id'],
            productId: row['product_id'],
            batchId: row['batch_id'],
            systemQuantity: row['system_quantity'],
            physicalQuantity: row['physical_quantity'],
            discrepancy: row['discrepancy'],
            notes: drift.Value(row['notes']),
            auditedBy: drift.Value(row['audited_by']),
            createdAt: DateTime.parse(row['created_at']),
          ));
        }
      });
    } catch (e) {
      debugPrint('[WarehouseService] Error syncing physicalAudits down: $e');
    }
  }

  @override
  Future<List<m.DisposalRequest>> fetchDisposalRequests() async {
    _syncDisposalsDown();

    try {
      final rows = await (_db.select(_db.disposals)..orderBy([(t) => drift.OrderingTerm.desc(t.createdAt)])).get();
      final products = await _db.select(_db.products).get();
      final batches = await _db.select(_db.batches).get();

      return rows.map((r) {
        final pList = products.where((p) => p.id == r.productId);
        final bList = batches.where((b) => b.id == r.batchId);
        final productName = pList.isNotEmpty ? pList.first.name : null;
        final batchNumber = bList.isNotEmpty ? bList.first.batchNumber : null;

        return m.DisposalRequest(
          id: r.id,
          productId: r.productId,
          batchId: r.batchId,
          quantity: r.quantity,
          reason: r.reason,
          status: m.DisposalStatus.fromKey(r.status),
          requestedBy: r.requestedBy,
          createdAt: r.createdAt,
          productName: productName,
          batchNumber: batchNumber,
          requesterName: 'Warehouse Manager',
        );
      }).toList();
    } catch (e) {
      debugPrint('[WarehouseService] Error reading local disposals: $e');
      return [];
    }
  }

  @override
  Future<m.DisposalRequest> submitDisposalRequest({
    required String productId,
    required String batchId,
    required int quantity,
    required String reason,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final currentUser = _client.auth.currentUser;

    final pRows = await (_db.select(_db.products)..where((t) => t.id.equals(productId))).get();
    final bRows = await (_db.select(_db.batches)..where((t) => t.id.equals(batchId))).get();
    final productName = pRows.isNotEmpty ? pRows.first.name : null;
    final batchNumber = bRows.isNotEmpty ? bRows.first.batchNumber : null;

    await _db.into(_db.disposals).insert(DisposalsCompanion.insert(
      id: id,
      productId: productId,
      batchId: batchId,
      quantity: quantity,
      reason: reason,
      status: 'pending',
      requestedBy: drift.Value(currentUser?.id),
      createdAt: now,
    ));

    await _sync.queueMutation(
      actionType: 'INSERT',
      tableName: 'disposals',
      payload: {
        'id': id,
        'product_id': productId,
        'batch_id': batchId,
        'quantity': quantity,
        'reason': reason,
        'requested_by': currentUser?.id,
        'status': 'pending',
        'created_at': now.toIso8601String(),
      },
    );

    return m.DisposalRequest(
      id: id,
      productId: productId,
      batchId: batchId,
      quantity: quantity,
      reason: reason,
      status: m.DisposalStatus.pending,
      requestedBy: currentUser?.id,
      createdAt: now,
      productName: productName,
      batchNumber: batchNumber,
      requesterName: 'Warehouse Manager',
    );
  }

  @override
  Future<List<m.PhysicalAudit>> fetchPhysicalAudits() async {
    _syncPhysicalAuditsDown();

    try {
      final rows = await (_db.select(_db.physicalAudits)..orderBy([(t) => drift.OrderingTerm.desc(t.createdAt)])).get();
      final products = await _db.select(_db.products).get();
      final batches = await _db.select(_db.batches).get();

      return rows.map((r) {
        final pList = products.where((p) => p.id == r.productId);
        final bList = batches.where((b) => b.id == r.batchId);
        final productName = pList.isNotEmpty ? pList.first.name : null;
        final batchNumber = bList.isNotEmpty ? bList.first.batchNumber : null;

        return m.PhysicalAudit(
          id: r.id,
          productId: r.productId,
          batchId: r.batchId,
          systemQuantity: r.systemQuantity,
          physicalQuantity: r.physicalQuantity,
          discrepancy: r.discrepancy,
          notes: r.notes,
          auditedBy: r.auditedBy,
          createdAt: r.createdAt,
          productName: productName,
          batchNumber: batchNumber,
          auditorName: 'Warehouse Manager',
        );
      }).toList();
    } catch (e) {
      debugPrint('[WarehouseService] Error reading local physicalAudits: $e');
      return [];
    }
  }

  @override
  Future<m.PhysicalAudit> logPhysicalAudit({
    required String productId,
    required String batchId,
    required int systemQuantity,
    required int physicalQuantity,
    String? notes,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final currentUser = _client.auth.currentUser;
    final discrepancy = physicalQuantity - systemQuantity;

    final pRows = await (_db.select(_db.products)..where((t) => t.id.equals(productId))).get();
    final bRows = await (_db.select(_db.batches)..where((t) => t.id.equals(batchId))).get();
    final productName = pRows.isNotEmpty ? pRows.first.name : null;
    final batchNumber = bRows.isNotEmpty ? bRows.first.batchNumber : null;

    await _db.into(_db.physicalAudits).insert(PhysicalAuditsCompanion.insert(
      id: id,
      productId: productId,
      batchId: batchId,
      systemQuantity: systemQuantity,
      physicalQuantity: physicalQuantity,
      discrepancy: discrepancy,
      notes: drift.Value(notes),
      auditedBy: drift.Value(currentUser?.id),
      createdAt: now,
    ));

    await _sync.queueMutation(
      actionType: 'INSERT',
      tableName: 'physical_audits',
      payload: {
        'id': id,
        'product_id': productId,
        'batch_id': batchId,
        'system_quantity': systemQuantity,
        'physical_quantity': physicalQuantity,
        'discrepancy': discrepancy,
        'notes': notes,
        'audited_by': currentUser?.id,
        'created_at': now.toIso8601String(),
      },
    );

    return m.PhysicalAudit(
      id: id,
      productId: productId,
      batchId: batchId,
      systemQuantity: systemQuantity,
      physicalQuantity: physicalQuantity,
      discrepancy: discrepancy,
      notes: notes,
      auditedBy: currentUser?.id,
      createdAt: now,
      productName: productName,
      batchNumber: batchNumber,
      auditorName: 'Warehouse Manager',
    );
  }
}
