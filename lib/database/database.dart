import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../services/sync_manager.dart';

part 'database.g.dart';

class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get sku => text()();
  RealColumn get price => real()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Batches extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text()();
  TextColumn get batchNumber => text()();
  IntColumn get quantity => integer()();
  IntColumn get initialQuantity => integer()();
  DateTimeColumn get expiryDate => dateTime()();
  DateTimeColumn get receivedDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Orders extends Table {
  TextColumn get id => text()();
  TextColumn get customerName => text()();
  TextColumn get customerId => text().nullable()();
  TextColumn get status => text()();
  TextColumn get salesStaffId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class OrderItems extends Table {
  TextColumn get id => text()();
  TextColumn get orderId => text()();
  TextColumn get productId => text()();
  IntColumn get quantity => integer()();
  TextColumn get productName => text().nullable()();
  RealColumn get productPrice => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get region => text()();
  TextColumn get township => text()();
  TextColumn get address => text().nullable()();
  TextColumn get phone => text()();
  TextColumn get status => text()();
  TextColumn get createdBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Disposals extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text()();
  TextColumn get batchId => text()();
  IntColumn get quantity => integer()();
  TextColumn get reason => text()();
  TextColumn get status => text()();
  TextColumn get requestedBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class PhysicalAudits extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text()();
  TextColumn get batchId => text()();
  IntColumn get systemQuantity => integer()();
  IntColumn get physicalQuantity => integer()();
  IntColumn get discrepancy => integer()();
  TextColumn get notes => text().nullable()();
  TextColumn get auditedBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Mutations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get actionType => text()();
  TextColumn get remoteTable => text().named('table_name')();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [
  Products,
  Batches,
  Orders,
  OrderItems,
  Customers,
  Disposals,
  PhysicalAudits,
  Mutations,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'may_snacks_local.db'));
    return NativeDatabase(file);
  });
}

class LocalDatabase {
  static late final AppDatabase instance;
  static late final SyncManager syncManager;

  static Future<void> initialize() async {
    instance = AppDatabase();
  }
}
