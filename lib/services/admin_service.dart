import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/audit_log.dart';
import '../models/product.dart';
import '../models/order.dart';

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
    try {
      // Query Supabase orders table with related order_items, products, and profiles
      final response = await _client
          .from('orders')
          .select('*, order_items(*, products(*)), profiles(display_name)')
          .order('created_at', ascending: true);

      final rawList = response as List;
      final List<Order> allOrders = rawList.map((json) => Order.fromJson(json as Map<String, dynamic>)).toList();
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
