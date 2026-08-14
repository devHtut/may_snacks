// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProductsTable extends Products with TableInfo<$ProductsTable, Product> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
    'sku',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, sku, price, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<Product> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sku')) {
      context.handle(
        _skuMeta,
        sku.isAcceptableOrUnknown(data['sku']!, _skuMeta),
      );
    } else if (isInserting) {
      context.missing(_skuMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Product map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Product(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sku: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class Product extends DataClass implements Insertable<Product> {
  final String id;
  final String name;
  final String sku;
  final double price;
  final DateTime createdAt;
  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['sku'] = Variable<String>(sku);
    map['price'] = Variable<double>(price);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      name: Value(name),
      sku: Value(sku),
      price: Value(price),
      createdAt: Value(createdAt),
    );
  }

  factory Product.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sku: serializer.fromJson<String>(json['sku']),
      price: serializer.fromJson<double>(json['price']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sku': serializer.toJson<String>(sku),
      'price': serializer.toJson<double>(price),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? sku,
    double? price,
    DateTime? createdAt,
  }) => Product(
    id: id ?? this.id,
    name: name ?? this.name,
    sku: sku ?? this.sku,
    price: price ?? this.price,
    createdAt: createdAt ?? this.createdAt,
  );
  Product copyWithCompanion(ProductsCompanion data) {
    return Product(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sku: data.sku.present ? data.sku.value : this.sku,
      price: data.price.present ? data.price.value : this.price,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sku: $sku, ')
          ..write('price: $price, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, sku, price, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.name == this.name &&
          other.sku == this.sku &&
          other.price == this.price &&
          other.createdAt == this.createdAt);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> sku;
  final Value<double> price;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sku = const Value.absent(),
    this.price = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    required String name,
    required String sku,
    required double price,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       sku = Value(sku),
       price = Value(price),
       createdAt = Value(createdAt);
  static Insertable<Product> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? sku,
    Expression<double>? price,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sku != null) 'sku': sku,
      if (price != null) 'price': price,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? sku,
    Value<double>? price,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sku: $sku, ')
          ..write('price: $price, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BatchesTable extends Batches with TableInfo<$BatchesTable, Batche> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchNumberMeta = const VerificationMeta(
    'batchNumber',
  );
  @override
  late final GeneratedColumn<String> batchNumber = GeneratedColumn<String>(
    'batch_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _initialQuantityMeta = const VerificationMeta(
    'initialQuantity',
  );
  @override
  late final GeneratedColumn<int> initialQuantity = GeneratedColumn<int>(
    'initial_quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiryDateMeta = const VerificationMeta(
    'expiryDate',
  );
  @override
  late final GeneratedColumn<DateTime> expiryDate = GeneratedColumn<DateTime>(
    'expiry_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedDateMeta = const VerificationMeta(
    'receivedDate',
  );
  @override
  late final GeneratedColumn<DateTime> receivedDate = GeneratedColumn<DateTime>(
    'received_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    batchNumber,
    quantity,
    initialQuantity,
    expiryDate,
    receivedDate,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'batches';
  @override
  VerificationContext validateIntegrity(
    Insertable<Batche> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('batch_number')) {
      context.handle(
        _batchNumberMeta,
        batchNumber.isAcceptableOrUnknown(
          data['batch_number']!,
          _batchNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_batchNumberMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('initial_quantity')) {
      context.handle(
        _initialQuantityMeta,
        initialQuantity.isAcceptableOrUnknown(
          data['initial_quantity']!,
          _initialQuantityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_initialQuantityMeta);
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
        _expiryDateMeta,
        expiryDate.isAcceptableOrUnknown(data['expiry_date']!, _expiryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_expiryDateMeta);
    }
    if (data.containsKey('received_date')) {
      context.handle(
        _receivedDateMeta,
        receivedDate.isAcceptableOrUnknown(
          data['received_date']!,
          _receivedDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_receivedDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Batche map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Batche(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      batchNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_number'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      initialQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}initial_quantity'],
      )!,
      expiryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expiry_date'],
      )!,
      receivedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BatchesTable createAlias(String alias) {
    return $BatchesTable(attachedDatabase, alias);
  }
}

class Batche extends DataClass implements Insertable<Batche> {
  final String id;
  final String productId;
  final String batchNumber;
  final int quantity;
  final int initialQuantity;
  final DateTime expiryDate;
  final DateTime receivedDate;
  final DateTime createdAt;
  const Batche({
    required this.id,
    required this.productId,
    required this.batchNumber,
    required this.quantity,
    required this.initialQuantity,
    required this.expiryDate,
    required this.receivedDate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['batch_number'] = Variable<String>(batchNumber);
    map['quantity'] = Variable<int>(quantity);
    map['initial_quantity'] = Variable<int>(initialQuantity);
    map['expiry_date'] = Variable<DateTime>(expiryDate);
    map['received_date'] = Variable<DateTime>(receivedDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BatchesCompanion toCompanion(bool nullToAbsent) {
    return BatchesCompanion(
      id: Value(id),
      productId: Value(productId),
      batchNumber: Value(batchNumber),
      quantity: Value(quantity),
      initialQuantity: Value(initialQuantity),
      expiryDate: Value(expiryDate),
      receivedDate: Value(receivedDate),
      createdAt: Value(createdAt),
    );
  }

  factory Batche.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Batche(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      batchNumber: serializer.fromJson<String>(json['batchNumber']),
      quantity: serializer.fromJson<int>(json['quantity']),
      initialQuantity: serializer.fromJson<int>(json['initialQuantity']),
      expiryDate: serializer.fromJson<DateTime>(json['expiryDate']),
      receivedDate: serializer.fromJson<DateTime>(json['receivedDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'batchNumber': serializer.toJson<String>(batchNumber),
      'quantity': serializer.toJson<int>(quantity),
      'initialQuantity': serializer.toJson<int>(initialQuantity),
      'expiryDate': serializer.toJson<DateTime>(expiryDate),
      'receivedDate': serializer.toJson<DateTime>(receivedDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Batche copyWith({
    String? id,
    String? productId,
    String? batchNumber,
    int? quantity,
    int? initialQuantity,
    DateTime? expiryDate,
    DateTime? receivedDate,
    DateTime? createdAt,
  }) => Batche(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    batchNumber: batchNumber ?? this.batchNumber,
    quantity: quantity ?? this.quantity,
    initialQuantity: initialQuantity ?? this.initialQuantity,
    expiryDate: expiryDate ?? this.expiryDate,
    receivedDate: receivedDate ?? this.receivedDate,
    createdAt: createdAt ?? this.createdAt,
  );
  Batche copyWithCompanion(BatchesCompanion data) {
    return Batche(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      batchNumber: data.batchNumber.present
          ? data.batchNumber.value
          : this.batchNumber,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      initialQuantity: data.initialQuantity.present
          ? data.initialQuantity.value
          : this.initialQuantity,
      expiryDate: data.expiryDate.present
          ? data.expiryDate.value
          : this.expiryDate,
      receivedDate: data.receivedDate.present
          ? data.receivedDate.value
          : this.receivedDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Batche(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('quantity: $quantity, ')
          ..write('initialQuantity: $initialQuantity, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('receivedDate: $receivedDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productId,
    batchNumber,
    quantity,
    initialQuantity,
    expiryDate,
    receivedDate,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Batche &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.batchNumber == this.batchNumber &&
          other.quantity == this.quantity &&
          other.initialQuantity == this.initialQuantity &&
          other.expiryDate == this.expiryDate &&
          other.receivedDate == this.receivedDate &&
          other.createdAt == this.createdAt);
}

class BatchesCompanion extends UpdateCompanion<Batche> {
  final Value<String> id;
  final Value<String> productId;
  final Value<String> batchNumber;
  final Value<int> quantity;
  final Value<int> initialQuantity;
  final Value<DateTime> expiryDate;
  final Value<DateTime> receivedDate;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BatchesCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.batchNumber = const Value.absent(),
    this.quantity = const Value.absent(),
    this.initialQuantity = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.receivedDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BatchesCompanion.insert({
    required String id,
    required String productId,
    required String batchNumber,
    required int quantity,
    required int initialQuantity,
    required DateTime expiryDate,
    required DateTime receivedDate,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId),
       batchNumber = Value(batchNumber),
       quantity = Value(quantity),
       initialQuantity = Value(initialQuantity),
       expiryDate = Value(expiryDate),
       receivedDate = Value(receivedDate),
       createdAt = Value(createdAt);
  static Insertable<Batche> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? batchNumber,
    Expression<int>? quantity,
    Expression<int>? initialQuantity,
    Expression<DateTime>? expiryDate,
    Expression<DateTime>? receivedDate,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (batchNumber != null) 'batch_number': batchNumber,
      if (quantity != null) 'quantity': quantity,
      if (initialQuantity != null) 'initial_quantity': initialQuantity,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (receivedDate != null) 'received_date': receivedDate,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BatchesCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<String>? batchNumber,
    Value<int>? quantity,
    Value<int>? initialQuantity,
    Value<DateTime>? expiryDate,
    Value<DateTime>? receivedDate,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BatchesCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      batchNumber: batchNumber ?? this.batchNumber,
      quantity: quantity ?? this.quantity,
      initialQuantity: initialQuantity ?? this.initialQuantity,
      expiryDate: expiryDate ?? this.expiryDate,
      receivedDate: receivedDate ?? this.receivedDate,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (batchNumber.present) {
      map['batch_number'] = Variable<String>(batchNumber.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (initialQuantity.present) {
      map['initial_quantity'] = Variable<int>(initialQuantity.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<DateTime>(expiryDate.value);
    }
    if (receivedDate.present) {
      map['received_date'] = Variable<DateTime>(receivedDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BatchesCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('quantity: $quantity, ')
          ..write('initialQuantity: $initialQuantity, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('receivedDate: $receivedDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrdersTable extends Orders with TableInfo<$OrdersTable, Order> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'customer_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _salesStaffIdMeta = const VerificationMeta(
    'salesStaffId',
  );
  @override
  late final GeneratedColumn<String> salesStaffId = GeneratedColumn<String>(
    'sales_staff_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerName,
    customerId,
    status,
    salesStaffId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'orders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Order> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('customer_name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['customer_name']!,
          _customerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('sales_staff_id')) {
      context.handle(
        _salesStaffIdMeta,
        salesStaffId.isAcceptableOrUnknown(
          data['sales_staff_id']!,
          _salesStaffIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Order map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Order(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_name'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      salesStaffId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sales_staff_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OrdersTable createAlias(String alias) {
    return $OrdersTable(attachedDatabase, alias);
  }
}

class Order extends DataClass implements Insertable<Order> {
  final String id;
  final String customerName;
  final String? customerId;
  final String status;
  final String? salesStaffId;
  final DateTime createdAt;
  const Order({
    required this.id,
    required this.customerName,
    this.customerId,
    required this.status,
    this.salesStaffId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['customer_name'] = Variable<String>(customerName);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || salesStaffId != null) {
      map['sales_staff_id'] = Variable<String>(salesStaffId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OrdersCompanion toCompanion(bool nullToAbsent) {
    return OrdersCompanion(
      id: Value(id),
      customerName: Value(customerName),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      status: Value(status),
      salesStaffId: salesStaffId == null && nullToAbsent
          ? const Value.absent()
          : Value(salesStaffId),
      createdAt: Value(createdAt),
    );
  }

  factory Order.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Order(
      id: serializer.fromJson<String>(json['id']),
      customerName: serializer.fromJson<String>(json['customerName']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      status: serializer.fromJson<String>(json['status']),
      salesStaffId: serializer.fromJson<String?>(json['salesStaffId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'customerName': serializer.toJson<String>(customerName),
      'customerId': serializer.toJson<String?>(customerId),
      'status': serializer.toJson<String>(status),
      'salesStaffId': serializer.toJson<String?>(salesStaffId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Order copyWith({
    String? id,
    String? customerName,
    Value<String?> customerId = const Value.absent(),
    String? status,
    Value<String?> salesStaffId = const Value.absent(),
    DateTime? createdAt,
  }) => Order(
    id: id ?? this.id,
    customerName: customerName ?? this.customerName,
    customerId: customerId.present ? customerId.value : this.customerId,
    status: status ?? this.status,
    salesStaffId: salesStaffId.present ? salesStaffId.value : this.salesStaffId,
    createdAt: createdAt ?? this.createdAt,
  );
  Order copyWithCompanion(OrdersCompanion data) {
    return Order(
      id: data.id.present ? data.id.value : this.id,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      status: data.status.present ? data.status.value : this.status,
      salesStaffId: data.salesStaffId.present
          ? data.salesStaffId.value
          : this.salesStaffId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Order(')
          ..write('id: $id, ')
          ..write('customerName: $customerName, ')
          ..write('customerId: $customerId, ')
          ..write('status: $status, ')
          ..write('salesStaffId: $salesStaffId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerName,
    customerId,
    status,
    salesStaffId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Order &&
          other.id == this.id &&
          other.customerName == this.customerName &&
          other.customerId == this.customerId &&
          other.status == this.status &&
          other.salesStaffId == this.salesStaffId &&
          other.createdAt == this.createdAt);
}

class OrdersCompanion extends UpdateCompanion<Order> {
  final Value<String> id;
  final Value<String> customerName;
  final Value<String?> customerId;
  final Value<String> status;
  final Value<String?> salesStaffId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const OrdersCompanion({
    this.id = const Value.absent(),
    this.customerName = const Value.absent(),
    this.customerId = const Value.absent(),
    this.status = const Value.absent(),
    this.salesStaffId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrdersCompanion.insert({
    required String id,
    required String customerName,
    this.customerId = const Value.absent(),
    required String status,
    this.salesStaffId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       customerName = Value(customerName),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<Order> custom({
    Expression<String>? id,
    Expression<String>? customerName,
    Expression<String>? customerId,
    Expression<String>? status,
    Expression<String>? salesStaffId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerName != null) 'customer_name': customerName,
      if (customerId != null) 'customer_id': customerId,
      if (status != null) 'status': status,
      if (salesStaffId != null) 'sales_staff_id': salesStaffId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrdersCompanion copyWith({
    Value<String>? id,
    Value<String>? customerName,
    Value<String?>? customerId,
    Value<String>? status,
    Value<String?>? salesStaffId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return OrdersCompanion(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerId: customerId ?? this.customerId,
      status: status ?? this.status,
      salesStaffId: salesStaffId ?? this.salesStaffId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (salesStaffId.present) {
      map['sales_staff_id'] = Variable<String>(salesStaffId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrdersCompanion(')
          ..write('id: $id, ')
          ..write('customerName: $customerName, ')
          ..write('customerId: $customerId, ')
          ..write('status: $status, ')
          ..write('salesStaffId: $salesStaffId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrderItemsTable extends OrderItems
    with TableInfo<$OrderItemsTable, OrderItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
    'order_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productPriceMeta = const VerificationMeta(
    'productPrice',
  );
  @override
  late final GeneratedColumn<double> productPrice = GeneratedColumn<double>(
    'product_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    orderId,
    productId,
    quantity,
    productName,
    productPrice,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<OrderItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    }
    if (data.containsKey('product_price')) {
      context.handle(
        _productPriceMeta,
        productPrice.isAcceptableOrUnknown(
          data['product_price']!,
          _productPriceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      ),
      productPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}product_price'],
      ),
    );
  }

  @override
  $OrderItemsTable createAlias(String alias) {
    return $OrderItemsTable(attachedDatabase, alias);
  }
}

class OrderItem extends DataClass implements Insertable<OrderItem> {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  final String? productName;
  final double? productPrice;
  const OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    this.productName,
    this.productPrice,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['order_id'] = Variable<String>(orderId);
    map['product_id'] = Variable<String>(productId);
    map['quantity'] = Variable<int>(quantity);
    if (!nullToAbsent || productName != null) {
      map['product_name'] = Variable<String>(productName);
    }
    if (!nullToAbsent || productPrice != null) {
      map['product_price'] = Variable<double>(productPrice);
    }
    return map;
  }

  OrderItemsCompanion toCompanion(bool nullToAbsent) {
    return OrderItemsCompanion(
      id: Value(id),
      orderId: Value(orderId),
      productId: Value(productId),
      quantity: Value(quantity),
      productName: productName == null && nullToAbsent
          ? const Value.absent()
          : Value(productName),
      productPrice: productPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(productPrice),
    );
  }

  factory OrderItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderItem(
      id: serializer.fromJson<String>(json['id']),
      orderId: serializer.fromJson<String>(json['orderId']),
      productId: serializer.fromJson<String>(json['productId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      productName: serializer.fromJson<String?>(json['productName']),
      productPrice: serializer.fromJson<double?>(json['productPrice']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'orderId': serializer.toJson<String>(orderId),
      'productId': serializer.toJson<String>(productId),
      'quantity': serializer.toJson<int>(quantity),
      'productName': serializer.toJson<String?>(productName),
      'productPrice': serializer.toJson<double?>(productPrice),
    };
  }

  OrderItem copyWith({
    String? id,
    String? orderId,
    String? productId,
    int? quantity,
    Value<String?> productName = const Value.absent(),
    Value<double?> productPrice = const Value.absent(),
  }) => OrderItem(
    id: id ?? this.id,
    orderId: orderId ?? this.orderId,
    productId: productId ?? this.productId,
    quantity: quantity ?? this.quantity,
    productName: productName.present ? productName.value : this.productName,
    productPrice: productPrice.present ? productPrice.value : this.productPrice,
  );
  OrderItem copyWithCompanion(OrderItemsCompanion data) {
    return OrderItem(
      id: data.id.present ? data.id.value : this.id,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      productPrice: data.productPrice.present
          ? data.productPrice.value
          : this.productPrice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderItem(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('productName: $productName, ')
          ..write('productPrice: $productPrice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, orderId, productId, quantity, productName, productPrice);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderItem &&
          other.id == this.id &&
          other.orderId == this.orderId &&
          other.productId == this.productId &&
          other.quantity == this.quantity &&
          other.productName == this.productName &&
          other.productPrice == this.productPrice);
}

class OrderItemsCompanion extends UpdateCompanion<OrderItem> {
  final Value<String> id;
  final Value<String> orderId;
  final Value<String> productId;
  final Value<int> quantity;
  final Value<String?> productName;
  final Value<double?> productPrice;
  final Value<int> rowid;
  const OrderItemsCompanion({
    this.id = const Value.absent(),
    this.orderId = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.productName = const Value.absent(),
    this.productPrice = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrderItemsCompanion.insert({
    required String id,
    required String orderId,
    required String productId,
    required int quantity,
    this.productName = const Value.absent(),
    this.productPrice = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       orderId = Value(orderId),
       productId = Value(productId),
       quantity = Value(quantity);
  static Insertable<OrderItem> custom({
    Expression<String>? id,
    Expression<String>? orderId,
    Expression<String>? productId,
    Expression<int>? quantity,
    Expression<String>? productName,
    Expression<double>? productPrice,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      if (productId != null) 'product_id': productId,
      if (quantity != null) 'quantity': quantity,
      if (productName != null) 'product_name': productName,
      if (productPrice != null) 'product_price': productPrice,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrderItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? orderId,
    Value<String>? productId,
    Value<int>? quantity,
    Value<String?>? productName,
    Value<double?>? productPrice,
    Value<int>? rowid,
  }) {
    return OrderItemsCompanion(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (productPrice.present) {
      map['product_price'] = Variable<double>(productPrice.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderItemsCompanion(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('productName: $productName, ')
          ..write('productPrice: $productPrice, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  @override
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
    'region',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _townshipMeta = const VerificationMeta(
    'township',
  );
  @override
  late final GeneratedColumn<String> township = GeneratedColumn<String>(
    'township',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    region,
    township,
    address,
    phone,
    status,
    createdBy,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Customer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('region')) {
      context.handle(
        _regionMeta,
        region.isAcceptableOrUnknown(data['region']!, _regionMeta),
      );
    } else if (isInserting) {
      context.missing(_regionMeta);
    }
    if (data.containsKey('township')) {
      context.handle(
        _townshipMeta,
        township.isAcceptableOrUnknown(data['township']!, _townshipMeta),
      );
    } else if (isInserting) {
      context.missing(_townshipMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      region: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region'],
      )!,
      township: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}township'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class Customer extends DataClass implements Insertable<Customer> {
  final String id;
  final String name;
  final String region;
  final String township;
  final String? address;
  final String phone;
  final String status;
  final String? createdBy;
  final DateTime createdAt;
  const Customer({
    required this.id,
    required this.name,
    required this.region,
    required this.township,
    this.address,
    required this.phone,
    required this.status,
    this.createdBy,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['region'] = Variable<String>(region);
    map['township'] = Variable<String>(township);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['phone'] = Variable<String>(phone);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      name: Value(name),
      region: Value(region),
      township: Value(township),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      phone: Value(phone),
      status: Value(status),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: Value(createdAt),
    );
  }

  factory Customer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      region: serializer.fromJson<String>(json['region']),
      township: serializer.fromJson<String>(json['township']),
      address: serializer.fromJson<String?>(json['address']),
      phone: serializer.fromJson<String>(json['phone']),
      status: serializer.fromJson<String>(json['status']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'region': serializer.toJson<String>(region),
      'township': serializer.toJson<String>(township),
      'address': serializer.toJson<String?>(address),
      'phone': serializer.toJson<String>(phone),
      'status': serializer.toJson<String>(status),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Customer copyWith({
    String? id,
    String? name,
    String? region,
    String? township,
    Value<String?> address = const Value.absent(),
    String? phone,
    String? status,
    Value<String?> createdBy = const Value.absent(),
    DateTime? createdAt,
  }) => Customer(
    id: id ?? this.id,
    name: name ?? this.name,
    region: region ?? this.region,
    township: township ?? this.township,
    address: address.present ? address.value : this.address,
    phone: phone ?? this.phone,
    status: status ?? this.status,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt ?? this.createdAt,
  );
  Customer copyWithCompanion(CustomersCompanion data) {
    return Customer(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      region: data.region.present ? data.region.value : this.region,
      township: data.township.present ? data.township.value : this.township,
      address: data.address.present ? data.address.value : this.address,
      phone: data.phone.present ? data.phone.value : this.phone,
      status: data.status.present ? data.status.value : this.status,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Customer(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('region: $region, ')
          ..write('township: $township, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('status: $status, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    region,
    township,
    address,
    phone,
    status,
    createdBy,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Customer &&
          other.id == this.id &&
          other.name == this.name &&
          other.region == this.region &&
          other.township == this.township &&
          other.address == this.address &&
          other.phone == this.phone &&
          other.status == this.status &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt);
}

class CustomersCompanion extends UpdateCompanion<Customer> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> region;
  final Value<String> township;
  final Value<String?> address;
  final Value<String> phone;
  final Value<String> status;
  final Value<String?> createdBy;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.region = const Value.absent(),
    this.township = const Value.absent(),
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.status = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersCompanion.insert({
    required String id,
    required String name,
    required String region,
    required String township,
    this.address = const Value.absent(),
    required String phone,
    required String status,
    this.createdBy = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       region = Value(region),
       township = Value(township),
       phone = Value(phone),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<Customer> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? region,
    Expression<String>? township,
    Expression<String>? address,
    Expression<String>? phone,
    Expression<String>? status,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (region != null) 'region': region,
      if (township != null) 'township': township,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (status != null) 'status': status,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? region,
    Value<String>? township,
    Value<String?>? address,
    Value<String>? phone,
    Value<String>? status,
    Value<String?>? createdBy,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CustomersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      region: region ?? this.region,
      township: township ?? this.township,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (township.present) {
      map['township'] = Variable<String>(township.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('region: $region, ')
          ..write('township: $township, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('status: $status, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DisposalsTable extends Disposals
    with TableInfo<$DisposalsTable, Disposal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DisposalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestedByMeta = const VerificationMeta(
    'requestedBy',
  );
  @override
  late final GeneratedColumn<String> requestedBy = GeneratedColumn<String>(
    'requested_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    batchId,
    quantity,
    reason,
    status,
    requestedBy,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'disposals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Disposal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('requested_by')) {
      context.handle(
        _requestedByMeta,
        requestedBy.isAcceptableOrUnknown(
          data['requested_by']!,
          _requestedByMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Disposal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Disposal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      requestedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}requested_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DisposalsTable createAlias(String alias) {
    return $DisposalsTable(attachedDatabase, alias);
  }
}

class Disposal extends DataClass implements Insertable<Disposal> {
  final String id;
  final String productId;
  final String batchId;
  final int quantity;
  final String reason;
  final String status;
  final String? requestedBy;
  final DateTime createdAt;
  const Disposal({
    required this.id,
    required this.productId,
    required this.batchId,
    required this.quantity,
    required this.reason,
    required this.status,
    this.requestedBy,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['batch_id'] = Variable<String>(batchId);
    map['quantity'] = Variable<int>(quantity);
    map['reason'] = Variable<String>(reason);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || requestedBy != null) {
      map['requested_by'] = Variable<String>(requestedBy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DisposalsCompanion toCompanion(bool nullToAbsent) {
    return DisposalsCompanion(
      id: Value(id),
      productId: Value(productId),
      batchId: Value(batchId),
      quantity: Value(quantity),
      reason: Value(reason),
      status: Value(status),
      requestedBy: requestedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(requestedBy),
      createdAt: Value(createdAt),
    );
  }

  factory Disposal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Disposal(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      batchId: serializer.fromJson<String>(json['batchId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      reason: serializer.fromJson<String>(json['reason']),
      status: serializer.fromJson<String>(json['status']),
      requestedBy: serializer.fromJson<String?>(json['requestedBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'batchId': serializer.toJson<String>(batchId),
      'quantity': serializer.toJson<int>(quantity),
      'reason': serializer.toJson<String>(reason),
      'status': serializer.toJson<String>(status),
      'requestedBy': serializer.toJson<String?>(requestedBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Disposal copyWith({
    String? id,
    String? productId,
    String? batchId,
    int? quantity,
    String? reason,
    String? status,
    Value<String?> requestedBy = const Value.absent(),
    DateTime? createdAt,
  }) => Disposal(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    batchId: batchId ?? this.batchId,
    quantity: quantity ?? this.quantity,
    reason: reason ?? this.reason,
    status: status ?? this.status,
    requestedBy: requestedBy.present ? requestedBy.value : this.requestedBy,
    createdAt: createdAt ?? this.createdAt,
  );
  Disposal copyWithCompanion(DisposalsCompanion data) {
    return Disposal(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      reason: data.reason.present ? data.reason.value : this.reason,
      status: data.status.present ? data.status.value : this.status,
      requestedBy: data.requestedBy.present
          ? data.requestedBy.value
          : this.requestedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Disposal(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('batchId: $batchId, ')
          ..write('quantity: $quantity, ')
          ..write('reason: $reason, ')
          ..write('status: $status, ')
          ..write('requestedBy: $requestedBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productId,
    batchId,
    quantity,
    reason,
    status,
    requestedBy,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Disposal &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.batchId == this.batchId &&
          other.quantity == this.quantity &&
          other.reason == this.reason &&
          other.status == this.status &&
          other.requestedBy == this.requestedBy &&
          other.createdAt == this.createdAt);
}

class DisposalsCompanion extends UpdateCompanion<Disposal> {
  final Value<String> id;
  final Value<String> productId;
  final Value<String> batchId;
  final Value<int> quantity;
  final Value<String> reason;
  final Value<String> status;
  final Value<String?> requestedBy;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DisposalsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.batchId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.reason = const Value.absent(),
    this.status = const Value.absent(),
    this.requestedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DisposalsCompanion.insert({
    required String id,
    required String productId,
    required String batchId,
    required int quantity,
    required String reason,
    required String status,
    this.requestedBy = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId),
       batchId = Value(batchId),
       quantity = Value(quantity),
       reason = Value(reason),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<Disposal> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? batchId,
    Expression<int>? quantity,
    Expression<String>? reason,
    Expression<String>? status,
    Expression<String>? requestedBy,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (batchId != null) 'batch_id': batchId,
      if (quantity != null) 'quantity': quantity,
      if (reason != null) 'reason': reason,
      if (status != null) 'status': status,
      if (requestedBy != null) 'requested_by': requestedBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DisposalsCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<String>? batchId,
    Value<int>? quantity,
    Value<String>? reason,
    Value<String>? status,
    Value<String?>? requestedBy,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return DisposalsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      batchId: batchId ?? this.batchId,
      quantity: quantity ?? this.quantity,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      requestedBy: requestedBy ?? this.requestedBy,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (requestedBy.present) {
      map['requested_by'] = Variable<String>(requestedBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DisposalsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('batchId: $batchId, ')
          ..write('quantity: $quantity, ')
          ..write('reason: $reason, ')
          ..write('status: $status, ')
          ..write('requestedBy: $requestedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhysicalAuditsTable extends PhysicalAudits
    with TableInfo<$PhysicalAuditsTable, PhysicalAudit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhysicalAuditsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _systemQuantityMeta = const VerificationMeta(
    'systemQuantity',
  );
  @override
  late final GeneratedColumn<int> systemQuantity = GeneratedColumn<int>(
    'system_quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _physicalQuantityMeta = const VerificationMeta(
    'physicalQuantity',
  );
  @override
  late final GeneratedColumn<int> physicalQuantity = GeneratedColumn<int>(
    'physical_quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discrepancyMeta = const VerificationMeta(
    'discrepancy',
  );
  @override
  late final GeneratedColumn<int> discrepancy = GeneratedColumn<int>(
    'discrepancy',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _auditedByMeta = const VerificationMeta(
    'auditedBy',
  );
  @override
  late final GeneratedColumn<String> auditedBy = GeneratedColumn<String>(
    'audited_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    batchId,
    systemQuantity,
    physicalQuantity,
    discrepancy,
    notes,
    auditedBy,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'physical_audits';
  @override
  VerificationContext validateIntegrity(
    Insertable<PhysicalAudit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('system_quantity')) {
      context.handle(
        _systemQuantityMeta,
        systemQuantity.isAcceptableOrUnknown(
          data['system_quantity']!,
          _systemQuantityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_systemQuantityMeta);
    }
    if (data.containsKey('physical_quantity')) {
      context.handle(
        _physicalQuantityMeta,
        physicalQuantity.isAcceptableOrUnknown(
          data['physical_quantity']!,
          _physicalQuantityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_physicalQuantityMeta);
    }
    if (data.containsKey('discrepancy')) {
      context.handle(
        _discrepancyMeta,
        discrepancy.isAcceptableOrUnknown(
          data['discrepancy']!,
          _discrepancyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_discrepancyMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('audited_by')) {
      context.handle(
        _auditedByMeta,
        auditedBy.isAcceptableOrUnknown(data['audited_by']!, _auditedByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PhysicalAudit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhysicalAudit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      )!,
      systemQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}system_quantity'],
      )!,
      physicalQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}physical_quantity'],
      )!,
      discrepancy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discrepancy'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      auditedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audited_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PhysicalAuditsTable createAlias(String alias) {
    return $PhysicalAuditsTable(attachedDatabase, alias);
  }
}

class PhysicalAudit extends DataClass implements Insertable<PhysicalAudit> {
  final String id;
  final String productId;
  final String batchId;
  final int systemQuantity;
  final int physicalQuantity;
  final int discrepancy;
  final String? notes;
  final String? auditedBy;
  final DateTime createdAt;
  const PhysicalAudit({
    required this.id,
    required this.productId,
    required this.batchId,
    required this.systemQuantity,
    required this.physicalQuantity,
    required this.discrepancy,
    this.notes,
    this.auditedBy,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['batch_id'] = Variable<String>(batchId);
    map['system_quantity'] = Variable<int>(systemQuantity);
    map['physical_quantity'] = Variable<int>(physicalQuantity);
    map['discrepancy'] = Variable<int>(discrepancy);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || auditedBy != null) {
      map['audited_by'] = Variable<String>(auditedBy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PhysicalAuditsCompanion toCompanion(bool nullToAbsent) {
    return PhysicalAuditsCompanion(
      id: Value(id),
      productId: Value(productId),
      batchId: Value(batchId),
      systemQuantity: Value(systemQuantity),
      physicalQuantity: Value(physicalQuantity),
      discrepancy: Value(discrepancy),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      auditedBy: auditedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(auditedBy),
      createdAt: Value(createdAt),
    );
  }

  factory PhysicalAudit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhysicalAudit(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      batchId: serializer.fromJson<String>(json['batchId']),
      systemQuantity: serializer.fromJson<int>(json['systemQuantity']),
      physicalQuantity: serializer.fromJson<int>(json['physicalQuantity']),
      discrepancy: serializer.fromJson<int>(json['discrepancy']),
      notes: serializer.fromJson<String?>(json['notes']),
      auditedBy: serializer.fromJson<String?>(json['auditedBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'batchId': serializer.toJson<String>(batchId),
      'systemQuantity': serializer.toJson<int>(systemQuantity),
      'physicalQuantity': serializer.toJson<int>(physicalQuantity),
      'discrepancy': serializer.toJson<int>(discrepancy),
      'notes': serializer.toJson<String?>(notes),
      'auditedBy': serializer.toJson<String?>(auditedBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PhysicalAudit copyWith({
    String? id,
    String? productId,
    String? batchId,
    int? systemQuantity,
    int? physicalQuantity,
    int? discrepancy,
    Value<String?> notes = const Value.absent(),
    Value<String?> auditedBy = const Value.absent(),
    DateTime? createdAt,
  }) => PhysicalAudit(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    batchId: batchId ?? this.batchId,
    systemQuantity: systemQuantity ?? this.systemQuantity,
    physicalQuantity: physicalQuantity ?? this.physicalQuantity,
    discrepancy: discrepancy ?? this.discrepancy,
    notes: notes.present ? notes.value : this.notes,
    auditedBy: auditedBy.present ? auditedBy.value : this.auditedBy,
    createdAt: createdAt ?? this.createdAt,
  );
  PhysicalAudit copyWithCompanion(PhysicalAuditsCompanion data) {
    return PhysicalAudit(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      systemQuantity: data.systemQuantity.present
          ? data.systemQuantity.value
          : this.systemQuantity,
      physicalQuantity: data.physicalQuantity.present
          ? data.physicalQuantity.value
          : this.physicalQuantity,
      discrepancy: data.discrepancy.present
          ? data.discrepancy.value
          : this.discrepancy,
      notes: data.notes.present ? data.notes.value : this.notes,
      auditedBy: data.auditedBy.present ? data.auditedBy.value : this.auditedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhysicalAudit(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('batchId: $batchId, ')
          ..write('systemQuantity: $systemQuantity, ')
          ..write('physicalQuantity: $physicalQuantity, ')
          ..write('discrepancy: $discrepancy, ')
          ..write('notes: $notes, ')
          ..write('auditedBy: $auditedBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productId,
    batchId,
    systemQuantity,
    physicalQuantity,
    discrepancy,
    notes,
    auditedBy,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhysicalAudit &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.batchId == this.batchId &&
          other.systemQuantity == this.systemQuantity &&
          other.physicalQuantity == this.physicalQuantity &&
          other.discrepancy == this.discrepancy &&
          other.notes == this.notes &&
          other.auditedBy == this.auditedBy &&
          other.createdAt == this.createdAt);
}

class PhysicalAuditsCompanion extends UpdateCompanion<PhysicalAudit> {
  final Value<String> id;
  final Value<String> productId;
  final Value<String> batchId;
  final Value<int> systemQuantity;
  final Value<int> physicalQuantity;
  final Value<int> discrepancy;
  final Value<String?> notes;
  final Value<String?> auditedBy;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PhysicalAuditsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.batchId = const Value.absent(),
    this.systemQuantity = const Value.absent(),
    this.physicalQuantity = const Value.absent(),
    this.discrepancy = const Value.absent(),
    this.notes = const Value.absent(),
    this.auditedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhysicalAuditsCompanion.insert({
    required String id,
    required String productId,
    required String batchId,
    required int systemQuantity,
    required int physicalQuantity,
    required int discrepancy,
    this.notes = const Value.absent(),
    this.auditedBy = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId),
       batchId = Value(batchId),
       systemQuantity = Value(systemQuantity),
       physicalQuantity = Value(physicalQuantity),
       discrepancy = Value(discrepancy),
       createdAt = Value(createdAt);
  static Insertable<PhysicalAudit> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? batchId,
    Expression<int>? systemQuantity,
    Expression<int>? physicalQuantity,
    Expression<int>? discrepancy,
    Expression<String>? notes,
    Expression<String>? auditedBy,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (batchId != null) 'batch_id': batchId,
      if (systemQuantity != null) 'system_quantity': systemQuantity,
      if (physicalQuantity != null) 'physical_quantity': physicalQuantity,
      if (discrepancy != null) 'discrepancy': discrepancy,
      if (notes != null) 'notes': notes,
      if (auditedBy != null) 'audited_by': auditedBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhysicalAuditsCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<String>? batchId,
    Value<int>? systemQuantity,
    Value<int>? physicalQuantity,
    Value<int>? discrepancy,
    Value<String?>? notes,
    Value<String?>? auditedBy,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PhysicalAuditsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      batchId: batchId ?? this.batchId,
      systemQuantity: systemQuantity ?? this.systemQuantity,
      physicalQuantity: physicalQuantity ?? this.physicalQuantity,
      discrepancy: discrepancy ?? this.discrepancy,
      notes: notes ?? this.notes,
      auditedBy: auditedBy ?? this.auditedBy,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (systemQuantity.present) {
      map['system_quantity'] = Variable<int>(systemQuantity.value);
    }
    if (physicalQuantity.present) {
      map['physical_quantity'] = Variable<int>(physicalQuantity.value);
    }
    if (discrepancy.present) {
      map['discrepancy'] = Variable<int>(discrepancy.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (auditedBy.present) {
      map['audited_by'] = Variable<String>(auditedBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhysicalAuditsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('batchId: $batchId, ')
          ..write('systemQuantity: $systemQuantity, ')
          ..write('physicalQuantity: $physicalQuantity, ')
          ..write('discrepancy: $discrepancy, ')
          ..write('notes: $notes, ')
          ..write('auditedBy: $auditedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MutationsTable extends Mutations
    with TableInfo<$MutationsTable, Mutation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MutationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _actionTypeMeta = const VerificationMeta(
    'actionType',
  );
  @override
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
    'action_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteTableMeta = const VerificationMeta(
    'remoteTable',
  );
  @override
  late final GeneratedColumn<String> remoteTable = GeneratedColumn<String>(
    'table_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    actionType,
    remoteTable,
    payload,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mutations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Mutation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('action_type')) {
      context.handle(
        _actionTypeMeta,
        actionType.isAcceptableOrUnknown(data['action_type']!, _actionTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_actionTypeMeta);
    }
    if (data.containsKey('table_name')) {
      context.handle(
        _remoteTableMeta,
        remoteTable.isAcceptableOrUnknown(
          data['table_name']!,
          _remoteTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remoteTableMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Mutation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Mutation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      actionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_type'],
      )!,
      remoteTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_name'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MutationsTable createAlias(String alias) {
    return $MutationsTable(attachedDatabase, alias);
  }
}

class Mutation extends DataClass implements Insertable<Mutation> {
  final int id;
  final String actionType;
  final String remoteTable;
  final String payload;
  final DateTime createdAt;
  const Mutation({
    required this.id,
    required this.actionType,
    required this.remoteTable,
    required this.payload,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['action_type'] = Variable<String>(actionType);
    map['table_name'] = Variable<String>(remoteTable);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MutationsCompanion toCompanion(bool nullToAbsent) {
    return MutationsCompanion(
      id: Value(id),
      actionType: Value(actionType),
      remoteTable: Value(remoteTable),
      payload: Value(payload),
      createdAt: Value(createdAt),
    );
  }

  factory Mutation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Mutation(
      id: serializer.fromJson<int>(json['id']),
      actionType: serializer.fromJson<String>(json['actionType']),
      remoteTable: serializer.fromJson<String>(json['remoteTable']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'actionType': serializer.toJson<String>(actionType),
      'remoteTable': serializer.toJson<String>(remoteTable),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Mutation copyWith({
    int? id,
    String? actionType,
    String? remoteTable,
    String? payload,
    DateTime? createdAt,
  }) => Mutation(
    id: id ?? this.id,
    actionType: actionType ?? this.actionType,
    remoteTable: remoteTable ?? this.remoteTable,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
  );
  Mutation copyWithCompanion(MutationsCompanion data) {
    return Mutation(
      id: data.id.present ? data.id.value : this.id,
      actionType: data.actionType.present
          ? data.actionType.value
          : this.actionType,
      remoteTable: data.remoteTable.present
          ? data.remoteTable.value
          : this.remoteTable,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Mutation(')
          ..write('id: $id, ')
          ..write('actionType: $actionType, ')
          ..write('remoteTable: $remoteTable, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, actionType, remoteTable, payload, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Mutation &&
          other.id == this.id &&
          other.actionType == this.actionType &&
          other.remoteTable == this.remoteTable &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt);
}

class MutationsCompanion extends UpdateCompanion<Mutation> {
  final Value<int> id;
  final Value<String> actionType;
  final Value<String> remoteTable;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  const MutationsCompanion({
    this.id = const Value.absent(),
    this.actionType = const Value.absent(),
    this.remoteTable = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MutationsCompanion.insert({
    this.id = const Value.absent(),
    required String actionType,
    required String remoteTable,
    required String payload,
    this.createdAt = const Value.absent(),
  }) : actionType = Value(actionType),
       remoteTable = Value(remoteTable),
       payload = Value(payload);
  static Insertable<Mutation> custom({
    Expression<int>? id,
    Expression<String>? actionType,
    Expression<String>? remoteTable,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (actionType != null) 'action_type': actionType,
      if (remoteTable != null) 'table_name': remoteTable,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MutationsCompanion copyWith({
    Value<int>? id,
    Value<String>? actionType,
    Value<String>? remoteTable,
    Value<String>? payload,
    Value<DateTime>? createdAt,
  }) {
    return MutationsCompanion(
      id: id ?? this.id,
      actionType: actionType ?? this.actionType,
      remoteTable: remoteTable ?? this.remoteTable,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (remoteTable.present) {
      map['table_name'] = Variable<String>(remoteTable.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MutationsCompanion(')
          ..write('id: $id, ')
          ..write('actionType: $actionType, ')
          ..write('remoteTable: $remoteTable, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $BatchesTable batches = $BatchesTable(this);
  late final $OrdersTable orders = $OrdersTable(this);
  late final $OrderItemsTable orderItems = $OrderItemsTable(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $DisposalsTable disposals = $DisposalsTable(this);
  late final $PhysicalAuditsTable physicalAudits = $PhysicalAuditsTable(this);
  late final $MutationsTable mutations = $MutationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    products,
    batches,
    orders,
    orderItems,
    customers,
    disposals,
    physicalAudits,
    mutations,
  ];
}

typedef $$ProductsTableCreateCompanionBuilder =
    ProductsCompanion Function({
      required String id,
      required String name,
      required String sku,
      required double price,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ProductsTableUpdateCompanionBuilder =
    ProductsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> sku,
      Value<double> price,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTable,
          Product,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (Product, BaseReferences<_$AppDatabase, $ProductsTable, Product>),
          Product,
          PrefetchHooks Function()
        > {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> sku = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                name: name,
                sku: sku,
                price: price,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String sku,
                required double price,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion.insert(
                id: id,
                name: name,
                sku: sku,
                price: price,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTable,
      Product,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (Product, BaseReferences<_$AppDatabase, $ProductsTable, Product>),
      Product,
      PrefetchHooks Function()
    >;
typedef $$BatchesTableCreateCompanionBuilder =
    BatchesCompanion Function({
      required String id,
      required String productId,
      required String batchNumber,
      required int quantity,
      required int initialQuantity,
      required DateTime expiryDate,
      required DateTime receivedDate,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$BatchesTableUpdateCompanionBuilder =
    BatchesCompanion Function({
      Value<String> id,
      Value<String> productId,
      Value<String> batchNumber,
      Value<int> quantity,
      Value<int> initialQuantity,
      Value<DateTime> expiryDate,
      Value<DateTime> receivedDate,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$BatchesTableFilterComposer
    extends Composer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get initialQuantity => $composableBuilder(
    column: $table.initialQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedDate => $composableBuilder(
    column: $table.receivedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get initialQuantity => $composableBuilder(
    column: $table.initialQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedDate => $composableBuilder(
    column: $table.receivedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get initialQuantity => $composableBuilder(
    column: $table.initialQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get receivedDate => $composableBuilder(
    column: $table.receivedDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BatchesTable,
          Batche,
          $$BatchesTableFilterComposer,
          $$BatchesTableOrderingComposer,
          $$BatchesTableAnnotationComposer,
          $$BatchesTableCreateCompanionBuilder,
          $$BatchesTableUpdateCompanionBuilder,
          (Batche, BaseReferences<_$AppDatabase, $BatchesTable, Batche>),
          Batche,
          PrefetchHooks Function()
        > {
  $$BatchesTableTableManager(_$AppDatabase db, $BatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> batchNumber = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> initialQuantity = const Value.absent(),
                Value<DateTime> expiryDate = const Value.absent(),
                Value<DateTime> receivedDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BatchesCompanion(
                id: id,
                productId: productId,
                batchNumber: batchNumber,
                quantity: quantity,
                initialQuantity: initialQuantity,
                expiryDate: expiryDate,
                receivedDate: receivedDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                required String batchNumber,
                required int quantity,
                required int initialQuantity,
                required DateTime expiryDate,
                required DateTime receivedDate,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BatchesCompanion.insert(
                id: id,
                productId: productId,
                batchNumber: batchNumber,
                quantity: quantity,
                initialQuantity: initialQuantity,
                expiryDate: expiryDate,
                receivedDate: receivedDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BatchesTable,
      Batche,
      $$BatchesTableFilterComposer,
      $$BatchesTableOrderingComposer,
      $$BatchesTableAnnotationComposer,
      $$BatchesTableCreateCompanionBuilder,
      $$BatchesTableUpdateCompanionBuilder,
      (Batche, BaseReferences<_$AppDatabase, $BatchesTable, Batche>),
      Batche,
      PrefetchHooks Function()
    >;
typedef $$OrdersTableCreateCompanionBuilder =
    OrdersCompanion Function({
      required String id,
      required String customerName,
      Value<String?> customerId,
      required String status,
      Value<String?> salesStaffId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$OrdersTableUpdateCompanionBuilder =
    OrdersCompanion Function({
      Value<String> id,
      Value<String> customerName,
      Value<String?> customerId,
      Value<String> status,
      Value<String?> salesStaffId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$OrdersTableFilterComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get salesStaffId => $composableBuilder(
    column: $table.salesStaffId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get salesStaffId => $composableBuilder(
    column: $table.salesStaffId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get salesStaffId => $composableBuilder(
    column: $table.salesStaffId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OrdersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrdersTable,
          Order,
          $$OrdersTableFilterComposer,
          $$OrdersTableOrderingComposer,
          $$OrdersTableAnnotationComposer,
          $$OrdersTableCreateCompanionBuilder,
          $$OrdersTableUpdateCompanionBuilder,
          (Order, BaseReferences<_$AppDatabase, $OrdersTable, Order>),
          Order,
          PrefetchHooks Function()
        > {
  $$OrdersTableTableManager(_$AppDatabase db, $OrdersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> customerName = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> salesStaffId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrdersCompanion(
                id: id,
                customerName: customerName,
                customerId: customerId,
                status: status,
                salesStaffId: salesStaffId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String customerName,
                Value<String?> customerId = const Value.absent(),
                required String status,
                Value<String?> salesStaffId = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => OrdersCompanion.insert(
                id: id,
                customerName: customerName,
                customerId: customerId,
                status: status,
                salesStaffId: salesStaffId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OrdersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrdersTable,
      Order,
      $$OrdersTableFilterComposer,
      $$OrdersTableOrderingComposer,
      $$OrdersTableAnnotationComposer,
      $$OrdersTableCreateCompanionBuilder,
      $$OrdersTableUpdateCompanionBuilder,
      (Order, BaseReferences<_$AppDatabase, $OrdersTable, Order>),
      Order,
      PrefetchHooks Function()
    >;
typedef $$OrderItemsTableCreateCompanionBuilder =
    OrderItemsCompanion Function({
      required String id,
      required String orderId,
      required String productId,
      required int quantity,
      Value<String?> productName,
      Value<double?> productPrice,
      Value<int> rowid,
    });
typedef $$OrderItemsTableUpdateCompanionBuilder =
    OrderItemsCompanion Function({
      Value<String> id,
      Value<String> orderId,
      Value<String> productId,
      Value<int> quantity,
      Value<String?> productName,
      Value<double?> productPrice,
      Value<int> rowid,
    });

class $$OrderItemsTableFilterComposer
    extends Composer<_$AppDatabase, $OrderItemsTable> {
  $$OrderItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get productPrice => $composableBuilder(
    column: $table.productPrice,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OrderItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderItemsTable> {
  $$OrderItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get productPrice => $composableBuilder(
    column: $table.productPrice,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OrderItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderItemsTable> {
  $$OrderItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get productPrice => $composableBuilder(
    column: $table.productPrice,
    builder: (column) => column,
  );
}

class $$OrderItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrderItemsTable,
          OrderItem,
          $$OrderItemsTableFilterComposer,
          $$OrderItemsTableOrderingComposer,
          $$OrderItemsTableAnnotationComposer,
          $$OrderItemsTableCreateCompanionBuilder,
          $$OrderItemsTableUpdateCompanionBuilder,
          (
            OrderItem,
            BaseReferences<_$AppDatabase, $OrderItemsTable, OrderItem>,
          ),
          OrderItem,
          PrefetchHooks Function()
        > {
  $$OrderItemsTableTableManager(_$AppDatabase db, $OrderItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrderItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> orderId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<String?> productName = const Value.absent(),
                Value<double?> productPrice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrderItemsCompanion(
                id: id,
                orderId: orderId,
                productId: productId,
                quantity: quantity,
                productName: productName,
                productPrice: productPrice,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String orderId,
                required String productId,
                required int quantity,
                Value<String?> productName = const Value.absent(),
                Value<double?> productPrice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrderItemsCompanion.insert(
                id: id,
                orderId: orderId,
                productId: productId,
                quantity: quantity,
                productName: productName,
                productPrice: productPrice,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OrderItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrderItemsTable,
      OrderItem,
      $$OrderItemsTableFilterComposer,
      $$OrderItemsTableOrderingComposer,
      $$OrderItemsTableAnnotationComposer,
      $$OrderItemsTableCreateCompanionBuilder,
      $$OrderItemsTableUpdateCompanionBuilder,
      (OrderItem, BaseReferences<_$AppDatabase, $OrderItemsTable, OrderItem>),
      OrderItem,
      PrefetchHooks Function()
    >;
typedef $$CustomersTableCreateCompanionBuilder =
    CustomersCompanion Function({
      required String id,
      required String name,
      required String region,
      required String township,
      Value<String?> address,
      required String phone,
      required String status,
      Value<String?> createdBy,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CustomersTableUpdateCompanionBuilder =
    CustomersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> region,
      Value<String> township,
      Value<String?> address,
      Value<String> phone,
      Value<String> status,
      Value<String?> createdBy,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get township => $composableBuilder(
    column: $table.township,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get township => $composableBuilder(
    column: $table.township,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  GeneratedColumn<String> get township =>
      $composableBuilder(column: $table.township, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          Customer,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
          Customer,
          PrefetchHooks Function()
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> region = const Value.absent(),
                Value<String> township = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion(
                id: id,
                name: name,
                region: region,
                township: township,
                address: address,
                phone: phone,
                status: status,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String region,
                required String township,
                Value<String?> address = const Value.absent(),
                required String phone,
                required String status,
                Value<String?> createdBy = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion.insert(
                id: id,
                name: name,
                region: region,
                township: township,
                address: address,
                phone: phone,
                status: status,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      Customer,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
      Customer,
      PrefetchHooks Function()
    >;
typedef $$DisposalsTableCreateCompanionBuilder =
    DisposalsCompanion Function({
      required String id,
      required String productId,
      required String batchId,
      required int quantity,
      required String reason,
      required String status,
      Value<String?> requestedBy,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$DisposalsTableUpdateCompanionBuilder =
    DisposalsCompanion Function({
      Value<String> id,
      Value<String> productId,
      Value<String> batchId,
      Value<int> quantity,
      Value<String> reason,
      Value<String> status,
      Value<String?> requestedBy,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$DisposalsTableFilterComposer
    extends Composer<_$AppDatabase, $DisposalsTable> {
  $$DisposalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestedBy => $composableBuilder(
    column: $table.requestedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DisposalsTableOrderingComposer
    extends Composer<_$AppDatabase, $DisposalsTable> {
  $$DisposalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestedBy => $composableBuilder(
    column: $table.requestedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DisposalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DisposalsTable> {
  $$DisposalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get requestedBy => $composableBuilder(
    column: $table.requestedBy,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DisposalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DisposalsTable,
          Disposal,
          $$DisposalsTableFilterComposer,
          $$DisposalsTableOrderingComposer,
          $$DisposalsTableAnnotationComposer,
          $$DisposalsTableCreateCompanionBuilder,
          $$DisposalsTableUpdateCompanionBuilder,
          (Disposal, BaseReferences<_$AppDatabase, $DisposalsTable, Disposal>),
          Disposal,
          PrefetchHooks Function()
        > {
  $$DisposalsTableTableManager(_$AppDatabase db, $DisposalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DisposalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DisposalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DisposalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> batchId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> requestedBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DisposalsCompanion(
                id: id,
                productId: productId,
                batchId: batchId,
                quantity: quantity,
                reason: reason,
                status: status,
                requestedBy: requestedBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                required String batchId,
                required int quantity,
                required String reason,
                required String status,
                Value<String?> requestedBy = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DisposalsCompanion.insert(
                id: id,
                productId: productId,
                batchId: batchId,
                quantity: quantity,
                reason: reason,
                status: status,
                requestedBy: requestedBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DisposalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DisposalsTable,
      Disposal,
      $$DisposalsTableFilterComposer,
      $$DisposalsTableOrderingComposer,
      $$DisposalsTableAnnotationComposer,
      $$DisposalsTableCreateCompanionBuilder,
      $$DisposalsTableUpdateCompanionBuilder,
      (Disposal, BaseReferences<_$AppDatabase, $DisposalsTable, Disposal>),
      Disposal,
      PrefetchHooks Function()
    >;
typedef $$PhysicalAuditsTableCreateCompanionBuilder =
    PhysicalAuditsCompanion Function({
      required String id,
      required String productId,
      required String batchId,
      required int systemQuantity,
      required int physicalQuantity,
      required int discrepancy,
      Value<String?> notes,
      Value<String?> auditedBy,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PhysicalAuditsTableUpdateCompanionBuilder =
    PhysicalAuditsCompanion Function({
      Value<String> id,
      Value<String> productId,
      Value<String> batchId,
      Value<int> systemQuantity,
      Value<int> physicalQuantity,
      Value<int> discrepancy,
      Value<String?> notes,
      Value<String?> auditedBy,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$PhysicalAuditsTableFilterComposer
    extends Composer<_$AppDatabase, $PhysicalAuditsTable> {
  $$PhysicalAuditsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get systemQuantity => $composableBuilder(
    column: $table.systemQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get physicalQuantity => $composableBuilder(
    column: $table.physicalQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discrepancy => $composableBuilder(
    column: $table.discrepancy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get auditedBy => $composableBuilder(
    column: $table.auditedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PhysicalAuditsTableOrderingComposer
    extends Composer<_$AppDatabase, $PhysicalAuditsTable> {
  $$PhysicalAuditsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get systemQuantity => $composableBuilder(
    column: $table.systemQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get physicalQuantity => $composableBuilder(
    column: $table.physicalQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discrepancy => $composableBuilder(
    column: $table.discrepancy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get auditedBy => $composableBuilder(
    column: $table.auditedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PhysicalAuditsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhysicalAuditsTable> {
  $$PhysicalAuditsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<int> get systemQuantity => $composableBuilder(
    column: $table.systemQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get physicalQuantity => $composableBuilder(
    column: $table.physicalQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discrepancy => $composableBuilder(
    column: $table.discrepancy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get auditedBy =>
      $composableBuilder(column: $table.auditedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PhysicalAuditsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhysicalAuditsTable,
          PhysicalAudit,
          $$PhysicalAuditsTableFilterComposer,
          $$PhysicalAuditsTableOrderingComposer,
          $$PhysicalAuditsTableAnnotationComposer,
          $$PhysicalAuditsTableCreateCompanionBuilder,
          $$PhysicalAuditsTableUpdateCompanionBuilder,
          (
            PhysicalAudit,
            BaseReferences<_$AppDatabase, $PhysicalAuditsTable, PhysicalAudit>,
          ),
          PhysicalAudit,
          PrefetchHooks Function()
        > {
  $$PhysicalAuditsTableTableManager(
    _$AppDatabase db,
    $PhysicalAuditsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhysicalAuditsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhysicalAuditsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhysicalAuditsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> batchId = const Value.absent(),
                Value<int> systemQuantity = const Value.absent(),
                Value<int> physicalQuantity = const Value.absent(),
                Value<int> discrepancy = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> auditedBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhysicalAuditsCompanion(
                id: id,
                productId: productId,
                batchId: batchId,
                systemQuantity: systemQuantity,
                physicalQuantity: physicalQuantity,
                discrepancy: discrepancy,
                notes: notes,
                auditedBy: auditedBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                required String batchId,
                required int systemQuantity,
                required int physicalQuantity,
                required int discrepancy,
                Value<String?> notes = const Value.absent(),
                Value<String?> auditedBy = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PhysicalAuditsCompanion.insert(
                id: id,
                productId: productId,
                batchId: batchId,
                systemQuantity: systemQuantity,
                physicalQuantity: physicalQuantity,
                discrepancy: discrepancy,
                notes: notes,
                auditedBy: auditedBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PhysicalAuditsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhysicalAuditsTable,
      PhysicalAudit,
      $$PhysicalAuditsTableFilterComposer,
      $$PhysicalAuditsTableOrderingComposer,
      $$PhysicalAuditsTableAnnotationComposer,
      $$PhysicalAuditsTableCreateCompanionBuilder,
      $$PhysicalAuditsTableUpdateCompanionBuilder,
      (
        PhysicalAudit,
        BaseReferences<_$AppDatabase, $PhysicalAuditsTable, PhysicalAudit>,
      ),
      PhysicalAudit,
      PrefetchHooks Function()
    >;
typedef $$MutationsTableCreateCompanionBuilder =
    MutationsCompanion Function({
      Value<int> id,
      required String actionType,
      required String remoteTable,
      required String payload,
      Value<DateTime> createdAt,
    });
typedef $$MutationsTableUpdateCompanionBuilder =
    MutationsCompanion Function({
      Value<int> id,
      Value<String> actionType,
      Value<String> remoteTable,
      Value<String> payload,
      Value<DateTime> createdAt,
    });

class $$MutationsTableFilterComposer
    extends Composer<_$AppDatabase, $MutationsTable> {
  $$MutationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteTable => $composableBuilder(
    column: $table.remoteTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MutationsTableOrderingComposer
    extends Composer<_$AppDatabase, $MutationsTable> {
  $$MutationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteTable => $composableBuilder(
    column: $table.remoteTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MutationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MutationsTable> {
  $$MutationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteTable => $composableBuilder(
    column: $table.remoteTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MutationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MutationsTable,
          Mutation,
          $$MutationsTableFilterComposer,
          $$MutationsTableOrderingComposer,
          $$MutationsTableAnnotationComposer,
          $$MutationsTableCreateCompanionBuilder,
          $$MutationsTableUpdateCompanionBuilder,
          (Mutation, BaseReferences<_$AppDatabase, $MutationsTable, Mutation>),
          Mutation,
          PrefetchHooks Function()
        > {
  $$MutationsTableTableManager(_$AppDatabase db, $MutationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MutationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MutationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MutationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> actionType = const Value.absent(),
                Value<String> remoteTable = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MutationsCompanion(
                id: id,
                actionType: actionType,
                remoteTable: remoteTable,
                payload: payload,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String actionType,
                required String remoteTable,
                required String payload,
                Value<DateTime> createdAt = const Value.absent(),
              }) => MutationsCompanion.insert(
                id: id,
                actionType: actionType,
                remoteTable: remoteTable,
                payload: payload,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MutationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MutationsTable,
      Mutation,
      $$MutationsTableFilterComposer,
      $$MutationsTableOrderingComposer,
      $$MutationsTableAnnotationComposer,
      $$MutationsTableCreateCompanionBuilder,
      $$MutationsTableUpdateCompanionBuilder,
      (Mutation, BaseReferences<_$AppDatabase, $MutationsTable, Mutation>),
      Mutation,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$BatchesTableTableManager get batches =>
      $$BatchesTableTableManager(_db, _db.batches);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db, _db.orders);
  $$OrderItemsTableTableManager get orderItems =>
      $$OrderItemsTableTableManager(_db, _db.orderItems);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$DisposalsTableTableManager get disposals =>
      $$DisposalsTableTableManager(_db, _db.disposals);
  $$PhysicalAuditsTableTableManager get physicalAudits =>
      $$PhysicalAuditsTableTableManager(_db, _db.physicalAudits);
  $$MutationsTableTableManager get mutations =>
      $$MutationsTableTableManager(_db, _db.mutations);
}
