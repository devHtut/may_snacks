import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../database/database.dart';

class SyncManager extends ChangeNotifier {
  SyncManager(this._db, this._client) {
    _initConnectivityListener();
  }

  final AppDatabase _db;
  final SupabaseClient _client;

  bool _isProcessing = false;
  bool _isOffline = true;
  bool _hasPendingTrigger = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool get isOffline => _isOffline;
  bool get isOnline => !_isOffline;
  bool get isProcessing => _isProcessing;

  Future<int> getPendingCount() async {
    try {
      final list = await _db.select(_db.mutations).get();
      return list.length;
    } catch (_) {
      return 0;
    }
  }

  void _initConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      final isNowOffline = results.every((r) => r == ConnectivityResult.none);
      if (_isOffline != isNowOffline) {
        _isOffline = isNowOffline;
        notifyListeners();
        if (!isNowOffline) {
          debugPrint('[SyncManager] Network transitioned from offline to online. Triggering processQueue().');
          processQueue();
        }
      }
    });
  }

  static Future<SyncManager> initialize(AppDatabase db, SupabaseClient client) async {
    final manager = SyncManager(db, client);
    LocalDatabase.syncManager = manager;

    try {
      final results = await Connectivity().checkConnectivity();
      final isOnline = results.any((r) => r != ConnectivityResult.none);
      manager._isOffline = !isOnline;

      if (isOnline) {
        debugPrint('[SyncManager] Already online at startup. Running processQueue().');
        manager.processQueue();
      } else {
        debugPrint('[SyncManager] Offline at startup. Postponing processQueue().');
      }
    } catch (e) {
      debugPrint('[SyncManager] Error checking connection during initialize: $e');
    }

    return manager;
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<bool> checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(
        const Duration(seconds: 5),
      );
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> queueMutation({
    required String actionType,
    required String tableName,
    required Map<String, dynamic> payload,
  }) async {
    final companion = MutationsCompanion.insert(
      actionType: actionType,
      remoteTable: tableName,
      payload: jsonEncode(payload),
      createdAt: Value(DateTime.now()),
    );
    await _db.into(_db.mutations).insert(companion);
    debugPrint('[SyncManager] Queued mutation: $actionType on $tableName');
    
    Future.delayed(Duration.zero, () {
      processQueue();
    });
  }

  Future<void> processQueue() async {
    if (_isProcessing) {
      _hasPendingTrigger = true;
      return;
    }
    _isProcessing = true;
    _hasPendingTrigger = false;
    notifyListeners();

    try {
      while (true) {
        final hasInternet = await checkConnectivity();
        if (!hasInternet) {
          debugPrint('[SyncManager] Offline. Postponing sync.');
          break;
        }

        final queue = await (_db.select(_db.mutations)
              ..orderBy([(t) => OrderingTerm(expression: t.id, mode: OrderingMode.asc)]))
            .get();

        if (queue.isEmpty) {
          break;
        }

        debugPrint('[SyncManager] Found ${queue.length} mutations in queue. Syncing...');

        for (final mutation in queue) {
          final Map<String, dynamic> payload =
              jsonDecode(mutation.payload) as Map<String, dynamic>;
          final String? id = payload['id']?.toString();

          try {
            if (mutation.actionType == 'INSERT') {
              dynamic response;
              try {
                response = await _client
                    .from(mutation.remoteTable)
                    .insert(payload)
                    .select('id')
                    .maybeSingle();
              } catch (_) {
                response = await _client
                    .from(mutation.remoteTable)
                    .upsert(payload)
                    .select('id')
                    .maybeSingle();
              }
              
              final serverId = response?['id']?.toString();
              final clientId = payload['id']?.toString();
              
              if (clientId != null && serverId != null && clientId != serverId) {
                debugPrint('[SyncManager] ID Mismatch detected for ${mutation.remoteTable}: Client ID = $clientId, Server ID = $serverId. Reconciling local DB and mutations queue...');
                await updateLocalIdInSQLite(mutation.remoteTable, clientId, serverId);
              }
            } else if (mutation.actionType == 'UPDATE') {
              if (id != null) {
                final updatePayload = Map<String, dynamic>.from(payload)
                  ..remove('id')
                  ..remove('created_at');
                await _client.from(mutation.remoteTable).update(updatePayload).eq('id', id);
              } else {
                throw Exception('Missing id in payload for UPDATE action on ${mutation.remoteTable}');
              }
            } else if (mutation.actionType == 'DELETE') {
              if (id != null) {
                await _client.from(mutation.remoteTable).delete().eq('id', id);
              } else {
                throw Exception('Missing id in payload for DELETE action on ${mutation.remoteTable}');
              }
            }

            await (_db.delete(_db.mutations)..where((t) => t.id.equals(mutation.id))).go();
            debugPrint('[SyncManager] Synced mutation #${mutation.id} (${mutation.actionType} on ${mutation.remoteTable})');
          } on PostgrestException catch (e) {
            debugPrint('[SyncManager] PostgrestException on mutation #${mutation.id} (${mutation.remoteTable}): $e');
            
            if (_isNetworkError(e.message)) {
              rethrow;
            } else {
              await (_db.delete(_db.mutations)..where((t) => t.id.equals(mutation.id))).go();
              debugPrint('[SyncManager] Non-network RLS/Server error on ${mutation.remoteTable}. Discarded mutation #${mutation.id}. Continuing queue processing...');
            }
          } catch (e) {
            debugPrint('[SyncManager] General error on mutation #${mutation.id}: $e');
            await (_db.delete(_db.mutations)..where((t) => t.id.equals(mutation.id))).go();
            debugPrint('[SyncManager] Discarded problematic mutation #${mutation.id}. Continuing queue processing...');
          }
        }

        if (!_hasPendingTrigger) {
          final doubleCheckQueue = await (_db.select(_db.mutations)..limit(1)).get();
          if (doubleCheckQueue.isEmpty) {
            break;
          }
        }
        _hasPendingTrigger = false;
      }
    } catch (e) {
      debugPrint('[SyncManager] Queue processing halted: $e');
    } finally {
      _isProcessing = false;
      notifyListeners();
      if (_hasPendingTrigger) {
        _hasPendingTrigger = false;
        Future.microtask(() => processQueue());
      }
    }
  }

  Future<void> clearPendingQueue() async {
    await _db.delete(_db.mutations).go();
    notifyListeners();
  }

  Future<void> waitForSync() async {
    while (_isProcessing) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    while (true) {
      final queue = await (_db.select(_db.mutations)..limit(1)).get();
      if (queue.isEmpty) {
        break;
      }
      final hasInternet = await checkConnectivity();
      if (!hasInternet) {
        break;
      }
      processQueue();
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  bool _isNetworkError(String message) {
    final lower = message.toLowerCase();
    return lower.contains('network') ||
        lower.contains('connection') ||
        lower.contains('failed to host') ||
        lower.contains('timeout') ||
        lower.contains('socket');
  }

  Future<void> updateLocalIdInSQLite(String tableName, String clientId, String serverId) async {
    await _db.transaction(() async {
      switch (tableName) {
        case 'products':
          await (_db.update(_db.products)..where((t) => t.id.equals(clientId)))
              .write(ProductsCompanion(id: Value(serverId)));
          await (_db.update(_db.batches)..where((t) => t.productId.equals(clientId)))
              .write(BatchesCompanion(productId: Value(serverId)));
          await (_db.update(_db.orderItems)..where((t) => t.productId.equals(clientId)))
              .write(OrderItemsCompanion(productId: Value(serverId)));
          await (_db.update(_db.reservedStocks)..where((t) => t.productId.equals(clientId)))
              .write(ReservedStocksCompanion(productId: Value(serverId)));
          await (_db.update(_db.disposals)..where((t) => t.productId.equals(clientId)))
              .write(DisposalsCompanion(productId: Value(serverId)));
          await (_db.update(_db.physicalAudits)..where((t) => t.productId.equals(clientId)))
              .write(PhysicalAuditsCompanion(productId: Value(serverId)));
          break;
        case 'customers':
          await (_db.update(_db.customers)..where((t) => t.id.equals(clientId)))
              .write(CustomersCompanion(id: Value(serverId)));
          await (_db.update(_db.orders)..where((t) => t.customerId.equals(clientId)))
              .write(OrdersCompanion(customerId: Value(serverId)));
          break;
        case 'orders':
          await (_db.update(_db.orders)..where((t) => t.id.equals(clientId)))
              .write(OrdersCompanion(id: Value(serverId)));
          await (_db.update(_db.orderItems)..where((t) => t.orderId.equals(clientId)))
              .write(OrderItemsCompanion(orderId: Value(serverId)));
          await (_db.update(_db.reservedStocks)..where((t) => t.orderId.equals(clientId)))
              .write(ReservedStocksCompanion(orderId: Value(serverId)));
          break;
        case 'batches':
          await (_db.update(_db.batches)..where((t) => t.id.equals(clientId)))
              .write(BatchesCompanion(id: Value(serverId)));
          await (_db.update(_db.reservedStocks)..where((t) => t.batchId.equals(clientId)))
              .write(ReservedStocksCompanion(batchId: Value(serverId)));
          await (_db.update(_db.disposals)..where((t) => t.batchId.equals(clientId)))
              .write(DisposalsCompanion(batchId: Value(serverId)));
          await (_db.update(_db.physicalAudits)..where((t) => t.batchId.equals(clientId)))
              .write(PhysicalAuditsCompanion(batchId: Value(serverId)));
          break;
        case 'order_items':
          await (_db.update(_db.orderItems)..where((t) => t.id.equals(clientId)))
              .write(OrderItemsCompanion(id: Value(serverId)));
          break;
        case 'reserved_stocks':
          await (_db.update(_db.reservedStocks)..where((t) => t.id.equals(clientId)))
              .write(ReservedStocksCompanion(id: Value(serverId)));
          break;
        case 'disposals':
          await (_db.update(_db.disposals)..where((t) => t.id.equals(clientId)))
              .write(DisposalsCompanion(id: Value(serverId)));
          break;
        case 'physical_audits':
          await (_db.update(_db.physicalAudits)..where((t) => t.id.equals(clientId)))
              .write(PhysicalAuditsCompanion(id: Value(serverId)));
          break;
      }
    });

    final remainingMutations = await _db.select(_db.mutations).get();
    for (final mutation in remainingMutations) {
      if (mutation.payload.contains(clientId)) {
        final updatedPayload = mutation.payload.replaceAll(clientId, serverId);
        await (_db.update(_db.mutations)..where((t) => t.id.equals(mutation.id)))
            .write(MutationsCompanion(payload: Value(updatedPayload)));
        debugPrint('[SyncManager] Updated pending mutation #${mutation.id} payload: replaced $clientId with $serverId');
      }
    }
  }
}
