import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/customer.dart';

class OfflineStorageService {
  static final OfflineStorageService instance = OfflineStorageService._internal();

  OfflineStorageService._internal();

  Directory? _storageDir;

  Future<Directory> _getStorageDirectory() async {
    if (_storageDir != null) return _storageDir!;
    
    // Cross-platform application storage directory (Android, iOS, Windows, macOS)
    final sysDir = Directory.systemTemp;
    final appDir = Directory('${sysDir.path}/may_snacks_offline_db');
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    _storageDir = appDir;
    return _storageDir!;
  }

  Future<File> _getFile(String filename) async {
    final dir = await _getStorageDirectory();
    return File('${dir.path}/$filename');
  }

  // --- Products Cache ---
  Future<void> saveProductsCache(List<Product> products) async {
    try {
      final file = await _getFile('cached_products.json');
      final jsonList = products.map((p) => p.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error writing products cache: $e');
    }
  }

  Future<List<Product>> loadProductsCache() async {
    try {
      final file = await _getFile('cached_products.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        return jsonList.map((j) => Product.fromJson(j as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('Error loading products cache: $e');
    }
    return [];
  }

  // --- Customers Cache ---
  Future<void> saveCustomersCache(List<Customer> customers) async {
    try {
      final file = await _getFile('cached_customers.json');
      final jsonList = customers.map((c) => c.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error writing customers cache: $e');
    }
  }

  Future<List<Customer>> loadCustomersCache() async {
    try {
      final file = await _getFile('cached_customers.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        return jsonList.map((j) => Customer.fromJson(j as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('Error loading customers cache: $e');
    }
    return [];
  }

  // --- Offline Orders Queue ---
  Future<void> saveOfflineOrdersQueue(List<Order> orders) async {
    try {
      final file = await _getFile('offline_orders_queue.json');
      final jsonList = orders.map((o) {
        final map = o.toJson();
        map['items'] = o.items.map((i) => i.toJson()).toList();
        return map;
      }).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error writing offline orders queue: $e');
    }
  }

  Future<List<Order>> loadOfflineOrdersQueue() async {
    try {
      final file = await _getFile('offline_orders_queue.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        return jsonList.map((j) {
          final itemsRaw = j['items'] as List<dynamic>?;
          return Order.fromJson(j as Map<String, dynamic>, itemsRaw);
        }).toList();
      }
    } catch (e) {
      debugPrint('Error loading offline orders queue: $e');
    }
    return [];
  }
}
