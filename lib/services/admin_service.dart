import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import '../models/audit_log.dart' as m;
import '../models/product.dart' as m;
import '../models/order.dart' as m;
import '../database/database.dart';
import 'sync_manager.dart';

abstract class AdminService {
  Future<List<m.AuditLog>> fetchAuditLogs();
  Future<void> logEvent(String action, String description, {String? actorName});
  Future<m.Product> addProduct(String name, String sku, double price);
  Future<void> updateProductPrice(String productId, double newPrice);
  Future<void> deleteProduct(String productId);
  Future<void> approveDisposal(String disposalId);
  Future<void> rejectDisposal(String disposalId);
  Future<Map<String, dynamic>> fetchSalesAnalytics({String duration = 'month'});
}

class SupabaseAdminService implements AdminService {
  final SupabaseClient _client;
  final _uuid = const Uuid();

  SupabaseAdminService(this._client);

  AppDatabase get _db => LocalDatabase.instance;
  SyncManager get _sync => LocalDatabase.syncManager;

  Future<void> _syncAuditLogsDown() async {
    try {
      final response = await _client
          .from('audit_logs')
          .select('*, profiles(display_name)')
          .order('created_at', ascending: false)
          .limit(500);

      await _db.transaction(() async {
        for (final row in response as List) {
          await _db.into(_db.auditLogs).insertOnConflictUpdate(AuditLogsCompanion.insert(
            id: row['id'] ?? _uuid.v4(),
            actorId: drift.Value(row['actor_id'] as String?),
            action: row['action'] ?? 'UNKNOWN',
            description: row['description'] ?? '',
            createdAt: DateTime.parse(row['created_at']),
          ));
        }
      });
    } catch (e) {
      debugPrint('[AdminService] Error syncing audit logs down: $e');
    }
  }

  @override
  Future<List<m.AuditLog>> fetchAuditLogs() async {
    _syncAuditLogsDown();

    try {
      final rows = await (_db.select(_db.auditLogs)
            ..orderBy([(t) => drift.OrderingTerm.desc(t.createdAt)])
            ..limit(500))
          .get();

      return rows
          .map((r) => m.AuditLog(
                id: r.id,
                actorId: r.actorId,
                action: r.action,
                description: r.description,
                createdAt: r.createdAt,
              ))
          .toList();
    } catch (e) {
      debugPrint('[AdminService] Error reading local audit logs: $e');
      return [];
    }
  }

  @override
  Future<void> logEvent(String action, String description, {String? actorName}) async {
    try {
      final user = _client.auth.currentUser;
      final id = _uuid.v4();
      final now = DateTime.now();

      await _db.into(_db.auditLogs).insert(AuditLogsCompanion.insert(
        id: id,
        actorId: drift.Value(user?.id),
        action: action,
        description: description,
        createdAt: now,
      ));

      await _sync.queueMutation(
        actionType: 'INSERT',
        tableName: 'audit_logs',
        payload: {
          'id': id,
          'actor_id': user?.id,
          'action': action,
          'description': description,
          'created_at': now.toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('[AdminService] Local audit log error (handled): $e');
    }
  }

  @override
  Future<m.Product> addProduct(String name, String sku, double price) async {
    final response = await _client.from('products').insert({
      'name': name,
      'sku': sku,
      'price': price,
    }).select().single();
    
    final product = m.Product.fromJson(response);
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
        
    final product = m.Product.fromJson(response);
    await logEvent('PRICE_UPDATED', 'Updated wholesale price of ${product.name} to $newPrice.');
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await (_db.delete(_db.products)..where((t) => t.id.equals(productId))).go();
    try {
      await _client.from('products').delete().eq('id', productId);
    } catch (_) {}

    await _sync.queueMutation(
      actionType: 'DELETE',
      tableName: 'products',
      payload: {'id': productId},
    );
    await logEvent('PRODUCT_DELETED', 'Deleted unused product from catalog (ID: $productId).');
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
    try {
      // Query Supabase orders table with related order_items, products, and profiles
      final response = await _client
          .from('orders')
          .select('*, order_items(*, products(*)), profiles(display_name)')
          .order('created_at', ascending: true);

      final rawList = response as List;
      final List<m.Order> allOrders = rawList.map((json) => m.Order.fromJson(json as Map<String, dynamic>)).toList();
      final now = DateTime.now();

      // Filter orders by requested duration
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
        final rawItem = rawList.cast<Map<String, dynamic>?>().firstWhere(
          (element) => element != null && element['id'] == order.id,
          orElse: () => null,
        );

        final actualStaffName = (rawItem?['profiles']?['display_name'] as String?) ??
            _resolveStaffName(order.salesStaffId);

        staffOrderCounts[actualStaffName] = (staffOrderCounts[actualStaffName] ?? 0) + 1;

        for (final item in order.items) {
          final productName = item.productName ?? 'Unknown Snack';
          final revenue = item.quantity * (item.productPrice ?? 0.0);

          salesByProduct[productName] = (salesByProduct[productName] ?? 0.0) + revenue;
          salesByStaff[actualStaffName] = (salesByStaff[actualStaffName] ?? 0.0) + revenue;
          totalRevenue += revenue;
        }
      }

      // Dynamic Time-series trend data from real Supabase order timestamps
      final List<Map<String, dynamic>> trendData = _buildDynamicTrendData(filteredOrders, duration, now);

      // Dynamic Product Category Data for Pie/Donut Chart
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
    } catch (e) {
      // In case Supabase table is empty or query fails, return empty dataset
      return {
        'totalRevenue': 0.0,
        'salesByProduct': {},
        'salesByStaff': {},
        'staffOrderCounts': {},
        'ordersCount': 0,
        'trendData': [],
        'categoryData': [],
      };
    }
  }
}

String _resolveStaffName(String? staffId) {
  if (staffId == 'sales-1' || staffId == 's1') return 'Daw Hla (Sales Staff)';
  if (staffId == 'sales-2' || staffId == 's2') return 'Ko Min (Sales Staff)';
  if (staffId == 'sales-3' || staffId == 's3') return 'U Tun Tun (Sales Staff)';
  if (staffId == 'sales-4' || staffId == 's4') return 'Ma Su (Sales Staff)';
  return 'Field Staff (Sales)';
}

List<Map<String, dynamic>> _buildDynamicTrendData(List<m.Order> orders, String duration, DateTime now) {
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
