import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/audit_log.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/disposal.dart';
import 'warehouse_service.dart';

abstract class AdminService {
  Future<List<AuditLog>> fetchAuditLogs();
  Future<void> logEvent(String action, String description, {String? actorName});
  Future<Product> addProduct(String name, String sku, double price);
  Future<void> updateProductPrice(String productId, double newPrice);
  Future<void> approveDisposal(String disposalId);
  Future<void> rejectDisposal(String disposalId);
  Future<Map<String, dynamic>> fetchSalesAnalytics({String duration = 'month'});
}

class SupabaseAdminService implements AdminService {
  final SupabaseClient _client;

  SupabaseAdminService(this._client);

  @override
  Future<List<AuditLog>> fetchAuditLogs() async {
    final response = await _client
        .from('audit_logs')
        .select('*, profiles(display_name)')
        .order('created_at', ascending: false);
    return (response as List).map((json) => AuditLog.fromJson(json)).toList();
  }

  @override
  Future<void> logEvent(String action, String description, {String? actorName}) async {
    final user = _client.auth.currentUser;
    await _client.from('audit_logs').insert({
      'actor_id': user?.id,
      'action': action,
      'description': description,
    });
  }

  @override
  Future<Product> addProduct(String name, String sku, double price) async {
    final response = await _client.from('products').insert({
      'name': name,
      'sku': sku,
      'price': price,
    }).select().single();
    
    final product = Product.fromJson(response);
    await logEvent('PRODUCT_CREATED', 'Added product ${product.name} (SKU: ${product.sku}) with price ${product.price}.');
    return product;
  }

  @override
  Future<void> updateProductPrice(String productId, double newPrice) async {
    final response = await _client
        .from('products')
        .update({'price': newPrice})
        .eq('id', productId)
        .select()
        .single();
        
    final product = Product.fromJson(response);
    await logEvent('PRICE_UPDATED', 'Updated wholesale price of ${product.name} to $newPrice.');
  }

  @override
  Future<void> approveDisposal(String disposalId) async {
    // Call the security definer RPC function to deduct batch stock and approve request in a transaction
    await _client.rpc('process_disposal_request', params: {
      'target_disposal_id': disposalId,
      'decision': 'approved',
    });
    await logEvent('DISPOSAL_APPROVED', 'Approved disposal request (ID: $disposalId).');
  }

  @override
  Future<void> rejectDisposal(String disposalId) async {
    // Call the security definer RPC function
    await _client.rpc('process_disposal_request', params: {
      'target_disposal_id': disposalId,
      'decision': 'rejected',
    });
    await logEvent('DISPOSAL_REJECTED', 'Rejected disposal request (ID: $disposalId).');
  }

  @override
  Future<Map<String, dynamic>> fetchSalesAnalytics({String duration = 'month'}) async {
    // Fetch all orders with status 'packed' or 'delivered' to aggregate sales
    final response = await _client
        .from('orders')
        .select('*, order_items(*, products(*)), profiles(display_name)')
        .or('status.eq.packed,status.eq.delivered');

    final orders = (response as List).map((json) => Order.fromJson(json)).toList();

    final Map<String, double> salesByProduct = {};
    final Map<String, double> salesByStaff = {};
    final Map<String, int> staffOrderCounts = {};
    double totalRevenue = 0.0;

    for (final order in orders) {
      // Get the sales staff displayName
      final actualStaffName = (order.toJson()['profiles']?['display_name'] as String?) ?? 'Field Staff';
      staffOrderCounts[actualStaffName] = (staffOrderCounts[actualStaffName] ?? 0) + 1;

      for (final item in order.items) {
        final productName = item.productName ?? 'Unknown';
        final revenue = item.quantity * (item.productPrice ?? 0.0);

        salesByProduct[productName] = (salesByProduct[productName] ?? 0.0) + revenue;
        salesByStaff[actualStaffName] = (salesByStaff[actualStaffName] ?? 0.0) + revenue;
        totalRevenue += revenue;
      }
    }

    return {
      'totalRevenue': totalRevenue,
      'salesByProduct': salesByProduct,
      'salesByStaff': salesByStaff,
      'staffOrderCounts': staffOrderCounts,
      'ordersCount': orders.length,
      'trendData': [
        {'label': 'Mon', 'revenue': totalRevenue * 0.15},
        {'label': 'Tue', 'revenue': totalRevenue * 0.20},
        {'label': 'Wed', 'revenue': totalRevenue * 0.18},
        {'label': 'Thu', 'revenue': totalRevenue * 0.22},
        {'label': 'Fri', 'revenue': totalRevenue * 0.25},
      ],
    };
  }
}

