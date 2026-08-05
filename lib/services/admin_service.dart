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
  Future<Map<String, dynamic>> fetchSalesAnalytics();
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
  Future<Map<String, dynamic>> fetchSalesAnalytics() async {
    // Fetch all orders with status 'packed' or 'delivered' to aggregate sales
    final response = await _client
        .from('orders')
        .select('*, order_items(*, products(*)), profiles(display_name)')
        .or('status.eq.packed,status.eq.delivered');

    final orders = (response as List).map((json) => Order.fromJson(json)).toList();

    final Map<String, double> salesByProduct = {};
    final Map<String, double> salesByStaff = {};
    double totalRevenue = 0.0;

    for (final order in orders) {
      // Get the sales staff displayName
      final actualStaffName = (order.toJson()['profiles']?['display_name'] as String?) ?? 'Field Staff';

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
      'ordersCount': orders.length,
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

  @override
  Future<Map<String, dynamic>> fetchSalesAnalytics() async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final orders = MockWarehouseService.ordersList.where((o) => o.status == OrderStatus.packed || o.status == OrderStatus.delivered).toList();
    
    final Map<String, double> salesByProduct = {};
    final Map<String, double> salesByStaff = {};
    double totalRevenue = 0.0;

    for (final order in orders) {
      final staffName = 'Field Staff';

      for (final item in order.items) {
        final productName = item.productName ?? 'Unknown';
        final revenue = item.quantity * (item.productPrice ?? 0.0);

        salesByProduct[productName] = (salesByProduct[productName] ?? 0.0) + revenue;
        salesByStaff[staffName] = (salesByStaff[staffName] ?? 0.0) + revenue;
        totalRevenue += revenue;
      }
    }

    // fallback in case no orders are packed/delivered yet, to avoid showing blank charts
    if (totalRevenue == 0) {
      salesByProduct['Butter Bread'] = 75000.0;
      salesByProduct['Crispy Rusks (Mini)'] = 24000.0;
      salesByProduct['Chocolate Cake Slice'] = 12000.0;

      salesByStaff['Field Staff'] = 111000.0;
      totalRevenue = 111000.0;
    }

    return {
      'totalRevenue': totalRevenue,
      'salesByProduct': salesByProduct,
      'salesByStaff': salesByStaff,
      'ordersCount': orders.isEmpty ? 3 : orders.length,
    };
  }
}