class MockAdminService implements AdminService {
  static final List<AuditLog> _logs = [
    AuditLog(
      id: 'l_1',
      actorId: 'sales-1',
      action: 'ORDER_SUBMITTED',
      description: 'Sales Staff Daw Hla submitted wholesale order #ORD-101 for Junction City Mart (Total: Ks 15,000).',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      actorName: 'Daw Hla (Sales Staff)',
    ),
    AuditLog(
      id: 'l_2',
      actorId: 'manager-1',
      action: 'ORDER_FULFILLED',
      description: 'Warehouse Manager U Mg Mg packed order #ORD-101 for Junction City Mart using FEFO stock allocation.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      actorName: 'U Mg Mg (Warehouse Manager)',
    ),
    AuditLog(
      id: 'l_3',
      actorId: 'sales-2',
      action: 'SHOP_REGISTERED',
      description: 'Sales Staff Ko Min requested field store registration for "Super One Mart" in Pabedan, Yangon.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      actorName: 'Ko Min (Sales Staff)',
    ),
    AuditLog(
      id: 'l_4',
      actorId: 'admin-1',
      action: 'STORE_APPROVED',
      description: 'Admin Ko Myo approved field customer store "Super One Mart" into official master dropdown.',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      actorName: 'Ko Myo (Admin)',
    ),
    AuditLog(
      id: 'l_5',
      actorId: 'manager-1',
      action: 'STOCK_IN',
      description: 'Warehouse Manager U Mg Mg recorded Stock-In for Butter Bread (Batch: #BATCH-2026-001, Qty: 200 pcs).',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      actorName: 'U Mg Mg (Warehouse Manager)',
    ),
    AuditLog(
      id: 'l_6',
      actorId: 'admin-1',
      action: 'SYSTEM_BOOTSTRAP',
      description: 'System bootstrapped with default master inventory catalog.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      actorName: 'Ko Myo (Admin)',
    ),
  ];

  @override
  Future<List<AuditLog>> fetchAuditLogs() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_logs);
  }

  @override
  Future<void> logEvent(String action, String description, {String? actorName}) async {
    _logs.insert(
      0,
      AuditLog(
        id: 'l_${DateTime.now().millisecondsSinceEpoch}',
        actorId: 'mock-actor-id',
        action: action,
        description: description,
        createdAt: DateTime.now(),
        actorName: actorName ?? 'Ko Myo (Admin)',
      ),
    );
  }

  @override
  Future<Product> addProduct(String name, String sku, double price) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final newProduct = Product(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      sku: sku,
      price: price,
      createdAt: DateTime.now(),
    );
    
    MockWarehouseService.productsList.add(newProduct);
    await logEvent('PRODUCT_CREATED', 'Added product ${newProduct.name} (SKU: ${newProduct.sku}) with price ${newProduct.price}.');
    return newProduct;
  }

  @override
  Future<void> updateProductPrice(String productId, double newPrice) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = MockWarehouseService.productsList.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final product = MockWarehouseService.productsList[index];
      MockWarehouseService.productsList[index] = product.copyWith(price: newPrice);
      await logEvent('PRICE_UPDATED', 'Updated wholesale price of ${product.name} to $newPrice.');
    }
  }

  @override
  Future<void> approveDisposal(String disposalId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final dispIndex = MockWarehouseService.disposalsList.indexWhere((d) => d.id == disposalId);
    if (dispIndex != -1) {
      final disposal = MockWarehouseService.disposalsList[dispIndex];
      // Update status
      MockWarehouseService.disposalsList[dispIndex] = DisposalRequest(
        id: disposal.id,
        productId: disposal.productId,
        batchId: disposal.batchId,
        quantity: disposal.quantity,
        reason: disposal.reason,
        status: DisposalStatus.approved,
        createdAt: disposal.createdAt,
        productName: disposal.productName,
        batchNumber: disposal.batchNumber,
        requesterName: disposal.requesterName,
      );

      // Deduct quantity from batch
      final batchIndex = MockWarehouseService.batchesList.indexWhere((b) => b.id == disposal.batchId);
      if (batchIndex != -1) {
        final batch = MockWarehouseService.batchesList[batchIndex];
        MockWarehouseService.batchesList[batchIndex] = batch.copyWith(
          quantity: (batch.quantity - disposal.quantity) < 0 ? 0 : (batch.quantity - disposal.quantity),
        );
      }

      await logEvent('DISPOSAL_APPROVED', 'Approved disposal request for ${disposal.productName} (Qty: ${disposal.quantity}).');
    }
  }

  @override
  Future<void> rejectDisposal(String disposalId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final dispIndex = MockWarehouseService.disposalsList.indexWhere((d) => d.id == disposalId);
    if (dispIndex != -1) {
      final disposal = MockWarehouseService.disposalsList[dispIndex];
      // Update status
      MockWarehouseService.disposalsList[dispIndex] = DisposalRequest(
        id: disposal.id,
        productId: disposal.productId,
        batchId: disposal.batchId,
        quantity: disposal.quantity,
        reason: disposal.reason,
        status: DisposalStatus.rejected,
        createdAt: disposal.createdAt,
        productName: disposal.productName,
        batchNumber: disposal.batchNumber,
        requesterName: disposal.requesterName,
      );
      await logEvent('DISPOSAL_REJECTED', 'Rejected disposal request for ${disposal.productName} (Qty: ${disposal.quantity}).');
    }
  }

  static void _ensureSampleOrdersSeeded() {
    if (MockWarehouseService.ordersList.length >= 10) return;

    final now = DateTime.now();
    final sampleOrders = [
      Order(
        id: 'o_seed_1',
        customerName: 'City Mart (Pabedan)',
        status: OrderStatus.delivered,
        salesStaffId: 'sales-1',
        createdAt: now.subtract(const Duration(hours: 2)),
        items: [
          OrderItem(id: 'item_1', orderId: 'o_seed_1', productId: 'p1', quantity: 20, productName: 'Butter Bread (Large)', productPrice: 1500.0),
          OrderItem(id: 'item_2', orderId: 'o_seed_1', productId: 'p2', quantity: 15, productName: 'Crispy Rusks (Mini)', productPrice: 1200.0),
        ],
      ),
      Order(
        id: 'o_seed_2',
        customerName: 'Super One Mart (Bahan)',
        status: OrderStatus.packed,
        salesStaffId: 'sales-2',
        createdAt: now.subtract(const Duration(hours: 4)),
        items: [
          OrderItem(id: 'item_3', orderId: 'o_seed_2', productId: 'p3', quantity: 10, productName: 'Chocolate Cake Slice', productPrice: 2500.0),
          OrderItem(id: 'item_4', orderId: 'o_seed_2', productId: 'p4', quantity: 25, productName: 'Banana Muffin (Pack)', productPrice: 1800.0),
        ],
      ),
      Order(
        id: 'o_seed_3',
        customerName: 'Family Market (Kamayut)',
        status: OrderStatus.delivered,
        salesStaffId: 'sales-1',
        createdAt: now.subtract(const Duration(days: 1)),
        items: [
          OrderItem(id: 'item_5', orderId: 'o_seed_3', productId: 'p1', quantity: 30, productName: 'Butter Bread (Large)', productPrice: 1500.0),
          OrderItem(id: 'item_6', orderId: 'o_seed_3', productId: 'p5', quantity: 12, productName: 'Coconut Cookie Box', productPrice: 3000.0),
        ],
      ),
      Order(
        id: 'o_seed_4',
        customerName: 'Capital Hypermarket (Thaketa)',
        status: OrderStatus.delivered,
        salesStaffId: 'sales-3',
        createdAt: now.subtract(const Duration(days: 2)),
        items: [
          OrderItem(id: 'item_7', orderId: 'o_seed_4', productId: 'p2', quantity: 40, productName: 'Crispy Rusks (Mini)', productPrice: 1200.0),
          OrderItem(id: 'item_8', orderId: 'o_seed_4', productId: 'p3', quantity: 15, productName: 'Chocolate Cake Slice', productPrice: 2500.0),
        ],
      ),
      Order(
        id: 'o_seed_5',
        customerName: 'Ocean Supercenter (Hledan)',
        status: OrderStatus.delivered,
        salesStaffId: 'sales-2',
        createdAt: now.subtract(const Duration(days: 3)),
        items: [
          OrderItem(id: 'item_9', orderId: 'o_seed_5', productId: 'p1', quantity: 50, productName: 'Butter Bread (Large)', productPrice: 1500.0),
          OrderItem(id: 'item_10', orderId: 'o_seed_5', productId: 'p4', quantity: 20, productName: 'Banana Muffin (Pack)', productPrice: 1800.0),
        ],
      ),
      Order(
        id: 'o_seed_6',
        customerName: 'Sein Gay Sar (Ahlone)',
        status: OrderStatus.delivered,
        salesStaffId: 'sales-4',
        createdAt: now.subtract(const Duration(days: 5)),
        items: [
          OrderItem(id: 'item_11', orderId: 'o_seed_6', productId: 'p5', quantity: 18, productName: 'Coconut Cookie Box', productPrice: 3000.0),
        ],
      ),
      Order(
        id: 'o_seed_7',
        customerName: 'Orange Supermarket (Yankin)',
        status: OrderStatus.delivered,
        salesStaffId: 'sales-1',
        createdAt: now.subtract(const Duration(days: 12)),
        items: [
          OrderItem(id: 'item_12', orderId: 'o_seed_7', productId: 'p1', quantity: 40, productName: 'Butter Bread (Large)', productPrice: 1500.0),
          OrderItem(id: 'item_13', orderId: 'o_seed_7', productId: 'p3', quantity: 20, productName: 'Chocolate Cake Slice', productPrice: 2500.0),
        ],
      ),
      Order(
        id: 'o_seed_8',
        customerName: 'Ruby Mart (Kyauktada)',
        status: OrderStatus.delivered,
        salesStaffId: 'sales-3',
        createdAt: now.subtract(const Duration(days: 20)),
        items: [
          OrderItem(id: 'item_14', orderId: 'o_seed_8', productId: 'p2', quantity: 50, productName: 'Crispy Rusks (Mini)', productPrice: 1200.0),
        ],
      ),
    ];

    MockWarehouseService.ordersList.addAll(sampleOrders);
  }

  @override
  Future<Map<String, dynamic>> fetchSalesAnalytics({String duration = 'month'}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _ensureSampleOrdersSeeded();

    final allOrders = MockWarehouseService.ordersList;
    final now = DateTime.now();

    final filteredOrders = allOrders.where((order) {
      final diffDays = now.difference(order.createdAt).inDays;
      if (duration == 'today') {
        return order.createdAt.year == now.year &&
            order.createdAt.month == now.month &&
            order.createdAt.day == now.day;
      } else if (duration == 'week') {
        return diffDays <= 7;
      } else if (duration == 'month') {
        return diffDays <= 30;
      }
      return true; // 'all'
    }).toList();

    final Map<String, double> salesByProduct = {};
    final Map<String, double> salesByStaff = {};
    final Map<String, int> staffOrderCounts = {};
    double totalRevenue = 0.0;

    for (final order in filteredOrders) {
      final staffName = _resolveStaffName(order.salesStaffId);
      staffOrderCounts[staffName] = (staffOrderCounts[staffName] ?? 0) + 1;

      for (final item in order.items) {
        final productName = item.productName ?? 'Unknown Snack';
        final revenue = item.quantity * (item.productPrice ?? 0.0);

        salesByProduct[productName] = (salesByProduct[productName] ?? 0.0) + revenue;
        salesByStaff[staffName] = (salesByStaff[staffName] ?? 0.0) + revenue;
        totalRevenue += revenue;
      }
    }

    final List<Map<String, dynamic>> trendData = _buildDynamicTrendData(filteredOrders, duration, now);

    final List<Map<String, dynamic>> categoryData = salesByProduct.entries.map((entry) {
      final pct = totalRevenue == 0 ? 0.0 : (entry.value / totalRevenue) * 100;
      return {
        'name': entry.key,
        'value': entry.value,
        'percentage': pct,
      };
    }).toList();

    return {
      'totalRevenue': totalRevenue,
      'salesByProduct': salesByProduct,
      'salesByStaff': salesByStaff,
      'staffOrderCounts': staffOrderCounts,
      'ordersCount': filteredOrders.length,
      'trendData': trendData,
      'categoryData': categoryData,
    };
  }

  String _resolveStaffName(String? staffId) {
    if (staffId == 'sales-1' || staffId == 's1') return 'Daw Hla (Sales Staff)';
    if (staffId == 'sales-2' || staffId == 's2') return 'Ko Min (Sales Staff)';
    if (staffId == 'sales-3' || staffId == 's3') return 'U Tun Tun (Sales Staff)';
    if (staffId == 'sales-4' || staffId == 's4') return 'Ma Su (Sales Staff)';
    return 'Field Staff (Sales)';
  }

  List<Map<String, dynamic>> _buildDynamicTrendData(List<Order> orders, String duration, DateTime now) {
    if (duration == 'today') {
      final buckets = <String, double>{
        '8 AM': 0.0,
        '10 AM': 0.0,
        '12 PM': 0.0,
        '2 PM': 0.0,
        '4 PM': 0.0,
        '6 PM': 0.0,
      };
      for (final order in orders) {
        final hour = order.createdAt.hour;
        if (hour < 9) {
          buckets['8 AM'] = (buckets['8 AM'] ?? 0) + order.totalAmount;
        } else if (hour < 11) {
          buckets['10 AM'] = (buckets['10 AM'] ?? 0) + order.totalAmount;
        } else if (hour < 13) {
          buckets['12 PM'] = (buckets['12 PM'] ?? 0) + order.totalAmount;
        } else if (hour < 15) {
          buckets['2 PM'] = (buckets['2 PM'] ?? 0) + order.totalAmount;
        } else if (hour < 17) {
          buckets['4 PM'] = (buckets['4 PM'] ?? 0) + order.totalAmount;
        } else {
          buckets['6 PM'] = (buckets['6 PM'] ?? 0) + order.totalAmount;
        }
      }
      return buckets.entries.map((e) => {'label': e.key, 'revenue': e.value}).toList();
    } else if (duration == 'week') {
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final buckets = <String, double>{for (var d in days) d: 0.0};
      for (final order in orders) {
        final dayName = days[order.createdAt.weekday - 1];
        buckets[dayName] = (buckets[dayName] ?? 0) + order.totalAmount;
      }
      return buckets.entries.map((e) => {'label': e.key, 'revenue': e.value}).toList();
    } else if (duration == 'month') {
      final buckets = <String, double>{
        'Week 1': 0.0,
        'Week 2': 0.0,
        'Week 3': 0.0,
        'Week 4': 0.0,
      };
      for (final order in orders) {
        final day = order.createdAt.day;
        if (day <= 7) {
          buckets['Week 1'] = (buckets['Week 1'] ?? 0) + order.totalAmount;
        } else if (day <= 14) {
          buckets['Week 2'] = (buckets['Week 2'] ?? 0) + order.totalAmount;
        } else if (day <= 21) {
          buckets['Week 3'] = (buckets['Week 3'] ?? 0) + order.totalAmount;
        } else {
          buckets['Week 4'] = (buckets['Week 4'] ?? 0) + order.totalAmount;
        }
      }
      return buckets.entries.map((e) => {'label': e.key, 'revenue': e.value}).toList();
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final buckets = <String, double>{for (var m in months) m: 0.0};
      for (final order in orders) {
        final mName = months[order.createdAt.month - 1];
        buckets[mName] = (buckets[mName] ?? 0) + order.totalAmount;
      }
      return buckets.entries.map((e) => {'label': e.key, 'revenue': e.value}).toList();
    }
  }
}
