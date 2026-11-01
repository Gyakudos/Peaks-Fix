// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 120),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, phone, email, notes, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(Insertable<Customer> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class Customer extends DataClass implements Insertable<Customer> {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Customer(
      {required this.id,
      required this.name,
      this.phone,
      this.email,
      this.notes,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      name: Value(name),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Customer.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Customer copyWith(
          {int? id,
          String? name,
          Value<String?> phone = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Customer(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone.present ? phone.value : this.phone,
        email: email.present ? email.value : this.email,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Customer copyWithCompanion(CustomersCompanion data) {
    return Customer(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Customer(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, phone, email, notes, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Customer &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CustomersCompanion extends UpdateCompanion<Customer> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CustomersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Customer> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CustomersCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? phone,
      Value<String?>? email,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return CustomersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $DeviceCategoriesTable extends DeviceCategories
    with TableInfo<$DeviceCategoriesTable, DeviceCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviceCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 60),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _warrantyDaysMeta =
      const VerificationMeta('warrantyDays');
  @override
  late final GeneratedColumn<int> warrantyDays = GeneratedColumn<int>(
      'warranty_days', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(WarrantyConfig.defaultDays));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, sortOrder, warrantyDays, isActive];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_categories';
  @override
  VerificationContext validateIntegrity(Insertable<DeviceCategory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('warranty_days')) {
      context.handle(
          _warrantyDaysMeta,
          warrantyDays.isAcceptableOrUnknown(
              data['warranty_days']!, _warrantyDaysMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {name},
      ];
  @override
  DeviceCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceCategory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      warrantyDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}warranty_days'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $DeviceCategoriesTable createAlias(String alias) {
    return $DeviceCategoriesTable(attachedDatabase, alias);
  }
}

class DeviceCategory extends DataClass implements Insertable<DeviceCategory> {
  final int id;
  final String name;
  final int sortOrder;

  /// Warranty length offered on Report 3 for devices in this category.
  final int warrantyDays;
  final bool isActive;
  const DeviceCategory(
      {required this.id,
      required this.name,
      required this.sortOrder,
      required this.warrantyDays,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    map['warranty_days'] = Variable<int>(warrantyDays);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  DeviceCategoriesCompanion toCompanion(bool nullToAbsent) {
    return DeviceCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      sortOrder: Value(sortOrder),
      warrantyDays: Value(warrantyDays),
      isActive: Value(isActive),
    );
  }

  factory DeviceCategory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceCategory(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      warrantyDays: serializer.fromJson<int>(json['warrantyDays']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'warrantyDays': serializer.toJson<int>(warrantyDays),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  DeviceCategory copyWith(
          {int? id,
          String? name,
          int? sortOrder,
          int? warrantyDays,
          bool? isActive}) =>
      DeviceCategory(
        id: id ?? this.id,
        name: name ?? this.name,
        sortOrder: sortOrder ?? this.sortOrder,
        warrantyDays: warrantyDays ?? this.warrantyDays,
        isActive: isActive ?? this.isActive,
      );
  DeviceCategory copyWithCompanion(DeviceCategoriesCompanion data) {
    return DeviceCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      warrantyDays: data.warrantyDays.present
          ? data.warrantyDays.value
          : this.warrantyDays,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceCategory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('warrantyDays: $warrantyDays, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, sortOrder, warrantyDays, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceCategory &&
          other.id == this.id &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.warrantyDays == this.warrantyDays &&
          other.isActive == this.isActive);
}

class DeviceCategoriesCompanion extends UpdateCompanion<DeviceCategory> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<int> warrantyDays;
  final Value<bool> isActive;
  const DeviceCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.warrantyDays = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  DeviceCategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.sortOrder = const Value.absent(),
    this.warrantyDays = const Value.absent(),
    this.isActive = const Value.absent(),
  }) : name = Value(name);
  static Insertable<DeviceCategory> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<int>? warrantyDays,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (warrantyDays != null) 'warranty_days': warrantyDays,
      if (isActive != null) 'is_active': isActive,
    });
  }

  DeviceCategoriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int>? sortOrder,
      Value<int>? warrantyDays,
      Value<bool>? isActive}) {
    return DeviceCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      warrantyDays: warrantyDays ?? this.warrantyDays,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (warrantyDays.present) {
      map['warranty_days'] = Variable<int>(warrantyDays.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('warrantyDays: $warrantyDays, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $DeviceBrandsTable extends DeviceBrands
    with TableInfo<$DeviceBrandsTable, DeviceBrand> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviceBrandsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES device_categories (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 60),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [id, categoryId, name, isActive];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_brands';
  @override
  VerificationContext validateIntegrity(Insertable<DeviceBrand> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {categoryId, name},
      ];
  @override
  DeviceBrand map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceBrand(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $DeviceBrandsTable createAlias(String alias) {
    return $DeviceBrandsTable(attachedDatabase, alias);
  }
}

class DeviceBrand extends DataClass implements Insertable<DeviceBrand> {
  final int id;
  final int categoryId;
  final String name;
  final bool isActive;
  const DeviceBrand(
      {required this.id,
      required this.categoryId,
      required this.name,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category_id'] = Variable<int>(categoryId);
    map['name'] = Variable<String>(name);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  DeviceBrandsCompanion toCompanion(bool nullToAbsent) {
    return DeviceBrandsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      name: Value(name),
      isActive: Value(isActive),
    );
  }

  factory DeviceBrand.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceBrand(
      id: serializer.fromJson<int>(json['id']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      name: serializer.fromJson<String>(json['name']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<int>(categoryId),
      'name': serializer.toJson<String>(name),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  DeviceBrand copyWith(
          {int? id, int? categoryId, String? name, bool? isActive}) =>
      DeviceBrand(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        name: name ?? this.name,
        isActive: isActive ?? this.isActive,
      );
  DeviceBrand copyWithCompanion(DeviceBrandsCompanion data) {
    return DeviceBrand(
      id: data.id.present ? data.id.value : this.id,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      name: data.name.present ? data.name.value : this.name,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceBrand(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, categoryId, name, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceBrand &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.name == this.name &&
          other.isActive == this.isActive);
}

class DeviceBrandsCompanion extends UpdateCompanion<DeviceBrand> {
  final Value<int> id;
  final Value<int> categoryId;
  final Value<String> name;
  final Value<bool> isActive;
  const DeviceBrandsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.name = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  DeviceBrandsCompanion.insert({
    this.id = const Value.absent(),
    required int categoryId,
    required String name,
    this.isActive = const Value.absent(),
  })  : categoryId = Value(categoryId),
        name = Value(name);
  static Insertable<DeviceBrand> custom({
    Expression<int>? id,
    Expression<int>? categoryId,
    Expression<String>? name,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (name != null) 'name': name,
      if (isActive != null) 'is_active': isActive,
    });
  }

  DeviceBrandsCompanion copyWith(
      {Value<int>? id,
      Value<int>? categoryId,
      Value<String>? name,
      Value<bool>? isActive}) {
    return DeviceBrandsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceBrandsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $DeviceModelsTable extends DeviceModels
    with TableInfo<$DeviceModelsTable, DeviceModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviceModelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _brandIdMeta =
      const VerificationMeta('brandId');
  @override
  late final GeneratedColumn<int> brandId = GeneratedColumn<int>(
      'brand_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES device_brands (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 80),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _attributesMeta =
      const VerificationMeta('attributes');
  @override
  late final GeneratedColumn<String> attributes = GeneratedColumn<String>(
      'attributes', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _photoTemplateKeyMeta =
      const VerificationMeta('photoTemplateKey');
  @override
  late final GeneratedColumn<String> photoTemplateKey = GeneratedColumn<String>(
      'photo_template_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns =>
      [id, brandId, name, sortOrder, attributes, photoTemplateKey, isActive];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_models';
  @override
  VerificationContext validateIntegrity(Insertable<DeviceModel> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('brand_id')) {
      context.handle(_brandIdMeta,
          brandId.isAcceptableOrUnknown(data['brand_id']!, _brandIdMeta));
    } else if (isInserting) {
      context.missing(_brandIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('attributes')) {
      context.handle(
          _attributesMeta,
          attributes.isAcceptableOrUnknown(
              data['attributes']!, _attributesMeta));
    }
    if (data.containsKey('photo_template_key')) {
      context.handle(
          _photoTemplateKeyMeta,
          photoTemplateKey.isAcceptableOrUnknown(
              data['photo_template_key']!, _photoTemplateKeyMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {brandId, name},
      ];
  @override
  DeviceModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceModel(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      brandId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}brand_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      attributes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}attributes'])!,
      photoTemplateKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}photo_template_key']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $DeviceModelsTable createAlias(String alias) {
    return $DeviceModelsTable(attachedDatabase, alias);
  }
}

class DeviceModel extends DataClass implements Insertable<DeviceModel> {
  final int id;
  final int brandId;
  final String name;

  /// Position inside the brand's model list. Seeded models are numbered, so the
  /// picker can show `DualShock 1 … 4, DualSense 5` in generation order instead
  /// of alphabetically. `0` means "not chosen yet" and sorts after the rest.
  final int sortOrder;

  /// Free-form specs (serial format, RAM/SSD, ...) so new categories do not
  /// need a schema change.
  final String attributes;

  /// Which Report 1 photo checklist this model gets, e.g. `hinged`.
  final String? photoTemplateKey;
  final bool isActive;
  const DeviceModel(
      {required this.id,
      required this.brandId,
      required this.name,
      required this.sortOrder,
      required this.attributes,
      this.photoTemplateKey,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['brand_id'] = Variable<int>(brandId);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    map['attributes'] = Variable<String>(attributes);
    if (!nullToAbsent || photoTemplateKey != null) {
      map['photo_template_key'] = Variable<String>(photoTemplateKey);
    }
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  DeviceModelsCompanion toCompanion(bool nullToAbsent) {
    return DeviceModelsCompanion(
      id: Value(id),
      brandId: Value(brandId),
      name: Value(name),
      sortOrder: Value(sortOrder),
      attributes: Value(attributes),
      photoTemplateKey: photoTemplateKey == null && nullToAbsent
          ? const Value.absent()
          : Value(photoTemplateKey),
      isActive: Value(isActive),
    );
  }

  factory DeviceModel.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceModel(
      id: serializer.fromJson<int>(json['id']),
      brandId: serializer.fromJson<int>(json['brandId']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      attributes: serializer.fromJson<String>(json['attributes']),
      photoTemplateKey: serializer.fromJson<String?>(json['photoTemplateKey']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'brandId': serializer.toJson<int>(brandId),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'attributes': serializer.toJson<String>(attributes),
      'photoTemplateKey': serializer.toJson<String?>(photoTemplateKey),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  DeviceModel copyWith(
          {int? id,
          int? brandId,
          String? name,
          int? sortOrder,
          String? attributes,
          Value<String?> photoTemplateKey = const Value.absent(),
          bool? isActive}) =>
      DeviceModel(
        id: id ?? this.id,
        brandId: brandId ?? this.brandId,
        name: name ?? this.name,
        sortOrder: sortOrder ?? this.sortOrder,
        attributes: attributes ?? this.attributes,
        photoTemplateKey: photoTemplateKey.present
            ? photoTemplateKey.value
            : this.photoTemplateKey,
        isActive: isActive ?? this.isActive,
      );
  DeviceModel copyWithCompanion(DeviceModelsCompanion data) {
    return DeviceModel(
      id: data.id.present ? data.id.value : this.id,
      brandId: data.brandId.present ? data.brandId.value : this.brandId,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      attributes:
          data.attributes.present ? data.attributes.value : this.attributes,
      photoTemplateKey: data.photoTemplateKey.present
          ? data.photoTemplateKey.value
          : this.photoTemplateKey,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceModel(')
          ..write('id: $id, ')
          ..write('brandId: $brandId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('attributes: $attributes, ')
          ..write('photoTemplateKey: $photoTemplateKey, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, brandId, name, sortOrder, attributes, photoTemplateKey, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceModel &&
          other.id == this.id &&
          other.brandId == this.brandId &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.attributes == this.attributes &&
          other.photoTemplateKey == this.photoTemplateKey &&
          other.isActive == this.isActive);
}

class DeviceModelsCompanion extends UpdateCompanion<DeviceModel> {
  final Value<int> id;
  final Value<int> brandId;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<String> attributes;
  final Value<String?> photoTemplateKey;
  final Value<bool> isActive;
  const DeviceModelsCompanion({
    this.id = const Value.absent(),
    this.brandId = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.attributes = const Value.absent(),
    this.photoTemplateKey = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  DeviceModelsCompanion.insert({
    this.id = const Value.absent(),
    required int brandId,
    required String name,
    this.sortOrder = const Value.absent(),
    this.attributes = const Value.absent(),
    this.photoTemplateKey = const Value.absent(),
    this.isActive = const Value.absent(),
  })  : brandId = Value(brandId),
        name = Value(name);
  static Insertable<DeviceModel> custom({
    Expression<int>? id,
    Expression<int>? brandId,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<String>? attributes,
    Expression<String>? photoTemplateKey,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (brandId != null) 'brand_id': brandId,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (attributes != null) 'attributes': attributes,
      if (photoTemplateKey != null) 'photo_template_key': photoTemplateKey,
      if (isActive != null) 'is_active': isActive,
    });
  }

  DeviceModelsCompanion copyWith(
      {Value<int>? id,
      Value<int>? brandId,
      Value<String>? name,
      Value<int>? sortOrder,
      Value<String>? attributes,
      Value<String?>? photoTemplateKey,
      Value<bool>? isActive}) {
    return DeviceModelsCompanion(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      attributes: attributes ?? this.attributes,
      photoTemplateKey: photoTemplateKey ?? this.photoTemplateKey,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (brandId.present) {
      map['brand_id'] = Variable<int>(brandId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (attributes.present) {
      map['attributes'] = Variable<String>(attributes.value);
    }
    if (photoTemplateKey.present) {
      map['photo_template_key'] = Variable<String>(photoTemplateKey.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceModelsCompanion(')
          ..write('id: $id, ')
          ..write('brandId: $brandId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('attributes: $attributes, ')
          ..write('photoTemplateKey: $photoTemplateKey, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $CustomerDevicesTable extends CustomerDevices
    with TableInfo<$CustomerDevicesTable, CustomerDevice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomerDevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _customerIdMeta =
      const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
      'customer_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES customers (id)'));
  static const VerificationMeta _deviceModelIdMeta =
      const VerificationMeta('deviceModelId');
  @override
  late final GeneratedColumn<int> deviceModelId = GeneratedColumn<int>(
      'device_model_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES device_models (id)'));
  static const VerificationMeta _deviceNameMeta =
      const VerificationMeta('deviceName');
  @override
  late final GeneratedColumn<String> deviceName = GeneratedColumn<String>(
      'device_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deviceVariantMeta =
      const VerificationMeta('deviceVariant');
  @override
  late final GeneratedColumn<String> deviceVariant = GeneratedColumn<String>(
      'device_variant', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deviceSideMeta =
      const VerificationMeta('deviceSide');
  @override
  late final GeneratedColumn<String> deviceSide = GeneratedColumn<String>(
      'device_side', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _serialMeta = const VerificationMeta('serial');
  @override
  late final GeneratedColumn<String> serial = GeneratedColumn<String>(
      'serial', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _serialMissingMeta =
      const VerificationMeta('serialMissing');
  @override
  late final GeneratedColumn<bool> serialMissing = GeneratedColumn<bool>(
      'serial_missing', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("serial_missing" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        customerId,
        deviceModelId,
        deviceName,
        deviceVariant,
        deviceSide,
        serial,
        serialMissing,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customer_devices';
  @override
  VerificationContext validateIntegrity(Insertable<CustomerDevice> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('customer_id')) {
      context.handle(
          _customerIdMeta,
          customerId.isAcceptableOrUnknown(
              data['customer_id']!, _customerIdMeta));
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('device_model_id')) {
      context.handle(
          _deviceModelIdMeta,
          deviceModelId.isAcceptableOrUnknown(
              data['device_model_id']!, _deviceModelIdMeta));
    }
    if (data.containsKey('device_name')) {
      context.handle(
          _deviceNameMeta,
          deviceName.isAcceptableOrUnknown(
              data['device_name']!, _deviceNameMeta));
    }
    if (data.containsKey('device_variant')) {
      context.handle(
          _deviceVariantMeta,
          deviceVariant.isAcceptableOrUnknown(
              data['device_variant']!, _deviceVariantMeta));
    }
    if (data.containsKey('device_side')) {
      context.handle(
          _deviceSideMeta,
          deviceSide.isAcceptableOrUnknown(
              data['device_side']!, _deviceSideMeta));
    }
    if (data.containsKey('serial')) {
      context.handle(_serialMeta,
          serial.isAcceptableOrUnknown(data['serial']!, _serialMeta));
    }
    if (data.containsKey('serial_missing')) {
      context.handle(
          _serialMissingMeta,
          serialMissing.isAcceptableOrUnknown(
              data['serial_missing']!, _serialMissingMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomerDevice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerDevice(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      customerId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}customer_id'])!,
      deviceModelId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}device_model_id']),
      deviceName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_name']),
      deviceVariant: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_variant']),
      deviceSide: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_side']),
      serial: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}serial']),
      serialMissing: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}serial_missing'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CustomerDevicesTable createAlias(String alias) {
    return $CustomerDevicesTable(attachedDatabase, alias);
  }
}

class CustomerDevice extends DataClass implements Insertable<CustomerDevice> {
  final int id;
  final int customerId;
  final int? deviceModelId;
  final String? deviceName;
  final String? deviceVariant;
  final String? deviceSide;
  final String? serial;
  final bool serialMissing;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CustomerDevice(
      {required this.id,
      required this.customerId,
      this.deviceModelId,
      this.deviceName,
      this.deviceVariant,
      this.deviceSide,
      this.serial,
      required this.serialMissing,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['customer_id'] = Variable<int>(customerId);
    if (!nullToAbsent || deviceModelId != null) {
      map['device_model_id'] = Variable<int>(deviceModelId);
    }
    if (!nullToAbsent || deviceName != null) {
      map['device_name'] = Variable<String>(deviceName);
    }
    if (!nullToAbsent || deviceVariant != null) {
      map['device_variant'] = Variable<String>(deviceVariant);
    }
    if (!nullToAbsent || deviceSide != null) {
      map['device_side'] = Variable<String>(deviceSide);
    }
    if (!nullToAbsent || serial != null) {
      map['serial'] = Variable<String>(serial);
    }
    map['serial_missing'] = Variable<bool>(serialMissing);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CustomerDevicesCompanion toCompanion(bool nullToAbsent) {
    return CustomerDevicesCompanion(
      id: Value(id),
      customerId: Value(customerId),
      deviceModelId: deviceModelId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceModelId),
      deviceName: deviceName == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceName),
      deviceVariant: deviceVariant == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceVariant),
      deviceSide: deviceSide == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceSide),
      serial:
          serial == null && nullToAbsent ? const Value.absent() : Value(serial),
      serialMissing: Value(serialMissing),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CustomerDevice.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerDevice(
      id: serializer.fromJson<int>(json['id']),
      customerId: serializer.fromJson<int>(json['customerId']),
      deviceModelId: serializer.fromJson<int?>(json['deviceModelId']),
      deviceName: serializer.fromJson<String?>(json['deviceName']),
      deviceVariant: serializer.fromJson<String?>(json['deviceVariant']),
      deviceSide: serializer.fromJson<String?>(json['deviceSide']),
      serial: serializer.fromJson<String?>(json['serial']),
      serialMissing: serializer.fromJson<bool>(json['serialMissing']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'customerId': serializer.toJson<int>(customerId),
      'deviceModelId': serializer.toJson<int?>(deviceModelId),
      'deviceName': serializer.toJson<String?>(deviceName),
      'deviceVariant': serializer.toJson<String?>(deviceVariant),
      'deviceSide': serializer.toJson<String?>(deviceSide),
      'serial': serializer.toJson<String?>(serial),
      'serialMissing': serializer.toJson<bool>(serialMissing),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CustomerDevice copyWith(
          {int? id,
          int? customerId,
          Value<int?> deviceModelId = const Value.absent(),
          Value<String?> deviceName = const Value.absent(),
          Value<String?> deviceVariant = const Value.absent(),
          Value<String?> deviceSide = const Value.absent(),
          Value<String?> serial = const Value.absent(),
          bool? serialMissing,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      CustomerDevice(
        id: id ?? this.id,
        customerId: customerId ?? this.customerId,
        deviceModelId:
            deviceModelId.present ? deviceModelId.value : this.deviceModelId,
        deviceName: deviceName.present ? deviceName.value : this.deviceName,
        deviceVariant:
            deviceVariant.present ? deviceVariant.value : this.deviceVariant,
        deviceSide: deviceSide.present ? deviceSide.value : this.deviceSide,
        serial: serial.present ? serial.value : this.serial,
        serialMissing: serialMissing ?? this.serialMissing,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CustomerDevice copyWithCompanion(CustomerDevicesCompanion data) {
    return CustomerDevice(
      id: data.id.present ? data.id.value : this.id,
      customerId:
          data.customerId.present ? data.customerId.value : this.customerId,
      deviceModelId: data.deviceModelId.present
          ? data.deviceModelId.value
          : this.deviceModelId,
      deviceName:
          data.deviceName.present ? data.deviceName.value : this.deviceName,
      deviceVariant: data.deviceVariant.present
          ? data.deviceVariant.value
          : this.deviceVariant,
      deviceSide:
          data.deviceSide.present ? data.deviceSide.value : this.deviceSide,
      serial: data.serial.present ? data.serial.value : this.serial,
      serialMissing: data.serialMissing.present
          ? data.serialMissing.value
          : this.serialMissing,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerDevice(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('deviceModelId: $deviceModelId, ')
          ..write('deviceName: $deviceName, ')
          ..write('deviceVariant: $deviceVariant, ')
          ..write('deviceSide: $deviceSide, ')
          ..write('serial: $serial, ')
          ..write('serialMissing: $serialMissing, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, customerId, deviceModelId, deviceName,
      deviceVariant, deviceSide, serial, serialMissing, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerDevice &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.deviceModelId == this.deviceModelId &&
          other.deviceName == this.deviceName &&
          other.deviceVariant == this.deviceVariant &&
          other.deviceSide == this.deviceSide &&
          other.serial == this.serial &&
          other.serialMissing == this.serialMissing &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CustomerDevicesCompanion extends UpdateCompanion<CustomerDevice> {
  final Value<int> id;
  final Value<int> customerId;
  final Value<int?> deviceModelId;
  final Value<String?> deviceName;
  final Value<String?> deviceVariant;
  final Value<String?> deviceSide;
  final Value<String?> serial;
  final Value<bool> serialMissing;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CustomerDevicesCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.deviceModelId = const Value.absent(),
    this.deviceName = const Value.absent(),
    this.deviceVariant = const Value.absent(),
    this.deviceSide = const Value.absent(),
    this.serial = const Value.absent(),
    this.serialMissing = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CustomerDevicesCompanion.insert({
    this.id = const Value.absent(),
    required int customerId,
    this.deviceModelId = const Value.absent(),
    this.deviceName = const Value.absent(),
    this.deviceVariant = const Value.absent(),
    this.deviceSide = const Value.absent(),
    this.serial = const Value.absent(),
    this.serialMissing = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : customerId = Value(customerId);
  static Insertable<CustomerDevice> custom({
    Expression<int>? id,
    Expression<int>? customerId,
    Expression<int>? deviceModelId,
    Expression<String>? deviceName,
    Expression<String>? deviceVariant,
    Expression<String>? deviceSide,
    Expression<String>? serial,
    Expression<bool>? serialMissing,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (deviceModelId != null) 'device_model_id': deviceModelId,
      if (deviceName != null) 'device_name': deviceName,
      if (deviceVariant != null) 'device_variant': deviceVariant,
      if (deviceSide != null) 'device_side': deviceSide,
      if (serial != null) 'serial': serial,
      if (serialMissing != null) 'serial_missing': serialMissing,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CustomerDevicesCompanion copyWith(
      {Value<int>? id,
      Value<int>? customerId,
      Value<int?>? deviceModelId,
      Value<String?>? deviceName,
      Value<String?>? deviceVariant,
      Value<String?>? deviceSide,
      Value<String?>? serial,
      Value<bool>? serialMissing,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return CustomerDevicesCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      deviceModelId: deviceModelId ?? this.deviceModelId,
      deviceName: deviceName ?? this.deviceName,
      deviceVariant: deviceVariant ?? this.deviceVariant,
      deviceSide: deviceSide ?? this.deviceSide,
      serial: serial ?? this.serial,
      serialMissing: serialMissing ?? this.serialMissing,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (deviceModelId.present) {
      map['device_model_id'] = Variable<int>(deviceModelId.value);
    }
    if (deviceName.present) {
      map['device_name'] = Variable<String>(deviceName.value);
    }
    if (deviceVariant.present) {
      map['device_variant'] = Variable<String>(deviceVariant.value);
    }
    if (deviceSide.present) {
      map['device_side'] = Variable<String>(deviceSide.value);
    }
    if (serial.present) {
      map['serial'] = Variable<String>(serial.value);
    }
    if (serialMissing.present) {
      map['serial_missing'] = Variable<bool>(serialMissing.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomerDevicesCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('deviceModelId: $deviceModelId, ')
          ..write('deviceName: $deviceName, ')
          ..write('deviceVariant: $deviceVariant, ')
          ..write('deviceSide: $deviceSide, ')
          ..write('serial: $serial, ')
          ..write('serialMissing: $serialMissing, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PhotoTemplatesTable extends PhotoTemplates
    with TableInfo<$PhotoTemplatesTable, PhotoTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotoTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 40),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 80),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, key, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photo_templates';
  @override
  VerificationContext validateIntegrity(Insertable<PhotoTemplate> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {key},
      ];
  @override
  PhotoTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhotoTemplate(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $PhotoTemplatesTable createAlias(String alias) {
    return $PhotoTemplatesTable(attachedDatabase, alias);
  }
}

class PhotoTemplate extends DataClass implements Insertable<PhotoTemplate> {
  final int id;
  final String key;
  final String name;
  const PhotoTemplate(
      {required this.id, required this.key, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['key'] = Variable<String>(key);
    map['name'] = Variable<String>(name);
    return map;
  }

  PhotoTemplatesCompanion toCompanion(bool nullToAbsent) {
    return PhotoTemplatesCompanion(
      id: Value(id),
      key: Value(key),
      name: Value(name),
    );
  }

  factory PhotoTemplate.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhotoTemplate(
      id: serializer.fromJson<int>(json['id']),
      key: serializer.fromJson<String>(json['key']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'key': serializer.toJson<String>(key),
      'name': serializer.toJson<String>(name),
    };
  }

  PhotoTemplate copyWith({int? id, String? key, String? name}) => PhotoTemplate(
        id: id ?? this.id,
        key: key ?? this.key,
        name: name ?? this.name,
      );
  PhotoTemplate copyWithCompanion(PhotoTemplatesCompanion data) {
    return PhotoTemplate(
      id: data.id.present ? data.id.value : this.id,
      key: data.key.present ? data.key.value : this.key,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhotoTemplate(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, key, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhotoTemplate &&
          other.id == this.id &&
          other.key == this.key &&
          other.name == this.name);
}

class PhotoTemplatesCompanion extends UpdateCompanion<PhotoTemplate> {
  final Value<int> id;
  final Value<String> key;
  final Value<String> name;
  const PhotoTemplatesCompanion({
    this.id = const Value.absent(),
    this.key = const Value.absent(),
    this.name = const Value.absent(),
  });
  PhotoTemplatesCompanion.insert({
    this.id = const Value.absent(),
    required String key,
    required String name,
  })  : key = Value(key),
        name = Value(name);
  static Insertable<PhotoTemplate> custom({
    Expression<int>? id,
    Expression<String>? key,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (key != null) 'key': key,
      if (name != null) 'name': name,
    });
  }

  PhotoTemplatesCompanion copyWith(
      {Value<int>? id, Value<String>? key, Value<String>? name}) {
    return PhotoTemplatesCompanion(
      id: id ?? this.id,
      key: key ?? this.key,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotoTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $PhotoTemplateSlotsTable extends PhotoTemplateSlots
    with TableInfo<$PhotoTemplateSlotsTable, PhotoTemplateSlot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotoTemplateSlotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _templateIdMeta =
      const VerificationMeta('templateId');
  @override
  late final GeneratedColumn<int> templateId = GeneratedColumn<int>(
      'template_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES photo_templates (id)'));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 80),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _hintMeta = const VerificationMeta('hint');
  @override
  late final GeneratedColumn<String> hint = GeneratedColumn<String>(
      'hint', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _requiredMeta =
      const VerificationMeta('required');
  @override
  late final GeneratedColumn<bool> required = GeneratedColumn<bool>(
      'required', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("required" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns =>
      [id, templateId, sortOrder, label, hint, required];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photo_template_slots';
  @override
  VerificationContext validateIntegrity(Insertable<PhotoTemplateSlot> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('template_id')) {
      context.handle(
          _templateIdMeta,
          templateId.isAcceptableOrUnknown(
              data['template_id']!, _templateIdMeta));
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('hint')) {
      context.handle(
          _hintMeta, hint.isAcceptableOrUnknown(data['hint']!, _hintMeta));
    }
    if (data.containsKey('required')) {
      context.handle(_requiredMeta,
          required.isAcceptableOrUnknown(data['required']!, _requiredMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {templateId, sortOrder},
      ];
  @override
  PhotoTemplateSlot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhotoTemplateSlot(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      templateId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}template_id'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      hint: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hint']),
      required: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}required'])!,
    );
  }

  @override
  $PhotoTemplateSlotsTable createAlias(String alias) {
    return $PhotoTemplateSlotsTable(attachedDatabase, alias);
  }
}

class PhotoTemplateSlot extends DataClass
    implements Insertable<PhotoTemplateSlot> {
  final int id;
  final int templateId;
  final int sortOrder;
  final String label;
  final String? hint;
  final bool required;
  const PhotoTemplateSlot(
      {required this.id,
      required this.templateId,
      required this.sortOrder,
      required this.label,
      this.hint,
      required this.required});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['template_id'] = Variable<int>(templateId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || hint != null) {
      map['hint'] = Variable<String>(hint);
    }
    map['required'] = Variable<bool>(required);
    return map;
  }

  PhotoTemplateSlotsCompanion toCompanion(bool nullToAbsent) {
    return PhotoTemplateSlotsCompanion(
      id: Value(id),
      templateId: Value(templateId),
      sortOrder: Value(sortOrder),
      label: Value(label),
      hint: hint == null && nullToAbsent ? const Value.absent() : Value(hint),
      required: Value(required),
    );
  }

  factory PhotoTemplateSlot.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhotoTemplateSlot(
      id: serializer.fromJson<int>(json['id']),
      templateId: serializer.fromJson<int>(json['templateId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      label: serializer.fromJson<String>(json['label']),
      hint: serializer.fromJson<String?>(json['hint']),
      required: serializer.fromJson<bool>(json['required']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'templateId': serializer.toJson<int>(templateId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'label': serializer.toJson<String>(label),
      'hint': serializer.toJson<String?>(hint),
      'required': serializer.toJson<bool>(required),
    };
  }

  PhotoTemplateSlot copyWith(
          {int? id,
          int? templateId,
          int? sortOrder,
          String? label,
          Value<String?> hint = const Value.absent(),
          bool? required}) =>
      PhotoTemplateSlot(
        id: id ?? this.id,
        templateId: templateId ?? this.templateId,
        sortOrder: sortOrder ?? this.sortOrder,
        label: label ?? this.label,
        hint: hint.present ? hint.value : this.hint,
        required: required ?? this.required,
      );
  PhotoTemplateSlot copyWithCompanion(PhotoTemplateSlotsCompanion data) {
    return PhotoTemplateSlot(
      id: data.id.present ? data.id.value : this.id,
      templateId:
          data.templateId.present ? data.templateId.value : this.templateId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      label: data.label.present ? data.label.value : this.label,
      hint: data.hint.present ? data.hint.value : this.hint,
      required: data.required.present ? data.required.value : this.required,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhotoTemplateSlot(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('label: $label, ')
          ..write('hint: $hint, ')
          ..write('required: $required')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, templateId, sortOrder, label, hint, required);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhotoTemplateSlot &&
          other.id == this.id &&
          other.templateId == this.templateId &&
          other.sortOrder == this.sortOrder &&
          other.label == this.label &&
          other.hint == this.hint &&
          other.required == this.required);
}

class PhotoTemplateSlotsCompanion extends UpdateCompanion<PhotoTemplateSlot> {
  final Value<int> id;
  final Value<int> templateId;
  final Value<int> sortOrder;
  final Value<String> label;
  final Value<String?> hint;
  final Value<bool> required;
  const PhotoTemplateSlotsCompanion({
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.label = const Value.absent(),
    this.hint = const Value.absent(),
    this.required = const Value.absent(),
  });
  PhotoTemplateSlotsCompanion.insert({
    this.id = const Value.absent(),
    required int templateId,
    required int sortOrder,
    required String label,
    this.hint = const Value.absent(),
    this.required = const Value.absent(),
  })  : templateId = Value(templateId),
        sortOrder = Value(sortOrder),
        label = Value(label);
  static Insertable<PhotoTemplateSlot> custom({
    Expression<int>? id,
    Expression<int>? templateId,
    Expression<int>? sortOrder,
    Expression<String>? label,
    Expression<String>? hint,
    Expression<bool>? required,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (label != null) 'label': label,
      if (hint != null) 'hint': hint,
      if (required != null) 'required': required,
    });
  }

  PhotoTemplateSlotsCompanion copyWith(
      {Value<int>? id,
      Value<int>? templateId,
      Value<int>? sortOrder,
      Value<String>? label,
      Value<String?>? hint,
      Value<bool>? required}) {
    return PhotoTemplateSlotsCompanion(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      sortOrder: sortOrder ?? this.sortOrder,
      label: label ?? this.label,
      hint: hint ?? this.hint,
      required: required ?? this.required,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<int>(templateId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (hint.present) {
      map['hint'] = Variable<String>(hint.value);
    }
    if (required.present) {
      map['required'] = Variable<bool>(required.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotoTemplateSlotsCompanion(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('label: $label, ')
          ..write('hint: $hint, ')
          ..write('required: $required')
          ..write(')'))
        .toString();
  }
}

class $ServicesTable extends Services with TableInfo<$ServicesTable, Service> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 120),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES device_categories (id)'));
  static const VerificationMeta _defaultPriceCentsMeta =
      const VerificationMeta('defaultPriceCents');
  @override
  late final GeneratedColumn<int> defaultPriceCents = GeneratedColumn<int>(
      'default_price_cents', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _defaultMinutesMeta =
      const VerificationMeta('defaultMinutes');
  @override
  late final GeneratedColumn<int> defaultMinutes = GeneratedColumn<int>(
      'default_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, categoryId, defaultPriceCents, defaultMinutes, isActive];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'services';
  @override
  VerificationContext validateIntegrity(Insertable<Service> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('default_price_cents')) {
      context.handle(
          _defaultPriceCentsMeta,
          defaultPriceCents.isAcceptableOrUnknown(
              data['default_price_cents']!, _defaultPriceCentsMeta));
    }
    if (data.containsKey('default_minutes')) {
      context.handle(
          _defaultMinutesMeta,
          defaultMinutes.isAcceptableOrUnknown(
              data['default_minutes']!, _defaultMinutesMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Service map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Service(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id']),
      defaultPriceCents: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}default_price_cents'])!,
      defaultMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}default_minutes'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $ServicesTable createAlias(String alias) {
    return $ServicesTable(attachedDatabase, alias);
  }
}

class Service extends DataClass implements Insertable<Service> {
  final int id;
  final String name;
  final int? categoryId;
  final int defaultPriceCents;
  final int defaultMinutes;
  final bool isActive;
  const Service(
      {required this.id,
      required this.name,
      this.categoryId,
      required this.defaultPriceCents,
      required this.defaultMinutes,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['default_price_cents'] = Variable<int>(defaultPriceCents);
    map['default_minutes'] = Variable<int>(defaultMinutes);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  ServicesCompanion toCompanion(bool nullToAbsent) {
    return ServicesCompanion(
      id: Value(id),
      name: Value(name),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      defaultPriceCents: Value(defaultPriceCents),
      defaultMinutes: Value(defaultMinutes),
      isActive: Value(isActive),
    );
  }

  factory Service.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Service(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      defaultPriceCents: serializer.fromJson<int>(json['defaultPriceCents']),
      defaultMinutes: serializer.fromJson<int>(json['defaultMinutes']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'categoryId': serializer.toJson<int?>(categoryId),
      'defaultPriceCents': serializer.toJson<int>(defaultPriceCents),
      'defaultMinutes': serializer.toJson<int>(defaultMinutes),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  Service copyWith(
          {int? id,
          String? name,
          Value<int?> categoryId = const Value.absent(),
          int? defaultPriceCents,
          int? defaultMinutes,
          bool? isActive}) =>
      Service(
        id: id ?? this.id,
        name: name ?? this.name,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        defaultPriceCents: defaultPriceCents ?? this.defaultPriceCents,
        defaultMinutes: defaultMinutes ?? this.defaultMinutes,
        isActive: isActive ?? this.isActive,
      );
  Service copyWithCompanion(ServicesCompanion data) {
    return Service(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      defaultPriceCents: data.defaultPriceCents.present
          ? data.defaultPriceCents.value
          : this.defaultPriceCents,
      defaultMinutes: data.defaultMinutes.present
          ? data.defaultMinutes.value
          : this.defaultMinutes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Service(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('defaultPriceCents: $defaultPriceCents, ')
          ..write('defaultMinutes: $defaultMinutes, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, categoryId, defaultPriceCents, defaultMinutes, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Service &&
          other.id == this.id &&
          other.name == this.name &&
          other.categoryId == this.categoryId &&
          other.defaultPriceCents == this.defaultPriceCents &&
          other.defaultMinutes == this.defaultMinutes &&
          other.isActive == this.isActive);
}

class ServicesCompanion extends UpdateCompanion<Service> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> categoryId;
  final Value<int> defaultPriceCents;
  final Value<int> defaultMinutes;
  final Value<bool> isActive;
  const ServicesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.defaultPriceCents = const Value.absent(),
    this.defaultMinutes = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  ServicesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.categoryId = const Value.absent(),
    this.defaultPriceCents = const Value.absent(),
    this.defaultMinutes = const Value.absent(),
    this.isActive = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Service> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? categoryId,
    Expression<int>? defaultPriceCents,
    Expression<int>? defaultMinutes,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (categoryId != null) 'category_id': categoryId,
      if (defaultPriceCents != null) 'default_price_cents': defaultPriceCents,
      if (defaultMinutes != null) 'default_minutes': defaultMinutes,
      if (isActive != null) 'is_active': isActive,
    });
  }

  ServicesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int?>? categoryId,
      Value<int>? defaultPriceCents,
      Value<int>? defaultMinutes,
      Value<bool>? isActive}) {
    return ServicesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      defaultPriceCents: defaultPriceCents ?? this.defaultPriceCents,
      defaultMinutes: defaultMinutes ?? this.defaultMinutes,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (defaultPriceCents.present) {
      map['default_price_cents'] = Variable<int>(defaultPriceCents.value);
    }
    if (defaultMinutes.present) {
      map['default_minutes'] = Variable<int>(defaultMinutes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServicesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('defaultPriceCents: $defaultPriceCents, ')
          ..write('defaultMinutes: $defaultMinutes, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $TicketsTable extends Tickets with TableInfo<$TicketsTable, Ticket> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TicketsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<String> number = GeneratedColumn<String>(
      'number', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 24),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _customerIdMeta =
      const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
      'customer_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES customers (id)'));
  static const VerificationMeta _customerDeviceIdMeta =
      const VerificationMeta('customerDeviceId');
  @override
  late final GeneratedColumn<int> customerDeviceId = GeneratedColumn<int>(
      'customer_device_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES customer_devices (id)'));
  static const VerificationMeta _deviceModelIdMeta =
      const VerificationMeta('deviceModelId');
  @override
  late final GeneratedColumn<int> deviceModelId = GeneratedColumn<int>(
      'device_model_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES device_models (id)'));
  static const VerificationMeta _deviceNameMeta =
      const VerificationMeta('deviceName');
  @override
  late final GeneratedColumn<String> deviceName = GeneratedColumn<String>(
      'device_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deviceVariantMeta =
      const VerificationMeta('deviceVariant');
  @override
  late final GeneratedColumn<String> deviceVariant = GeneratedColumn<String>(
      'device_variant', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deviceSideMeta =
      const VerificationMeta('deviceSide');
  @override
  late final GeneratedColumn<String> deviceSide = GeneratedColumn<String>(
      'device_side', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _serialMeta = const VerificationMeta('serial');
  @override
  late final GeneratedColumn<String> serial = GeneratedColumn<String>(
      'serial', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _serialMissingMeta =
      const VerificationMeta('serialMissing');
  @override
  late final GeneratedColumn<bool> serialMissing = GeneratedColumn<bool>(
      'serial_missing', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("serial_missing" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _shopTagMeta =
      const VerificationMeta('shopTag');
  @override
  late final GeneratedColumn<String> shopTag = GeneratedColumn<String>(
      'shop_tag', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _complaintMeta =
      const VerificationMeta('complaint');
  @override
  late final GeneratedColumn<String> complaint = GeneratedColumn<String>(
      'complaint', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _diagnosisMeta =
      const VerificationMeta('diagnosis');
  @override
  late final GeneratedColumn<String> diagnosis = GeneratedColumn<String>(
      'diagnosis', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _intakeNotesMeta =
      const VerificationMeta('intakeNotes');
  @override
  late final GeneratedColumn<String> intakeNotes = GeneratedColumn<String>(
      'intake_notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _report1CompletedAtMeta =
      const VerificationMeta('report1CompletedAt');
  @override
  late final GeneratedColumn<DateTime> report1CompletedAt =
      GeneratedColumn<DateTime>('report1_completed_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _report2CompletedAtMeta =
      const VerificationMeta('report2CompletedAt');
  @override
  late final GeneratedColumn<DateTime> report2CompletedAt =
      GeneratedColumn<DateTime>('report2_completed_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _report3CompletedAtMeta =
      const VerificationMeta('report3CompletedAt');
  @override
  late final GeneratedColumn<DateTime> report3CompletedAt =
      GeneratedColumn<DateTime>('report3_completed_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _dropOffAtMeta =
      const VerificationMeta('dropOffAt');
  @override
  late final GeneratedColumn<DateTime> dropOffAt = GeneratedColumn<DateTime>(
      'drop_off_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _technicianStartAtMeta =
      const VerificationMeta('technicianStartAt');
  @override
  late final GeneratedColumn<DateTime> technicianStartAt =
      GeneratedColumn<DateTime>('technician_start_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _partsArriveAtMeta =
      const VerificationMeta('partsArriveAt');
  @override
  late final GeneratedColumn<DateTime> partsArriveAt =
      GeneratedColumn<DateTime>('parts_arrive_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _customerContactedAtMeta =
      const VerificationMeta('customerContactedAt');
  @override
  late final GeneratedColumn<DateTime> customerContactedAt =
      GeneratedColumn<DateTime>('customer_contacted_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _photoTemplateKeyMeta =
      const VerificationMeta('photoTemplateKey');
  @override
  late final GeneratedColumn<String> photoTemplateKey = GeneratedColumn<String>(
      'photo_template_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<TicketStatus, int> status =
      GeneratedColumn<int>('status', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<TicketStatus>($TicketsTable.$converterstatus);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _estimateCentsMeta =
      const VerificationMeta('estimateCents');
  @override
  late final GeneratedColumn<int> estimateCents = GeneratedColumn<int>(
      'estimate_cents', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  late final GeneratedColumnWithTypeConverter<InvoiceDiscountKind, int>
      invoiceDiscountKind = GeneratedColumn<int>(
              'invoice_discount_kind', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              defaultValue: const Constant(0))
          .withConverter<InvoiceDiscountKind>(
              $TicketsTable.$converterinvoiceDiscountKind);
  static const VerificationMeta _invoiceDiscountValueMeta =
      const VerificationMeta('invoiceDiscountValue');
  @override
  late final GeneratedColumn<int> invoiceDiscountValue = GeneratedColumn<int>(
      'invoice_discount_value', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _partnerNameMeta =
      const VerificationMeta('partnerName');
  @override
  late final GeneratedColumn<String> partnerName = GeneratedColumn<String>(
      'partner_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _partnerPartsPercentMeta =
      const VerificationMeta('partnerPartsPercent');
  @override
  late final GeneratedColumn<int> partnerPartsPercent = GeneratedColumn<int>(
      'partner_parts_percent', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _partnerLabourPercentMeta =
      const VerificationMeta('partnerLabourPercent');
  @override
  late final GeneratedColumn<int> partnerLabourPercent = GeneratedColumn<int>(
      'partner_labour_percent', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _gstCentsMeta =
      const VerificationMeta('gstCents');
  @override
  late final GeneratedColumn<int> gstCents = GeneratedColumn<int>(
      'gst_cents', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _pstCentsMeta =
      const VerificationMeta('pstCents');
  @override
  late final GeneratedColumn<int> pstCents = GeneratedColumn<int>(
      'pst_cents', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
      'due_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _pickedUpAtMeta =
      const VerificationMeta('pickedUpAt');
  @override
  late final GeneratedColumn<DateTime> pickedUpAt = GeneratedColumn<DateTime>(
      'picked_up_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        number,
        customerId,
        customerDeviceId,
        deviceModelId,
        deviceName,
        deviceVariant,
        deviceSide,
        serial,
        serialMissing,
        shopTag,
        complaint,
        diagnosis,
        intakeNotes,
        report1CompletedAt,
        report2CompletedAt,
        report3CompletedAt,
        dropOffAt,
        technicianStartAt,
        partsArriveAt,
        customerContactedAt,
        photoTemplateKey,
        status,
        priority,
        estimateCents,
        invoiceDiscountKind,
        invoiceDiscountValue,
        notes,
        partnerName,
        partnerPartsPercent,
        partnerLabourPercent,
        gstCents,
        pstCents,
        createdAt,
        updatedAt,
        dueAt,
        completedAt,
        pickedUpAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tickets';
  @override
  VerificationContext validateIntegrity(Insertable<Ticket> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('number')) {
      context.handle(_numberMeta,
          number.isAcceptableOrUnknown(data['number']!, _numberMeta));
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
          _customerIdMeta,
          customerId.isAcceptableOrUnknown(
              data['customer_id']!, _customerIdMeta));
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('customer_device_id')) {
      context.handle(
          _customerDeviceIdMeta,
          customerDeviceId.isAcceptableOrUnknown(
              data['customer_device_id']!, _customerDeviceIdMeta));
    }
    if (data.containsKey('device_model_id')) {
      context.handle(
          _deviceModelIdMeta,
          deviceModelId.isAcceptableOrUnknown(
              data['device_model_id']!, _deviceModelIdMeta));
    }
    if (data.containsKey('device_name')) {
      context.handle(
          _deviceNameMeta,
          deviceName.isAcceptableOrUnknown(
              data['device_name']!, _deviceNameMeta));
    }
    if (data.containsKey('device_variant')) {
      context.handle(
          _deviceVariantMeta,
          deviceVariant.isAcceptableOrUnknown(
              data['device_variant']!, _deviceVariantMeta));
    }
    if (data.containsKey('device_side')) {
      context.handle(
          _deviceSideMeta,
          deviceSide.isAcceptableOrUnknown(
              data['device_side']!, _deviceSideMeta));
    }
    if (data.containsKey('serial')) {
      context.handle(_serialMeta,
          serial.isAcceptableOrUnknown(data['serial']!, _serialMeta));
    }
    if (data.containsKey('serial_missing')) {
      context.handle(
          _serialMissingMeta,
          serialMissing.isAcceptableOrUnknown(
              data['serial_missing']!, _serialMissingMeta));
    }
    if (data.containsKey('shop_tag')) {
      context.handle(_shopTagMeta,
          shopTag.isAcceptableOrUnknown(data['shop_tag']!, _shopTagMeta));
    }
    if (data.containsKey('complaint')) {
      context.handle(_complaintMeta,
          complaint.isAcceptableOrUnknown(data['complaint']!, _complaintMeta));
    } else if (isInserting) {
      context.missing(_complaintMeta);
    }
    if (data.containsKey('diagnosis')) {
      context.handle(_diagnosisMeta,
          diagnosis.isAcceptableOrUnknown(data['diagnosis']!, _diagnosisMeta));
    }
    if (data.containsKey('intake_notes')) {
      context.handle(
          _intakeNotesMeta,
          intakeNotes.isAcceptableOrUnknown(
              data['intake_notes']!, _intakeNotesMeta));
    }
    if (data.containsKey('report1_completed_at')) {
      context.handle(
          _report1CompletedAtMeta,
          report1CompletedAt.isAcceptableOrUnknown(
              data['report1_completed_at']!, _report1CompletedAtMeta));
    }
    if (data.containsKey('report2_completed_at')) {
      context.handle(
          _report2CompletedAtMeta,
          report2CompletedAt.isAcceptableOrUnknown(
              data['report2_completed_at']!, _report2CompletedAtMeta));
    }
    if (data.containsKey('report3_completed_at')) {
      context.handle(
          _report3CompletedAtMeta,
          report3CompletedAt.isAcceptableOrUnknown(
              data['report3_completed_at']!, _report3CompletedAtMeta));
    }
    if (data.containsKey('drop_off_at')) {
      context.handle(
          _dropOffAtMeta,
          dropOffAt.isAcceptableOrUnknown(
              data['drop_off_at']!, _dropOffAtMeta));
    }
    if (data.containsKey('technician_start_at')) {
      context.handle(
          _technicianStartAtMeta,
          technicianStartAt.isAcceptableOrUnknown(
              data['technician_start_at']!, _technicianStartAtMeta));
    }
    if (data.containsKey('parts_arrive_at')) {
      context.handle(
          _partsArriveAtMeta,
          partsArriveAt.isAcceptableOrUnknown(
              data['parts_arrive_at']!, _partsArriveAtMeta));
    }
    if (data.containsKey('customer_contacted_at')) {
      context.handle(
          _customerContactedAtMeta,
          customerContactedAt.isAcceptableOrUnknown(
              data['customer_contacted_at']!, _customerContactedAtMeta));
    }
    if (data.containsKey('photo_template_key')) {
      context.handle(
          _photoTemplateKeyMeta,
          photoTemplateKey.isAcceptableOrUnknown(
              data['photo_template_key']!, _photoTemplateKeyMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('estimate_cents')) {
      context.handle(
          _estimateCentsMeta,
          estimateCents.isAcceptableOrUnknown(
              data['estimate_cents']!, _estimateCentsMeta));
    }
    if (data.containsKey('invoice_discount_value')) {
      context.handle(
          _invoiceDiscountValueMeta,
          invoiceDiscountValue.isAcceptableOrUnknown(
              data['invoice_discount_value']!, _invoiceDiscountValueMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('partner_name')) {
      context.handle(
          _partnerNameMeta,
          partnerName.isAcceptableOrUnknown(
              data['partner_name']!, _partnerNameMeta));
    }
    if (data.containsKey('partner_parts_percent')) {
      context.handle(
          _partnerPartsPercentMeta,
          partnerPartsPercent.isAcceptableOrUnknown(
              data['partner_parts_percent']!, _partnerPartsPercentMeta));
    }
    if (data.containsKey('partner_labour_percent')) {
      context.handle(
          _partnerLabourPercentMeta,
          partnerLabourPercent.isAcceptableOrUnknown(
              data['partner_labour_percent']!, _partnerLabourPercentMeta));
    }
    if (data.containsKey('gst_cents')) {
      context.handle(_gstCentsMeta,
          gstCents.isAcceptableOrUnknown(data['gst_cents']!, _gstCentsMeta));
    }
    if (data.containsKey('pst_cents')) {
      context.handle(_pstCentsMeta,
          pstCents.isAcceptableOrUnknown(data['pst_cents']!, _pstCentsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('due_at')) {
      context.handle(
          _dueAtMeta, dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('picked_up_at')) {
      context.handle(
          _pickedUpAtMeta,
          pickedUpAt.isAcceptableOrUnknown(
              data['picked_up_at']!, _pickedUpAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {number},
      ];
  @override
  Ticket map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ticket(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      number: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}number'])!,
      customerId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}customer_id'])!,
      customerDeviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}customer_device_id']),
      deviceModelId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}device_model_id']),
      deviceName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_name']),
      deviceVariant: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_variant']),
      deviceSide: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_side']),
      serial: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}serial']),
      serialMissing: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}serial_missing'])!,
      shopTag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shop_tag']),
      complaint: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}complaint'])!,
      diagnosis: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}diagnosis']),
      intakeNotes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}intake_notes']),
      report1CompletedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}report1_completed_at']),
      report2CompletedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}report2_completed_at']),
      report3CompletedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}report3_completed_at']),
      dropOffAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}drop_off_at']),
      technicianStartAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}technician_start_at']),
      partsArriveAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}parts_arrive_at']),
      customerContactedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}customer_contacted_at']),
      photoTemplateKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}photo_template_key']),
      status: $TicketsTable.$converterstatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!),
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      estimateCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}estimate_cents'])!,
      invoiceDiscountKind: $TicketsTable.$converterinvoiceDiscountKind.fromSql(
          attachedDatabase.typeMapping.read(DriftSqlType.int,
              data['${effectivePrefix}invoice_discount_kind'])!),
      invoiceDiscountValue: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}invoice_discount_value'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      partnerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}partner_name'])!,
      partnerPartsPercent: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}partner_parts_percent'])!,
      partnerLabourPercent: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}partner_labour_percent'])!,
      gstCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}gst_cents'])!,
      pstCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pst_cents'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      dueAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_at']),
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      pickedUpAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}picked_up_at']),
    );
  }

  @override
  $TicketsTable createAlias(String alias) {
    return $TicketsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TicketStatus, int, int> $converterstatus =
      const EnumIndexConverter<TicketStatus>(TicketStatus.values);
  static JsonTypeConverter2<InvoiceDiscountKind, int, int>
      $converterinvoiceDiscountKind =
      const EnumIndexConverter<InvoiceDiscountKind>(InvoiceDiscountKind.values);
}

class Ticket extends DataClass implements Insertable<Ticket> {
  final int id;

  /// Human-facing job number, e.g. `PF-000123`. Never reused.
  final String number;
  final int customerId;
  final int? customerDeviceId;

  /// Null when the device is not in the catalog yet; [deviceName] is then the
  /// free-text description.
  final int? deviceModelId;
  final String? deviceName;

  /// Model number or variant within a catalog family, e.g. `PSP-3000`,
  /// `New 3DS XL`, `PS5 Slim (disc)`. Kept free-text so one catalog row can
  /// cover a whole family without inventing rows for every revision.
  final String? deviceVariant;

  /// Which half of a two-part device this job is: `left` or `right`. Set for a
  /// single Joy-Con, where the model alone does not identify the unit.
  final String? deviceSide;

  /// Serial exactly as printed on the device, or the shop-applied serial
  /// (`PFS-482913057`) when the factory sticker is gone.
  final String? serial;

  /// No readable factory serial/IMEI sticker was present. [serial] then holds
  /// the shop-applied serial, so a missing sticker still has a stable identity.
  final bool serialMissing;

  /// The tag currently stuck on the device, e.g. `G-482913057`. The full issue
  /// history lives in [ShopTags]; this is the value printed on the paperwork.
  final String? shopTag;
  final String complaint;
  final String? diagnosis;

  /// Report 1 condition notes: scratches, cracks, stickers, missing parts and
  /// anything else the photos do not make obvious.
  final String? intakeNotes;

  /// When Report 1 was marked complete. Report 2 stays locked until this is
  /// set; reopening Report 1 clears it.
  final DateTime? report1CompletedAt;

  /// When the technical (report 2) stage was marked complete. The client report
  /// stays editable either way.
  final DateTime? report2CompletedAt;

  /// When the client report (report 3) was marked complete. Completing it also
  /// moves the ticket to [TicketStatus.ready] so it appears in Checkout.
  final DateTime? report3CompletedAt;

  /// Shop workflow dates. Drop-off falls back to the ticket creation date on
  /// older records; pickup reuses [pickedUpAt].
  final DateTime? dropOffAt;
  final DateTime? technicianStartAt;
  final DateTime? partsArriveAt;
  final DateTime? customerContactedAt;

  /// Report 1 checklist family this job was booked under, e.g. `hinged`. The
  /// slots themselves are copied into [TicketPhotoSlots] at intake.
  final String? photoTemplateKey;
  final TicketStatus status;
  final int priority;
  final int estimateCents;
  final InvoiceDiscountKind invoiceDiscountKind;
  final int invoiceDiscountValue;
  final String? notes;

  /// The partner (drop-off location) the ticket came through, kept as text so
  /// it survives the partner being removed.
  final String partnerName;

  /// Partner discount, as a percentage of the parts and of the labour on the
  /// invoice. Applied on top of the manual discount.
  final int partnerPartsPercent;
  final int partnerLabourPercent;

  /// Tax snapshot taken when the ticket is closed, so later rate changes never
  /// rewrite an old invoice. Revenue stays pre-tax on Financial.
  final int gstCents;
  final int pstCents;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueAt;
  final DateTime? completedAt;
  final DateTime? pickedUpAt;
  const Ticket(
      {required this.id,
      required this.number,
      required this.customerId,
      this.customerDeviceId,
      this.deviceModelId,
      this.deviceName,
      this.deviceVariant,
      this.deviceSide,
      this.serial,
      required this.serialMissing,
      this.shopTag,
      required this.complaint,
      this.diagnosis,
      this.intakeNotes,
      this.report1CompletedAt,
      this.report2CompletedAt,
      this.report3CompletedAt,
      this.dropOffAt,
      this.technicianStartAt,
      this.partsArriveAt,
      this.customerContactedAt,
      this.photoTemplateKey,
      required this.status,
      required this.priority,
      required this.estimateCents,
      required this.invoiceDiscountKind,
      required this.invoiceDiscountValue,
      this.notes,
      required this.partnerName,
      required this.partnerPartsPercent,
      required this.partnerLabourPercent,
      required this.gstCents,
      required this.pstCents,
      required this.createdAt,
      required this.updatedAt,
      this.dueAt,
      this.completedAt,
      this.pickedUpAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['number'] = Variable<String>(number);
    map['customer_id'] = Variable<int>(customerId);
    if (!nullToAbsent || customerDeviceId != null) {
      map['customer_device_id'] = Variable<int>(customerDeviceId);
    }
    if (!nullToAbsent || deviceModelId != null) {
      map['device_model_id'] = Variable<int>(deviceModelId);
    }
    if (!nullToAbsent || deviceName != null) {
      map['device_name'] = Variable<String>(deviceName);
    }
    if (!nullToAbsent || deviceVariant != null) {
      map['device_variant'] = Variable<String>(deviceVariant);
    }
    if (!nullToAbsent || deviceSide != null) {
      map['device_side'] = Variable<String>(deviceSide);
    }
    if (!nullToAbsent || serial != null) {
      map['serial'] = Variable<String>(serial);
    }
    map['serial_missing'] = Variable<bool>(serialMissing);
    if (!nullToAbsent || shopTag != null) {
      map['shop_tag'] = Variable<String>(shopTag);
    }
    map['complaint'] = Variable<String>(complaint);
    if (!nullToAbsent || diagnosis != null) {
      map['diagnosis'] = Variable<String>(diagnosis);
    }
    if (!nullToAbsent || intakeNotes != null) {
      map['intake_notes'] = Variable<String>(intakeNotes);
    }
    if (!nullToAbsent || report1CompletedAt != null) {
      map['report1_completed_at'] = Variable<DateTime>(report1CompletedAt);
    }
    if (!nullToAbsent || report2CompletedAt != null) {
      map['report2_completed_at'] = Variable<DateTime>(report2CompletedAt);
    }
    if (!nullToAbsent || report3CompletedAt != null) {
      map['report3_completed_at'] = Variable<DateTime>(report3CompletedAt);
    }
    if (!nullToAbsent || dropOffAt != null) {
      map['drop_off_at'] = Variable<DateTime>(dropOffAt);
    }
    if (!nullToAbsent || technicianStartAt != null) {
      map['technician_start_at'] = Variable<DateTime>(technicianStartAt);
    }
    if (!nullToAbsent || partsArriveAt != null) {
      map['parts_arrive_at'] = Variable<DateTime>(partsArriveAt);
    }
    if (!nullToAbsent || customerContactedAt != null) {
      map['customer_contacted_at'] = Variable<DateTime>(customerContactedAt);
    }
    if (!nullToAbsent || photoTemplateKey != null) {
      map['photo_template_key'] = Variable<String>(photoTemplateKey);
    }
    {
      map['status'] =
          Variable<int>($TicketsTable.$converterstatus.toSql(status));
    }
    map['priority'] = Variable<int>(priority);
    map['estimate_cents'] = Variable<int>(estimateCents);
    {
      map['invoice_discount_kind'] = Variable<int>($TicketsTable
          .$converterinvoiceDiscountKind
          .toSql(invoiceDiscountKind));
    }
    map['invoice_discount_value'] = Variable<int>(invoiceDiscountValue);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['partner_name'] = Variable<String>(partnerName);
    map['partner_parts_percent'] = Variable<int>(partnerPartsPercent);
    map['partner_labour_percent'] = Variable<int>(partnerLabourPercent);
    map['gst_cents'] = Variable<int>(gstCents);
    map['pst_cents'] = Variable<int>(pstCents);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<DateTime>(dueAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || pickedUpAt != null) {
      map['picked_up_at'] = Variable<DateTime>(pickedUpAt);
    }
    return map;
  }

  TicketsCompanion toCompanion(bool nullToAbsent) {
    return TicketsCompanion(
      id: Value(id),
      number: Value(number),
      customerId: Value(customerId),
      customerDeviceId: customerDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerDeviceId),
      deviceModelId: deviceModelId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceModelId),
      deviceName: deviceName == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceName),
      deviceVariant: deviceVariant == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceVariant),
      deviceSide: deviceSide == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceSide),
      serial:
          serial == null && nullToAbsent ? const Value.absent() : Value(serial),
      serialMissing: Value(serialMissing),
      shopTag: shopTag == null && nullToAbsent
          ? const Value.absent()
          : Value(shopTag),
      complaint: Value(complaint),
      diagnosis: diagnosis == null && nullToAbsent
          ? const Value.absent()
          : Value(diagnosis),
      intakeNotes: intakeNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(intakeNotes),
      report1CompletedAt: report1CompletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(report1CompletedAt),
      report2CompletedAt: report2CompletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(report2CompletedAt),
      report3CompletedAt: report3CompletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(report3CompletedAt),
      dropOffAt: dropOffAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dropOffAt),
      technicianStartAt: technicianStartAt == null && nullToAbsent
          ? const Value.absent()
          : Value(technicianStartAt),
      partsArriveAt: partsArriveAt == null && nullToAbsent
          ? const Value.absent()
          : Value(partsArriveAt),
      customerContactedAt: customerContactedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(customerContactedAt),
      photoTemplateKey: photoTemplateKey == null && nullToAbsent
          ? const Value.absent()
          : Value(photoTemplateKey),
      status: Value(status),
      priority: Value(priority),
      estimateCents: Value(estimateCents),
      invoiceDiscountKind: Value(invoiceDiscountKind),
      invoiceDiscountValue: Value(invoiceDiscountValue),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      partnerName: Value(partnerName),
      partnerPartsPercent: Value(partnerPartsPercent),
      partnerLabourPercent: Value(partnerLabourPercent),
      gstCents: Value(gstCents),
      pstCents: Value(pstCents),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      dueAt:
          dueAt == null && nullToAbsent ? const Value.absent() : Value(dueAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      pickedUpAt: pickedUpAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pickedUpAt),
    );
  }

  factory Ticket.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ticket(
      id: serializer.fromJson<int>(json['id']),
      number: serializer.fromJson<String>(json['number']),
      customerId: serializer.fromJson<int>(json['customerId']),
      customerDeviceId: serializer.fromJson<int?>(json['customerDeviceId']),
      deviceModelId: serializer.fromJson<int?>(json['deviceModelId']),
      deviceName: serializer.fromJson<String?>(json['deviceName']),
      deviceVariant: serializer.fromJson<String?>(json['deviceVariant']),
      deviceSide: serializer.fromJson<String?>(json['deviceSide']),
      serial: serializer.fromJson<String?>(json['serial']),
      serialMissing: serializer.fromJson<bool>(json['serialMissing']),
      shopTag: serializer.fromJson<String?>(json['shopTag']),
      complaint: serializer.fromJson<String>(json['complaint']),
      diagnosis: serializer.fromJson<String?>(json['diagnosis']),
      intakeNotes: serializer.fromJson<String?>(json['intakeNotes']),
      report1CompletedAt:
          serializer.fromJson<DateTime?>(json['report1CompletedAt']),
      report2CompletedAt:
          serializer.fromJson<DateTime?>(json['report2CompletedAt']),
      report3CompletedAt:
          serializer.fromJson<DateTime?>(json['report3CompletedAt']),
      dropOffAt: serializer.fromJson<DateTime?>(json['dropOffAt']),
      technicianStartAt:
          serializer.fromJson<DateTime?>(json['technicianStartAt']),
      partsArriveAt: serializer.fromJson<DateTime?>(json['partsArriveAt']),
      customerContactedAt:
          serializer.fromJson<DateTime?>(json['customerContactedAt']),
      photoTemplateKey: serializer.fromJson<String?>(json['photoTemplateKey']),
      status: $TicketsTable.$converterstatus
          .fromJson(serializer.fromJson<int>(json['status'])),
      priority: serializer.fromJson<int>(json['priority']),
      estimateCents: serializer.fromJson<int>(json['estimateCents']),
      invoiceDiscountKind: $TicketsTable.$converterinvoiceDiscountKind
          .fromJson(serializer.fromJson<int>(json['invoiceDiscountKind'])),
      invoiceDiscountValue:
          serializer.fromJson<int>(json['invoiceDiscountValue']),
      notes: serializer.fromJson<String?>(json['notes']),
      partnerName: serializer.fromJson<String>(json['partnerName']),
      partnerPartsPercent:
          serializer.fromJson<int>(json['partnerPartsPercent']),
      partnerLabourPercent:
          serializer.fromJson<int>(json['partnerLabourPercent']),
      gstCents: serializer.fromJson<int>(json['gstCents']),
      pstCents: serializer.fromJson<int>(json['pstCents']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      dueAt: serializer.fromJson<DateTime?>(json['dueAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      pickedUpAt: serializer.fromJson<DateTime?>(json['pickedUpAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'number': serializer.toJson<String>(number),
      'customerId': serializer.toJson<int>(customerId),
      'customerDeviceId': serializer.toJson<int?>(customerDeviceId),
      'deviceModelId': serializer.toJson<int?>(deviceModelId),
      'deviceName': serializer.toJson<String?>(deviceName),
      'deviceVariant': serializer.toJson<String?>(deviceVariant),
      'deviceSide': serializer.toJson<String?>(deviceSide),
      'serial': serializer.toJson<String?>(serial),
      'serialMissing': serializer.toJson<bool>(serialMissing),
      'shopTag': serializer.toJson<String?>(shopTag),
      'complaint': serializer.toJson<String>(complaint),
      'diagnosis': serializer.toJson<String?>(diagnosis),
      'intakeNotes': serializer.toJson<String?>(intakeNotes),
      'report1CompletedAt': serializer.toJson<DateTime?>(report1CompletedAt),
      'report2CompletedAt': serializer.toJson<DateTime?>(report2CompletedAt),
      'report3CompletedAt': serializer.toJson<DateTime?>(report3CompletedAt),
      'dropOffAt': serializer.toJson<DateTime?>(dropOffAt),
      'technicianStartAt': serializer.toJson<DateTime?>(technicianStartAt),
      'partsArriveAt': serializer.toJson<DateTime?>(partsArriveAt),
      'customerContactedAt': serializer.toJson<DateTime?>(customerContactedAt),
      'photoTemplateKey': serializer.toJson<String?>(photoTemplateKey),
      'status':
          serializer.toJson<int>($TicketsTable.$converterstatus.toJson(status)),
      'priority': serializer.toJson<int>(priority),
      'estimateCents': serializer.toJson<int>(estimateCents),
      'invoiceDiscountKind': serializer.toJson<int>($TicketsTable
          .$converterinvoiceDiscountKind
          .toJson(invoiceDiscountKind)),
      'invoiceDiscountValue': serializer.toJson<int>(invoiceDiscountValue),
      'notes': serializer.toJson<String?>(notes),
      'partnerName': serializer.toJson<String>(partnerName),
      'partnerPartsPercent': serializer.toJson<int>(partnerPartsPercent),
      'partnerLabourPercent': serializer.toJson<int>(partnerLabourPercent),
      'gstCents': serializer.toJson<int>(gstCents),
      'pstCents': serializer.toJson<int>(pstCents),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'dueAt': serializer.toJson<DateTime?>(dueAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'pickedUpAt': serializer.toJson<DateTime?>(pickedUpAt),
    };
  }

  Ticket copyWith(
          {int? id,
          String? number,
          int? customerId,
          Value<int?> customerDeviceId = const Value.absent(),
          Value<int?> deviceModelId = const Value.absent(),
          Value<String?> deviceName = const Value.absent(),
          Value<String?> deviceVariant = const Value.absent(),
          Value<String?> deviceSide = const Value.absent(),
          Value<String?> serial = const Value.absent(),
          bool? serialMissing,
          Value<String?> shopTag = const Value.absent(),
          String? complaint,
          Value<String?> diagnosis = const Value.absent(),
          Value<String?> intakeNotes = const Value.absent(),
          Value<DateTime?> report1CompletedAt = const Value.absent(),
          Value<DateTime?> report2CompletedAt = const Value.absent(),
          Value<DateTime?> report3CompletedAt = const Value.absent(),
          Value<DateTime?> dropOffAt = const Value.absent(),
          Value<DateTime?> technicianStartAt = const Value.absent(),
          Value<DateTime?> partsArriveAt = const Value.absent(),
          Value<DateTime?> customerContactedAt = const Value.absent(),
          Value<String?> photoTemplateKey = const Value.absent(),
          TicketStatus? status,
          int? priority,
          int? estimateCents,
          InvoiceDiscountKind? invoiceDiscountKind,
          int? invoiceDiscountValue,
          Value<String?> notes = const Value.absent(),
          String? partnerName,
          int? partnerPartsPercent,
          int? partnerLabourPercent,
          int? gstCents,
          int? pstCents,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> dueAt = const Value.absent(),
          Value<DateTime?> completedAt = const Value.absent(),
          Value<DateTime?> pickedUpAt = const Value.absent()}) =>
      Ticket(
        id: id ?? this.id,
        number: number ?? this.number,
        customerId: customerId ?? this.customerId,
        customerDeviceId: customerDeviceId.present
            ? customerDeviceId.value
            : this.customerDeviceId,
        deviceModelId:
            deviceModelId.present ? deviceModelId.value : this.deviceModelId,
        deviceName: deviceName.present ? deviceName.value : this.deviceName,
        deviceVariant:
            deviceVariant.present ? deviceVariant.value : this.deviceVariant,
        deviceSide: deviceSide.present ? deviceSide.value : this.deviceSide,
        serial: serial.present ? serial.value : this.serial,
        serialMissing: serialMissing ?? this.serialMissing,
        shopTag: shopTag.present ? shopTag.value : this.shopTag,
        complaint: complaint ?? this.complaint,
        diagnosis: diagnosis.present ? diagnosis.value : this.diagnosis,
        intakeNotes: intakeNotes.present ? intakeNotes.value : this.intakeNotes,
        report1CompletedAt: report1CompletedAt.present
            ? report1CompletedAt.value
            : this.report1CompletedAt,
        report2CompletedAt: report2CompletedAt.present
            ? report2CompletedAt.value
            : this.report2CompletedAt,
        report3CompletedAt: report3CompletedAt.present
            ? report3CompletedAt.value
            : this.report3CompletedAt,
        dropOffAt: dropOffAt.present ? dropOffAt.value : this.dropOffAt,
        technicianStartAt: technicianStartAt.present
            ? technicianStartAt.value
            : this.technicianStartAt,
        partsArriveAt:
            partsArriveAt.present ? partsArriveAt.value : this.partsArriveAt,
        customerContactedAt: customerContactedAt.present
            ? customerContactedAt.value
            : this.customerContactedAt,
        photoTemplateKey: photoTemplateKey.present
            ? photoTemplateKey.value
            : this.photoTemplateKey,
        status: status ?? this.status,
        priority: priority ?? this.priority,
        estimateCents: estimateCents ?? this.estimateCents,
        invoiceDiscountKind: invoiceDiscountKind ?? this.invoiceDiscountKind,
        invoiceDiscountValue: invoiceDiscountValue ?? this.invoiceDiscountValue,
        notes: notes.present ? notes.value : this.notes,
        partnerName: partnerName ?? this.partnerName,
        partnerPartsPercent: partnerPartsPercent ?? this.partnerPartsPercent,
        partnerLabourPercent: partnerLabourPercent ?? this.partnerLabourPercent,
        gstCents: gstCents ?? this.gstCents,
        pstCents: pstCents ?? this.pstCents,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        dueAt: dueAt.present ? dueAt.value : this.dueAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        pickedUpAt: pickedUpAt.present ? pickedUpAt.value : this.pickedUpAt,
      );
  Ticket copyWithCompanion(TicketsCompanion data) {
    return Ticket(
      id: data.id.present ? data.id.value : this.id,
      number: data.number.present ? data.number.value : this.number,
      customerId:
          data.customerId.present ? data.customerId.value : this.customerId,
      customerDeviceId: data.customerDeviceId.present
          ? data.customerDeviceId.value
          : this.customerDeviceId,
      deviceModelId: data.deviceModelId.present
          ? data.deviceModelId.value
          : this.deviceModelId,
      deviceName:
          data.deviceName.present ? data.deviceName.value : this.deviceName,
      deviceVariant: data.deviceVariant.present
          ? data.deviceVariant.value
          : this.deviceVariant,
      deviceSide:
          data.deviceSide.present ? data.deviceSide.value : this.deviceSide,
      serial: data.serial.present ? data.serial.value : this.serial,
      serialMissing: data.serialMissing.present
          ? data.serialMissing.value
          : this.serialMissing,
      shopTag: data.shopTag.present ? data.shopTag.value : this.shopTag,
      complaint: data.complaint.present ? data.complaint.value : this.complaint,
      diagnosis: data.diagnosis.present ? data.diagnosis.value : this.diagnosis,
      intakeNotes:
          data.intakeNotes.present ? data.intakeNotes.value : this.intakeNotes,
      report1CompletedAt: data.report1CompletedAt.present
          ? data.report1CompletedAt.value
          : this.report1CompletedAt,
      report2CompletedAt: data.report2CompletedAt.present
          ? data.report2CompletedAt.value
          : this.report2CompletedAt,
      report3CompletedAt: data.report3CompletedAt.present
          ? data.report3CompletedAt.value
          : this.report3CompletedAt,
      dropOffAt: data.dropOffAt.present ? data.dropOffAt.value : this.dropOffAt,
      technicianStartAt: data.technicianStartAt.present
          ? data.technicianStartAt.value
          : this.technicianStartAt,
      partsArriveAt: data.partsArriveAt.present
          ? data.partsArriveAt.value
          : this.partsArriveAt,
      customerContactedAt: data.customerContactedAt.present
          ? data.customerContactedAt.value
          : this.customerContactedAt,
      photoTemplateKey: data.photoTemplateKey.present
          ? data.photoTemplateKey.value
          : this.photoTemplateKey,
      status: data.status.present ? data.status.value : this.status,
      priority: data.priority.present ? data.priority.value : this.priority,
      estimateCents: data.estimateCents.present
          ? data.estimateCents.value
          : this.estimateCents,
      invoiceDiscountKind: data.invoiceDiscountKind.present
          ? data.invoiceDiscountKind.value
          : this.invoiceDiscountKind,
      invoiceDiscountValue: data.invoiceDiscountValue.present
          ? data.invoiceDiscountValue.value
          : this.invoiceDiscountValue,
      notes: data.notes.present ? data.notes.value : this.notes,
      partnerName:
          data.partnerName.present ? data.partnerName.value : this.partnerName,
      partnerPartsPercent: data.partnerPartsPercent.present
          ? data.partnerPartsPercent.value
          : this.partnerPartsPercent,
      partnerLabourPercent: data.partnerLabourPercent.present
          ? data.partnerLabourPercent.value
          : this.partnerLabourPercent,
      gstCents: data.gstCents.present ? data.gstCents.value : this.gstCents,
      pstCents: data.pstCents.present ? data.pstCents.value : this.pstCents,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      pickedUpAt:
          data.pickedUpAt.present ? data.pickedUpAt.value : this.pickedUpAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ticket(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('customerId: $customerId, ')
          ..write('customerDeviceId: $customerDeviceId, ')
          ..write('deviceModelId: $deviceModelId, ')
          ..write('deviceName: $deviceName, ')
          ..write('deviceVariant: $deviceVariant, ')
          ..write('deviceSide: $deviceSide, ')
          ..write('serial: $serial, ')
          ..write('serialMissing: $serialMissing, ')
          ..write('shopTag: $shopTag, ')
          ..write('complaint: $complaint, ')
          ..write('diagnosis: $diagnosis, ')
          ..write('intakeNotes: $intakeNotes, ')
          ..write('report1CompletedAt: $report1CompletedAt, ')
          ..write('report2CompletedAt: $report2CompletedAt, ')
          ..write('report3CompletedAt: $report3CompletedAt, ')
          ..write('dropOffAt: $dropOffAt, ')
          ..write('technicianStartAt: $technicianStartAt, ')
          ..write('partsArriveAt: $partsArriveAt, ')
          ..write('customerContactedAt: $customerContactedAt, ')
          ..write('photoTemplateKey: $photoTemplateKey, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('estimateCents: $estimateCents, ')
          ..write('invoiceDiscountKind: $invoiceDiscountKind, ')
          ..write('invoiceDiscountValue: $invoiceDiscountValue, ')
          ..write('notes: $notes, ')
          ..write('partnerName: $partnerName, ')
          ..write('partnerPartsPercent: $partnerPartsPercent, ')
          ..write('partnerLabourPercent: $partnerLabourPercent, ')
          ..write('gstCents: $gstCents, ')
          ..write('pstCents: $pstCents, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dueAt: $dueAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('pickedUpAt: $pickedUpAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        number,
        customerId,
        customerDeviceId,
        deviceModelId,
        deviceName,
        deviceVariant,
        deviceSide,
        serial,
        serialMissing,
        shopTag,
        complaint,
        diagnosis,
        intakeNotes,
        report1CompletedAt,
        report2CompletedAt,
        report3CompletedAt,
        dropOffAt,
        technicianStartAt,
        partsArriveAt,
        customerContactedAt,
        photoTemplateKey,
        status,
        priority,
        estimateCents,
        invoiceDiscountKind,
        invoiceDiscountValue,
        notes,
        partnerName,
        partnerPartsPercent,
        partnerLabourPercent,
        gstCents,
        pstCents,
        createdAt,
        updatedAt,
        dueAt,
        completedAt,
        pickedUpAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ticket &&
          other.id == this.id &&
          other.number == this.number &&
          other.customerId == this.customerId &&
          other.customerDeviceId == this.customerDeviceId &&
          other.deviceModelId == this.deviceModelId &&
          other.deviceName == this.deviceName &&
          other.deviceVariant == this.deviceVariant &&
          other.deviceSide == this.deviceSide &&
          other.serial == this.serial &&
          other.serialMissing == this.serialMissing &&
          other.shopTag == this.shopTag &&
          other.complaint == this.complaint &&
          other.diagnosis == this.diagnosis &&
          other.intakeNotes == this.intakeNotes &&
          other.report1CompletedAt == this.report1CompletedAt &&
          other.report2CompletedAt == this.report2CompletedAt &&
          other.report3CompletedAt == this.report3CompletedAt &&
          other.dropOffAt == this.dropOffAt &&
          other.technicianStartAt == this.technicianStartAt &&
          other.partsArriveAt == this.partsArriveAt &&
          other.customerContactedAt == this.customerContactedAt &&
          other.photoTemplateKey == this.photoTemplateKey &&
          other.status == this.status &&
          other.priority == this.priority &&
          other.estimateCents == this.estimateCents &&
          other.invoiceDiscountKind == this.invoiceDiscountKind &&
          other.invoiceDiscountValue == this.invoiceDiscountValue &&
          other.notes == this.notes &&
          other.partnerName == this.partnerName &&
          other.partnerPartsPercent == this.partnerPartsPercent &&
          other.partnerLabourPercent == this.partnerLabourPercent &&
          other.gstCents == this.gstCents &&
          other.pstCents == this.pstCents &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.dueAt == this.dueAt &&
          other.completedAt == this.completedAt &&
          other.pickedUpAt == this.pickedUpAt);
}

class TicketsCompanion extends UpdateCompanion<Ticket> {
  final Value<int> id;
  final Value<String> number;
  final Value<int> customerId;
  final Value<int?> customerDeviceId;
  final Value<int?> deviceModelId;
  final Value<String?> deviceName;
  final Value<String?> deviceVariant;
  final Value<String?> deviceSide;
  final Value<String?> serial;
  final Value<bool> serialMissing;
  final Value<String?> shopTag;
  final Value<String> complaint;
  final Value<String?> diagnosis;
  final Value<String?> intakeNotes;
  final Value<DateTime?> report1CompletedAt;
  final Value<DateTime?> report2CompletedAt;
  final Value<DateTime?> report3CompletedAt;
  final Value<DateTime?> dropOffAt;
  final Value<DateTime?> technicianStartAt;
  final Value<DateTime?> partsArriveAt;
  final Value<DateTime?> customerContactedAt;
  final Value<String?> photoTemplateKey;
  final Value<TicketStatus> status;
  final Value<int> priority;
  final Value<int> estimateCents;
  final Value<InvoiceDiscountKind> invoiceDiscountKind;
  final Value<int> invoiceDiscountValue;
  final Value<String?> notes;
  final Value<String> partnerName;
  final Value<int> partnerPartsPercent;
  final Value<int> partnerLabourPercent;
  final Value<int> gstCents;
  final Value<int> pstCents;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> dueAt;
  final Value<DateTime?> completedAt;
  final Value<DateTime?> pickedUpAt;
  const TicketsCompanion({
    this.id = const Value.absent(),
    this.number = const Value.absent(),
    this.customerId = const Value.absent(),
    this.customerDeviceId = const Value.absent(),
    this.deviceModelId = const Value.absent(),
    this.deviceName = const Value.absent(),
    this.deviceVariant = const Value.absent(),
    this.deviceSide = const Value.absent(),
    this.serial = const Value.absent(),
    this.serialMissing = const Value.absent(),
    this.shopTag = const Value.absent(),
    this.complaint = const Value.absent(),
    this.diagnosis = const Value.absent(),
    this.intakeNotes = const Value.absent(),
    this.report1CompletedAt = const Value.absent(),
    this.report2CompletedAt = const Value.absent(),
    this.report3CompletedAt = const Value.absent(),
    this.dropOffAt = const Value.absent(),
    this.technicianStartAt = const Value.absent(),
    this.partsArriveAt = const Value.absent(),
    this.customerContactedAt = const Value.absent(),
    this.photoTemplateKey = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.estimateCents = const Value.absent(),
    this.invoiceDiscountKind = const Value.absent(),
    this.invoiceDiscountValue = const Value.absent(),
    this.notes = const Value.absent(),
    this.partnerName = const Value.absent(),
    this.partnerPartsPercent = const Value.absent(),
    this.partnerLabourPercent = const Value.absent(),
    this.gstCents = const Value.absent(),
    this.pstCents = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.pickedUpAt = const Value.absent(),
  });
  TicketsCompanion.insert({
    this.id = const Value.absent(),
    required String number,
    required int customerId,
    this.customerDeviceId = const Value.absent(),
    this.deviceModelId = const Value.absent(),
    this.deviceName = const Value.absent(),
    this.deviceVariant = const Value.absent(),
    this.deviceSide = const Value.absent(),
    this.serial = const Value.absent(),
    this.serialMissing = const Value.absent(),
    this.shopTag = const Value.absent(),
    required String complaint,
    this.diagnosis = const Value.absent(),
    this.intakeNotes = const Value.absent(),
    this.report1CompletedAt = const Value.absent(),
    this.report2CompletedAt = const Value.absent(),
    this.report3CompletedAt = const Value.absent(),
    this.dropOffAt = const Value.absent(),
    this.technicianStartAt = const Value.absent(),
    this.partsArriveAt = const Value.absent(),
    this.customerContactedAt = const Value.absent(),
    this.photoTemplateKey = const Value.absent(),
    required TicketStatus status,
    this.priority = const Value.absent(),
    this.estimateCents = const Value.absent(),
    this.invoiceDiscountKind = const Value.absent(),
    this.invoiceDiscountValue = const Value.absent(),
    this.notes = const Value.absent(),
    this.partnerName = const Value.absent(),
    this.partnerPartsPercent = const Value.absent(),
    this.partnerLabourPercent = const Value.absent(),
    this.gstCents = const Value.absent(),
    this.pstCents = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.pickedUpAt = const Value.absent(),
  })  : number = Value(number),
        customerId = Value(customerId),
        complaint = Value(complaint),
        status = Value(status);
  static Insertable<Ticket> custom({
    Expression<int>? id,
    Expression<String>? number,
    Expression<int>? customerId,
    Expression<int>? customerDeviceId,
    Expression<int>? deviceModelId,
    Expression<String>? deviceName,
    Expression<String>? deviceVariant,
    Expression<String>? deviceSide,
    Expression<String>? serial,
    Expression<bool>? serialMissing,
    Expression<String>? shopTag,
    Expression<String>? complaint,
    Expression<String>? diagnosis,
    Expression<String>? intakeNotes,
    Expression<DateTime>? report1CompletedAt,
    Expression<DateTime>? report2CompletedAt,
    Expression<DateTime>? report3CompletedAt,
    Expression<DateTime>? dropOffAt,
    Expression<DateTime>? technicianStartAt,
    Expression<DateTime>? partsArriveAt,
    Expression<DateTime>? customerContactedAt,
    Expression<String>? photoTemplateKey,
    Expression<int>? status,
    Expression<int>? priority,
    Expression<int>? estimateCents,
    Expression<int>? invoiceDiscountKind,
    Expression<int>? invoiceDiscountValue,
    Expression<String>? notes,
    Expression<String>? partnerName,
    Expression<int>? partnerPartsPercent,
    Expression<int>? partnerLabourPercent,
    Expression<int>? gstCents,
    Expression<int>? pstCents,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? dueAt,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? pickedUpAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (number != null) 'number': number,
      if (customerId != null) 'customer_id': customerId,
      if (customerDeviceId != null) 'customer_device_id': customerDeviceId,
      if (deviceModelId != null) 'device_model_id': deviceModelId,
      if (deviceName != null) 'device_name': deviceName,
      if (deviceVariant != null) 'device_variant': deviceVariant,
      if (deviceSide != null) 'device_side': deviceSide,
      if (serial != null) 'serial': serial,
      if (serialMissing != null) 'serial_missing': serialMissing,
      if (shopTag != null) 'shop_tag': shopTag,
      if (complaint != null) 'complaint': complaint,
      if (diagnosis != null) 'diagnosis': diagnosis,
      if (intakeNotes != null) 'intake_notes': intakeNotes,
      if (report1CompletedAt != null)
        'report1_completed_at': report1CompletedAt,
      if (report2CompletedAt != null)
        'report2_completed_at': report2CompletedAt,
      if (report3CompletedAt != null)
        'report3_completed_at': report3CompletedAt,
      if (dropOffAt != null) 'drop_off_at': dropOffAt,
      if (technicianStartAt != null) 'technician_start_at': technicianStartAt,
      if (partsArriveAt != null) 'parts_arrive_at': partsArriveAt,
      if (customerContactedAt != null)
        'customer_contacted_at': customerContactedAt,
      if (photoTemplateKey != null) 'photo_template_key': photoTemplateKey,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (estimateCents != null) 'estimate_cents': estimateCents,
      if (invoiceDiscountKind != null)
        'invoice_discount_kind': invoiceDiscountKind,
      if (invoiceDiscountValue != null)
        'invoice_discount_value': invoiceDiscountValue,
      if (notes != null) 'notes': notes,
      if (partnerName != null) 'partner_name': partnerName,
      if (partnerPartsPercent != null)
        'partner_parts_percent': partnerPartsPercent,
      if (partnerLabourPercent != null)
        'partner_labour_percent': partnerLabourPercent,
      if (gstCents != null) 'gst_cents': gstCents,
      if (pstCents != null) 'pst_cents': pstCents,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (dueAt != null) 'due_at': dueAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (pickedUpAt != null) 'picked_up_at': pickedUpAt,
    });
  }

  TicketsCompanion copyWith(
      {Value<int>? id,
      Value<String>? number,
      Value<int>? customerId,
      Value<int?>? customerDeviceId,
      Value<int?>? deviceModelId,
      Value<String?>? deviceName,
      Value<String?>? deviceVariant,
      Value<String?>? deviceSide,
      Value<String?>? serial,
      Value<bool>? serialMissing,
      Value<String?>? shopTag,
      Value<String>? complaint,
      Value<String?>? diagnosis,
      Value<String?>? intakeNotes,
      Value<DateTime?>? report1CompletedAt,
      Value<DateTime?>? report2CompletedAt,
      Value<DateTime?>? report3CompletedAt,
      Value<DateTime?>? dropOffAt,
      Value<DateTime?>? technicianStartAt,
      Value<DateTime?>? partsArriveAt,
      Value<DateTime?>? customerContactedAt,
      Value<String?>? photoTemplateKey,
      Value<TicketStatus>? status,
      Value<int>? priority,
      Value<int>? estimateCents,
      Value<InvoiceDiscountKind>? invoiceDiscountKind,
      Value<int>? invoiceDiscountValue,
      Value<String?>? notes,
      Value<String>? partnerName,
      Value<int>? partnerPartsPercent,
      Value<int>? partnerLabourPercent,
      Value<int>? gstCents,
      Value<int>? pstCents,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? dueAt,
      Value<DateTime?>? completedAt,
      Value<DateTime?>? pickedUpAt}) {
    return TicketsCompanion(
      id: id ?? this.id,
      number: number ?? this.number,
      customerId: customerId ?? this.customerId,
      customerDeviceId: customerDeviceId ?? this.customerDeviceId,
      deviceModelId: deviceModelId ?? this.deviceModelId,
      deviceName: deviceName ?? this.deviceName,
      deviceVariant: deviceVariant ?? this.deviceVariant,
      deviceSide: deviceSide ?? this.deviceSide,
      serial: serial ?? this.serial,
      serialMissing: serialMissing ?? this.serialMissing,
      shopTag: shopTag ?? this.shopTag,
      complaint: complaint ?? this.complaint,
      diagnosis: diagnosis ?? this.diagnosis,
      intakeNotes: intakeNotes ?? this.intakeNotes,
      report1CompletedAt: report1CompletedAt ?? this.report1CompletedAt,
      report2CompletedAt: report2CompletedAt ?? this.report2CompletedAt,
      report3CompletedAt: report3CompletedAt ?? this.report3CompletedAt,
      dropOffAt: dropOffAt ?? this.dropOffAt,
      technicianStartAt: technicianStartAt ?? this.technicianStartAt,
      partsArriveAt: partsArriveAt ?? this.partsArriveAt,
      customerContactedAt: customerContactedAt ?? this.customerContactedAt,
      photoTemplateKey: photoTemplateKey ?? this.photoTemplateKey,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      estimateCents: estimateCents ?? this.estimateCents,
      invoiceDiscountKind: invoiceDiscountKind ?? this.invoiceDiscountKind,
      invoiceDiscountValue: invoiceDiscountValue ?? this.invoiceDiscountValue,
      notes: notes ?? this.notes,
      partnerName: partnerName ?? this.partnerName,
      partnerPartsPercent: partnerPartsPercent ?? this.partnerPartsPercent,
      partnerLabourPercent: partnerLabourPercent ?? this.partnerLabourPercent,
      gstCents: gstCents ?? this.gstCents,
      pstCents: pstCents ?? this.pstCents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueAt: dueAt ?? this.dueAt,
      completedAt: completedAt ?? this.completedAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (number.present) {
      map['number'] = Variable<String>(number.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (customerDeviceId.present) {
      map['customer_device_id'] = Variable<int>(customerDeviceId.value);
    }
    if (deviceModelId.present) {
      map['device_model_id'] = Variable<int>(deviceModelId.value);
    }
    if (deviceName.present) {
      map['device_name'] = Variable<String>(deviceName.value);
    }
    if (deviceVariant.present) {
      map['device_variant'] = Variable<String>(deviceVariant.value);
    }
    if (deviceSide.present) {
      map['device_side'] = Variable<String>(deviceSide.value);
    }
    if (serial.present) {
      map['serial'] = Variable<String>(serial.value);
    }
    if (serialMissing.present) {
      map['serial_missing'] = Variable<bool>(serialMissing.value);
    }
    if (shopTag.present) {
      map['shop_tag'] = Variable<String>(shopTag.value);
    }
    if (complaint.present) {
      map['complaint'] = Variable<String>(complaint.value);
    }
    if (diagnosis.present) {
      map['diagnosis'] = Variable<String>(diagnosis.value);
    }
    if (intakeNotes.present) {
      map['intake_notes'] = Variable<String>(intakeNotes.value);
    }
    if (report1CompletedAt.present) {
      map['report1_completed_at'] =
          Variable<DateTime>(report1CompletedAt.value);
    }
    if (report2CompletedAt.present) {
      map['report2_completed_at'] =
          Variable<DateTime>(report2CompletedAt.value);
    }
    if (report3CompletedAt.present) {
      map['report3_completed_at'] =
          Variable<DateTime>(report3CompletedAt.value);
    }
    if (dropOffAt.present) {
      map['drop_off_at'] = Variable<DateTime>(dropOffAt.value);
    }
    if (technicianStartAt.present) {
      map['technician_start_at'] = Variable<DateTime>(technicianStartAt.value);
    }
    if (partsArriveAt.present) {
      map['parts_arrive_at'] = Variable<DateTime>(partsArriveAt.value);
    }
    if (customerContactedAt.present) {
      map['customer_contacted_at'] =
          Variable<DateTime>(customerContactedAt.value);
    }
    if (photoTemplateKey.present) {
      map['photo_template_key'] = Variable<String>(photoTemplateKey.value);
    }
    if (status.present) {
      map['status'] =
          Variable<int>($TicketsTable.$converterstatus.toSql(status.value));
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (estimateCents.present) {
      map['estimate_cents'] = Variable<int>(estimateCents.value);
    }
    if (invoiceDiscountKind.present) {
      map['invoice_discount_kind'] = Variable<int>($TicketsTable
          .$converterinvoiceDiscountKind
          .toSql(invoiceDiscountKind.value));
    }
    if (invoiceDiscountValue.present) {
      map['invoice_discount_value'] = Variable<int>(invoiceDiscountValue.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (partnerName.present) {
      map['partner_name'] = Variable<String>(partnerName.value);
    }
    if (partnerPartsPercent.present) {
      map['partner_parts_percent'] = Variable<int>(partnerPartsPercent.value);
    }
    if (partnerLabourPercent.present) {
      map['partner_labour_percent'] = Variable<int>(partnerLabourPercent.value);
    }
    if (gstCents.present) {
      map['gst_cents'] = Variable<int>(gstCents.value);
    }
    if (pstCents.present) {
      map['pst_cents'] = Variable<int>(pstCents.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (pickedUpAt.present) {
      map['picked_up_at'] = Variable<DateTime>(pickedUpAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TicketsCompanion(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('customerId: $customerId, ')
          ..write('customerDeviceId: $customerDeviceId, ')
          ..write('deviceModelId: $deviceModelId, ')
          ..write('deviceName: $deviceName, ')
          ..write('deviceVariant: $deviceVariant, ')
          ..write('deviceSide: $deviceSide, ')
          ..write('serial: $serial, ')
          ..write('serialMissing: $serialMissing, ')
          ..write('shopTag: $shopTag, ')
          ..write('complaint: $complaint, ')
          ..write('diagnosis: $diagnosis, ')
          ..write('intakeNotes: $intakeNotes, ')
          ..write('report1CompletedAt: $report1CompletedAt, ')
          ..write('report2CompletedAt: $report2CompletedAt, ')
          ..write('report3CompletedAt: $report3CompletedAt, ')
          ..write('dropOffAt: $dropOffAt, ')
          ..write('technicianStartAt: $technicianStartAt, ')
          ..write('partsArriveAt: $partsArriveAt, ')
          ..write('customerContactedAt: $customerContactedAt, ')
          ..write('photoTemplateKey: $photoTemplateKey, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('estimateCents: $estimateCents, ')
          ..write('invoiceDiscountKind: $invoiceDiscountKind, ')
          ..write('invoiceDiscountValue: $invoiceDiscountValue, ')
          ..write('notes: $notes, ')
          ..write('partnerName: $partnerName, ')
          ..write('partnerPartsPercent: $partnerPartsPercent, ')
          ..write('partnerLabourPercent: $partnerLabourPercent, ')
          ..write('gstCents: $gstCents, ')
          ..write('pstCents: $pstCents, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dueAt: $dueAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('pickedUpAt: $pickedUpAt')
          ..write(')'))
        .toString();
  }
}

class $ShopTagsTable extends ShopTags with TableInfo<$ShopTagsTable, ShopTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShopTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
      'tag', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 24),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _ticketIdMeta =
      const VerificationMeta('ticketId');
  @override
  late final GeneratedColumn<int> ticketId = GeneratedColumn<int>(
      'ticket_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES tickets (id)'));
  static const VerificationMeta _issuedAtMeta =
      const VerificationMeta('issuedAt');
  @override
  late final GeneratedColumn<DateTime> issuedAt = GeneratedColumn<DateTime>(
      'issued_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _retiredAtMeta =
      const VerificationMeta('retiredAt');
  @override
  late final GeneratedColumn<DateTime> retiredAt = GeneratedColumn<DateTime>(
      'retired_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [tag, ticketId, issuedAt, retiredAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shop_tags';
  @override
  VerificationContext validateIntegrity(Insertable<ShopTag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tag')) {
      context.handle(
          _tagMeta, tag.isAcceptableOrUnknown(data['tag']!, _tagMeta));
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    if (data.containsKey('ticket_id')) {
      context.handle(_ticketIdMeta,
          ticketId.isAcceptableOrUnknown(data['ticket_id']!, _ticketIdMeta));
    }
    if (data.containsKey('issued_at')) {
      context.handle(_issuedAtMeta,
          issuedAt.isAcceptableOrUnknown(data['issued_at']!, _issuedAtMeta));
    }
    if (data.containsKey('retired_at')) {
      context.handle(_retiredAtMeta,
          retiredAt.isAcceptableOrUnknown(data['retired_at']!, _retiredAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tag};
  @override
  ShopTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShopTag(
      tag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag'])!,
      ticketId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ticket_id']),
      issuedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}issued_at'])!,
      retiredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}retired_at']),
    );
  }

  @override
  $ShopTagsTable createAlias(String alias) {
    return $ShopTagsTable(attachedDatabase, alias);
  }
}

class ShopTag extends DataClass implements Insertable<ShopTag> {
  final String tag;

  /// Null only if the ticket was removed; the tag is kept either way so it can
  /// never be handed out a second time.
  final int? ticketId;
  final DateTime issuedAt;

  /// Set when a sticker is lost and replaced, so only one tag is current.
  final DateTime? retiredAt;
  const ShopTag(
      {required this.tag,
      this.ticketId,
      required this.issuedAt,
      this.retiredAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tag'] = Variable<String>(tag);
    if (!nullToAbsent || ticketId != null) {
      map['ticket_id'] = Variable<int>(ticketId);
    }
    map['issued_at'] = Variable<DateTime>(issuedAt);
    if (!nullToAbsent || retiredAt != null) {
      map['retired_at'] = Variable<DateTime>(retiredAt);
    }
    return map;
  }

  ShopTagsCompanion toCompanion(bool nullToAbsent) {
    return ShopTagsCompanion(
      tag: Value(tag),
      ticketId: ticketId == null && nullToAbsent
          ? const Value.absent()
          : Value(ticketId),
      issuedAt: Value(issuedAt),
      retiredAt: retiredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(retiredAt),
    );
  }

  factory ShopTag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShopTag(
      tag: serializer.fromJson<String>(json['tag']),
      ticketId: serializer.fromJson<int?>(json['ticketId']),
      issuedAt: serializer.fromJson<DateTime>(json['issuedAt']),
      retiredAt: serializer.fromJson<DateTime?>(json['retiredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tag': serializer.toJson<String>(tag),
      'ticketId': serializer.toJson<int?>(ticketId),
      'issuedAt': serializer.toJson<DateTime>(issuedAt),
      'retiredAt': serializer.toJson<DateTime?>(retiredAt),
    };
  }

  ShopTag copyWith(
          {String? tag,
          Value<int?> ticketId = const Value.absent(),
          DateTime? issuedAt,
          Value<DateTime?> retiredAt = const Value.absent()}) =>
      ShopTag(
        tag: tag ?? this.tag,
        ticketId: ticketId.present ? ticketId.value : this.ticketId,
        issuedAt: issuedAt ?? this.issuedAt,
        retiredAt: retiredAt.present ? retiredAt.value : this.retiredAt,
      );
  ShopTag copyWithCompanion(ShopTagsCompanion data) {
    return ShopTag(
      tag: data.tag.present ? data.tag.value : this.tag,
      ticketId: data.ticketId.present ? data.ticketId.value : this.ticketId,
      issuedAt: data.issuedAt.present ? data.issuedAt.value : this.issuedAt,
      retiredAt: data.retiredAt.present ? data.retiredAt.value : this.retiredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShopTag(')
          ..write('tag: $tag, ')
          ..write('ticketId: $ticketId, ')
          ..write('issuedAt: $issuedAt, ')
          ..write('retiredAt: $retiredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(tag, ticketId, issuedAt, retiredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShopTag &&
          other.tag == this.tag &&
          other.ticketId == this.ticketId &&
          other.issuedAt == this.issuedAt &&
          other.retiredAt == this.retiredAt);
}

class ShopTagsCompanion extends UpdateCompanion<ShopTag> {
  final Value<String> tag;
  final Value<int?> ticketId;
  final Value<DateTime> issuedAt;
  final Value<DateTime?> retiredAt;
  final Value<int> rowid;
  const ShopTagsCompanion({
    this.tag = const Value.absent(),
    this.ticketId = const Value.absent(),
    this.issuedAt = const Value.absent(),
    this.retiredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShopTagsCompanion.insert({
    required String tag,
    this.ticketId = const Value.absent(),
    this.issuedAt = const Value.absent(),
    this.retiredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : tag = Value(tag);
  static Insertable<ShopTag> custom({
    Expression<String>? tag,
    Expression<int>? ticketId,
    Expression<DateTime>? issuedAt,
    Expression<DateTime>? retiredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tag != null) 'tag': tag,
      if (ticketId != null) 'ticket_id': ticketId,
      if (issuedAt != null) 'issued_at': issuedAt,
      if (retiredAt != null) 'retired_at': retiredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShopTagsCompanion copyWith(
      {Value<String>? tag,
      Value<int?>? ticketId,
      Value<DateTime>? issuedAt,
      Value<DateTime?>? retiredAt,
      Value<int>? rowid}) {
    return ShopTagsCompanion(
      tag: tag ?? this.tag,
      ticketId: ticketId ?? this.ticketId,
      issuedAt: issuedAt ?? this.issuedAt,
      retiredAt: retiredAt ?? this.retiredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (ticketId.present) {
      map['ticket_id'] = Variable<int>(ticketId.value);
    }
    if (issuedAt.present) {
      map['issued_at'] = Variable<DateTime>(issuedAt.value);
    }
    if (retiredAt.present) {
      map['retired_at'] = Variable<DateTime>(retiredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShopTagsCompanion(')
          ..write('tag: $tag, ')
          ..write('ticketId: $ticketId, ')
          ..write('issuedAt: $issuedAt, ')
          ..write('retiredAt: $retiredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PartsTable extends Parts with TableInfo<$PartsTable, Part> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 120),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
      'sku', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _vendorIdMeta =
      const VerificationMeta('vendorId');
  @override
  late final GeneratedColumn<String> vendorId = GeneratedColumn<String>(
      'vendor_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _vendorSkuMeta =
      const VerificationMeta('vendorSku');
  @override
  late final GeneratedColumn<String> vendorSku = GeneratedColumn<String>(
      'vendor_sku', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
      'brand', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<int> stock = GeneratedColumn<int>(
      'stock', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _costCentsMeta =
      const VerificationMeta('costCents');
  @override
  late final GeneratedColumn<int> costCents = GeneratedColumn<int>(
      'cost_cents', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _priceCentsMeta =
      const VerificationMeta('priceCents');
  @override
  late final GeneratedColumn<int> priceCents = GeneratedColumn<int>(
      'price_cents', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  late final GeneratedColumnWithTypeConverter<PartPurchaseType, int>
      purchaseType = GeneratedColumn<int>('purchase_type', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              defaultValue: const Constant(0))
          .withConverter<PartPurchaseType>($PartsTable.$converterpurchaseType);
  static const VerificationMeta _bulkQuantityMeta =
      const VerificationMeta('bulkQuantity');
  @override
  late final GeneratedColumn<int> bulkQuantity = GeneratedColumn<int>(
      'bulk_quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _bulkTotalCentsMeta =
      const VerificationMeta('bulkTotalCents');
  @override
  late final GeneratedColumn<int> bulkTotalCents = GeneratedColumn<int>(
      'bulk_total_cents', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _chargeShopSupplyMeta =
      const VerificationMeta('chargeShopSupply');
  @override
  late final GeneratedColumn<bool> chargeShopSupply = GeneratedColumn<bool>(
      'charge_shop_supply', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("charge_shop_supply" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _reorderLevelMeta =
      const VerificationMeta('reorderLevel');
  @override
  late final GeneratedColumn<int> reorderLevel = GeneratedColumn<int>(
      'reorder_level', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _supplierMeta =
      const VerificationMeta('supplier');
  @override
  late final GeneratedColumn<String> supplier = GeneratedColumn<String>(
      'supplier', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        description,
        sku,
        vendorId,
        vendorSku,
        brand,
        category,
        location,
        stock,
        costCents,
        priceCents,
        purchaseType,
        bulkQuantity,
        bulkTotalCents,
        chargeShopSupply,
        reorderLevel,
        supplier,
        isActive
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parts';
  @override
  VerificationContext validateIntegrity(Insertable<Part> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('sku')) {
      context.handle(
          _skuMeta, sku.isAcceptableOrUnknown(data['sku']!, _skuMeta));
    }
    if (data.containsKey('vendor_id')) {
      context.handle(_vendorIdMeta,
          vendorId.isAcceptableOrUnknown(data['vendor_id']!, _vendorIdMeta));
    }
    if (data.containsKey('vendor_sku')) {
      context.handle(_vendorSkuMeta,
          vendorSku.isAcceptableOrUnknown(data['vendor_sku']!, _vendorSkuMeta));
    }
    if (data.containsKey('brand')) {
      context.handle(
          _brandMeta, brand.isAcceptableOrUnknown(data['brand']!, _brandMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('stock')) {
      context.handle(
          _stockMeta, stock.isAcceptableOrUnknown(data['stock']!, _stockMeta));
    }
    if (data.containsKey('cost_cents')) {
      context.handle(_costCentsMeta,
          costCents.isAcceptableOrUnknown(data['cost_cents']!, _costCentsMeta));
    }
    if (data.containsKey('price_cents')) {
      context.handle(
          _priceCentsMeta,
          priceCents.isAcceptableOrUnknown(
              data['price_cents']!, _priceCentsMeta));
    }
    if (data.containsKey('bulk_quantity')) {
      context.handle(
          _bulkQuantityMeta,
          bulkQuantity.isAcceptableOrUnknown(
              data['bulk_quantity']!, _bulkQuantityMeta));
    }
    if (data.containsKey('bulk_total_cents')) {
      context.handle(
          _bulkTotalCentsMeta,
          bulkTotalCents.isAcceptableOrUnknown(
              data['bulk_total_cents']!, _bulkTotalCentsMeta));
    }
    if (data.containsKey('charge_shop_supply')) {
      context.handle(
          _chargeShopSupplyMeta,
          chargeShopSupply.isAcceptableOrUnknown(
              data['charge_shop_supply']!, _chargeShopSupplyMeta));
    }
    if (data.containsKey('reorder_level')) {
      context.handle(
          _reorderLevelMeta,
          reorderLevel.isAcceptableOrUnknown(
              data['reorder_level']!, _reorderLevelMeta));
    }
    if (data.containsKey('supplier')) {
      context.handle(_supplierMeta,
          supplier.isAcceptableOrUnknown(data['supplier']!, _supplierMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Part map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Part(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      sku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sku']),
      vendorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vendor_id']),
      vendorSku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vendor_sku']),
      brand: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}brand']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location']),
      stock: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stock'])!,
      costCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cost_cents'])!,
      priceCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}price_cents'])!,
      purchaseType: $PartsTable.$converterpurchaseType.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}purchase_type'])!),
      bulkQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bulk_quantity'])!,
      bulkTotalCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bulk_total_cents'])!,
      chargeShopSupply: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}charge_shop_supply'])!,
      reorderLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reorder_level'])!,
      supplier: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supplier']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $PartsTable createAlias(String alias) {
    return $PartsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PartPurchaseType, int, int> $converterpurchaseType =
      const EnumIndexConverter<PartPurchaseType>(PartPurchaseType.values);
}

class Part extends DataClass implements Insertable<Part> {
  final int id;
  final String name;
  final String? description;

  /// Shop SKU in `NNN-NNN` form. Blank SKUs are assigned at creation time.
  final String? sku;

  /// Where the part is purchased, e.g. a supplier account or store name.
  final String? vendorId;

  /// The vendor's catalogue SKU for the exact item ordered.
  final String? vendorSku;

  /// The part's brand or manufacturer.
  final String? brand;
  final String? category;
  final String? location;
  final int stock;
  final int costCents;
  final int priceCents;

  /// Single-item or bulk-lot purchase. [costCents] is always the per-item cost.
  final PartPurchaseType purchaseType;

  /// How many items were in the bulk lot (1 for a single item).
  final int bulkQuantity;

  /// What the whole bulk lot cost, kept so the calculator can be reopened.
  final int bulkTotalCents;

  /// Shop supplies only: bill the retail price per use instead of nothing.
  final bool chargeShopSupply;
  final int reorderLevel;
  final String? supplier;
  final bool isActive;
  const Part(
      {required this.id,
      required this.name,
      this.description,
      this.sku,
      this.vendorId,
      this.vendorSku,
      this.brand,
      this.category,
      this.location,
      required this.stock,
      required this.costCents,
      required this.priceCents,
      required this.purchaseType,
      required this.bulkQuantity,
      required this.bulkTotalCents,
      required this.chargeShopSupply,
      required this.reorderLevel,
      this.supplier,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || sku != null) {
      map['sku'] = Variable<String>(sku);
    }
    if (!nullToAbsent || vendorId != null) {
      map['vendor_id'] = Variable<String>(vendorId);
    }
    if (!nullToAbsent || vendorSku != null) {
      map['vendor_sku'] = Variable<String>(vendorSku);
    }
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['stock'] = Variable<int>(stock);
    map['cost_cents'] = Variable<int>(costCents);
    map['price_cents'] = Variable<int>(priceCents);
    {
      map['purchase_type'] =
          Variable<int>($PartsTable.$converterpurchaseType.toSql(purchaseType));
    }
    map['bulk_quantity'] = Variable<int>(bulkQuantity);
    map['bulk_total_cents'] = Variable<int>(bulkTotalCents);
    map['charge_shop_supply'] = Variable<bool>(chargeShopSupply);
    map['reorder_level'] = Variable<int>(reorderLevel);
    if (!nullToAbsent || supplier != null) {
      map['supplier'] = Variable<String>(supplier);
    }
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  PartsCompanion toCompanion(bool nullToAbsent) {
    return PartsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      sku: sku == null && nullToAbsent ? const Value.absent() : Value(sku),
      vendorId: vendorId == null && nullToAbsent
          ? const Value.absent()
          : Value(vendorId),
      vendorSku: vendorSku == null && nullToAbsent
          ? const Value.absent()
          : Value(vendorSku),
      brand:
          brand == null && nullToAbsent ? const Value.absent() : Value(brand),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      stock: Value(stock),
      costCents: Value(costCents),
      priceCents: Value(priceCents),
      purchaseType: Value(purchaseType),
      bulkQuantity: Value(bulkQuantity),
      bulkTotalCents: Value(bulkTotalCents),
      chargeShopSupply: Value(chargeShopSupply),
      reorderLevel: Value(reorderLevel),
      supplier: supplier == null && nullToAbsent
          ? const Value.absent()
          : Value(supplier),
      isActive: Value(isActive),
    );
  }

  factory Part.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Part(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      sku: serializer.fromJson<String?>(json['sku']),
      vendorId: serializer.fromJson<String?>(json['vendorId']),
      vendorSku: serializer.fromJson<String?>(json['vendorSku']),
      brand: serializer.fromJson<String?>(json['brand']),
      category: serializer.fromJson<String?>(json['category']),
      location: serializer.fromJson<String?>(json['location']),
      stock: serializer.fromJson<int>(json['stock']),
      costCents: serializer.fromJson<int>(json['costCents']),
      priceCents: serializer.fromJson<int>(json['priceCents']),
      purchaseType: $PartsTable.$converterpurchaseType
          .fromJson(serializer.fromJson<int>(json['purchaseType'])),
      bulkQuantity: serializer.fromJson<int>(json['bulkQuantity']),
      bulkTotalCents: serializer.fromJson<int>(json['bulkTotalCents']),
      chargeShopSupply: serializer.fromJson<bool>(json['chargeShopSupply']),
      reorderLevel: serializer.fromJson<int>(json['reorderLevel']),
      supplier: serializer.fromJson<String?>(json['supplier']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'sku': serializer.toJson<String?>(sku),
      'vendorId': serializer.toJson<String?>(vendorId),
      'vendorSku': serializer.toJson<String?>(vendorSku),
      'brand': serializer.toJson<String?>(brand),
      'category': serializer.toJson<String?>(category),
      'location': serializer.toJson<String?>(location),
      'stock': serializer.toJson<int>(stock),
      'costCents': serializer.toJson<int>(costCents),
      'priceCents': serializer.toJson<int>(priceCents),
      'purchaseType': serializer
          .toJson<int>($PartsTable.$converterpurchaseType.toJson(purchaseType)),
      'bulkQuantity': serializer.toJson<int>(bulkQuantity),
      'bulkTotalCents': serializer.toJson<int>(bulkTotalCents),
      'chargeShopSupply': serializer.toJson<bool>(chargeShopSupply),
      'reorderLevel': serializer.toJson<int>(reorderLevel),
      'supplier': serializer.toJson<String?>(supplier),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  Part copyWith(
          {int? id,
          String? name,
          Value<String?> description = const Value.absent(),
          Value<String?> sku = const Value.absent(),
          Value<String?> vendorId = const Value.absent(),
          Value<String?> vendorSku = const Value.absent(),
          Value<String?> brand = const Value.absent(),
          Value<String?> category = const Value.absent(),
          Value<String?> location = const Value.absent(),
          int? stock,
          int? costCents,
          int? priceCents,
          PartPurchaseType? purchaseType,
          int? bulkQuantity,
          int? bulkTotalCents,
          bool? chargeShopSupply,
          int? reorderLevel,
          Value<String?> supplier = const Value.absent(),
          bool? isActive}) =>
      Part(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        sku: sku.present ? sku.value : this.sku,
        vendorId: vendorId.present ? vendorId.value : this.vendorId,
        vendorSku: vendorSku.present ? vendorSku.value : this.vendorSku,
        brand: brand.present ? brand.value : this.brand,
        category: category.present ? category.value : this.category,
        location: location.present ? location.value : this.location,
        stock: stock ?? this.stock,
        costCents: costCents ?? this.costCents,
        priceCents: priceCents ?? this.priceCents,
        purchaseType: purchaseType ?? this.purchaseType,
        bulkQuantity: bulkQuantity ?? this.bulkQuantity,
        bulkTotalCents: bulkTotalCents ?? this.bulkTotalCents,
        chargeShopSupply: chargeShopSupply ?? this.chargeShopSupply,
        reorderLevel: reorderLevel ?? this.reorderLevel,
        supplier: supplier.present ? supplier.value : this.supplier,
        isActive: isActive ?? this.isActive,
      );
  Part copyWithCompanion(PartsCompanion data) {
    return Part(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      sku: data.sku.present ? data.sku.value : this.sku,
      vendorId: data.vendorId.present ? data.vendorId.value : this.vendorId,
      vendorSku: data.vendorSku.present ? data.vendorSku.value : this.vendorSku,
      brand: data.brand.present ? data.brand.value : this.brand,
      category: data.category.present ? data.category.value : this.category,
      location: data.location.present ? data.location.value : this.location,
      stock: data.stock.present ? data.stock.value : this.stock,
      costCents: data.costCents.present ? data.costCents.value : this.costCents,
      priceCents:
          data.priceCents.present ? data.priceCents.value : this.priceCents,
      purchaseType: data.purchaseType.present
          ? data.purchaseType.value
          : this.purchaseType,
      bulkQuantity: data.bulkQuantity.present
          ? data.bulkQuantity.value
          : this.bulkQuantity,
      bulkTotalCents: data.bulkTotalCents.present
          ? data.bulkTotalCents.value
          : this.bulkTotalCents,
      chargeShopSupply: data.chargeShopSupply.present
          ? data.chargeShopSupply.value
          : this.chargeShopSupply,
      reorderLevel: data.reorderLevel.present
          ? data.reorderLevel.value
          : this.reorderLevel,
      supplier: data.supplier.present ? data.supplier.value : this.supplier,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Part(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('sku: $sku, ')
          ..write('vendorId: $vendorId, ')
          ..write('vendorSku: $vendorSku, ')
          ..write('brand: $brand, ')
          ..write('category: $category, ')
          ..write('location: $location, ')
          ..write('stock: $stock, ')
          ..write('costCents: $costCents, ')
          ..write('priceCents: $priceCents, ')
          ..write('purchaseType: $purchaseType, ')
          ..write('bulkQuantity: $bulkQuantity, ')
          ..write('bulkTotalCents: $bulkTotalCents, ')
          ..write('chargeShopSupply: $chargeShopSupply, ')
          ..write('reorderLevel: $reorderLevel, ')
          ..write('supplier: $supplier, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      description,
      sku,
      vendorId,
      vendorSku,
      brand,
      category,
      location,
      stock,
      costCents,
      priceCents,
      purchaseType,
      bulkQuantity,
      bulkTotalCents,
      chargeShopSupply,
      reorderLevel,
      supplier,
      isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Part &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.sku == this.sku &&
          other.vendorId == this.vendorId &&
          other.vendorSku == this.vendorSku &&
          other.brand == this.brand &&
          other.category == this.category &&
          other.location == this.location &&
          other.stock == this.stock &&
          other.costCents == this.costCents &&
          other.priceCents == this.priceCents &&
          other.purchaseType == this.purchaseType &&
          other.bulkQuantity == this.bulkQuantity &&
          other.bulkTotalCents == this.bulkTotalCents &&
          other.chargeShopSupply == this.chargeShopSupply &&
          other.reorderLevel == this.reorderLevel &&
          other.supplier == this.supplier &&
          other.isActive == this.isActive);
}

class PartsCompanion extends UpdateCompanion<Part> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> sku;
  final Value<String?> vendorId;
  final Value<String?> vendorSku;
  final Value<String?> brand;
  final Value<String?> category;
  final Value<String?> location;
  final Value<int> stock;
  final Value<int> costCents;
  final Value<int> priceCents;
  final Value<PartPurchaseType> purchaseType;
  final Value<int> bulkQuantity;
  final Value<int> bulkTotalCents;
  final Value<bool> chargeShopSupply;
  final Value<int> reorderLevel;
  final Value<String?> supplier;
  final Value<bool> isActive;
  const PartsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.sku = const Value.absent(),
    this.vendorId = const Value.absent(),
    this.vendorSku = const Value.absent(),
    this.brand = const Value.absent(),
    this.category = const Value.absent(),
    this.location = const Value.absent(),
    this.stock = const Value.absent(),
    this.costCents = const Value.absent(),
    this.priceCents = const Value.absent(),
    this.purchaseType = const Value.absent(),
    this.bulkQuantity = const Value.absent(),
    this.bulkTotalCents = const Value.absent(),
    this.chargeShopSupply = const Value.absent(),
    this.reorderLevel = const Value.absent(),
    this.supplier = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  PartsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.sku = const Value.absent(),
    this.vendorId = const Value.absent(),
    this.vendorSku = const Value.absent(),
    this.brand = const Value.absent(),
    this.category = const Value.absent(),
    this.location = const Value.absent(),
    this.stock = const Value.absent(),
    this.costCents = const Value.absent(),
    this.priceCents = const Value.absent(),
    this.purchaseType = const Value.absent(),
    this.bulkQuantity = const Value.absent(),
    this.bulkTotalCents = const Value.absent(),
    this.chargeShopSupply = const Value.absent(),
    this.reorderLevel = const Value.absent(),
    this.supplier = const Value.absent(),
    this.isActive = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Part> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? sku,
    Expression<String>? vendorId,
    Expression<String>? vendorSku,
    Expression<String>? brand,
    Expression<String>? category,
    Expression<String>? location,
    Expression<int>? stock,
    Expression<int>? costCents,
    Expression<int>? priceCents,
    Expression<int>? purchaseType,
    Expression<int>? bulkQuantity,
    Expression<int>? bulkTotalCents,
    Expression<bool>? chargeShopSupply,
    Expression<int>? reorderLevel,
    Expression<String>? supplier,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (sku != null) 'sku': sku,
      if (vendorId != null) 'vendor_id': vendorId,
      if (vendorSku != null) 'vendor_sku': vendorSku,
      if (brand != null) 'brand': brand,
      if (category != null) 'category': category,
      if (location != null) 'location': location,
      if (stock != null) 'stock': stock,
      if (costCents != null) 'cost_cents': costCents,
      if (priceCents != null) 'price_cents': priceCents,
      if (purchaseType != null) 'purchase_type': purchaseType,
      if (bulkQuantity != null) 'bulk_quantity': bulkQuantity,
      if (bulkTotalCents != null) 'bulk_total_cents': bulkTotalCents,
      if (chargeShopSupply != null) 'charge_shop_supply': chargeShopSupply,
      if (reorderLevel != null) 'reorder_level': reorderLevel,
      if (supplier != null) 'supplier': supplier,
      if (isActive != null) 'is_active': isActive,
    });
  }

  PartsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String?>? sku,
      Value<String?>? vendorId,
      Value<String?>? vendorSku,
      Value<String?>? brand,
      Value<String?>? category,
      Value<String?>? location,
      Value<int>? stock,
      Value<int>? costCents,
      Value<int>? priceCents,
      Value<PartPurchaseType>? purchaseType,
      Value<int>? bulkQuantity,
      Value<int>? bulkTotalCents,
      Value<bool>? chargeShopSupply,
      Value<int>? reorderLevel,
      Value<String?>? supplier,
      Value<bool>? isActive}) {
    return PartsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sku: sku ?? this.sku,
      vendorId: vendorId ?? this.vendorId,
      vendorSku: vendorSku ?? this.vendorSku,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      location: location ?? this.location,
      stock: stock ?? this.stock,
      costCents: costCents ?? this.costCents,
      priceCents: priceCents ?? this.priceCents,
      purchaseType: purchaseType ?? this.purchaseType,
      bulkQuantity: bulkQuantity ?? this.bulkQuantity,
      bulkTotalCents: bulkTotalCents ?? this.bulkTotalCents,
      chargeShopSupply: chargeShopSupply ?? this.chargeShopSupply,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      supplier: supplier ?? this.supplier,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (vendorId.present) {
      map['vendor_id'] = Variable<String>(vendorId.value);
    }
    if (vendorSku.present) {
      map['vendor_sku'] = Variable<String>(vendorSku.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (stock.present) {
      map['stock'] = Variable<int>(stock.value);
    }
    if (costCents.present) {
      map['cost_cents'] = Variable<int>(costCents.value);
    }
    if (priceCents.present) {
      map['price_cents'] = Variable<int>(priceCents.value);
    }
    if (purchaseType.present) {
      map['purchase_type'] = Variable<int>(
          $PartsTable.$converterpurchaseType.toSql(purchaseType.value));
    }
    if (bulkQuantity.present) {
      map['bulk_quantity'] = Variable<int>(bulkQuantity.value);
    }
    if (bulkTotalCents.present) {
      map['bulk_total_cents'] = Variable<int>(bulkTotalCents.value);
    }
    if (chargeShopSupply.present) {
      map['charge_shop_supply'] = Variable<bool>(chargeShopSupply.value);
    }
    if (reorderLevel.present) {
      map['reorder_level'] = Variable<int>(reorderLevel.value);
    }
    if (supplier.present) {
      map['supplier'] = Variable<String>(supplier.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('sku: $sku, ')
          ..write('vendorId: $vendorId, ')
          ..write('vendorSku: $vendorSku, ')
          ..write('brand: $brand, ')
          ..write('category: $category, ')
          ..write('location: $location, ')
          ..write('stock: $stock, ')
          ..write('costCents: $costCents, ')
          ..write('priceCents: $priceCents, ')
          ..write('purchaseType: $purchaseType, ')
          ..write('bulkQuantity: $bulkQuantity, ')
          ..write('bulkTotalCents: $bulkTotalCents, ')
          ..write('chargeShopSupply: $chargeShopSupply, ')
          ..write('reorderLevel: $reorderLevel, ')
          ..write('supplier: $supplier, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $TicketItemsTable extends TicketItems
    with TableInfo<$TicketItemsTable, TicketItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TicketItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _ticketIdMeta =
      const VerificationMeta('ticketId');
  @override
  late final GeneratedColumn<int> ticketId = GeneratedColumn<int>(
      'ticket_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES tickets (id)'));
  @override
  late final GeneratedColumnWithTypeConverter<TicketItemKind, int> kind =
      GeneratedColumn<int>('kind', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<TicketItemKind>($TicketItemsTable.$converterkind);
  static const VerificationMeta _serviceIdMeta =
      const VerificationMeta('serviceId');
  @override
  late final GeneratedColumn<int> serviceId = GeneratedColumn<int>(
      'service_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES services (id)'));
  static const VerificationMeta _partIdMeta = const VerificationMeta('partId');
  @override
  late final GeneratedColumn<int> partId = GeneratedColumn<int>(
      'part_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES parts (id)'));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _unitPriceCentsMeta =
      const VerificationMeta('unitPriceCents');
  @override
  late final GeneratedColumn<int> unitPriceCents = GeneratedColumn<int>(
      'unit_price_cents', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _unitCostCentsMeta =
      const VerificationMeta('unitCostCents');
  @override
  late final GeneratedColumn<int> unitCostCents = GeneratedColumn<int>(
      'unit_cost_cents', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _consumedQuantityMeta =
      const VerificationMeta('consumedQuantity');
  @override
  late final GeneratedColumn<int> consumedQuantity = GeneratedColumn<int>(
      'consumed_quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        ticketId,
        kind,
        serviceId,
        partId,
        description,
        quantity,
        unitPriceCents,
        unitCostCents,
        consumedQuantity
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ticket_items';
  @override
  VerificationContext validateIntegrity(Insertable<TicketItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ticket_id')) {
      context.handle(_ticketIdMeta,
          ticketId.isAcceptableOrUnknown(data['ticket_id']!, _ticketIdMeta));
    } else if (isInserting) {
      context.missing(_ticketIdMeta);
    }
    if (data.containsKey('service_id')) {
      context.handle(_serviceIdMeta,
          serviceId.isAcceptableOrUnknown(data['service_id']!, _serviceIdMeta));
    }
    if (data.containsKey('part_id')) {
      context.handle(_partIdMeta,
          partId.isAcceptableOrUnknown(data['part_id']!, _partIdMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('unit_price_cents')) {
      context.handle(
          _unitPriceCentsMeta,
          unitPriceCents.isAcceptableOrUnknown(
              data['unit_price_cents']!, _unitPriceCentsMeta));
    }
    if (data.containsKey('unit_cost_cents')) {
      context.handle(
          _unitCostCentsMeta,
          unitCostCents.isAcceptableOrUnknown(
              data['unit_cost_cents']!, _unitCostCentsMeta));
    }
    if (data.containsKey('consumed_quantity')) {
      context.handle(
          _consumedQuantityMeta,
          consumedQuantity.isAcceptableOrUnknown(
              data['consumed_quantity']!, _consumedQuantityMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TicketItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TicketItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      ticketId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ticket_id'])!,
      kind: $TicketItemsTable.$converterkind.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}kind'])!),
      serviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}service_id']),
      partId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}part_id']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      unitPriceCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unit_price_cents'])!,
      unitCostCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unit_cost_cents']),
      consumedQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}consumed_quantity'])!,
    );
  }

  @override
  $TicketItemsTable createAlias(String alias) {
    return $TicketItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TicketItemKind, int, int> $converterkind =
      const EnumIndexConverter<TicketItemKind>(TicketItemKind.values);
}

class TicketItem extends DataClass implements Insertable<TicketItem> {
  final int id;
  final int ticketId;
  final TicketItemKind kind;
  final int? serviceId;
  final int? partId;
  final String description;
  final int quantity;
  final int unitPriceCents;
  final int? unitCostCents;

  /// How many of a part line have already been taken out of stock by closing
  /// its ticket. Reopened tickets keep this value, so closing again only
  /// deducts the parts added since.
  final int consumedQuantity;
  const TicketItem(
      {required this.id,
      required this.ticketId,
      required this.kind,
      this.serviceId,
      this.partId,
      required this.description,
      required this.quantity,
      required this.unitPriceCents,
      this.unitCostCents,
      required this.consumedQuantity});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ticket_id'] = Variable<int>(ticketId);
    {
      map['kind'] = Variable<int>($TicketItemsTable.$converterkind.toSql(kind));
    }
    if (!nullToAbsent || serviceId != null) {
      map['service_id'] = Variable<int>(serviceId);
    }
    if (!nullToAbsent || partId != null) {
      map['part_id'] = Variable<int>(partId);
    }
    map['description'] = Variable<String>(description);
    map['quantity'] = Variable<int>(quantity);
    map['unit_price_cents'] = Variable<int>(unitPriceCents);
    if (!nullToAbsent || unitCostCents != null) {
      map['unit_cost_cents'] = Variable<int>(unitCostCents);
    }
    map['consumed_quantity'] = Variable<int>(consumedQuantity);
    return map;
  }

  TicketItemsCompanion toCompanion(bool nullToAbsent) {
    return TicketItemsCompanion(
      id: Value(id),
      ticketId: Value(ticketId),
      kind: Value(kind),
      serviceId: serviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(serviceId),
      partId:
          partId == null && nullToAbsent ? const Value.absent() : Value(partId),
      description: Value(description),
      quantity: Value(quantity),
      unitPriceCents: Value(unitPriceCents),
      unitCostCents: unitCostCents == null && nullToAbsent
          ? const Value.absent()
          : Value(unitCostCents),
      consumedQuantity: Value(consumedQuantity),
    );
  }

  factory TicketItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TicketItem(
      id: serializer.fromJson<int>(json['id']),
      ticketId: serializer.fromJson<int>(json['ticketId']),
      kind: $TicketItemsTable.$converterkind
          .fromJson(serializer.fromJson<int>(json['kind'])),
      serviceId: serializer.fromJson<int?>(json['serviceId']),
      partId: serializer.fromJson<int?>(json['partId']),
      description: serializer.fromJson<String>(json['description']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitPriceCents: serializer.fromJson<int>(json['unitPriceCents']),
      unitCostCents: serializer.fromJson<int?>(json['unitCostCents']),
      consumedQuantity: serializer.fromJson<int>(json['consumedQuantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ticketId': serializer.toJson<int>(ticketId),
      'kind':
          serializer.toJson<int>($TicketItemsTable.$converterkind.toJson(kind)),
      'serviceId': serializer.toJson<int?>(serviceId),
      'partId': serializer.toJson<int?>(partId),
      'description': serializer.toJson<String>(description),
      'quantity': serializer.toJson<int>(quantity),
      'unitPriceCents': serializer.toJson<int>(unitPriceCents),
      'unitCostCents': serializer.toJson<int?>(unitCostCents),
      'consumedQuantity': serializer.toJson<int>(consumedQuantity),
    };
  }

  TicketItem copyWith(
          {int? id,
          int? ticketId,
          TicketItemKind? kind,
          Value<int?> serviceId = const Value.absent(),
          Value<int?> partId = const Value.absent(),
          String? description,
          int? quantity,
          int? unitPriceCents,
          Value<int?> unitCostCents = const Value.absent(),
          int? consumedQuantity}) =>
      TicketItem(
        id: id ?? this.id,
        ticketId: ticketId ?? this.ticketId,
        kind: kind ?? this.kind,
        serviceId: serviceId.present ? serviceId.value : this.serviceId,
        partId: partId.present ? partId.value : this.partId,
        description: description ?? this.description,
        quantity: quantity ?? this.quantity,
        unitPriceCents: unitPriceCents ?? this.unitPriceCents,
        unitCostCents:
            unitCostCents.present ? unitCostCents.value : this.unitCostCents,
        consumedQuantity: consumedQuantity ?? this.consumedQuantity,
      );
  TicketItem copyWithCompanion(TicketItemsCompanion data) {
    return TicketItem(
      id: data.id.present ? data.id.value : this.id,
      ticketId: data.ticketId.present ? data.ticketId.value : this.ticketId,
      kind: data.kind.present ? data.kind.value : this.kind,
      serviceId: data.serviceId.present ? data.serviceId.value : this.serviceId,
      partId: data.partId.present ? data.partId.value : this.partId,
      description:
          data.description.present ? data.description.value : this.description,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPriceCents: data.unitPriceCents.present
          ? data.unitPriceCents.value
          : this.unitPriceCents,
      unitCostCents: data.unitCostCents.present
          ? data.unitCostCents.value
          : this.unitCostCents,
      consumedQuantity: data.consumedQuantity.present
          ? data.consumedQuantity.value
          : this.consumedQuantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TicketItem(')
          ..write('id: $id, ')
          ..write('ticketId: $ticketId, ')
          ..write('kind: $kind, ')
          ..write('serviceId: $serviceId, ')
          ..write('partId: $partId, ')
          ..write('description: $description, ')
          ..write('quantity: $quantity, ')
          ..write('unitPriceCents: $unitPriceCents, ')
          ..write('unitCostCents: $unitCostCents, ')
          ..write('consumedQuantity: $consumedQuantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ticketId, kind, serviceId, partId,
      description, quantity, unitPriceCents, unitCostCents, consumedQuantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TicketItem &&
          other.id == this.id &&
          other.ticketId == this.ticketId &&
          other.kind == this.kind &&
          other.serviceId == this.serviceId &&
          other.partId == this.partId &&
          other.description == this.description &&
          other.quantity == this.quantity &&
          other.unitPriceCents == this.unitPriceCents &&
          other.unitCostCents == this.unitCostCents &&
          other.consumedQuantity == this.consumedQuantity);
}

class TicketItemsCompanion extends UpdateCompanion<TicketItem> {
  final Value<int> id;
  final Value<int> ticketId;
  final Value<TicketItemKind> kind;
  final Value<int?> serviceId;
  final Value<int?> partId;
  final Value<String> description;
  final Value<int> quantity;
  final Value<int> unitPriceCents;
  final Value<int?> unitCostCents;
  final Value<int> consumedQuantity;
  const TicketItemsCompanion({
    this.id = const Value.absent(),
    this.ticketId = const Value.absent(),
    this.kind = const Value.absent(),
    this.serviceId = const Value.absent(),
    this.partId = const Value.absent(),
    this.description = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPriceCents = const Value.absent(),
    this.unitCostCents = const Value.absent(),
    this.consumedQuantity = const Value.absent(),
  });
  TicketItemsCompanion.insert({
    this.id = const Value.absent(),
    required int ticketId,
    required TicketItemKind kind,
    this.serviceId = const Value.absent(),
    this.partId = const Value.absent(),
    required String description,
    this.quantity = const Value.absent(),
    this.unitPriceCents = const Value.absent(),
    this.unitCostCents = const Value.absent(),
    this.consumedQuantity = const Value.absent(),
  })  : ticketId = Value(ticketId),
        kind = Value(kind),
        description = Value(description);
  static Insertable<TicketItem> custom({
    Expression<int>? id,
    Expression<int>? ticketId,
    Expression<int>? kind,
    Expression<int>? serviceId,
    Expression<int>? partId,
    Expression<String>? description,
    Expression<int>? quantity,
    Expression<int>? unitPriceCents,
    Expression<int>? unitCostCents,
    Expression<int>? consumedQuantity,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ticketId != null) 'ticket_id': ticketId,
      if (kind != null) 'kind': kind,
      if (serviceId != null) 'service_id': serviceId,
      if (partId != null) 'part_id': partId,
      if (description != null) 'description': description,
      if (quantity != null) 'quantity': quantity,
      if (unitPriceCents != null) 'unit_price_cents': unitPriceCents,
      if (unitCostCents != null) 'unit_cost_cents': unitCostCents,
      if (consumedQuantity != null) 'consumed_quantity': consumedQuantity,
    });
  }

  TicketItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? ticketId,
      Value<TicketItemKind>? kind,
      Value<int?>? serviceId,
      Value<int?>? partId,
      Value<String>? description,
      Value<int>? quantity,
      Value<int>? unitPriceCents,
      Value<int?>? unitCostCents,
      Value<int>? consumedQuantity}) {
    return TicketItemsCompanion(
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      kind: kind ?? this.kind,
      serviceId: serviceId ?? this.serviceId,
      partId: partId ?? this.partId,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPriceCents: unitPriceCents ?? this.unitPriceCents,
      unitCostCents: unitCostCents ?? this.unitCostCents,
      consumedQuantity: consumedQuantity ?? this.consumedQuantity,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ticketId.present) {
      map['ticket_id'] = Variable<int>(ticketId.value);
    }
    if (kind.present) {
      map['kind'] =
          Variable<int>($TicketItemsTable.$converterkind.toSql(kind.value));
    }
    if (serviceId.present) {
      map['service_id'] = Variable<int>(serviceId.value);
    }
    if (partId.present) {
      map['part_id'] = Variable<int>(partId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitPriceCents.present) {
      map['unit_price_cents'] = Variable<int>(unitPriceCents.value);
    }
    if (unitCostCents.present) {
      map['unit_cost_cents'] = Variable<int>(unitCostCents.value);
    }
    if (consumedQuantity.present) {
      map['consumed_quantity'] = Variable<int>(consumedQuantity.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TicketItemsCompanion(')
          ..write('id: $id, ')
          ..write('ticketId: $ticketId, ')
          ..write('kind: $kind, ')
          ..write('serviceId: $serviceId, ')
          ..write('partId: $partId, ')
          ..write('description: $description, ')
          ..write('quantity: $quantity, ')
          ..write('unitPriceCents: $unitPriceCents, ')
          ..write('unitCostCents: $unitCostCents, ')
          ..write('consumedQuantity: $consumedQuantity')
          ..write(')'))
        .toString();
  }
}

class $TicketPhotosTable extends TicketPhotos
    with TableInfo<$TicketPhotosTable, TicketPhoto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TicketPhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _ticketIdMeta =
      const VerificationMeta('ticketId');
  @override
  late final GeneratedColumn<int> ticketId = GeneratedColumn<int>(
      'ticket_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES tickets (id)'));
  @override
  late final GeneratedColumnWithTypeConverter<PhotoSlot, int> slot =
      GeneratedColumn<int>('slot', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<PhotoSlot>($TicketPhotosTable.$converterslot);
  @override
  late final GeneratedColumnWithTypeConverter<PhotoStage, int> stage =
      GeneratedColumn<int>('stage', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              defaultValue: const Constant(0))
          .withConverter<PhotoStage>($TicketPhotosTable.$converterstage);
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
      'path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _captionMeta =
      const VerificationMeta('caption');
  @override
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
      'caption', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _visibleToClientMeta =
      const VerificationMeta('visibleToClient');
  @override
  late final GeneratedColumn<bool> visibleToClient = GeneratedColumn<bool>(
      'visible_to_client', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("visible_to_client" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _takenAtMeta =
      const VerificationMeta('takenAt');
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
      'taken_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, ticketId, slot, stage, path, caption, visibleToClient, takenAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ticket_photos';
  @override
  VerificationContext validateIntegrity(Insertable<TicketPhoto> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ticket_id')) {
      context.handle(_ticketIdMeta,
          ticketId.isAcceptableOrUnknown(data['ticket_id']!, _ticketIdMeta));
    } else if (isInserting) {
      context.missing(_ticketIdMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
          _pathMeta, path.isAcceptableOrUnknown(data['path']!, _pathMeta));
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('caption')) {
      context.handle(_captionMeta,
          caption.isAcceptableOrUnknown(data['caption']!, _captionMeta));
    }
    if (data.containsKey('visible_to_client')) {
      context.handle(
          _visibleToClientMeta,
          visibleToClient.isAcceptableOrUnknown(
              data['visible_to_client']!, _visibleToClientMeta));
    }
    if (data.containsKey('taken_at')) {
      context.handle(_takenAtMeta,
          takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TicketPhoto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TicketPhoto(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      ticketId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ticket_id'])!,
      slot: $TicketPhotosTable.$converterslot.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}slot'])!),
      stage: $TicketPhotosTable.$converterstage.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stage'])!),
      path: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}path'])!,
      caption: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}caption']),
      visibleToClient: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}visible_to_client'])!,
      takenAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}taken_at'])!,
    );
  }

  @override
  $TicketPhotosTable createAlias(String alias) {
    return $TicketPhotosTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PhotoSlot, int, int> $converterslot =
      const EnumIndexConverter<PhotoSlot>(PhotoSlot.values);
  static JsonTypeConverter2<PhotoStage, int, int> $converterstage =
      const EnumIndexConverter<PhotoStage>(PhotoStage.values);
}

class TicketPhoto extends DataClass implements Insertable<TicketPhoto> {
  final int id;
  final int ticketId;
  final PhotoSlot slot;

  /// Intake "before" shots, repair progress, or completion "after" shots.
  final PhotoStage stage;
  final String path;
  final String? caption;
  final bool visibleToClient;
  final DateTime takenAt;
  const TicketPhoto(
      {required this.id,
      required this.ticketId,
      required this.slot,
      required this.stage,
      required this.path,
      this.caption,
      required this.visibleToClient,
      required this.takenAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ticket_id'] = Variable<int>(ticketId);
    {
      map['slot'] =
          Variable<int>($TicketPhotosTable.$converterslot.toSql(slot));
    }
    {
      map['stage'] =
          Variable<int>($TicketPhotosTable.$converterstage.toSql(stage));
    }
    map['path'] = Variable<String>(path);
    if (!nullToAbsent || caption != null) {
      map['caption'] = Variable<String>(caption);
    }
    map['visible_to_client'] = Variable<bool>(visibleToClient);
    map['taken_at'] = Variable<DateTime>(takenAt);
    return map;
  }

  TicketPhotosCompanion toCompanion(bool nullToAbsent) {
    return TicketPhotosCompanion(
      id: Value(id),
      ticketId: Value(ticketId),
      slot: Value(slot),
      stage: Value(stage),
      path: Value(path),
      caption: caption == null && nullToAbsent
          ? const Value.absent()
          : Value(caption),
      visibleToClient: Value(visibleToClient),
      takenAt: Value(takenAt),
    );
  }

  factory TicketPhoto.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TicketPhoto(
      id: serializer.fromJson<int>(json['id']),
      ticketId: serializer.fromJson<int>(json['ticketId']),
      slot: $TicketPhotosTable.$converterslot
          .fromJson(serializer.fromJson<int>(json['slot'])),
      stage: $TicketPhotosTable.$converterstage
          .fromJson(serializer.fromJson<int>(json['stage'])),
      path: serializer.fromJson<String>(json['path']),
      caption: serializer.fromJson<String?>(json['caption']),
      visibleToClient: serializer.fromJson<bool>(json['visibleToClient']),
      takenAt: serializer.fromJson<DateTime>(json['takenAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ticketId': serializer.toJson<int>(ticketId),
      'slot': serializer
          .toJson<int>($TicketPhotosTable.$converterslot.toJson(slot)),
      'stage': serializer
          .toJson<int>($TicketPhotosTable.$converterstage.toJson(stage)),
      'path': serializer.toJson<String>(path),
      'caption': serializer.toJson<String?>(caption),
      'visibleToClient': serializer.toJson<bool>(visibleToClient),
      'takenAt': serializer.toJson<DateTime>(takenAt),
    };
  }

  TicketPhoto copyWith(
          {int? id,
          int? ticketId,
          PhotoSlot? slot,
          PhotoStage? stage,
          String? path,
          Value<String?> caption = const Value.absent(),
          bool? visibleToClient,
          DateTime? takenAt}) =>
      TicketPhoto(
        id: id ?? this.id,
        ticketId: ticketId ?? this.ticketId,
        slot: slot ?? this.slot,
        stage: stage ?? this.stage,
        path: path ?? this.path,
        caption: caption.present ? caption.value : this.caption,
        visibleToClient: visibleToClient ?? this.visibleToClient,
        takenAt: takenAt ?? this.takenAt,
      );
  TicketPhoto copyWithCompanion(TicketPhotosCompanion data) {
    return TicketPhoto(
      id: data.id.present ? data.id.value : this.id,
      ticketId: data.ticketId.present ? data.ticketId.value : this.ticketId,
      slot: data.slot.present ? data.slot.value : this.slot,
      stage: data.stage.present ? data.stage.value : this.stage,
      path: data.path.present ? data.path.value : this.path,
      caption: data.caption.present ? data.caption.value : this.caption,
      visibleToClient: data.visibleToClient.present
          ? data.visibleToClient.value
          : this.visibleToClient,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TicketPhoto(')
          ..write('id: $id, ')
          ..write('ticketId: $ticketId, ')
          ..write('slot: $slot, ')
          ..write('stage: $stage, ')
          ..write('path: $path, ')
          ..write('caption: $caption, ')
          ..write('visibleToClient: $visibleToClient, ')
          ..write('takenAt: $takenAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, ticketId, slot, stage, path, caption, visibleToClient, takenAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TicketPhoto &&
          other.id == this.id &&
          other.ticketId == this.ticketId &&
          other.slot == this.slot &&
          other.stage == this.stage &&
          other.path == this.path &&
          other.caption == this.caption &&
          other.visibleToClient == this.visibleToClient &&
          other.takenAt == this.takenAt);
}

class TicketPhotosCompanion extends UpdateCompanion<TicketPhoto> {
  final Value<int> id;
  final Value<int> ticketId;
  final Value<PhotoSlot> slot;
  final Value<PhotoStage> stage;
  final Value<String> path;
  final Value<String?> caption;
  final Value<bool> visibleToClient;
  final Value<DateTime> takenAt;
  const TicketPhotosCompanion({
    this.id = const Value.absent(),
    this.ticketId = const Value.absent(),
    this.slot = const Value.absent(),
    this.stage = const Value.absent(),
    this.path = const Value.absent(),
    this.caption = const Value.absent(),
    this.visibleToClient = const Value.absent(),
    this.takenAt = const Value.absent(),
  });
  TicketPhotosCompanion.insert({
    this.id = const Value.absent(),
    required int ticketId,
    required PhotoSlot slot,
    this.stage = const Value.absent(),
    required String path,
    this.caption = const Value.absent(),
    this.visibleToClient = const Value.absent(),
    this.takenAt = const Value.absent(),
  })  : ticketId = Value(ticketId),
        slot = Value(slot),
        path = Value(path);
  static Insertable<TicketPhoto> custom({
    Expression<int>? id,
    Expression<int>? ticketId,
    Expression<int>? slot,
    Expression<int>? stage,
    Expression<String>? path,
    Expression<String>? caption,
    Expression<bool>? visibleToClient,
    Expression<DateTime>? takenAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ticketId != null) 'ticket_id': ticketId,
      if (slot != null) 'slot': slot,
      if (stage != null) 'stage': stage,
      if (path != null) 'path': path,
      if (caption != null) 'caption': caption,
      if (visibleToClient != null) 'visible_to_client': visibleToClient,
      if (takenAt != null) 'taken_at': takenAt,
    });
  }

  TicketPhotosCompanion copyWith(
      {Value<int>? id,
      Value<int>? ticketId,
      Value<PhotoSlot>? slot,
      Value<PhotoStage>? stage,
      Value<String>? path,
      Value<String?>? caption,
      Value<bool>? visibleToClient,
      Value<DateTime>? takenAt}) {
    return TicketPhotosCompanion(
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      slot: slot ?? this.slot,
      stage: stage ?? this.stage,
      path: path ?? this.path,
      caption: caption ?? this.caption,
      visibleToClient: visibleToClient ?? this.visibleToClient,
      takenAt: takenAt ?? this.takenAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ticketId.present) {
      map['ticket_id'] = Variable<int>(ticketId.value);
    }
    if (slot.present) {
      map['slot'] =
          Variable<int>($TicketPhotosTable.$converterslot.toSql(slot.value));
    }
    if (stage.present) {
      map['stage'] =
          Variable<int>($TicketPhotosTable.$converterstage.toSql(stage.value));
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
    }
    if (visibleToClient.present) {
      map['visible_to_client'] = Variable<bool>(visibleToClient.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TicketPhotosCompanion(')
          ..write('id: $id, ')
          ..write('ticketId: $ticketId, ')
          ..write('slot: $slot, ')
          ..write('stage: $stage, ')
          ..write('path: $path, ')
          ..write('caption: $caption, ')
          ..write('visibleToClient: $visibleToClient, ')
          ..write('takenAt: $takenAt')
          ..write(')'))
        .toString();
  }
}

class $TicketPhotoSlotsTable extends TicketPhotoSlots
    with TableInfo<$TicketPhotoSlotsTable, TicketPhotoSlot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TicketPhotoSlotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _ticketIdMeta =
      const VerificationMeta('ticketId');
  @override
  late final GeneratedColumn<int> ticketId = GeneratedColumn<int>(
      'ticket_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES tickets (id)'));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 80),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _hintMeta = const VerificationMeta('hint');
  @override
  late final GeneratedColumn<String> hint = GeneratedColumn<String>(
      'hint', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _requiredMeta =
      const VerificationMeta('required');
  @override
  late final GeneratedColumn<bool> required = GeneratedColumn<bool>(
      'required', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("required" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _photoPathMeta =
      const VerificationMeta('photoPath');
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
      'photo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _capturedAtMeta =
      const VerificationMeta('capturedAt');
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
      'captured_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, ticketId, sortOrder, label, hint, required, photoPath, capturedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ticket_photo_slots';
  @override
  VerificationContext validateIntegrity(Insertable<TicketPhotoSlot> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ticket_id')) {
      context.handle(_ticketIdMeta,
          ticketId.isAcceptableOrUnknown(data['ticket_id']!, _ticketIdMeta));
    } else if (isInserting) {
      context.missing(_ticketIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('hint')) {
      context.handle(
          _hintMeta, hint.isAcceptableOrUnknown(data['hint']!, _hintMeta));
    }
    if (data.containsKey('required')) {
      context.handle(_requiredMeta,
          required.isAcceptableOrUnknown(data['required']!, _requiredMeta));
    }
    if (data.containsKey('photo_path')) {
      context.handle(_photoPathMeta,
          photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta));
    }
    if (data.containsKey('captured_at')) {
      context.handle(
          _capturedAtMeta,
          capturedAt.isAcceptableOrUnknown(
              data['captured_at']!, _capturedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {ticketId, sortOrder},
      ];
  @override
  TicketPhotoSlot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TicketPhotoSlot(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      ticketId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ticket_id'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      hint: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hint']),
      required: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}required'])!,
      photoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_path']),
      capturedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}captured_at']),
    );
  }

  @override
  $TicketPhotoSlotsTable createAlias(String alias) {
    return $TicketPhotoSlotsTable(attachedDatabase, alias);
  }
}

class TicketPhotoSlot extends DataClass implements Insertable<TicketPhotoSlot> {
  final int id;
  final int ticketId;
  final int sortOrder;
  final String label;
  final String? hint;
  final bool required;
  final String? photoPath;
  final DateTime? capturedAt;
  const TicketPhotoSlot(
      {required this.id,
      required this.ticketId,
      required this.sortOrder,
      required this.label,
      this.hint,
      required this.required,
      this.photoPath,
      this.capturedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ticket_id'] = Variable<int>(ticketId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || hint != null) {
      map['hint'] = Variable<String>(hint);
    }
    map['required'] = Variable<bool>(required);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || capturedAt != null) {
      map['captured_at'] = Variable<DateTime>(capturedAt);
    }
    return map;
  }

  TicketPhotoSlotsCompanion toCompanion(bool nullToAbsent) {
    return TicketPhotoSlotsCompanion(
      id: Value(id),
      ticketId: Value(ticketId),
      sortOrder: Value(sortOrder),
      label: Value(label),
      hint: hint == null && nullToAbsent ? const Value.absent() : Value(hint),
      required: Value(required),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      capturedAt: capturedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(capturedAt),
    );
  }

  factory TicketPhotoSlot.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TicketPhotoSlot(
      id: serializer.fromJson<int>(json['id']),
      ticketId: serializer.fromJson<int>(json['ticketId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      label: serializer.fromJson<String>(json['label']),
      hint: serializer.fromJson<String?>(json['hint']),
      required: serializer.fromJson<bool>(json['required']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      capturedAt: serializer.fromJson<DateTime?>(json['capturedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ticketId': serializer.toJson<int>(ticketId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'label': serializer.toJson<String>(label),
      'hint': serializer.toJson<String?>(hint),
      'required': serializer.toJson<bool>(required),
      'photoPath': serializer.toJson<String?>(photoPath),
      'capturedAt': serializer.toJson<DateTime?>(capturedAt),
    };
  }

  TicketPhotoSlot copyWith(
          {int? id,
          int? ticketId,
          int? sortOrder,
          String? label,
          Value<String?> hint = const Value.absent(),
          bool? required,
          Value<String?> photoPath = const Value.absent(),
          Value<DateTime?> capturedAt = const Value.absent()}) =>
      TicketPhotoSlot(
        id: id ?? this.id,
        ticketId: ticketId ?? this.ticketId,
        sortOrder: sortOrder ?? this.sortOrder,
        label: label ?? this.label,
        hint: hint.present ? hint.value : this.hint,
        required: required ?? this.required,
        photoPath: photoPath.present ? photoPath.value : this.photoPath,
        capturedAt: capturedAt.present ? capturedAt.value : this.capturedAt,
      );
  TicketPhotoSlot copyWithCompanion(TicketPhotoSlotsCompanion data) {
    return TicketPhotoSlot(
      id: data.id.present ? data.id.value : this.id,
      ticketId: data.ticketId.present ? data.ticketId.value : this.ticketId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      label: data.label.present ? data.label.value : this.label,
      hint: data.hint.present ? data.hint.value : this.hint,
      required: data.required.present ? data.required.value : this.required,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      capturedAt:
          data.capturedAt.present ? data.capturedAt.value : this.capturedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TicketPhotoSlot(')
          ..write('id: $id, ')
          ..write('ticketId: $ticketId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('label: $label, ')
          ..write('hint: $hint, ')
          ..write('required: $required, ')
          ..write('photoPath: $photoPath, ')
          ..write('capturedAt: $capturedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, ticketId, sortOrder, label, hint, required, photoPath, capturedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TicketPhotoSlot &&
          other.id == this.id &&
          other.ticketId == this.ticketId &&
          other.sortOrder == this.sortOrder &&
          other.label == this.label &&
          other.hint == this.hint &&
          other.required == this.required &&
          other.photoPath == this.photoPath &&
          other.capturedAt == this.capturedAt);
}

class TicketPhotoSlotsCompanion extends UpdateCompanion<TicketPhotoSlot> {
  final Value<int> id;
  final Value<int> ticketId;
  final Value<int> sortOrder;
  final Value<String> label;
  final Value<String?> hint;
  final Value<bool> required;
  final Value<String?> photoPath;
  final Value<DateTime?> capturedAt;
  const TicketPhotoSlotsCompanion({
    this.id = const Value.absent(),
    this.ticketId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.label = const Value.absent(),
    this.hint = const Value.absent(),
    this.required = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.capturedAt = const Value.absent(),
  });
  TicketPhotoSlotsCompanion.insert({
    this.id = const Value.absent(),
    required int ticketId,
    required int sortOrder,
    required String label,
    this.hint = const Value.absent(),
    this.required = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.capturedAt = const Value.absent(),
  })  : ticketId = Value(ticketId),
        sortOrder = Value(sortOrder),
        label = Value(label);
  static Insertable<TicketPhotoSlot> custom({
    Expression<int>? id,
    Expression<int>? ticketId,
    Expression<int>? sortOrder,
    Expression<String>? label,
    Expression<String>? hint,
    Expression<bool>? required,
    Expression<String>? photoPath,
    Expression<DateTime>? capturedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ticketId != null) 'ticket_id': ticketId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (label != null) 'label': label,
      if (hint != null) 'hint': hint,
      if (required != null) 'required': required,
      if (photoPath != null) 'photo_path': photoPath,
      if (capturedAt != null) 'captured_at': capturedAt,
    });
  }

  TicketPhotoSlotsCompanion copyWith(
      {Value<int>? id,
      Value<int>? ticketId,
      Value<int>? sortOrder,
      Value<String>? label,
      Value<String?>? hint,
      Value<bool>? required,
      Value<String?>? photoPath,
      Value<DateTime?>? capturedAt}) {
    return TicketPhotoSlotsCompanion(
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      sortOrder: sortOrder ?? this.sortOrder,
      label: label ?? this.label,
      hint: hint ?? this.hint,
      required: required ?? this.required,
      photoPath: photoPath ?? this.photoPath,
      capturedAt: capturedAt ?? this.capturedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ticketId.present) {
      map['ticket_id'] = Variable<int>(ticketId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (hint.present) {
      map['hint'] = Variable<String>(hint.value);
    }
    if (required.present) {
      map['required'] = Variable<bool>(required.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TicketPhotoSlotsCompanion(')
          ..write('id: $id, ')
          ..write('ticketId: $ticketId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('label: $label, ')
          ..write('hint: $hint, ')
          ..write('required: $required, ')
          ..write('photoPath: $photoPath, ')
          ..write('capturedAt: $capturedAt')
          ..write(')'))
        .toString();
  }
}

class $TicketReportsTable extends TicketReports
    with TableInfo<$TicketReportsTable, TicketReport> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TicketReportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _ticketIdMeta =
      const VerificationMeta('ticketId');
  @override
  late final GeneratedColumn<int> ticketId = GeneratedColumn<int>(
      'ticket_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES tickets (id)'));
  @override
  late final GeneratedColumnWithTypeConverter<ReportKind, int> kind =
      GeneratedColumn<int>('kind', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<ReportKind>($TicketReportsTable.$converterkind);
  @override
  late final GeneratedColumnWithTypeConverter<ReportStatus, int> status =
      GeneratedColumn<int>('status', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<ReportStatus>($TicketReportsTable.$converterstatus);
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
      'author', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 120),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _revisionMeta =
      const VerificationMeta('revision');
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
      'revision', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _summaryMeta =
      const VerificationMeta('summary');
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
      'summary', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _warrantyDaysMeta =
      const VerificationMeta('warrantyDays');
  @override
  late final GeneratedColumn<int> warrantyDays = GeneratedColumn<int>(
      'warranty_days', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _warrantyStartAtMeta =
      const VerificationMeta('warrantyStartAt');
  @override
  late final GeneratedColumn<DateTime> warrantyStartAt =
      GeneratedColumn<DateTime>('warranty_start_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _warrantyTermsMeta =
      const VerificationMeta('warrantyTerms');
  @override
  late final GeneratedColumn<String> warrantyTerms = GeneratedColumn<String>(
      'warranty_terms', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<ReportOutcome?, int> outcome =
      GeneratedColumn<int>('outcome', aliasedName, true,
              type: DriftSqlType.int, requiredDuringInsert: false)
          .withConverter<ReportOutcome?>(
              $TicketReportsTable.$converteroutcomen);
  static const VerificationMeta _shopTagMeta =
      const VerificationMeta('shopTag');
  @override
  late final GeneratedColumn<String> shopTag = GeneratedColumn<String>(
      'shop_tag', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _finalizedAtMeta =
      const VerificationMeta('finalizedAt');
  @override
  late final GeneratedColumn<DateTime> finalizedAt = GeneratedColumn<DateTime>(
      'finalized_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        ticketId,
        kind,
        status,
        author,
        revision,
        summary,
        warrantyDays,
        warrantyStartAt,
        warrantyTerms,
        outcome,
        shopTag,
        createdAt,
        updatedAt,
        finalizedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ticket_reports';
  @override
  VerificationContext validateIntegrity(Insertable<TicketReport> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ticket_id')) {
      context.handle(_ticketIdMeta,
          ticketId.isAcceptableOrUnknown(data['ticket_id']!, _ticketIdMeta));
    } else if (isInserting) {
      context.missing(_ticketIdMeta);
    }
    if (data.containsKey('author')) {
      context.handle(_authorMeta,
          author.isAcceptableOrUnknown(data['author']!, _authorMeta));
    } else if (isInserting) {
      context.missing(_authorMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(_revisionMeta,
          revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta));
    }
    if (data.containsKey('summary')) {
      context.handle(_summaryMeta,
          summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta));
    }
    if (data.containsKey('warranty_days')) {
      context.handle(
          _warrantyDaysMeta,
          warrantyDays.isAcceptableOrUnknown(
              data['warranty_days']!, _warrantyDaysMeta));
    }
    if (data.containsKey('warranty_start_at')) {
      context.handle(
          _warrantyStartAtMeta,
          warrantyStartAt.isAcceptableOrUnknown(
              data['warranty_start_at']!, _warrantyStartAtMeta));
    }
    if (data.containsKey('warranty_terms')) {
      context.handle(
          _warrantyTermsMeta,
          warrantyTerms.isAcceptableOrUnknown(
              data['warranty_terms']!, _warrantyTermsMeta));
    }
    if (data.containsKey('shop_tag')) {
      context.handle(_shopTagMeta,
          shopTag.isAcceptableOrUnknown(data['shop_tag']!, _shopTagMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('finalized_at')) {
      context.handle(
          _finalizedAtMeta,
          finalizedAt.isAcceptableOrUnknown(
              data['finalized_at']!, _finalizedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {ticketId, kind, revision},
      ];
  @override
  TicketReport map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TicketReport(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      ticketId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ticket_id'])!,
      kind: $TicketReportsTable.$converterkind.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}kind'])!),
      status: $TicketReportsTable.$converterstatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!),
      author: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author'])!,
      revision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}revision'])!,
      summary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}summary']),
      warrantyDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}warranty_days']),
      warrantyStartAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}warranty_start_at']),
      warrantyTerms: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}warranty_terms']),
      outcome: $TicketReportsTable.$converteroutcomen.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}outcome'])),
      shopTag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shop_tag']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      finalizedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}finalized_at']),
    );
  }

  @override
  $TicketReportsTable createAlias(String alias) {
    return $TicketReportsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ReportKind, int, int> $converterkind =
      const EnumIndexConverter<ReportKind>(ReportKind.values);
  static JsonTypeConverter2<ReportStatus, int, int> $converterstatus =
      const EnumIndexConverter<ReportStatus>(ReportStatus.values);
  static JsonTypeConverter2<ReportOutcome, int, int> $converteroutcome =
      const EnumIndexConverter<ReportOutcome>(ReportOutcome.values);
  static JsonTypeConverter2<ReportOutcome?, int?, int?> $converteroutcomen =
      JsonTypeConverter2.asNullable($converteroutcome);
}

class TicketReport extends DataClass implements Insertable<TicketReport> {
  final int id;
  final int ticketId;
  final ReportKind kind;
  final ReportStatus status;
  final String author;

  /// Bumped when a sent report is edited; earlier revisions are kept.
  final int revision;
  final String? summary;

  /// Warranty length in days, counted from [warrantyStartAt].
  final int? warrantyDays;

  /// Start of cover — normally the pickup/completion date, captured when the
  /// client report is finalised, not when it was drafted.
  final DateTime? warrantyStartAt;

  /// What the warranty covers and excludes, frozen with this revision.
  final String? warrantyTerms;
  final ReportOutcome? outcome;

  /// Shop tag printed on this revision, e.g. `G-482913057`. Copied in when the
  /// report is written so a sent report keeps the tag it was issued with, even
  /// if the sticker is later replaced.
  final String? shopTag;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? finalizedAt;
  const TicketReport(
      {required this.id,
      required this.ticketId,
      required this.kind,
      required this.status,
      required this.author,
      required this.revision,
      this.summary,
      this.warrantyDays,
      this.warrantyStartAt,
      this.warrantyTerms,
      this.outcome,
      this.shopTag,
      required this.createdAt,
      required this.updatedAt,
      this.finalizedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ticket_id'] = Variable<int>(ticketId);
    {
      map['kind'] =
          Variable<int>($TicketReportsTable.$converterkind.toSql(kind));
    }
    {
      map['status'] =
          Variable<int>($TicketReportsTable.$converterstatus.toSql(status));
    }
    map['author'] = Variable<String>(author);
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    if (!nullToAbsent || warrantyDays != null) {
      map['warranty_days'] = Variable<int>(warrantyDays);
    }
    if (!nullToAbsent || warrantyStartAt != null) {
      map['warranty_start_at'] = Variable<DateTime>(warrantyStartAt);
    }
    if (!nullToAbsent || warrantyTerms != null) {
      map['warranty_terms'] = Variable<String>(warrantyTerms);
    }
    if (!nullToAbsent || outcome != null) {
      map['outcome'] =
          Variable<int>($TicketReportsTable.$converteroutcomen.toSql(outcome));
    }
    if (!nullToAbsent || shopTag != null) {
      map['shop_tag'] = Variable<String>(shopTag);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || finalizedAt != null) {
      map['finalized_at'] = Variable<DateTime>(finalizedAt);
    }
    return map;
  }

  TicketReportsCompanion toCompanion(bool nullToAbsent) {
    return TicketReportsCompanion(
      id: Value(id),
      ticketId: Value(ticketId),
      kind: Value(kind),
      status: Value(status),
      author: Value(author),
      revision: Value(revision),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      warrantyDays: warrantyDays == null && nullToAbsent
          ? const Value.absent()
          : Value(warrantyDays),
      warrantyStartAt: warrantyStartAt == null && nullToAbsent
          ? const Value.absent()
          : Value(warrantyStartAt),
      warrantyTerms: warrantyTerms == null && nullToAbsent
          ? const Value.absent()
          : Value(warrantyTerms),
      outcome: outcome == null && nullToAbsent
          ? const Value.absent()
          : Value(outcome),
      shopTag: shopTag == null && nullToAbsent
          ? const Value.absent()
          : Value(shopTag),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      finalizedAt: finalizedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finalizedAt),
    );
  }

  factory TicketReport.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TicketReport(
      id: serializer.fromJson<int>(json['id']),
      ticketId: serializer.fromJson<int>(json['ticketId']),
      kind: $TicketReportsTable.$converterkind
          .fromJson(serializer.fromJson<int>(json['kind'])),
      status: $TicketReportsTable.$converterstatus
          .fromJson(serializer.fromJson<int>(json['status'])),
      author: serializer.fromJson<String>(json['author']),
      revision: serializer.fromJson<int>(json['revision']),
      summary: serializer.fromJson<String?>(json['summary']),
      warrantyDays: serializer.fromJson<int?>(json['warrantyDays']),
      warrantyStartAt: serializer.fromJson<DateTime?>(json['warrantyStartAt']),
      warrantyTerms: serializer.fromJson<String?>(json['warrantyTerms']),
      outcome: $TicketReportsTable.$converteroutcomen
          .fromJson(serializer.fromJson<int?>(json['outcome'])),
      shopTag: serializer.fromJson<String?>(json['shopTag']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      finalizedAt: serializer.fromJson<DateTime?>(json['finalizedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ticketId': serializer.toJson<int>(ticketId),
      'kind': serializer
          .toJson<int>($TicketReportsTable.$converterkind.toJson(kind)),
      'status': serializer
          .toJson<int>($TicketReportsTable.$converterstatus.toJson(status)),
      'author': serializer.toJson<String>(author),
      'revision': serializer.toJson<int>(revision),
      'summary': serializer.toJson<String?>(summary),
      'warrantyDays': serializer.toJson<int?>(warrantyDays),
      'warrantyStartAt': serializer.toJson<DateTime?>(warrantyStartAt),
      'warrantyTerms': serializer.toJson<String?>(warrantyTerms),
      'outcome': serializer
          .toJson<int?>($TicketReportsTable.$converteroutcomen.toJson(outcome)),
      'shopTag': serializer.toJson<String?>(shopTag),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'finalizedAt': serializer.toJson<DateTime?>(finalizedAt),
    };
  }

  TicketReport copyWith(
          {int? id,
          int? ticketId,
          ReportKind? kind,
          ReportStatus? status,
          String? author,
          int? revision,
          Value<String?> summary = const Value.absent(),
          Value<int?> warrantyDays = const Value.absent(),
          Value<DateTime?> warrantyStartAt = const Value.absent(),
          Value<String?> warrantyTerms = const Value.absent(),
          Value<ReportOutcome?> outcome = const Value.absent(),
          Value<String?> shopTag = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> finalizedAt = const Value.absent()}) =>
      TicketReport(
        id: id ?? this.id,
        ticketId: ticketId ?? this.ticketId,
        kind: kind ?? this.kind,
        status: status ?? this.status,
        author: author ?? this.author,
        revision: revision ?? this.revision,
        summary: summary.present ? summary.value : this.summary,
        warrantyDays:
            warrantyDays.present ? warrantyDays.value : this.warrantyDays,
        warrantyStartAt: warrantyStartAt.present
            ? warrantyStartAt.value
            : this.warrantyStartAt,
        warrantyTerms:
            warrantyTerms.present ? warrantyTerms.value : this.warrantyTerms,
        outcome: outcome.present ? outcome.value : this.outcome,
        shopTag: shopTag.present ? shopTag.value : this.shopTag,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        finalizedAt: finalizedAt.present ? finalizedAt.value : this.finalizedAt,
      );
  TicketReport copyWithCompanion(TicketReportsCompanion data) {
    return TicketReport(
      id: data.id.present ? data.id.value : this.id,
      ticketId: data.ticketId.present ? data.ticketId.value : this.ticketId,
      kind: data.kind.present ? data.kind.value : this.kind,
      status: data.status.present ? data.status.value : this.status,
      author: data.author.present ? data.author.value : this.author,
      revision: data.revision.present ? data.revision.value : this.revision,
      summary: data.summary.present ? data.summary.value : this.summary,
      warrantyDays: data.warrantyDays.present
          ? data.warrantyDays.value
          : this.warrantyDays,
      warrantyStartAt: data.warrantyStartAt.present
          ? data.warrantyStartAt.value
          : this.warrantyStartAt,
      warrantyTerms: data.warrantyTerms.present
          ? data.warrantyTerms.value
          : this.warrantyTerms,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      shopTag: data.shopTag.present ? data.shopTag.value : this.shopTag,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      finalizedAt:
          data.finalizedAt.present ? data.finalizedAt.value : this.finalizedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TicketReport(')
          ..write('id: $id, ')
          ..write('ticketId: $ticketId, ')
          ..write('kind: $kind, ')
          ..write('status: $status, ')
          ..write('author: $author, ')
          ..write('revision: $revision, ')
          ..write('summary: $summary, ')
          ..write('warrantyDays: $warrantyDays, ')
          ..write('warrantyStartAt: $warrantyStartAt, ')
          ..write('warrantyTerms: $warrantyTerms, ')
          ..write('outcome: $outcome, ')
          ..write('shopTag: $shopTag, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('finalizedAt: $finalizedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      ticketId,
      kind,
      status,
      author,
      revision,
      summary,
      warrantyDays,
      warrantyStartAt,
      warrantyTerms,
      outcome,
      shopTag,
      createdAt,
      updatedAt,
      finalizedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TicketReport &&
          other.id == this.id &&
          other.ticketId == this.ticketId &&
          other.kind == this.kind &&
          other.status == this.status &&
          other.author == this.author &&
          other.revision == this.revision &&
          other.summary == this.summary &&
          other.warrantyDays == this.warrantyDays &&
          other.warrantyStartAt == this.warrantyStartAt &&
          other.warrantyTerms == this.warrantyTerms &&
          other.outcome == this.outcome &&
          other.shopTag == this.shopTag &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.finalizedAt == this.finalizedAt);
}

class TicketReportsCompanion extends UpdateCompanion<TicketReport> {
  final Value<int> id;
  final Value<int> ticketId;
  final Value<ReportKind> kind;
  final Value<ReportStatus> status;
  final Value<String> author;
  final Value<int> revision;
  final Value<String?> summary;
  final Value<int?> warrantyDays;
  final Value<DateTime?> warrantyStartAt;
  final Value<String?> warrantyTerms;
  final Value<ReportOutcome?> outcome;
  final Value<String?> shopTag;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> finalizedAt;
  const TicketReportsCompanion({
    this.id = const Value.absent(),
    this.ticketId = const Value.absent(),
    this.kind = const Value.absent(),
    this.status = const Value.absent(),
    this.author = const Value.absent(),
    this.revision = const Value.absent(),
    this.summary = const Value.absent(),
    this.warrantyDays = const Value.absent(),
    this.warrantyStartAt = const Value.absent(),
    this.warrantyTerms = const Value.absent(),
    this.outcome = const Value.absent(),
    this.shopTag = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.finalizedAt = const Value.absent(),
  });
  TicketReportsCompanion.insert({
    this.id = const Value.absent(),
    required int ticketId,
    required ReportKind kind,
    required ReportStatus status,
    required String author,
    this.revision = const Value.absent(),
    this.summary = const Value.absent(),
    this.warrantyDays = const Value.absent(),
    this.warrantyStartAt = const Value.absent(),
    this.warrantyTerms = const Value.absent(),
    this.outcome = const Value.absent(),
    this.shopTag = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.finalizedAt = const Value.absent(),
  })  : ticketId = Value(ticketId),
        kind = Value(kind),
        status = Value(status),
        author = Value(author);
  static Insertable<TicketReport> custom({
    Expression<int>? id,
    Expression<int>? ticketId,
    Expression<int>? kind,
    Expression<int>? status,
    Expression<String>? author,
    Expression<int>? revision,
    Expression<String>? summary,
    Expression<int>? warrantyDays,
    Expression<DateTime>? warrantyStartAt,
    Expression<String>? warrantyTerms,
    Expression<int>? outcome,
    Expression<String>? shopTag,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? finalizedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ticketId != null) 'ticket_id': ticketId,
      if (kind != null) 'kind': kind,
      if (status != null) 'status': status,
      if (author != null) 'author': author,
      if (revision != null) 'revision': revision,
      if (summary != null) 'summary': summary,
      if (warrantyDays != null) 'warranty_days': warrantyDays,
      if (warrantyStartAt != null) 'warranty_start_at': warrantyStartAt,
      if (warrantyTerms != null) 'warranty_terms': warrantyTerms,
      if (outcome != null) 'outcome': outcome,
      if (shopTag != null) 'shop_tag': shopTag,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (finalizedAt != null) 'finalized_at': finalizedAt,
    });
  }

  TicketReportsCompanion copyWith(
      {Value<int>? id,
      Value<int>? ticketId,
      Value<ReportKind>? kind,
      Value<ReportStatus>? status,
      Value<String>? author,
      Value<int>? revision,
      Value<String?>? summary,
      Value<int?>? warrantyDays,
      Value<DateTime?>? warrantyStartAt,
      Value<String?>? warrantyTerms,
      Value<ReportOutcome?>? outcome,
      Value<String?>? shopTag,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? finalizedAt}) {
    return TicketReportsCompanion(
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      kind: kind ?? this.kind,
      status: status ?? this.status,
      author: author ?? this.author,
      revision: revision ?? this.revision,
      summary: summary ?? this.summary,
      warrantyDays: warrantyDays ?? this.warrantyDays,
      warrantyStartAt: warrantyStartAt ?? this.warrantyStartAt,
      warrantyTerms: warrantyTerms ?? this.warrantyTerms,
      outcome: outcome ?? this.outcome,
      shopTag: shopTag ?? this.shopTag,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      finalizedAt: finalizedAt ?? this.finalizedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ticketId.present) {
      map['ticket_id'] = Variable<int>(ticketId.value);
    }
    if (kind.present) {
      map['kind'] =
          Variable<int>($TicketReportsTable.$converterkind.toSql(kind.value));
    }
    if (status.present) {
      map['status'] = Variable<int>(
          $TicketReportsTable.$converterstatus.toSql(status.value));
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (warrantyDays.present) {
      map['warranty_days'] = Variable<int>(warrantyDays.value);
    }
    if (warrantyStartAt.present) {
      map['warranty_start_at'] = Variable<DateTime>(warrantyStartAt.value);
    }
    if (warrantyTerms.present) {
      map['warranty_terms'] = Variable<String>(warrantyTerms.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<int>(
          $TicketReportsTable.$converteroutcomen.toSql(outcome.value));
    }
    if (shopTag.present) {
      map['shop_tag'] = Variable<String>(shopTag.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (finalizedAt.present) {
      map['finalized_at'] = Variable<DateTime>(finalizedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TicketReportsCompanion(')
          ..write('id: $id, ')
          ..write('ticketId: $ticketId, ')
          ..write('kind: $kind, ')
          ..write('status: $status, ')
          ..write('author: $author, ')
          ..write('revision: $revision, ')
          ..write('summary: $summary, ')
          ..write('warrantyDays: $warrantyDays, ')
          ..write('warrantyStartAt: $warrantyStartAt, ')
          ..write('warrantyTerms: $warrantyTerms, ')
          ..write('outcome: $outcome, ')
          ..write('shopTag: $shopTag, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('finalizedAt: $finalizedAt')
          ..write(')'))
        .toString();
  }
}

class $ReportCosmeticItemsTable extends ReportCosmeticItems
    with TableInfo<$ReportCosmeticItemsTable, ReportCosmeticItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReportCosmeticItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _reportIdMeta =
      const VerificationMeta('reportId');
  @override
  late final GeneratedColumn<int> reportId = GeneratedColumn<int>(
      'report_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES ticket_reports (id)'));
  static const VerificationMeta _areaMeta = const VerificationMeta('area');
  @override
  late final GeneratedColumn<String> area = GeneratedColumn<String>(
      'area', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 60),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<CosmeticCondition, int>
      condition = GeneratedColumn<int>('condition', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<CosmeticCondition>(
              $ReportCosmeticItemsTable.$convertercondition);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, reportId, area, condition, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'report_cosmetic_items';
  @override
  VerificationContext validateIntegrity(Insertable<ReportCosmeticItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('report_id')) {
      context.handle(_reportIdMeta,
          reportId.isAcceptableOrUnknown(data['report_id']!, _reportIdMeta));
    } else if (isInserting) {
      context.missing(_reportIdMeta);
    }
    if (data.containsKey('area')) {
      context.handle(
          _areaMeta, area.isAcceptableOrUnknown(data['area']!, _areaMeta));
    } else if (isInserting) {
      context.missing(_areaMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReportCosmeticItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReportCosmeticItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      reportId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}report_id'])!,
      area: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}area'])!,
      condition: $ReportCosmeticItemsTable.$convertercondition.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}condition'])!),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $ReportCosmeticItemsTable createAlias(String alias) {
    return $ReportCosmeticItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CosmeticCondition, int, int> $convertercondition =
      const EnumIndexConverter<CosmeticCondition>(CosmeticCondition.values);
}

class ReportCosmeticItem extends DataClass
    implements Insertable<ReportCosmeticItem> {
  final int id;
  final int reportId;
  final String area;
  final CosmeticCondition condition;
  final String? note;
  const ReportCosmeticItem(
      {required this.id,
      required this.reportId,
      required this.area,
      required this.condition,
      this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['report_id'] = Variable<int>(reportId);
    map['area'] = Variable<String>(area);
    {
      map['condition'] = Variable<int>(
          $ReportCosmeticItemsTable.$convertercondition.toSql(condition));
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  ReportCosmeticItemsCompanion toCompanion(bool nullToAbsent) {
    return ReportCosmeticItemsCompanion(
      id: Value(id),
      reportId: Value(reportId),
      area: Value(area),
      condition: Value(condition),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory ReportCosmeticItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReportCosmeticItem(
      id: serializer.fromJson<int>(json['id']),
      reportId: serializer.fromJson<int>(json['reportId']),
      area: serializer.fromJson<String>(json['area']),
      condition: $ReportCosmeticItemsTable.$convertercondition
          .fromJson(serializer.fromJson<int>(json['condition'])),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'reportId': serializer.toJson<int>(reportId),
      'area': serializer.toJson<String>(area),
      'condition': serializer.toJson<int>(
          $ReportCosmeticItemsTable.$convertercondition.toJson(condition)),
      'note': serializer.toJson<String?>(note),
    };
  }

  ReportCosmeticItem copyWith(
          {int? id,
          int? reportId,
          String? area,
          CosmeticCondition? condition,
          Value<String?> note = const Value.absent()}) =>
      ReportCosmeticItem(
        id: id ?? this.id,
        reportId: reportId ?? this.reportId,
        area: area ?? this.area,
        condition: condition ?? this.condition,
        note: note.present ? note.value : this.note,
      );
  ReportCosmeticItem copyWithCompanion(ReportCosmeticItemsCompanion data) {
    return ReportCosmeticItem(
      id: data.id.present ? data.id.value : this.id,
      reportId: data.reportId.present ? data.reportId.value : this.reportId,
      area: data.area.present ? data.area.value : this.area,
      condition: data.condition.present ? data.condition.value : this.condition,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReportCosmeticItem(')
          ..write('id: $id, ')
          ..write('reportId: $reportId, ')
          ..write('area: $area, ')
          ..write('condition: $condition, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, reportId, area, condition, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReportCosmeticItem &&
          other.id == this.id &&
          other.reportId == this.reportId &&
          other.area == this.area &&
          other.condition == this.condition &&
          other.note == this.note);
}

class ReportCosmeticItemsCompanion extends UpdateCompanion<ReportCosmeticItem> {
  final Value<int> id;
  final Value<int> reportId;
  final Value<String> area;
  final Value<CosmeticCondition> condition;
  final Value<String?> note;
  const ReportCosmeticItemsCompanion({
    this.id = const Value.absent(),
    this.reportId = const Value.absent(),
    this.area = const Value.absent(),
    this.condition = const Value.absent(),
    this.note = const Value.absent(),
  });
  ReportCosmeticItemsCompanion.insert({
    this.id = const Value.absent(),
    required int reportId,
    required String area,
    required CosmeticCondition condition,
    this.note = const Value.absent(),
  })  : reportId = Value(reportId),
        area = Value(area),
        condition = Value(condition);
  static Insertable<ReportCosmeticItem> custom({
    Expression<int>? id,
    Expression<int>? reportId,
    Expression<String>? area,
    Expression<int>? condition,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reportId != null) 'report_id': reportId,
      if (area != null) 'area': area,
      if (condition != null) 'condition': condition,
      if (note != null) 'note': note,
    });
  }

  ReportCosmeticItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? reportId,
      Value<String>? area,
      Value<CosmeticCondition>? condition,
      Value<String?>? note}) {
    return ReportCosmeticItemsCompanion(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      area: area ?? this.area,
      condition: condition ?? this.condition,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (reportId.present) {
      map['report_id'] = Variable<int>(reportId.value);
    }
    if (area.present) {
      map['area'] = Variable<String>(area.value);
    }
    if (condition.present) {
      map['condition'] = Variable<int>(
          $ReportCosmeticItemsTable.$convertercondition.toSql(condition.value));
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReportCosmeticItemsCompanion(')
          ..write('id: $id, ')
          ..write('reportId: $reportId, ')
          ..write('area: $area, ')
          ..write('condition: $condition, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $ReportFindingsTable extends ReportFindings
    with TableInfo<$ReportFindingsTable, ReportFinding> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReportFindingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _reportIdMeta =
      const VerificationMeta('reportId');
  @override
  late final GeneratedColumn<int> reportId = GeneratedColumn<int>(
      'report_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES ticket_reports (id)'));
  static const VerificationMeta _areaMeta = const VerificationMeta('area');
  @override
  late final GeneratedColumn<String> area = GeneratedColumn<String>(
      'area', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 60),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _symptomMeta =
      const VerificationMeta('symptom');
  @override
  late final GeneratedColumn<String> symptom = GeneratedColumn<String>(
      'symptom', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _causeMeta = const VerificationMeta('cause');
  @override
  late final GeneratedColumn<String> cause = GeneratedColumn<String>(
      'cause', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<Severity, int> severity =
      GeneratedColumn<int>('severity', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<Severity>($ReportFindingsTable.$converterseverity);
  static const VerificationMeta _proposedFixMeta =
      const VerificationMeta('proposedFix');
  @override
  late final GeneratedColumn<String> proposedFix = GeneratedColumn<String>(
      'proposed_fix', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, reportId, area, symptom, cause, severity, proposedFix];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'report_findings';
  @override
  VerificationContext validateIntegrity(Insertable<ReportFinding> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('report_id')) {
      context.handle(_reportIdMeta,
          reportId.isAcceptableOrUnknown(data['report_id']!, _reportIdMeta));
    } else if (isInserting) {
      context.missing(_reportIdMeta);
    }
    if (data.containsKey('area')) {
      context.handle(
          _areaMeta, area.isAcceptableOrUnknown(data['area']!, _areaMeta));
    } else if (isInserting) {
      context.missing(_areaMeta);
    }
    if (data.containsKey('symptom')) {
      context.handle(_symptomMeta,
          symptom.isAcceptableOrUnknown(data['symptom']!, _symptomMeta));
    } else if (isInserting) {
      context.missing(_symptomMeta);
    }
    if (data.containsKey('cause')) {
      context.handle(
          _causeMeta, cause.isAcceptableOrUnknown(data['cause']!, _causeMeta));
    }
    if (data.containsKey('proposed_fix')) {
      context.handle(
          _proposedFixMeta,
          proposedFix.isAcceptableOrUnknown(
              data['proposed_fix']!, _proposedFixMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReportFinding map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReportFinding(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      reportId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}report_id'])!,
      area: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}area'])!,
      symptom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}symptom'])!,
      cause: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cause']),
      severity: $ReportFindingsTable.$converterseverity.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}severity'])!),
      proposedFix: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}proposed_fix']),
    );
  }

  @override
  $ReportFindingsTable createAlias(String alias) {
    return $ReportFindingsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Severity, int, int> $converterseverity =
      const EnumIndexConverter<Severity>(Severity.values);
}

class ReportFinding extends DataClass implements Insertable<ReportFinding> {
  final int id;
  final int reportId;
  final String area;
  final String symptom;
  final String? cause;
  final Severity severity;
  final String? proposedFix;
  const ReportFinding(
      {required this.id,
      required this.reportId,
      required this.area,
      required this.symptom,
      this.cause,
      required this.severity,
      this.proposedFix});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['report_id'] = Variable<int>(reportId);
    map['area'] = Variable<String>(area);
    map['symptom'] = Variable<String>(symptom);
    if (!nullToAbsent || cause != null) {
      map['cause'] = Variable<String>(cause);
    }
    {
      map['severity'] = Variable<int>(
          $ReportFindingsTable.$converterseverity.toSql(severity));
    }
    if (!nullToAbsent || proposedFix != null) {
      map['proposed_fix'] = Variable<String>(proposedFix);
    }
    return map;
  }

  ReportFindingsCompanion toCompanion(bool nullToAbsent) {
    return ReportFindingsCompanion(
      id: Value(id),
      reportId: Value(reportId),
      area: Value(area),
      symptom: Value(symptom),
      cause:
          cause == null && nullToAbsent ? const Value.absent() : Value(cause),
      severity: Value(severity),
      proposedFix: proposedFix == null && nullToAbsent
          ? const Value.absent()
          : Value(proposedFix),
    );
  }

  factory ReportFinding.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReportFinding(
      id: serializer.fromJson<int>(json['id']),
      reportId: serializer.fromJson<int>(json['reportId']),
      area: serializer.fromJson<String>(json['area']),
      symptom: serializer.fromJson<String>(json['symptom']),
      cause: serializer.fromJson<String?>(json['cause']),
      severity: $ReportFindingsTable.$converterseverity
          .fromJson(serializer.fromJson<int>(json['severity'])),
      proposedFix: serializer.fromJson<String?>(json['proposedFix']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'reportId': serializer.toJson<int>(reportId),
      'area': serializer.toJson<String>(area),
      'symptom': serializer.toJson<String>(symptom),
      'cause': serializer.toJson<String?>(cause),
      'severity': serializer.toJson<int>(
          $ReportFindingsTable.$converterseverity.toJson(severity)),
      'proposedFix': serializer.toJson<String?>(proposedFix),
    };
  }

  ReportFinding copyWith(
          {int? id,
          int? reportId,
          String? area,
          String? symptom,
          Value<String?> cause = const Value.absent(),
          Severity? severity,
          Value<String?> proposedFix = const Value.absent()}) =>
      ReportFinding(
        id: id ?? this.id,
        reportId: reportId ?? this.reportId,
        area: area ?? this.area,
        symptom: symptom ?? this.symptom,
        cause: cause.present ? cause.value : this.cause,
        severity: severity ?? this.severity,
        proposedFix: proposedFix.present ? proposedFix.value : this.proposedFix,
      );
  ReportFinding copyWithCompanion(ReportFindingsCompanion data) {
    return ReportFinding(
      id: data.id.present ? data.id.value : this.id,
      reportId: data.reportId.present ? data.reportId.value : this.reportId,
      area: data.area.present ? data.area.value : this.area,
      symptom: data.symptom.present ? data.symptom.value : this.symptom,
      cause: data.cause.present ? data.cause.value : this.cause,
      severity: data.severity.present ? data.severity.value : this.severity,
      proposedFix:
          data.proposedFix.present ? data.proposedFix.value : this.proposedFix,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReportFinding(')
          ..write('id: $id, ')
          ..write('reportId: $reportId, ')
          ..write('area: $area, ')
          ..write('symptom: $symptom, ')
          ..write('cause: $cause, ')
          ..write('severity: $severity, ')
          ..write('proposedFix: $proposedFix')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, reportId, area, symptom, cause, severity, proposedFix);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReportFinding &&
          other.id == this.id &&
          other.reportId == this.reportId &&
          other.area == this.area &&
          other.symptom == this.symptom &&
          other.cause == this.cause &&
          other.severity == this.severity &&
          other.proposedFix == this.proposedFix);
}

class ReportFindingsCompanion extends UpdateCompanion<ReportFinding> {
  final Value<int> id;
  final Value<int> reportId;
  final Value<String> area;
  final Value<String> symptom;
  final Value<String?> cause;
  final Value<Severity> severity;
  final Value<String?> proposedFix;
  const ReportFindingsCompanion({
    this.id = const Value.absent(),
    this.reportId = const Value.absent(),
    this.area = const Value.absent(),
    this.symptom = const Value.absent(),
    this.cause = const Value.absent(),
    this.severity = const Value.absent(),
    this.proposedFix = const Value.absent(),
  });
  ReportFindingsCompanion.insert({
    this.id = const Value.absent(),
    required int reportId,
    required String area,
    required String symptom,
    this.cause = const Value.absent(),
    required Severity severity,
    this.proposedFix = const Value.absent(),
  })  : reportId = Value(reportId),
        area = Value(area),
        symptom = Value(symptom),
        severity = Value(severity);
  static Insertable<ReportFinding> custom({
    Expression<int>? id,
    Expression<int>? reportId,
    Expression<String>? area,
    Expression<String>? symptom,
    Expression<String>? cause,
    Expression<int>? severity,
    Expression<String>? proposedFix,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reportId != null) 'report_id': reportId,
      if (area != null) 'area': area,
      if (symptom != null) 'symptom': symptom,
      if (cause != null) 'cause': cause,
      if (severity != null) 'severity': severity,
      if (proposedFix != null) 'proposed_fix': proposedFix,
    });
  }

  ReportFindingsCompanion copyWith(
      {Value<int>? id,
      Value<int>? reportId,
      Value<String>? area,
      Value<String>? symptom,
      Value<String?>? cause,
      Value<Severity>? severity,
      Value<String?>? proposedFix}) {
    return ReportFindingsCompanion(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      area: area ?? this.area,
      symptom: symptom ?? this.symptom,
      cause: cause ?? this.cause,
      severity: severity ?? this.severity,
      proposedFix: proposedFix ?? this.proposedFix,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (reportId.present) {
      map['report_id'] = Variable<int>(reportId.value);
    }
    if (area.present) {
      map['area'] = Variable<String>(area.value);
    }
    if (symptom.present) {
      map['symptom'] = Variable<String>(symptom.value);
    }
    if (cause.present) {
      map['cause'] = Variable<String>(cause.value);
    }
    if (severity.present) {
      map['severity'] = Variable<int>(
          $ReportFindingsTable.$converterseverity.toSql(severity.value));
    }
    if (proposedFix.present) {
      map['proposed_fix'] = Variable<String>(proposedFix.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReportFindingsCompanion(')
          ..write('id: $id, ')
          ..write('reportId: $reportId, ')
          ..write('area: $area, ')
          ..write('symptom: $symptom, ')
          ..write('cause: $cause, ')
          ..write('severity: $severity, ')
          ..write('proposedFix: $proposedFix')
          ..write(')'))
        .toString();
  }
}

class $TechnicalReportEntriesTable extends TechnicalReportEntries
    with TableInfo<$TechnicalReportEntriesTable, TechnicalReportEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TechnicalReportEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _reportIdMeta =
      const VerificationMeta('reportId');
  @override
  late final GeneratedColumn<int> reportId = GeneratedColumn<int>(
      'report_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES ticket_reports (id)'));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<TechnicalEntryKind, int> kind =
      GeneratedColumn<int>('kind', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<TechnicalEntryKind>(
              $TechnicalReportEntriesTable.$converterkind);
  static const VerificationMeta _parentEntryIdMeta =
      const VerificationMeta('parentEntryId');
  @override
  late final GeneratedColumn<int> parentEntryId = GeneratedColumn<int>(
      'parent_entry_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _photoPathMeta =
      const VerificationMeta('photoPath');
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
      'photo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _captionMeta =
      const VerificationMeta('caption');
  @override
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
      'caption', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, reportId, sortOrder, kind, parentEntryId, body, photoPath, caption];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'technical_report_entries';
  @override
  VerificationContext validateIntegrity(
      Insertable<TechnicalReportEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('report_id')) {
      context.handle(_reportIdMeta,
          reportId.isAcceptableOrUnknown(data['report_id']!, _reportIdMeta));
    } else if (isInserting) {
      context.missing(_reportIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('parent_entry_id')) {
      context.handle(
          _parentEntryIdMeta,
          parentEntryId.isAcceptableOrUnknown(
              data['parent_entry_id']!, _parentEntryIdMeta));
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    }
    if (data.containsKey('photo_path')) {
      context.handle(_photoPathMeta,
          photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta));
    }
    if (data.containsKey('caption')) {
      context.handle(_captionMeta,
          caption.isAcceptableOrUnknown(data['caption']!, _captionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TechnicalReportEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TechnicalReportEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      reportId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}report_id'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      kind: $TechnicalReportEntriesTable.$converterkind.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}kind'])!),
      parentEntryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}parent_entry_id']),
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body']),
      photoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_path']),
      caption: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}caption']),
    );
  }

  @override
  $TechnicalReportEntriesTable createAlias(String alias) {
    return $TechnicalReportEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TechnicalEntryKind, int, int> $converterkind =
      const EnumIndexConverter<TechnicalEntryKind>(TechnicalEntryKind.values);
}

class TechnicalReportEntry extends DataClass
    implements Insertable<TechnicalReportEntry> {
  final int id;
  final int reportId;
  final int sortOrder;
  final TechnicalEntryKind kind;
  final int? parentEntryId;
  final String? body;
  final String? photoPath;
  final String? caption;
  const TechnicalReportEntry(
      {required this.id,
      required this.reportId,
      required this.sortOrder,
      required this.kind,
      this.parentEntryId,
      this.body,
      this.photoPath,
      this.caption});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['report_id'] = Variable<int>(reportId);
    map['sort_order'] = Variable<int>(sortOrder);
    {
      map['kind'] = Variable<int>(
          $TechnicalReportEntriesTable.$converterkind.toSql(kind));
    }
    if (!nullToAbsent || parentEntryId != null) {
      map['parent_entry_id'] = Variable<int>(parentEntryId);
    }
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<String>(body);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || caption != null) {
      map['caption'] = Variable<String>(caption);
    }
    return map;
  }

  TechnicalReportEntriesCompanion toCompanion(bool nullToAbsent) {
    return TechnicalReportEntriesCompanion(
      id: Value(id),
      reportId: Value(reportId),
      sortOrder: Value(sortOrder),
      kind: Value(kind),
      parentEntryId: parentEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentEntryId),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      caption: caption == null && nullToAbsent
          ? const Value.absent()
          : Value(caption),
    );
  }

  factory TechnicalReportEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TechnicalReportEntry(
      id: serializer.fromJson<int>(json['id']),
      reportId: serializer.fromJson<int>(json['reportId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      kind: $TechnicalReportEntriesTable.$converterkind
          .fromJson(serializer.fromJson<int>(json['kind'])),
      parentEntryId: serializer.fromJson<int?>(json['parentEntryId']),
      body: serializer.fromJson<String?>(json['body']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      caption: serializer.fromJson<String?>(json['caption']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'reportId': serializer.toJson<int>(reportId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'kind': serializer.toJson<int>(
          $TechnicalReportEntriesTable.$converterkind.toJson(kind)),
      'parentEntryId': serializer.toJson<int?>(parentEntryId),
      'body': serializer.toJson<String?>(body),
      'photoPath': serializer.toJson<String?>(photoPath),
      'caption': serializer.toJson<String?>(caption),
    };
  }

  TechnicalReportEntry copyWith(
          {int? id,
          int? reportId,
          int? sortOrder,
          TechnicalEntryKind? kind,
          Value<int?> parentEntryId = const Value.absent(),
          Value<String?> body = const Value.absent(),
          Value<String?> photoPath = const Value.absent(),
          Value<String?> caption = const Value.absent()}) =>
      TechnicalReportEntry(
        id: id ?? this.id,
        reportId: reportId ?? this.reportId,
        sortOrder: sortOrder ?? this.sortOrder,
        kind: kind ?? this.kind,
        parentEntryId:
            parentEntryId.present ? parentEntryId.value : this.parentEntryId,
        body: body.present ? body.value : this.body,
        photoPath: photoPath.present ? photoPath.value : this.photoPath,
        caption: caption.present ? caption.value : this.caption,
      );
  TechnicalReportEntry copyWithCompanion(TechnicalReportEntriesCompanion data) {
    return TechnicalReportEntry(
      id: data.id.present ? data.id.value : this.id,
      reportId: data.reportId.present ? data.reportId.value : this.reportId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      kind: data.kind.present ? data.kind.value : this.kind,
      parentEntryId: data.parentEntryId.present
          ? data.parentEntryId.value
          : this.parentEntryId,
      body: data.body.present ? data.body.value : this.body,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      caption: data.caption.present ? data.caption.value : this.caption,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TechnicalReportEntry(')
          ..write('id: $id, ')
          ..write('reportId: $reportId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('kind: $kind, ')
          ..write('parentEntryId: $parentEntryId, ')
          ..write('body: $body, ')
          ..write('photoPath: $photoPath, ')
          ..write('caption: $caption')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, reportId, sortOrder, kind, parentEntryId, body, photoPath, caption);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TechnicalReportEntry &&
          other.id == this.id &&
          other.reportId == this.reportId &&
          other.sortOrder == this.sortOrder &&
          other.kind == this.kind &&
          other.parentEntryId == this.parentEntryId &&
          other.body == this.body &&
          other.photoPath == this.photoPath &&
          other.caption == this.caption);
}

class TechnicalReportEntriesCompanion
    extends UpdateCompanion<TechnicalReportEntry> {
  final Value<int> id;
  final Value<int> reportId;
  final Value<int> sortOrder;
  final Value<TechnicalEntryKind> kind;
  final Value<int?> parentEntryId;
  final Value<String?> body;
  final Value<String?> photoPath;
  final Value<String?> caption;
  const TechnicalReportEntriesCompanion({
    this.id = const Value.absent(),
    this.reportId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.kind = const Value.absent(),
    this.parentEntryId = const Value.absent(),
    this.body = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.caption = const Value.absent(),
  });
  TechnicalReportEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int reportId,
    required int sortOrder,
    required TechnicalEntryKind kind,
    this.parentEntryId = const Value.absent(),
    this.body = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.caption = const Value.absent(),
  })  : reportId = Value(reportId),
        sortOrder = Value(sortOrder),
        kind = Value(kind);
  static Insertable<TechnicalReportEntry> custom({
    Expression<int>? id,
    Expression<int>? reportId,
    Expression<int>? sortOrder,
    Expression<int>? kind,
    Expression<int>? parentEntryId,
    Expression<String>? body,
    Expression<String>? photoPath,
    Expression<String>? caption,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reportId != null) 'report_id': reportId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (kind != null) 'kind': kind,
      if (parentEntryId != null) 'parent_entry_id': parentEntryId,
      if (body != null) 'body': body,
      if (photoPath != null) 'photo_path': photoPath,
      if (caption != null) 'caption': caption,
    });
  }

  TechnicalReportEntriesCompanion copyWith(
      {Value<int>? id,
      Value<int>? reportId,
      Value<int>? sortOrder,
      Value<TechnicalEntryKind>? kind,
      Value<int?>? parentEntryId,
      Value<String?>? body,
      Value<String?>? photoPath,
      Value<String?>? caption}) {
    return TechnicalReportEntriesCompanion(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      sortOrder: sortOrder ?? this.sortOrder,
      kind: kind ?? this.kind,
      parentEntryId: parentEntryId ?? this.parentEntryId,
      body: body ?? this.body,
      photoPath: photoPath ?? this.photoPath,
      caption: caption ?? this.caption,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (reportId.present) {
      map['report_id'] = Variable<int>(reportId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (kind.present) {
      map['kind'] = Variable<int>(
          $TechnicalReportEntriesTable.$converterkind.toSql(kind.value));
    }
    if (parentEntryId.present) {
      map['parent_entry_id'] = Variable<int>(parentEntryId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TechnicalReportEntriesCompanion(')
          ..write('id: $id, ')
          ..write('reportId: $reportId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('kind: $kind, ')
          ..write('parentEntryId: $parentEntryId, ')
          ..write('body: $body, ')
          ..write('photoPath: $photoPath, ')
          ..write('caption: $caption')
          ..write(')'))
        .toString();
  }
}

class $ClientReportEntriesTable extends ClientReportEntries
    with TableInfo<$ClientReportEntriesTable, ClientReportEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientReportEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _reportIdMeta =
      const VerificationMeta('reportId');
  @override
  late final GeneratedColumn<int> reportId = GeneratedColumn<int>(
      'report_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES ticket_reports (id)'));
  static const VerificationMeta _sourceEntryIdMeta =
      const VerificationMeta('sourceEntryId');
  @override
  late final GeneratedColumn<int> sourceEntryId = GeneratedColumn<int>(
      'source_entry_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _parentSourceEntryIdMeta =
      const VerificationMeta('parentSourceEntryId');
  @override
  late final GeneratedColumn<int> parentSourceEntryId = GeneratedColumn<int>(
      'parent_source_entry_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<TechnicalEntryKind, int> kind =
      GeneratedColumn<int>('kind', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<TechnicalEntryKind>(
              $ClientReportEntriesTable.$converterkind);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _photoPathMeta =
      const VerificationMeta('photoPath');
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
      'photo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _captionMeta =
      const VerificationMeta('caption');
  @override
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
      'caption', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _contentEditedMeta =
      const VerificationMeta('contentEdited');
  @override
  late final GeneratedColumn<bool> contentEdited = GeneratedColumn<bool>(
      'content_edited', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("content_edited" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _inclusionEditedMeta =
      const VerificationMeta('inclusionEdited');
  @override
  late final GeneratedColumn<bool> inclusionEdited = GeneratedColumn<bool>(
      'inclusion_edited', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("inclusion_edited" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _includedMeta =
      const VerificationMeta('included');
  @override
  late final GeneratedColumn<bool> included = GeneratedColumn<bool>(
      'included', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("included" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        reportId,
        sourceEntryId,
        parentSourceEntryId,
        sortOrder,
        kind,
        body,
        photoPath,
        caption,
        contentEdited,
        inclusionEdited,
        included
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'client_report_entries';
  @override
  VerificationContext validateIntegrity(Insertable<ClientReportEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('report_id')) {
      context.handle(_reportIdMeta,
          reportId.isAcceptableOrUnknown(data['report_id']!, _reportIdMeta));
    } else if (isInserting) {
      context.missing(_reportIdMeta);
    }
    if (data.containsKey('source_entry_id')) {
      context.handle(
          _sourceEntryIdMeta,
          sourceEntryId.isAcceptableOrUnknown(
              data['source_entry_id']!, _sourceEntryIdMeta));
    }
    if (data.containsKey('parent_source_entry_id')) {
      context.handle(
          _parentSourceEntryIdMeta,
          parentSourceEntryId.isAcceptableOrUnknown(
              data['parent_source_entry_id']!, _parentSourceEntryIdMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    }
    if (data.containsKey('photo_path')) {
      context.handle(_photoPathMeta,
          photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta));
    }
    if (data.containsKey('caption')) {
      context.handle(_captionMeta,
          caption.isAcceptableOrUnknown(data['caption']!, _captionMeta));
    }
    if (data.containsKey('content_edited')) {
      context.handle(
          _contentEditedMeta,
          contentEdited.isAcceptableOrUnknown(
              data['content_edited']!, _contentEditedMeta));
    }
    if (data.containsKey('inclusion_edited')) {
      context.handle(
          _inclusionEditedMeta,
          inclusionEdited.isAcceptableOrUnknown(
              data['inclusion_edited']!, _inclusionEditedMeta));
    }
    if (data.containsKey('included')) {
      context.handle(_includedMeta,
          included.isAcceptableOrUnknown(data['included']!, _includedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClientReportEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClientReportEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      reportId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}report_id'])!,
      sourceEntryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}source_entry_id']),
      parentSourceEntryId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}parent_source_entry_id']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      kind: $ClientReportEntriesTable.$converterkind.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}kind'])!),
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body']),
      photoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_path']),
      caption: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}caption']),
      contentEdited: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}content_edited'])!,
      inclusionEdited: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}inclusion_edited'])!,
      included: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}included'])!,
    );
  }

  @override
  $ClientReportEntriesTable createAlias(String alias) {
    return $ClientReportEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TechnicalEntryKind, int, int> $converterkind =
      const EnumIndexConverter<TechnicalEntryKind>(TechnicalEntryKind.values);
}

class ClientReportEntry extends DataClass
    implements Insertable<ClientReportEntry> {
  final int id;
  final int reportId;
  final int? sourceEntryId;
  final int? parentSourceEntryId;
  final int sortOrder;
  final TechnicalEntryKind kind;
  final String? body;
  final String? photoPath;
  final String? caption;
  final bool contentEdited;
  final bool inclusionEdited;
  final bool included;
  const ClientReportEntry(
      {required this.id,
      required this.reportId,
      this.sourceEntryId,
      this.parentSourceEntryId,
      required this.sortOrder,
      required this.kind,
      this.body,
      this.photoPath,
      this.caption,
      required this.contentEdited,
      required this.inclusionEdited,
      required this.included});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['report_id'] = Variable<int>(reportId);
    if (!nullToAbsent || sourceEntryId != null) {
      map['source_entry_id'] = Variable<int>(sourceEntryId);
    }
    if (!nullToAbsent || parentSourceEntryId != null) {
      map['parent_source_entry_id'] = Variable<int>(parentSourceEntryId);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    {
      map['kind'] =
          Variable<int>($ClientReportEntriesTable.$converterkind.toSql(kind));
    }
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<String>(body);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || caption != null) {
      map['caption'] = Variable<String>(caption);
    }
    map['content_edited'] = Variable<bool>(contentEdited);
    map['inclusion_edited'] = Variable<bool>(inclusionEdited);
    map['included'] = Variable<bool>(included);
    return map;
  }

  ClientReportEntriesCompanion toCompanion(bool nullToAbsent) {
    return ClientReportEntriesCompanion(
      id: Value(id),
      reportId: Value(reportId),
      sourceEntryId: sourceEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceEntryId),
      parentSourceEntryId: parentSourceEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentSourceEntryId),
      sortOrder: Value(sortOrder),
      kind: Value(kind),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      caption: caption == null && nullToAbsent
          ? const Value.absent()
          : Value(caption),
      contentEdited: Value(contentEdited),
      inclusionEdited: Value(inclusionEdited),
      included: Value(included),
    );
  }

  factory ClientReportEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClientReportEntry(
      id: serializer.fromJson<int>(json['id']),
      reportId: serializer.fromJson<int>(json['reportId']),
      sourceEntryId: serializer.fromJson<int?>(json['sourceEntryId']),
      parentSourceEntryId:
          serializer.fromJson<int?>(json['parentSourceEntryId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      kind: $ClientReportEntriesTable.$converterkind
          .fromJson(serializer.fromJson<int>(json['kind'])),
      body: serializer.fromJson<String?>(json['body']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      caption: serializer.fromJson<String?>(json['caption']),
      contentEdited: serializer.fromJson<bool>(json['contentEdited']),
      inclusionEdited: serializer.fromJson<bool>(json['inclusionEdited']),
      included: serializer.fromJson<bool>(json['included']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'reportId': serializer.toJson<int>(reportId),
      'sourceEntryId': serializer.toJson<int?>(sourceEntryId),
      'parentSourceEntryId': serializer.toJson<int?>(parentSourceEntryId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'kind': serializer
          .toJson<int>($ClientReportEntriesTable.$converterkind.toJson(kind)),
      'body': serializer.toJson<String?>(body),
      'photoPath': serializer.toJson<String?>(photoPath),
      'caption': serializer.toJson<String?>(caption),
      'contentEdited': serializer.toJson<bool>(contentEdited),
      'inclusionEdited': serializer.toJson<bool>(inclusionEdited),
      'included': serializer.toJson<bool>(included),
    };
  }

  ClientReportEntry copyWith(
          {int? id,
          int? reportId,
          Value<int?> sourceEntryId = const Value.absent(),
          Value<int?> parentSourceEntryId = const Value.absent(),
          int? sortOrder,
          TechnicalEntryKind? kind,
          Value<String?> body = const Value.absent(),
          Value<String?> photoPath = const Value.absent(),
          Value<String?> caption = const Value.absent(),
          bool? contentEdited,
          bool? inclusionEdited,
          bool? included}) =>
      ClientReportEntry(
        id: id ?? this.id,
        reportId: reportId ?? this.reportId,
        sourceEntryId:
            sourceEntryId.present ? sourceEntryId.value : this.sourceEntryId,
        parentSourceEntryId: parentSourceEntryId.present
            ? parentSourceEntryId.value
            : this.parentSourceEntryId,
        sortOrder: sortOrder ?? this.sortOrder,
        kind: kind ?? this.kind,
        body: body.present ? body.value : this.body,
        photoPath: photoPath.present ? photoPath.value : this.photoPath,
        caption: caption.present ? caption.value : this.caption,
        contentEdited: contentEdited ?? this.contentEdited,
        inclusionEdited: inclusionEdited ?? this.inclusionEdited,
        included: included ?? this.included,
      );
  ClientReportEntry copyWithCompanion(ClientReportEntriesCompanion data) {
    return ClientReportEntry(
      id: data.id.present ? data.id.value : this.id,
      reportId: data.reportId.present ? data.reportId.value : this.reportId,
      sourceEntryId: data.sourceEntryId.present
          ? data.sourceEntryId.value
          : this.sourceEntryId,
      parentSourceEntryId: data.parentSourceEntryId.present
          ? data.parentSourceEntryId.value
          : this.parentSourceEntryId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      kind: data.kind.present ? data.kind.value : this.kind,
      body: data.body.present ? data.body.value : this.body,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      caption: data.caption.present ? data.caption.value : this.caption,
      contentEdited: data.contentEdited.present
          ? data.contentEdited.value
          : this.contentEdited,
      inclusionEdited: data.inclusionEdited.present
          ? data.inclusionEdited.value
          : this.inclusionEdited,
      included: data.included.present ? data.included.value : this.included,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClientReportEntry(')
          ..write('id: $id, ')
          ..write('reportId: $reportId, ')
          ..write('sourceEntryId: $sourceEntryId, ')
          ..write('parentSourceEntryId: $parentSourceEntryId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('kind: $kind, ')
          ..write('body: $body, ')
          ..write('photoPath: $photoPath, ')
          ..write('caption: $caption, ')
          ..write('contentEdited: $contentEdited, ')
          ..write('inclusionEdited: $inclusionEdited, ')
          ..write('included: $included')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      reportId,
      sourceEntryId,
      parentSourceEntryId,
      sortOrder,
      kind,
      body,
      photoPath,
      caption,
      contentEdited,
      inclusionEdited,
      included);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClientReportEntry &&
          other.id == this.id &&
          other.reportId == this.reportId &&
          other.sourceEntryId == this.sourceEntryId &&
          other.parentSourceEntryId == this.parentSourceEntryId &&
          other.sortOrder == this.sortOrder &&
          other.kind == this.kind &&
          other.body == this.body &&
          other.photoPath == this.photoPath &&
          other.caption == this.caption &&
          other.contentEdited == this.contentEdited &&
          other.inclusionEdited == this.inclusionEdited &&
          other.included == this.included);
}

class ClientReportEntriesCompanion extends UpdateCompanion<ClientReportEntry> {
  final Value<int> id;
  final Value<int> reportId;
  final Value<int?> sourceEntryId;
  final Value<int?> parentSourceEntryId;
  final Value<int> sortOrder;
  final Value<TechnicalEntryKind> kind;
  final Value<String?> body;
  final Value<String?> photoPath;
  final Value<String?> caption;
  final Value<bool> contentEdited;
  final Value<bool> inclusionEdited;
  final Value<bool> included;
  const ClientReportEntriesCompanion({
    this.id = const Value.absent(),
    this.reportId = const Value.absent(),
    this.sourceEntryId = const Value.absent(),
    this.parentSourceEntryId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.kind = const Value.absent(),
    this.body = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.caption = const Value.absent(),
    this.contentEdited = const Value.absent(),
    this.inclusionEdited = const Value.absent(),
    this.included = const Value.absent(),
  });
  ClientReportEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int reportId,
    this.sourceEntryId = const Value.absent(),
    this.parentSourceEntryId = const Value.absent(),
    required int sortOrder,
    required TechnicalEntryKind kind,
    this.body = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.caption = const Value.absent(),
    this.contentEdited = const Value.absent(),
    this.inclusionEdited = const Value.absent(),
    this.included = const Value.absent(),
  })  : reportId = Value(reportId),
        sortOrder = Value(sortOrder),
        kind = Value(kind);
  static Insertable<ClientReportEntry> custom({
    Expression<int>? id,
    Expression<int>? reportId,
    Expression<int>? sourceEntryId,
    Expression<int>? parentSourceEntryId,
    Expression<int>? sortOrder,
    Expression<int>? kind,
    Expression<String>? body,
    Expression<String>? photoPath,
    Expression<String>? caption,
    Expression<bool>? contentEdited,
    Expression<bool>? inclusionEdited,
    Expression<bool>? included,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reportId != null) 'report_id': reportId,
      if (sourceEntryId != null) 'source_entry_id': sourceEntryId,
      if (parentSourceEntryId != null)
        'parent_source_entry_id': parentSourceEntryId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (kind != null) 'kind': kind,
      if (body != null) 'body': body,
      if (photoPath != null) 'photo_path': photoPath,
      if (caption != null) 'caption': caption,
      if (contentEdited != null) 'content_edited': contentEdited,
      if (inclusionEdited != null) 'inclusion_edited': inclusionEdited,
      if (included != null) 'included': included,
    });
  }

  ClientReportEntriesCompanion copyWith(
      {Value<int>? id,
      Value<int>? reportId,
      Value<int?>? sourceEntryId,
      Value<int?>? parentSourceEntryId,
      Value<int>? sortOrder,
      Value<TechnicalEntryKind>? kind,
      Value<String?>? body,
      Value<String?>? photoPath,
      Value<String?>? caption,
      Value<bool>? contentEdited,
      Value<bool>? inclusionEdited,
      Value<bool>? included}) {
    return ClientReportEntriesCompanion(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      sourceEntryId: sourceEntryId ?? this.sourceEntryId,
      parentSourceEntryId: parentSourceEntryId ?? this.parentSourceEntryId,
      sortOrder: sortOrder ?? this.sortOrder,
      kind: kind ?? this.kind,
      body: body ?? this.body,
      photoPath: photoPath ?? this.photoPath,
      caption: caption ?? this.caption,
      contentEdited: contentEdited ?? this.contentEdited,
      inclusionEdited: inclusionEdited ?? this.inclusionEdited,
      included: included ?? this.included,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (reportId.present) {
      map['report_id'] = Variable<int>(reportId.value);
    }
    if (sourceEntryId.present) {
      map['source_entry_id'] = Variable<int>(sourceEntryId.value);
    }
    if (parentSourceEntryId.present) {
      map['parent_source_entry_id'] = Variable<int>(parentSourceEntryId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (kind.present) {
      map['kind'] = Variable<int>(
          $ClientReportEntriesTable.$converterkind.toSql(kind.value));
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
    }
    if (contentEdited.present) {
      map['content_edited'] = Variable<bool>(contentEdited.value);
    }
    if (inclusionEdited.present) {
      map['inclusion_edited'] = Variable<bool>(inclusionEdited.value);
    }
    if (included.present) {
      map['included'] = Variable<bool>(included.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientReportEntriesCompanion(')
          ..write('id: $id, ')
          ..write('reportId: $reportId, ')
          ..write('sourceEntryId: $sourceEntryId, ')
          ..write('parentSourceEntryId: $parentSourceEntryId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('kind: $kind, ')
          ..write('body: $body, ')
          ..write('photoPath: $photoPath, ')
          ..write('caption: $caption, ')
          ..write('contentEdited: $contentEdited, ')
          ..write('inclusionEdited: $inclusionEdited, ')
          ..write('included: $included')
          ..write(')'))
        .toString();
  }
}

class $ReportContactLogTable extends ReportContactLog
    with TableInfo<$ReportContactLogTable, ReportContactLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReportContactLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _reportIdMeta =
      const VerificationMeta('reportId');
  @override
  late final GeneratedColumn<int> reportId = GeneratedColumn<int>(
      'report_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES ticket_reports (id)'));
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
      'at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  late final GeneratedColumnWithTypeConverter<ContactMethod, int> method =
      GeneratedColumn<int>('method', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<ContactMethod>(
              $ReportContactLogTable.$convertermethod);
  @override
  late final GeneratedColumnWithTypeConverter<ContactOutcome, int> outcome =
      GeneratedColumn<int>('outcome', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<ContactOutcome>(
              $ReportContactLogTable.$converteroutcome);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, reportId, at, method, outcome, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'report_contact_log';
  @override
  VerificationContext validateIntegrity(
      Insertable<ReportContactLogData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('report_id')) {
      context.handle(_reportIdMeta,
          reportId.isAcceptableOrUnknown(data['report_id']!, _reportIdMeta));
    } else if (isInserting) {
      context.missing(_reportIdMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReportContactLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReportContactLogData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      reportId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}report_id'])!,
      at: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}at'])!,
      method: $ReportContactLogTable.$convertermethod.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}method'])!),
      outcome: $ReportContactLogTable.$converteroutcome.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}outcome'])!),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $ReportContactLogTable createAlias(String alias) {
    return $ReportContactLogTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ContactMethod, int, int> $convertermethod =
      const EnumIndexConverter<ContactMethod>(ContactMethod.values);
  static JsonTypeConverter2<ContactOutcome, int, int> $converteroutcome =
      const EnumIndexConverter<ContactOutcome>(ContactOutcome.values);
}

class ReportContactLogData extends DataClass
    implements Insertable<ReportContactLogData> {
  final int id;
  final int reportId;
  final DateTime at;
  final ContactMethod method;
  final ContactOutcome outcome;
  final String? note;
  const ReportContactLogData(
      {required this.id,
      required this.reportId,
      required this.at,
      required this.method,
      required this.outcome,
      this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['report_id'] = Variable<int>(reportId);
    map['at'] = Variable<DateTime>(at);
    {
      map['method'] =
          Variable<int>($ReportContactLogTable.$convertermethod.toSql(method));
    }
    {
      map['outcome'] = Variable<int>(
          $ReportContactLogTable.$converteroutcome.toSql(outcome));
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  ReportContactLogCompanion toCompanion(bool nullToAbsent) {
    return ReportContactLogCompanion(
      id: Value(id),
      reportId: Value(reportId),
      at: Value(at),
      method: Value(method),
      outcome: Value(outcome),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory ReportContactLogData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReportContactLogData(
      id: serializer.fromJson<int>(json['id']),
      reportId: serializer.fromJson<int>(json['reportId']),
      at: serializer.fromJson<DateTime>(json['at']),
      method: $ReportContactLogTable.$convertermethod
          .fromJson(serializer.fromJson<int>(json['method'])),
      outcome: $ReportContactLogTable.$converteroutcome
          .fromJson(serializer.fromJson<int>(json['outcome'])),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'reportId': serializer.toJson<int>(reportId),
      'at': serializer.toJson<DateTime>(at),
      'method': serializer
          .toJson<int>($ReportContactLogTable.$convertermethod.toJson(method)),
      'outcome': serializer.toJson<int>(
          $ReportContactLogTable.$converteroutcome.toJson(outcome)),
      'note': serializer.toJson<String?>(note),
    };
  }

  ReportContactLogData copyWith(
          {int? id,
          int? reportId,
          DateTime? at,
          ContactMethod? method,
          ContactOutcome? outcome,
          Value<String?> note = const Value.absent()}) =>
      ReportContactLogData(
        id: id ?? this.id,
        reportId: reportId ?? this.reportId,
        at: at ?? this.at,
        method: method ?? this.method,
        outcome: outcome ?? this.outcome,
        note: note.present ? note.value : this.note,
      );
  ReportContactLogData copyWithCompanion(ReportContactLogCompanion data) {
    return ReportContactLogData(
      id: data.id.present ? data.id.value : this.id,
      reportId: data.reportId.present ? data.reportId.value : this.reportId,
      at: data.at.present ? data.at.value : this.at,
      method: data.method.present ? data.method.value : this.method,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReportContactLogData(')
          ..write('id: $id, ')
          ..write('reportId: $reportId, ')
          ..write('at: $at, ')
          ..write('method: $method, ')
          ..write('outcome: $outcome, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, reportId, at, method, outcome, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReportContactLogData &&
          other.id == this.id &&
          other.reportId == this.reportId &&
          other.at == this.at &&
          other.method == this.method &&
          other.outcome == this.outcome &&
          other.note == this.note);
}

class ReportContactLogCompanion extends UpdateCompanion<ReportContactLogData> {
  final Value<int> id;
  final Value<int> reportId;
  final Value<DateTime> at;
  final Value<ContactMethod> method;
  final Value<ContactOutcome> outcome;
  final Value<String?> note;
  const ReportContactLogCompanion({
    this.id = const Value.absent(),
    this.reportId = const Value.absent(),
    this.at = const Value.absent(),
    this.method = const Value.absent(),
    this.outcome = const Value.absent(),
    this.note = const Value.absent(),
  });
  ReportContactLogCompanion.insert({
    this.id = const Value.absent(),
    required int reportId,
    this.at = const Value.absent(),
    required ContactMethod method,
    required ContactOutcome outcome,
    this.note = const Value.absent(),
  })  : reportId = Value(reportId),
        method = Value(method),
        outcome = Value(outcome);
  static Insertable<ReportContactLogData> custom({
    Expression<int>? id,
    Expression<int>? reportId,
    Expression<DateTime>? at,
    Expression<int>? method,
    Expression<int>? outcome,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reportId != null) 'report_id': reportId,
      if (at != null) 'at': at,
      if (method != null) 'method': method,
      if (outcome != null) 'outcome': outcome,
      if (note != null) 'note': note,
    });
  }

  ReportContactLogCompanion copyWith(
      {Value<int>? id,
      Value<int>? reportId,
      Value<DateTime>? at,
      Value<ContactMethod>? method,
      Value<ContactOutcome>? outcome,
      Value<String?>? note}) {
    return ReportContactLogCompanion(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      at: at ?? this.at,
      method: method ?? this.method,
      outcome: outcome ?? this.outcome,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (reportId.present) {
      map['report_id'] = Variable<int>(reportId.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (method.present) {
      map['method'] = Variable<int>(
          $ReportContactLogTable.$convertermethod.toSql(method.value));
    }
    if (outcome.present) {
      map['outcome'] = Variable<int>(
          $ReportContactLogTable.$converteroutcome.toSql(outcome.value));
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReportContactLogCompanion(')
          ..write('id: $id, ')
          ..write('reportId: $reportId, ')
          ..write('at: $at, ')
          ..write('method: $method, ')
          ..write('outcome: $outcome, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $PartMovementsTable extends PartMovements
    with TableInfo<$PartMovementsTable, PartMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _partIdMeta = const VerificationMeta('partId');
  @override
  late final GeneratedColumn<int> partId = GeneratedColumn<int>(
      'part_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES parts (id)'));
  static const VerificationMeta _ticketIdMeta =
      const VerificationMeta('ticketId');
  @override
  late final GeneratedColumn<int> ticketId = GeneratedColumn<int>(
      'ticket_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES tickets (id)'));
  static const VerificationMeta _deltaMeta = const VerificationMeta('delta');
  @override
  late final GeneratedColumn<int> delta = GeneratedColumn<int>(
      'delta', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
      'at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, partId, ticketId, delta, note, at];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'part_movements';
  @override
  VerificationContext validateIntegrity(Insertable<PartMovement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('part_id')) {
      context.handle(_partIdMeta,
          partId.isAcceptableOrUnknown(data['part_id']!, _partIdMeta));
    } else if (isInserting) {
      context.missing(_partIdMeta);
    }
    if (data.containsKey('ticket_id')) {
      context.handle(_ticketIdMeta,
          ticketId.isAcceptableOrUnknown(data['ticket_id']!, _ticketIdMeta));
    }
    if (data.containsKey('delta')) {
      context.handle(
          _deltaMeta, delta.isAcceptableOrUnknown(data['delta']!, _deltaMeta));
    } else if (isInserting) {
      context.missing(_deltaMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PartMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PartMovement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      partId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}part_id'])!,
      ticketId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ticket_id']),
      delta: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}delta'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      at: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}at'])!,
    );
  }

  @override
  $PartMovementsTable createAlias(String alias) {
    return $PartMovementsTable(attachedDatabase, alias);
  }
}

class PartMovement extends DataClass implements Insertable<PartMovement> {
  final int id;
  final int partId;
  final int? ticketId;
  final int delta;
  final String? note;
  final DateTime at;
  const PartMovement(
      {required this.id,
      required this.partId,
      this.ticketId,
      required this.delta,
      this.note,
      required this.at});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['part_id'] = Variable<int>(partId);
    if (!nullToAbsent || ticketId != null) {
      map['ticket_id'] = Variable<int>(ticketId);
    }
    map['delta'] = Variable<int>(delta);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['at'] = Variable<DateTime>(at);
    return map;
  }

  PartMovementsCompanion toCompanion(bool nullToAbsent) {
    return PartMovementsCompanion(
      id: Value(id),
      partId: Value(partId),
      ticketId: ticketId == null && nullToAbsent
          ? const Value.absent()
          : Value(ticketId),
      delta: Value(delta),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      at: Value(at),
    );
  }

  factory PartMovement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PartMovement(
      id: serializer.fromJson<int>(json['id']),
      partId: serializer.fromJson<int>(json['partId']),
      ticketId: serializer.fromJson<int?>(json['ticketId']),
      delta: serializer.fromJson<int>(json['delta']),
      note: serializer.fromJson<String?>(json['note']),
      at: serializer.fromJson<DateTime>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'partId': serializer.toJson<int>(partId),
      'ticketId': serializer.toJson<int?>(ticketId),
      'delta': serializer.toJson<int>(delta),
      'note': serializer.toJson<String?>(note),
      'at': serializer.toJson<DateTime>(at),
    };
  }

  PartMovement copyWith(
          {int? id,
          int? partId,
          Value<int?> ticketId = const Value.absent(),
          int? delta,
          Value<String?> note = const Value.absent(),
          DateTime? at}) =>
      PartMovement(
        id: id ?? this.id,
        partId: partId ?? this.partId,
        ticketId: ticketId.present ? ticketId.value : this.ticketId,
        delta: delta ?? this.delta,
        note: note.present ? note.value : this.note,
        at: at ?? this.at,
      );
  PartMovement copyWithCompanion(PartMovementsCompanion data) {
    return PartMovement(
      id: data.id.present ? data.id.value : this.id,
      partId: data.partId.present ? data.partId.value : this.partId,
      ticketId: data.ticketId.present ? data.ticketId.value : this.ticketId,
      delta: data.delta.present ? data.delta.value : this.delta,
      note: data.note.present ? data.note.value : this.note,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PartMovement(')
          ..write('id: $id, ')
          ..write('partId: $partId, ')
          ..write('ticketId: $ticketId, ')
          ..write('delta: $delta, ')
          ..write('note: $note, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, partId, ticketId, delta, note, at);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PartMovement &&
          other.id == this.id &&
          other.partId == this.partId &&
          other.ticketId == this.ticketId &&
          other.delta == this.delta &&
          other.note == this.note &&
          other.at == this.at);
}

class PartMovementsCompanion extends UpdateCompanion<PartMovement> {
  final Value<int> id;
  final Value<int> partId;
  final Value<int?> ticketId;
  final Value<int> delta;
  final Value<String?> note;
  final Value<DateTime> at;
  const PartMovementsCompanion({
    this.id = const Value.absent(),
    this.partId = const Value.absent(),
    this.ticketId = const Value.absent(),
    this.delta = const Value.absent(),
    this.note = const Value.absent(),
    this.at = const Value.absent(),
  });
  PartMovementsCompanion.insert({
    this.id = const Value.absent(),
    required int partId,
    this.ticketId = const Value.absent(),
    required int delta,
    this.note = const Value.absent(),
    this.at = const Value.absent(),
  })  : partId = Value(partId),
        delta = Value(delta);
  static Insertable<PartMovement> custom({
    Expression<int>? id,
    Expression<int>? partId,
    Expression<int>? ticketId,
    Expression<int>? delta,
    Expression<String>? note,
    Expression<DateTime>? at,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (partId != null) 'part_id': partId,
      if (ticketId != null) 'ticket_id': ticketId,
      if (delta != null) 'delta': delta,
      if (note != null) 'note': note,
      if (at != null) 'at': at,
    });
  }

  PartMovementsCompanion copyWith(
      {Value<int>? id,
      Value<int>? partId,
      Value<int?>? ticketId,
      Value<int>? delta,
      Value<String?>? note,
      Value<DateTime>? at}) {
    return PartMovementsCompanion(
      id: id ?? this.id,
      partId: partId ?? this.partId,
      ticketId: ticketId ?? this.ticketId,
      delta: delta ?? this.delta,
      note: note ?? this.note,
      at: at ?? this.at,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (partId.present) {
      map['part_id'] = Variable<int>(partId.value);
    }
    if (ticketId.present) {
      map['ticket_id'] = Variable<int>(ticketId.value);
    }
    if (delta.present) {
      map['delta'] = Variable<int>(delta.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartMovementsCompanion(')
          ..write('id: $id, ')
          ..write('partId: $partId, ')
          ..write('ticketId: $ticketId, ')
          ..write('delta: $delta, ')
          ..write('note: $note, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }
}

class $MerchProductsTable extends MerchProducts
    with TableInfo<$MerchProductsTable, MerchProduct> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MerchProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 120),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
      'sku', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<int> stock = GeneratedColumn<int>(
      'stock', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _costCentsMeta =
      const VerificationMeta('costCents');
  @override
  late final GeneratedColumn<int> costCents = GeneratedColumn<int>(
      'cost_cents', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _priceCentsMeta =
      const VerificationMeta('priceCents');
  @override
  late final GeneratedColumn<int> priceCents = GeneratedColumn<int>(
      'price_cents', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        category,
        description,
        sku,
        location,
        stock,
        costCents,
        priceCents,
        isActive
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'merch_products';
  @override
  VerificationContext validateIntegrity(Insertable<MerchProduct> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('sku')) {
      context.handle(
          _skuMeta, sku.isAcceptableOrUnknown(data['sku']!, _skuMeta));
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('stock')) {
      context.handle(
          _stockMeta, stock.isAcceptableOrUnknown(data['stock']!, _stockMeta));
    }
    if (data.containsKey('cost_cents')) {
      context.handle(_costCentsMeta,
          costCents.isAcceptableOrUnknown(data['cost_cents']!, _costCentsMeta));
    }
    if (data.containsKey('price_cents')) {
      context.handle(
          _priceCentsMeta,
          priceCents.isAcceptableOrUnknown(
              data['price_cents']!, _priceCentsMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MerchProduct map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MerchProduct(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      sku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sku']),
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location']),
      stock: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stock'])!,
      costCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cost_cents'])!,
      priceCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}price_cents'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $MerchProductsTable createAlias(String alias) {
    return $MerchProductsTable(attachedDatabase, alias);
  }
}

class MerchProduct extends DataClass implements Insertable<MerchProduct> {
  final int id;
  final String name;
  final String? category;
  final String? description;

  /// Shop SKU in `NNN-NNN` form, separate from the parts SKU sequence.
  final String? sku;
  final String? location;
  final int stock;
  final int costCents;
  final int priceCents;
  final bool isActive;
  const MerchProduct(
      {required this.id,
      required this.name,
      this.category,
      this.description,
      this.sku,
      this.location,
      required this.stock,
      required this.costCents,
      required this.priceCents,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || sku != null) {
      map['sku'] = Variable<String>(sku);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['stock'] = Variable<int>(stock);
    map['cost_cents'] = Variable<int>(costCents);
    map['price_cents'] = Variable<int>(priceCents);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  MerchProductsCompanion toCompanion(bool nullToAbsent) {
    return MerchProductsCompanion(
      id: Value(id),
      name: Value(name),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      sku: sku == null && nullToAbsent ? const Value.absent() : Value(sku),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      stock: Value(stock),
      costCents: Value(costCents),
      priceCents: Value(priceCents),
      isActive: Value(isActive),
    );
  }

  factory MerchProduct.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MerchProduct(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String?>(json['category']),
      description: serializer.fromJson<String?>(json['description']),
      sku: serializer.fromJson<String?>(json['sku']),
      location: serializer.fromJson<String?>(json['location']),
      stock: serializer.fromJson<int>(json['stock']),
      costCents: serializer.fromJson<int>(json['costCents']),
      priceCents: serializer.fromJson<int>(json['priceCents']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String?>(category),
      'description': serializer.toJson<String?>(description),
      'sku': serializer.toJson<String?>(sku),
      'location': serializer.toJson<String?>(location),
      'stock': serializer.toJson<int>(stock),
      'costCents': serializer.toJson<int>(costCents),
      'priceCents': serializer.toJson<int>(priceCents),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  MerchProduct copyWith(
          {int? id,
          String? name,
          Value<String?> category = const Value.absent(),
          Value<String?> description = const Value.absent(),
          Value<String?> sku = const Value.absent(),
          Value<String?> location = const Value.absent(),
          int? stock,
          int? costCents,
          int? priceCents,
          bool? isActive}) =>
      MerchProduct(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category.present ? category.value : this.category,
        description: description.present ? description.value : this.description,
        sku: sku.present ? sku.value : this.sku,
        location: location.present ? location.value : this.location,
        stock: stock ?? this.stock,
        costCents: costCents ?? this.costCents,
        priceCents: priceCents ?? this.priceCents,
        isActive: isActive ?? this.isActive,
      );
  MerchProduct copyWithCompanion(MerchProductsCompanion data) {
    return MerchProduct(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      description:
          data.description.present ? data.description.value : this.description,
      sku: data.sku.present ? data.sku.value : this.sku,
      location: data.location.present ? data.location.value : this.location,
      stock: data.stock.present ? data.stock.value : this.stock,
      costCents: data.costCents.present ? data.costCents.value : this.costCents,
      priceCents:
          data.priceCents.present ? data.priceCents.value : this.priceCents,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MerchProduct(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('sku: $sku, ')
          ..write('location: $location, ')
          ..write('stock: $stock, ')
          ..write('costCents: $costCents, ')
          ..write('priceCents: $priceCents, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, category, description, sku,
      location, stock, costCents, priceCents, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MerchProduct &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.description == this.description &&
          other.sku == this.sku &&
          other.location == this.location &&
          other.stock == this.stock &&
          other.costCents == this.costCents &&
          other.priceCents == this.priceCents &&
          other.isActive == this.isActive);
}

class MerchProductsCompanion extends UpdateCompanion<MerchProduct> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> category;
  final Value<String?> description;
  final Value<String?> sku;
  final Value<String?> location;
  final Value<int> stock;
  final Value<int> costCents;
  final Value<int> priceCents;
  final Value<bool> isActive;
  const MerchProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.sku = const Value.absent(),
    this.location = const Value.absent(),
    this.stock = const Value.absent(),
    this.costCents = const Value.absent(),
    this.priceCents = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  MerchProductsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.sku = const Value.absent(),
    this.location = const Value.absent(),
    this.stock = const Value.absent(),
    this.costCents = const Value.absent(),
    this.priceCents = const Value.absent(),
    this.isActive = const Value.absent(),
  }) : name = Value(name);
  static Insertable<MerchProduct> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? description,
    Expression<String>? sku,
    Expression<String>? location,
    Expression<int>? stock,
    Expression<int>? costCents,
    Expression<int>? priceCents,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (sku != null) 'sku': sku,
      if (location != null) 'location': location,
      if (stock != null) 'stock': stock,
      if (costCents != null) 'cost_cents': costCents,
      if (priceCents != null) 'price_cents': priceCents,
      if (isActive != null) 'is_active': isActive,
    });
  }

  MerchProductsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? category,
      Value<String?>? description,
      Value<String?>? sku,
      Value<String?>? location,
      Value<int>? stock,
      Value<int>? costCents,
      Value<int>? priceCents,
      Value<bool>? isActive}) {
    return MerchProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      sku: sku ?? this.sku,
      location: location ?? this.location,
      stock: stock ?? this.stock,
      costCents: costCents ?? this.costCents,
      priceCents: priceCents ?? this.priceCents,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (stock.present) {
      map['stock'] = Variable<int>(stock.value);
    }
    if (costCents.present) {
      map['cost_cents'] = Variable<int>(costCents.value);
    }
    if (priceCents.present) {
      map['price_cents'] = Variable<int>(priceCents.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MerchProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('sku: $sku, ')
          ..write('location: $location, ')
          ..write('stock: $stock, ')
          ..write('costCents: $costCents, ')
          ..write('priceCents: $priceCents, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $MerchVariantsTable extends MerchVariants
    with TableInfo<$MerchVariantsTable, MerchVariant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MerchVariantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
      'product_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES merch_products (id)'));
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 60),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
      'sku', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _barcodeMeta =
      const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
      'barcode', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<int> stock = GeneratedColumn<int>(
      'stock', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _costCentsMeta =
      const VerificationMeta('costCents');
  @override
  late final GeneratedColumn<int> costCents = GeneratedColumn<int>(
      'cost_cents', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _priceCentsMeta =
      const VerificationMeta('priceCents');
  @override
  late final GeneratedColumn<int> priceCents = GeneratedColumn<int>(
      'price_cents', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        productId,
        label,
        sku,
        barcode,
        stock,
        costCents,
        priceCents,
        isActive
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'merch_variants';
  @override
  VerificationContext validateIntegrity(Insertable<MerchVariant> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('sku')) {
      context.handle(
          _skuMeta, sku.isAcceptableOrUnknown(data['sku']!, _skuMeta));
    }
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta,
          barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    }
    if (data.containsKey('stock')) {
      context.handle(
          _stockMeta, stock.isAcceptableOrUnknown(data['stock']!, _stockMeta));
    }
    if (data.containsKey('cost_cents')) {
      context.handle(_costCentsMeta,
          costCents.isAcceptableOrUnknown(data['cost_cents']!, _costCentsMeta));
    }
    if (data.containsKey('price_cents')) {
      context.handle(
          _priceCentsMeta,
          priceCents.isAcceptableOrUnknown(
              data['price_cents']!, _priceCentsMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {productId, label},
      ];
  @override
  MerchVariant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MerchVariant(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}product_id'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      sku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sku']),
      barcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode']),
      stock: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stock'])!,
      costCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cost_cents'])!,
      priceCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}price_cents'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $MerchVariantsTable createAlias(String alias) {
    return $MerchVariantsTable(attachedDatabase, alias);
  }
}

class MerchVariant extends DataClass implements Insertable<MerchVariant> {
  final int id;
  final int productId;

  /// Size / colour / fit, e.g. `L / Black`.
  final String label;
  final String? sku;
  final String? barcode;
  final int stock;
  final int costCents;
  final int priceCents;
  final bool isActive;
  const MerchVariant(
      {required this.id,
      required this.productId,
      required this.label,
      this.sku,
      this.barcode,
      required this.stock,
      required this.costCents,
      required this.priceCents,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['product_id'] = Variable<int>(productId);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || sku != null) {
      map['sku'] = Variable<String>(sku);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['stock'] = Variable<int>(stock);
    map['cost_cents'] = Variable<int>(costCents);
    map['price_cents'] = Variable<int>(priceCents);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  MerchVariantsCompanion toCompanion(bool nullToAbsent) {
    return MerchVariantsCompanion(
      id: Value(id),
      productId: Value(productId),
      label: Value(label),
      sku: sku == null && nullToAbsent ? const Value.absent() : Value(sku),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      stock: Value(stock),
      costCents: Value(costCents),
      priceCents: Value(priceCents),
      isActive: Value(isActive),
    );
  }

  factory MerchVariant.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MerchVariant(
      id: serializer.fromJson<int>(json['id']),
      productId: serializer.fromJson<int>(json['productId']),
      label: serializer.fromJson<String>(json['label']),
      sku: serializer.fromJson<String?>(json['sku']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      stock: serializer.fromJson<int>(json['stock']),
      costCents: serializer.fromJson<int>(json['costCents']),
      priceCents: serializer.fromJson<int>(json['priceCents']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'productId': serializer.toJson<int>(productId),
      'label': serializer.toJson<String>(label),
      'sku': serializer.toJson<String?>(sku),
      'barcode': serializer.toJson<String?>(barcode),
      'stock': serializer.toJson<int>(stock),
      'costCents': serializer.toJson<int>(costCents),
      'priceCents': serializer.toJson<int>(priceCents),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  MerchVariant copyWith(
          {int? id,
          int? productId,
          String? label,
          Value<String?> sku = const Value.absent(),
          Value<String?> barcode = const Value.absent(),
          int? stock,
          int? costCents,
          int? priceCents,
          bool? isActive}) =>
      MerchVariant(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        label: label ?? this.label,
        sku: sku.present ? sku.value : this.sku,
        barcode: barcode.present ? barcode.value : this.barcode,
        stock: stock ?? this.stock,
        costCents: costCents ?? this.costCents,
        priceCents: priceCents ?? this.priceCents,
        isActive: isActive ?? this.isActive,
      );
  MerchVariant copyWithCompanion(MerchVariantsCompanion data) {
    return MerchVariant(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      label: data.label.present ? data.label.value : this.label,
      sku: data.sku.present ? data.sku.value : this.sku,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      stock: data.stock.present ? data.stock.value : this.stock,
      costCents: data.costCents.present ? data.costCents.value : this.costCents,
      priceCents:
          data.priceCents.present ? data.priceCents.value : this.priceCents,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MerchVariant(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('label: $label, ')
          ..write('sku: $sku, ')
          ..write('barcode: $barcode, ')
          ..write('stock: $stock, ')
          ..write('costCents: $costCents, ')
          ..write('priceCents: $priceCents, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, productId, label, sku, barcode, stock,
      costCents, priceCents, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MerchVariant &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.label == this.label &&
          other.sku == this.sku &&
          other.barcode == this.barcode &&
          other.stock == this.stock &&
          other.costCents == this.costCents &&
          other.priceCents == this.priceCents &&
          other.isActive == this.isActive);
}

class MerchVariantsCompanion extends UpdateCompanion<MerchVariant> {
  final Value<int> id;
  final Value<int> productId;
  final Value<String> label;
  final Value<String?> sku;
  final Value<String?> barcode;
  final Value<int> stock;
  final Value<int> costCents;
  final Value<int> priceCents;
  final Value<bool> isActive;
  const MerchVariantsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.label = const Value.absent(),
    this.sku = const Value.absent(),
    this.barcode = const Value.absent(),
    this.stock = const Value.absent(),
    this.costCents = const Value.absent(),
    this.priceCents = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  MerchVariantsCompanion.insert({
    this.id = const Value.absent(),
    required int productId,
    required String label,
    this.sku = const Value.absent(),
    this.barcode = const Value.absent(),
    this.stock = const Value.absent(),
    this.costCents = const Value.absent(),
    this.priceCents = const Value.absent(),
    this.isActive = const Value.absent(),
  })  : productId = Value(productId),
        label = Value(label);
  static Insertable<MerchVariant> custom({
    Expression<int>? id,
    Expression<int>? productId,
    Expression<String>? label,
    Expression<String>? sku,
    Expression<String>? barcode,
    Expression<int>? stock,
    Expression<int>? costCents,
    Expression<int>? priceCents,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (label != null) 'label': label,
      if (sku != null) 'sku': sku,
      if (barcode != null) 'barcode': barcode,
      if (stock != null) 'stock': stock,
      if (costCents != null) 'cost_cents': costCents,
      if (priceCents != null) 'price_cents': priceCents,
      if (isActive != null) 'is_active': isActive,
    });
  }

  MerchVariantsCompanion copyWith(
      {Value<int>? id,
      Value<int>? productId,
      Value<String>? label,
      Value<String?>? sku,
      Value<String?>? barcode,
      Value<int>? stock,
      Value<int>? costCents,
      Value<int>? priceCents,
      Value<bool>? isActive}) {
    return MerchVariantsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      label: label ?? this.label,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      stock: stock ?? this.stock,
      costCents: costCents ?? this.costCents,
      priceCents: priceCents ?? this.priceCents,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (stock.present) {
      map['stock'] = Variable<int>(stock.value);
    }
    if (costCents.present) {
      map['cost_cents'] = Variable<int>(costCents.value);
    }
    if (priceCents.present) {
      map['price_cents'] = Variable<int>(priceCents.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MerchVariantsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('label: $label, ')
          ..write('sku: $sku, ')
          ..write('barcode: $barcode, ')
          ..write('stock: $stock, ')
          ..write('costCents: $costCents, ')
          ..write('priceCents: $priceCents, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $MerchSalesTable extends MerchSales
    with TableInfo<$MerchSalesTable, MerchSale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MerchSalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<String> number = GeneratedColumn<String>(
      'number', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 24),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _customerIdMeta =
      const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
      'customer_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES customers (id)'));
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
      'at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  late final GeneratedColumnWithTypeConverter<PaymentMethod, int>
      paymentMethod = GeneratedColumn<int>('payment_method', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<PaymentMethod>(
              $MerchSalesTable.$converterpaymentMethod);
  static const VerificationMeta _totalCentsMeta =
      const VerificationMeta('totalCents');
  @override
  late final GeneratedColumn<int> totalCents = GeneratedColumn<int>(
      'total_cents', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, number, customerId, at, paymentMethod, totalCents, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'merch_sales';
  @override
  VerificationContext validateIntegrity(Insertable<MerchSale> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('number')) {
      context.handle(_numberMeta,
          number.isAcceptableOrUnknown(data['number']!, _numberMeta));
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
          _customerIdMeta,
          customerId.isAcceptableOrUnknown(
              data['customer_id']!, _customerIdMeta));
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    }
    if (data.containsKey('total_cents')) {
      context.handle(
          _totalCentsMeta,
          totalCents.isAcceptableOrUnknown(
              data['total_cents']!, _totalCentsMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {number},
      ];
  @override
  MerchSale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MerchSale(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      number: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}number'])!,
      customerId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}customer_id']),
      at: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}at'])!,
      paymentMethod: $MerchSalesTable.$converterpaymentMethod.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.int, data['${effectivePrefix}payment_method'])!),
      totalCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_cents'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $MerchSalesTable createAlias(String alias) {
    return $MerchSalesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PaymentMethod, int, int> $converterpaymentMethod =
      const EnumIndexConverter<PaymentMethod>(PaymentMethod.values);
}

class MerchSale extends DataClass implements Insertable<MerchSale> {
  final int id;
  final String number;
  final int? customerId;
  final DateTime at;
  final PaymentMethod paymentMethod;
  final int totalCents;
  final String? note;
  const MerchSale(
      {required this.id,
      required this.number,
      this.customerId,
      required this.at,
      required this.paymentMethod,
      required this.totalCents,
      this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['number'] = Variable<String>(number);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<int>(customerId);
    }
    map['at'] = Variable<DateTime>(at);
    {
      map['payment_method'] = Variable<int>(
          $MerchSalesTable.$converterpaymentMethod.toSql(paymentMethod));
    }
    map['total_cents'] = Variable<int>(totalCents);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  MerchSalesCompanion toCompanion(bool nullToAbsent) {
    return MerchSalesCompanion(
      id: Value(id),
      number: Value(number),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      at: Value(at),
      paymentMethod: Value(paymentMethod),
      totalCents: Value(totalCents),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory MerchSale.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MerchSale(
      id: serializer.fromJson<int>(json['id']),
      number: serializer.fromJson<String>(json['number']),
      customerId: serializer.fromJson<int?>(json['customerId']),
      at: serializer.fromJson<DateTime>(json['at']),
      paymentMethod: $MerchSalesTable.$converterpaymentMethod
          .fromJson(serializer.fromJson<int>(json['paymentMethod'])),
      totalCents: serializer.fromJson<int>(json['totalCents']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'number': serializer.toJson<String>(number),
      'customerId': serializer.toJson<int?>(customerId),
      'at': serializer.toJson<DateTime>(at),
      'paymentMethod': serializer.toJson<int>(
          $MerchSalesTable.$converterpaymentMethod.toJson(paymentMethod)),
      'totalCents': serializer.toJson<int>(totalCents),
      'note': serializer.toJson<String?>(note),
    };
  }

  MerchSale copyWith(
          {int? id,
          String? number,
          Value<int?> customerId = const Value.absent(),
          DateTime? at,
          PaymentMethod? paymentMethod,
          int? totalCents,
          Value<String?> note = const Value.absent()}) =>
      MerchSale(
        id: id ?? this.id,
        number: number ?? this.number,
        customerId: customerId.present ? customerId.value : this.customerId,
        at: at ?? this.at,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        totalCents: totalCents ?? this.totalCents,
        note: note.present ? note.value : this.note,
      );
  MerchSale copyWithCompanion(MerchSalesCompanion data) {
    return MerchSale(
      id: data.id.present ? data.id.value : this.id,
      number: data.number.present ? data.number.value : this.number,
      customerId:
          data.customerId.present ? data.customerId.value : this.customerId,
      at: data.at.present ? data.at.value : this.at,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      totalCents:
          data.totalCents.present ? data.totalCents.value : this.totalCents,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MerchSale(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('customerId: $customerId, ')
          ..write('at: $at, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('totalCents: $totalCents, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, number, customerId, at, paymentMethod, totalCents, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MerchSale &&
          other.id == this.id &&
          other.number == this.number &&
          other.customerId == this.customerId &&
          other.at == this.at &&
          other.paymentMethod == this.paymentMethod &&
          other.totalCents == this.totalCents &&
          other.note == this.note);
}

class MerchSalesCompanion extends UpdateCompanion<MerchSale> {
  final Value<int> id;
  final Value<String> number;
  final Value<int?> customerId;
  final Value<DateTime> at;
  final Value<PaymentMethod> paymentMethod;
  final Value<int> totalCents;
  final Value<String?> note;
  const MerchSalesCompanion({
    this.id = const Value.absent(),
    this.number = const Value.absent(),
    this.customerId = const Value.absent(),
    this.at = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.totalCents = const Value.absent(),
    this.note = const Value.absent(),
  });
  MerchSalesCompanion.insert({
    this.id = const Value.absent(),
    required String number,
    this.customerId = const Value.absent(),
    this.at = const Value.absent(),
    required PaymentMethod paymentMethod,
    this.totalCents = const Value.absent(),
    this.note = const Value.absent(),
  })  : number = Value(number),
        paymentMethod = Value(paymentMethod);
  static Insertable<MerchSale> custom({
    Expression<int>? id,
    Expression<String>? number,
    Expression<int>? customerId,
    Expression<DateTime>? at,
    Expression<int>? paymentMethod,
    Expression<int>? totalCents,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (number != null) 'number': number,
      if (customerId != null) 'customer_id': customerId,
      if (at != null) 'at': at,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (totalCents != null) 'total_cents': totalCents,
      if (note != null) 'note': note,
    });
  }

  MerchSalesCompanion copyWith(
      {Value<int>? id,
      Value<String>? number,
      Value<int?>? customerId,
      Value<DateTime>? at,
      Value<PaymentMethod>? paymentMethod,
      Value<int>? totalCents,
      Value<String?>? note}) {
    return MerchSalesCompanion(
      id: id ?? this.id,
      number: number ?? this.number,
      customerId: customerId ?? this.customerId,
      at: at ?? this.at,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      totalCents: totalCents ?? this.totalCents,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (number.present) {
      map['number'] = Variable<String>(number.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<int>(
          $MerchSalesTable.$converterpaymentMethod.toSql(paymentMethod.value));
    }
    if (totalCents.present) {
      map['total_cents'] = Variable<int>(totalCents.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MerchSalesCompanion(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('customerId: $customerId, ')
          ..write('at: $at, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('totalCents: $totalCents, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $MerchSaleLinesTable extends MerchSaleLines
    with TableInfo<$MerchSaleLinesTable, MerchSaleLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MerchSaleLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<int> saleId = GeneratedColumn<int>(
      'sale_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES merch_sales (id)'));
  static const VerificationMeta _variantIdMeta =
      const VerificationMeta('variantId');
  @override
  late final GeneratedColumn<int> variantId = GeneratedColumn<int>(
      'variant_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES merch_variants (id)'));
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _unitPriceCentsMeta =
      const VerificationMeta('unitPriceCents');
  @override
  late final GeneratedColumn<int> unitPriceCents = GeneratedColumn<int>(
      'unit_price_cents', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _unitCostCentsMeta =
      const VerificationMeta('unitCostCents');
  @override
  late final GeneratedColumn<int> unitCostCents = GeneratedColumn<int>(
      'unit_cost_cents', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, saleId, variantId, quantity, unitPriceCents, unitCostCents];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'merch_sale_lines';
  @override
  VerificationContext validateIntegrity(Insertable<MerchSaleLine> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sale_id')) {
      context.handle(_saleIdMeta,
          saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta));
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('variant_id')) {
      context.handle(_variantIdMeta,
          variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta));
    } else if (isInserting) {
      context.missing(_variantIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('unit_price_cents')) {
      context.handle(
          _unitPriceCentsMeta,
          unitPriceCents.isAcceptableOrUnknown(
              data['unit_price_cents']!, _unitPriceCentsMeta));
    } else if (isInserting) {
      context.missing(_unitPriceCentsMeta);
    }
    if (data.containsKey('unit_cost_cents')) {
      context.handle(
          _unitCostCentsMeta,
          unitCostCents.isAcceptableOrUnknown(
              data['unit_cost_cents']!, _unitCostCentsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MerchSaleLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MerchSaleLine(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      saleId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sale_id'])!,
      variantId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}variant_id'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      unitPriceCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unit_price_cents'])!,
      unitCostCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unit_cost_cents']),
    );
  }

  @override
  $MerchSaleLinesTable createAlias(String alias) {
    return $MerchSaleLinesTable(attachedDatabase, alias);
  }
}

class MerchSaleLine extends DataClass implements Insertable<MerchSaleLine> {
  final int id;
  final int saleId;
  final int variantId;
  final int quantity;
  final int unitPriceCents;
  final int? unitCostCents;
  const MerchSaleLine(
      {required this.id,
      required this.saleId,
      required this.variantId,
      required this.quantity,
      required this.unitPriceCents,
      this.unitCostCents});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sale_id'] = Variable<int>(saleId);
    map['variant_id'] = Variable<int>(variantId);
    map['quantity'] = Variable<int>(quantity);
    map['unit_price_cents'] = Variable<int>(unitPriceCents);
    if (!nullToAbsent || unitCostCents != null) {
      map['unit_cost_cents'] = Variable<int>(unitCostCents);
    }
    return map;
  }

  MerchSaleLinesCompanion toCompanion(bool nullToAbsent) {
    return MerchSaleLinesCompanion(
      id: Value(id),
      saleId: Value(saleId),
      variantId: Value(variantId),
      quantity: Value(quantity),
      unitPriceCents: Value(unitPriceCents),
      unitCostCents: unitCostCents == null && nullToAbsent
          ? const Value.absent()
          : Value(unitCostCents),
    );
  }

  factory MerchSaleLine.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MerchSaleLine(
      id: serializer.fromJson<int>(json['id']),
      saleId: serializer.fromJson<int>(json['saleId']),
      variantId: serializer.fromJson<int>(json['variantId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitPriceCents: serializer.fromJson<int>(json['unitPriceCents']),
      unitCostCents: serializer.fromJson<int?>(json['unitCostCents']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'saleId': serializer.toJson<int>(saleId),
      'variantId': serializer.toJson<int>(variantId),
      'quantity': serializer.toJson<int>(quantity),
      'unitPriceCents': serializer.toJson<int>(unitPriceCents),
      'unitCostCents': serializer.toJson<int?>(unitCostCents),
    };
  }

  MerchSaleLine copyWith(
          {int? id,
          int? saleId,
          int? variantId,
          int? quantity,
          int? unitPriceCents,
          Value<int?> unitCostCents = const Value.absent()}) =>
      MerchSaleLine(
        id: id ?? this.id,
        saleId: saleId ?? this.saleId,
        variantId: variantId ?? this.variantId,
        quantity: quantity ?? this.quantity,
        unitPriceCents: unitPriceCents ?? this.unitPriceCents,
        unitCostCents:
            unitCostCents.present ? unitCostCents.value : this.unitCostCents,
      );
  MerchSaleLine copyWithCompanion(MerchSaleLinesCompanion data) {
    return MerchSaleLine(
      id: data.id.present ? data.id.value : this.id,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPriceCents: data.unitPriceCents.present
          ? data.unitPriceCents.value
          : this.unitPriceCents,
      unitCostCents: data.unitCostCents.present
          ? data.unitCostCents.value
          : this.unitCostCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MerchSaleLine(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('variantId: $variantId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPriceCents: $unitPriceCents, ')
          ..write('unitCostCents: $unitCostCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, saleId, variantId, quantity, unitPriceCents, unitCostCents);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MerchSaleLine &&
          other.id == this.id &&
          other.saleId == this.saleId &&
          other.variantId == this.variantId &&
          other.quantity == this.quantity &&
          other.unitPriceCents == this.unitPriceCents &&
          other.unitCostCents == this.unitCostCents);
}

class MerchSaleLinesCompanion extends UpdateCompanion<MerchSaleLine> {
  final Value<int> id;
  final Value<int> saleId;
  final Value<int> variantId;
  final Value<int> quantity;
  final Value<int> unitPriceCents;
  final Value<int?> unitCostCents;
  const MerchSaleLinesCompanion({
    this.id = const Value.absent(),
    this.saleId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPriceCents = const Value.absent(),
    this.unitCostCents = const Value.absent(),
  });
  MerchSaleLinesCompanion.insert({
    this.id = const Value.absent(),
    required int saleId,
    required int variantId,
    this.quantity = const Value.absent(),
    required int unitPriceCents,
    this.unitCostCents = const Value.absent(),
  })  : saleId = Value(saleId),
        variantId = Value(variantId),
        unitPriceCents = Value(unitPriceCents);
  static Insertable<MerchSaleLine> custom({
    Expression<int>? id,
    Expression<int>? saleId,
    Expression<int>? variantId,
    Expression<int>? quantity,
    Expression<int>? unitPriceCents,
    Expression<int>? unitCostCents,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saleId != null) 'sale_id': saleId,
      if (variantId != null) 'variant_id': variantId,
      if (quantity != null) 'quantity': quantity,
      if (unitPriceCents != null) 'unit_price_cents': unitPriceCents,
      if (unitCostCents != null) 'unit_cost_cents': unitCostCents,
    });
  }

  MerchSaleLinesCompanion copyWith(
      {Value<int>? id,
      Value<int>? saleId,
      Value<int>? variantId,
      Value<int>? quantity,
      Value<int>? unitPriceCents,
      Value<int?>? unitCostCents}) {
    return MerchSaleLinesCompanion(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      variantId: variantId ?? this.variantId,
      quantity: quantity ?? this.quantity,
      unitPriceCents: unitPriceCents ?? this.unitPriceCents,
      unitCostCents: unitCostCents ?? this.unitCostCents,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<int>(saleId.value);
    }
    if (variantId.present) {
      map['variant_id'] = Variable<int>(variantId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitPriceCents.present) {
      map['unit_price_cents'] = Variable<int>(unitPriceCents.value);
    }
    if (unitCostCents.present) {
      map['unit_cost_cents'] = Variable<int>(unitCostCents.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MerchSaleLinesCompanion(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('variantId: $variantId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPriceCents: $unitPriceCents, ')
          ..write('unitCostCents: $unitCostCents')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _ticketIdMeta =
      const VerificationMeta('ticketId');
  @override
  late final GeneratedColumn<int> ticketId = GeneratedColumn<int>(
      'ticket_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES tickets (id)'));
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
      'at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _amountCentsMeta =
      const VerificationMeta('amountCents');
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
      'amount_cents', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<PaymentMethod, int> method =
      GeneratedColumn<int>('method', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<PaymentMethod>($PaymentsTable.$convertermethod);
  @override
  late final GeneratedColumnWithTypeConverter<PaymentKind, int> kind =
      GeneratedColumn<int>('kind', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<PaymentKind>($PaymentsTable.$converterkind);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, ticketId, at, amountCents, method, kind, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(Insertable<Payment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ticket_id')) {
      context.handle(_ticketIdMeta,
          ticketId.isAcceptableOrUnknown(data['ticket_id']!, _ticketIdMeta));
    } else if (isInserting) {
      context.missing(_ticketIdMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
          _amountCentsMeta,
          amountCents.isAcceptableOrUnknown(
              data['amount_cents']!, _amountCentsMeta));
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      ticketId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ticket_id'])!,
      at: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}at'])!,
      amountCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_cents'])!,
      method: $PaymentsTable.$convertermethod.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}method'])!),
      kind: $PaymentsTable.$converterkind.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}kind'])!),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PaymentMethod, int, int> $convertermethod =
      const EnumIndexConverter<PaymentMethod>(PaymentMethod.values);
  static JsonTypeConverter2<PaymentKind, int, int> $converterkind =
      const EnumIndexConverter<PaymentKind>(PaymentKind.values);
}

class Payment extends DataClass implements Insertable<Payment> {
  final int id;
  final int ticketId;
  final DateTime at;
  final int amountCents;
  final PaymentMethod method;
  final PaymentKind kind;
  final String? note;
  const Payment(
      {required this.id,
      required this.ticketId,
      required this.at,
      required this.amountCents,
      required this.method,
      required this.kind,
      this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ticket_id'] = Variable<int>(ticketId);
    map['at'] = Variable<DateTime>(at);
    map['amount_cents'] = Variable<int>(amountCents);
    {
      map['method'] =
          Variable<int>($PaymentsTable.$convertermethod.toSql(method));
    }
    {
      map['kind'] = Variable<int>($PaymentsTable.$converterkind.toSql(kind));
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      ticketId: Value(ticketId),
      at: Value(at),
      amountCents: Value(amountCents),
      method: Value(method),
      kind: Value(kind),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Payment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<int>(json['id']),
      ticketId: serializer.fromJson<int>(json['ticketId']),
      at: serializer.fromJson<DateTime>(json['at']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      method: $PaymentsTable.$convertermethod
          .fromJson(serializer.fromJson<int>(json['method'])),
      kind: $PaymentsTable.$converterkind
          .fromJson(serializer.fromJson<int>(json['kind'])),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ticketId': serializer.toJson<int>(ticketId),
      'at': serializer.toJson<DateTime>(at),
      'amountCents': serializer.toJson<int>(amountCents),
      'method': serializer
          .toJson<int>($PaymentsTable.$convertermethod.toJson(method)),
      'kind':
          serializer.toJson<int>($PaymentsTable.$converterkind.toJson(kind)),
      'note': serializer.toJson<String?>(note),
    };
  }

  Payment copyWith(
          {int? id,
          int? ticketId,
          DateTime? at,
          int? amountCents,
          PaymentMethod? method,
          PaymentKind? kind,
          Value<String?> note = const Value.absent()}) =>
      Payment(
        id: id ?? this.id,
        ticketId: ticketId ?? this.ticketId,
        at: at ?? this.at,
        amountCents: amountCents ?? this.amountCents,
        method: method ?? this.method,
        kind: kind ?? this.kind,
        note: note.present ? note.value : this.note,
      );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      ticketId: data.ticketId.present ? data.ticketId.value : this.ticketId,
      at: data.at.present ? data.at.value : this.at,
      amountCents:
          data.amountCents.present ? data.amountCents.value : this.amountCents,
      method: data.method.present ? data.method.value : this.method,
      kind: data.kind.present ? data.kind.value : this.kind,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('ticketId: $ticketId, ')
          ..write('at: $at, ')
          ..write('amountCents: $amountCents, ')
          ..write('method: $method, ')
          ..write('kind: $kind, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, ticketId, at, amountCents, method, kind, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.ticketId == this.ticketId &&
          other.at == this.at &&
          other.amountCents == this.amountCents &&
          other.method == this.method &&
          other.kind == this.kind &&
          other.note == this.note);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<int> id;
  final Value<int> ticketId;
  final Value<DateTime> at;
  final Value<int> amountCents;
  final Value<PaymentMethod> method;
  final Value<PaymentKind> kind;
  final Value<String?> note;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.ticketId = const Value.absent(),
    this.at = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.method = const Value.absent(),
    this.kind = const Value.absent(),
    this.note = const Value.absent(),
  });
  PaymentsCompanion.insert({
    this.id = const Value.absent(),
    required int ticketId,
    this.at = const Value.absent(),
    required int amountCents,
    required PaymentMethod method,
    required PaymentKind kind,
    this.note = const Value.absent(),
  })  : ticketId = Value(ticketId),
        amountCents = Value(amountCents),
        method = Value(method),
        kind = Value(kind);
  static Insertable<Payment> custom({
    Expression<int>? id,
    Expression<int>? ticketId,
    Expression<DateTime>? at,
    Expression<int>? amountCents,
    Expression<int>? method,
    Expression<int>? kind,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ticketId != null) 'ticket_id': ticketId,
      if (at != null) 'at': at,
      if (amountCents != null) 'amount_cents': amountCents,
      if (method != null) 'method': method,
      if (kind != null) 'kind': kind,
      if (note != null) 'note': note,
    });
  }

  PaymentsCompanion copyWith(
      {Value<int>? id,
      Value<int>? ticketId,
      Value<DateTime>? at,
      Value<int>? amountCents,
      Value<PaymentMethod>? method,
      Value<PaymentKind>? kind,
      Value<String?>? note}) {
    return PaymentsCompanion(
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      at: at ?? this.at,
      amountCents: amountCents ?? this.amountCents,
      method: method ?? this.method,
      kind: kind ?? this.kind,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ticketId.present) {
      map['ticket_id'] = Variable<int>(ticketId.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (method.present) {
      map['method'] =
          Variable<int>($PaymentsTable.$convertermethod.toSql(method.value));
    }
    if (kind.present) {
      map['kind'] =
          Variable<int>($PaymentsTable.$converterkind.toSql(kind.value));
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('ticketId: $ticketId, ')
          ..write('at: $at, ')
          ..write('amountCents: $amountCents, ')
          ..write('method: $method, ')
          ..write('kind: $kind, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<Setting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory Setting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) => Setting(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $DeviceCategoriesTable deviceCategories =
      $DeviceCategoriesTable(this);
  late final $DeviceBrandsTable deviceBrands = $DeviceBrandsTable(this);
  late final $DeviceModelsTable deviceModels = $DeviceModelsTable(this);
  late final $CustomerDevicesTable customerDevices =
      $CustomerDevicesTable(this);
  late final $PhotoTemplatesTable photoTemplates = $PhotoTemplatesTable(this);
  late final $PhotoTemplateSlotsTable photoTemplateSlots =
      $PhotoTemplateSlotsTable(this);
  late final $ServicesTable services = $ServicesTable(this);
  late final $TicketsTable tickets = $TicketsTable(this);
  late final $ShopTagsTable shopTags = $ShopTagsTable(this);
  late final $PartsTable parts = $PartsTable(this);
  late final $TicketItemsTable ticketItems = $TicketItemsTable(this);
  late final $TicketPhotosTable ticketPhotos = $TicketPhotosTable(this);
  late final $TicketPhotoSlotsTable ticketPhotoSlots =
      $TicketPhotoSlotsTable(this);
  late final $TicketReportsTable ticketReports = $TicketReportsTable(this);
  late final $ReportCosmeticItemsTable reportCosmeticItems =
      $ReportCosmeticItemsTable(this);
  late final $ReportFindingsTable reportFindings = $ReportFindingsTable(this);
  late final $TechnicalReportEntriesTable technicalReportEntries =
      $TechnicalReportEntriesTable(this);
  late final $ClientReportEntriesTable clientReportEntries =
      $ClientReportEntriesTable(this);
  late final $ReportContactLogTable reportContactLog =
      $ReportContactLogTable(this);
  late final $PartMovementsTable partMovements = $PartMovementsTable(this);
  late final $MerchProductsTable merchProducts = $MerchProductsTable(this);
  late final $MerchVariantsTable merchVariants = $MerchVariantsTable(this);
  late final $MerchSalesTable merchSales = $MerchSalesTable(this);
  late final $MerchSaleLinesTable merchSaleLines = $MerchSaleLinesTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        customers,
        deviceCategories,
        deviceBrands,
        deviceModels,
        customerDevices,
        photoTemplates,
        photoTemplateSlots,
        services,
        tickets,
        shopTags,
        parts,
        ticketItems,
        ticketPhotos,
        ticketPhotoSlots,
        ticketReports,
        reportCosmeticItems,
        reportFindings,
        technicalReportEntries,
        clientReportEntries,
        reportContactLog,
        partMovements,
        merchProducts,
        merchVariants,
        merchSales,
        merchSaleLines,
        payments,
        settings
      ];
}

typedef $$CustomersTableCreateCompanionBuilder = CustomersCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$CustomersTableUpdateCompanionBuilder = CustomersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$CustomersTableReferences
    extends BaseReferences<_$AppDatabase, $CustomersTable, Customer> {
  $$CustomersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CustomerDevicesTable, List<CustomerDevice>>
      _customerDevicesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.customerDevices,
              aliasName: 'customers__id__customer_devices__customer_id');

  $$CustomerDevicesTableProcessedTableManager get customerDevicesRefs {
    final manager =
        $$CustomerDevicesTableTableManager($_db, $_db.customerDevices)
            .filter((f) => f.customerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_customerDevicesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TicketsTable, List<Ticket>> _ticketsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.tickets,
          aliasName: 'customers__id__tickets__customer_id');

  $$TicketsTableProcessedTableManager get ticketsRefs {
    final manager = $$TicketsTableTableManager($_db, $_db.tickets)
        .filter((f) => f.customerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ticketsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$MerchSalesTable, List<MerchSale>>
      _merchSalesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.merchSales,
              aliasName: 'customers__id__merch_sales__customer_id');

  $$MerchSalesTableProcessedTableManager get merchSalesRefs {
    final manager = $$MerchSalesTableTableManager($_db, $_db.merchSales)
        .filter((f) => f.customerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_merchSalesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> customerDevicesRefs(
      Expression<bool> Function($$CustomerDevicesTableFilterComposer f) f) {
    final $$CustomerDevicesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.customerDevices,
        getReferencedColumn: (t) => t.customerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomerDevicesTableFilterComposer(
              $db: $db,
              $table: $db.customerDevices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> ticketsRefs(
      Expression<bool> Function($$TicketsTableFilterComposer f) f) {
    final $$TicketsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.customerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableFilterComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> merchSalesRefs(
      Expression<bool> Function($$MerchSalesTableFilterComposer f) f) {
    final $$MerchSalesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.merchSales,
        getReferencedColumn: (t) => t.customerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MerchSalesTableFilterComposer(
              $db: $db,
              $table: $db.merchSales,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
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
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
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
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> customerDevicesRefs<T extends Object>(
      Expression<T> Function($$CustomerDevicesTableAnnotationComposer a) f) {
    final $$CustomerDevicesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.customerDevices,
        getReferencedColumn: (t) => t.customerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomerDevicesTableAnnotationComposer(
              $db: $db,
              $table: $db.customerDevices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> ticketsRefs<T extends Object>(
      Expression<T> Function($$TicketsTableAnnotationComposer a) f) {
    final $$TicketsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.customerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableAnnotationComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> merchSalesRefs<T extends Object>(
      Expression<T> Function($$MerchSalesTableAnnotationComposer a) f) {
    final $$MerchSalesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.merchSales,
        getReferencedColumn: (t) => t.customerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MerchSalesTableAnnotationComposer(
              $db: $db,
              $table: $db.merchSales,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CustomersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CustomersTable,
    Customer,
    $$CustomersTableFilterComposer,
    $$CustomersTableOrderingComposer,
    $$CustomersTableAnnotationComposer,
    $$CustomersTableCreateCompanionBuilder,
    $$CustomersTableUpdateCompanionBuilder,
    (Customer, $$CustomersTableReferences),
    Customer,
    PrefetchHooks Function(
        {bool customerDevicesRefs, bool ticketsRefs, bool merchSalesRefs})> {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              CustomersCompanion(
            id: id,
            name: name,
            phone: phone,
            email: email,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              CustomersCompanion.insert(
            id: id,
            name: name,
            phone: phone,
            email: email,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CustomersTable, Customer>(table),
                    $$CustomersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {customerDevicesRefs = false,
              ticketsRefs = false,
              merchSalesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (customerDevicesRefs) db.customerDevices,
                if (ticketsRefs) db.tickets,
                if (merchSalesRefs) db.merchSales
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (customerDevicesRefs)
                    await $_getPrefetchedDataByColumns<
                            Customer,
                            $CustomersTable,
                            CustomerDevice,
                            $CustomerDevicesTable>(
                        currentTable: table,
                        referencedTable: $$CustomersTableReferences
                            ._customerDevicesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CustomersTableReferences(db, table, p0)
                                .customerDevicesRefs,
                        currentColumn: 'id',
                        referencedColumn: 'customer_id',
                        typedResults: items),
                  if (ticketsRefs)
                    await $_getPrefetchedDataByColumns<Customer,
                            $CustomersTable, Ticket, $TicketsTable>(
                        currentTable: table,
                        referencedTable:
                            $$CustomersTableReferences._ticketsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CustomersTableReferences(db, table, p0)
                                .ticketsRefs,
                        currentColumn: 'id',
                        referencedColumn: 'customer_id',
                        typedResults: items),
                  if (merchSalesRefs)
                    await $_getPrefetchedDataByColumns<Customer,
                            $CustomersTable, MerchSale, $MerchSalesTable>(
                        currentTable: table,
                        referencedTable:
                            $$CustomersTableReferences._merchSalesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CustomersTableReferences(db, table, p0)
                                .merchSalesRefs,
                        currentColumn: 'id',
                        referencedColumn: 'customer_id',
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CustomersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CustomersTable,
    Customer,
    $$CustomersTableFilterComposer,
    $$CustomersTableOrderingComposer,
    $$CustomersTableAnnotationComposer,
    $$CustomersTableCreateCompanionBuilder,
    $$CustomersTableUpdateCompanionBuilder,
    (Customer, $$CustomersTableReferences),
    Customer,
    PrefetchHooks Function(
        {bool customerDevicesRefs, bool ticketsRefs, bool merchSalesRefs})>;
typedef $$DeviceCategoriesTableCreateCompanionBuilder
    = DeviceCategoriesCompanion Function({
  Value<int> id,
  required String name,
  Value<int> sortOrder,
  Value<int> warrantyDays,
  Value<bool> isActive,
});
typedef $$DeviceCategoriesTableUpdateCompanionBuilder
    = DeviceCategoriesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> sortOrder,
  Value<int> warrantyDays,
  Value<bool> isActive,
});

final class $$DeviceCategoriesTableReferences extends BaseReferences<
    _$AppDatabase, $DeviceCategoriesTable, DeviceCategory> {
  $$DeviceCategoriesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DeviceBrandsTable, List<DeviceBrand>>
      _deviceBrandsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.deviceBrands,
              aliasName: 'device_categories__id__device_brands__category_id');

  $$DeviceBrandsTableProcessedTableManager get deviceBrandsRefs {
    final manager = $$DeviceBrandsTableTableManager($_db, $_db.deviceBrands)
        .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_deviceBrandsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ServicesTable, List<Service>> _servicesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.services,
          aliasName: 'device_categories__id__services__category_id');

  $$ServicesTableProcessedTableManager get servicesRefs {
    final manager = $$ServicesTableTableManager($_db, $_db.services)
        .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_servicesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DeviceCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $DeviceCategoriesTable> {
  $$DeviceCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get warrantyDays => $composableBuilder(
      column: $table.warrantyDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  Expression<bool> deviceBrandsRefs(
      Expression<bool> Function($$DeviceBrandsTableFilterComposer f) f) {
    final $$DeviceBrandsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.deviceBrands,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeviceBrandsTableFilterComposer(
              $db: $db,
              $table: $db.deviceBrands,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> servicesRefs(
      Expression<bool> Function($$ServicesTableFilterComposer f) f) {
    final $$ServicesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.services,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ServicesTableFilterComposer(
              $db: $db,
              $table: $db.services,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DeviceCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DeviceCategoriesTable> {
  $$DeviceCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get warrantyDays => $composableBuilder(
      column: $table.warrantyDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));
}

class $$DeviceCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeviceCategoriesTable> {
  $$DeviceCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get warrantyDays => $composableBuilder(
      column: $table.warrantyDays, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  Expression<T> deviceBrandsRefs<T extends Object>(
      Expression<T> Function($$DeviceBrandsTableAnnotationComposer a) f) {
    final $$DeviceBrandsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.deviceBrands,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeviceBrandsTableAnnotationComposer(
              $db: $db,
              $table: $db.deviceBrands,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> servicesRefs<T extends Object>(
      Expression<T> Function($$ServicesTableAnnotationComposer a) f) {
    final $$ServicesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.services,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ServicesTableAnnotationComposer(
              $db: $db,
              $table: $db.services,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DeviceCategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DeviceCategoriesTable,
    DeviceCategory,
    $$DeviceCategoriesTableFilterComposer,
    $$DeviceCategoriesTableOrderingComposer,
    $$DeviceCategoriesTableAnnotationComposer,
    $$DeviceCategoriesTableCreateCompanionBuilder,
    $$DeviceCategoriesTableUpdateCompanionBuilder,
    (DeviceCategory, $$DeviceCategoriesTableReferences),
    DeviceCategory,
    PrefetchHooks Function({bool deviceBrandsRefs, bool servicesRefs})> {
  $$DeviceCategoriesTableTableManager(
      _$AppDatabase db, $DeviceCategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeviceCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeviceCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeviceCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> warrantyDays = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
          }) =>
              DeviceCategoriesCompanion(
            id: id,
            name: name,
            sortOrder: sortOrder,
            warrantyDays: warrantyDays,
            isActive: isActive,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<int> sortOrder = const Value.absent(),
            Value<int> warrantyDays = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
          }) =>
              DeviceCategoriesCompanion.insert(
            id: id,
            name: name,
            sortOrder: sortOrder,
            warrantyDays: warrantyDays,
            isActive: isActive,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$DeviceCategoriesTable, DeviceCategory>(table),
                    $$DeviceCategoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {deviceBrandsRefs = false, servicesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (deviceBrandsRefs) db.deviceBrands,
                if (servicesRefs) db.services
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (deviceBrandsRefs)
                    await $_getPrefetchedDataByColumns<
                            DeviceCategory,
                            $DeviceCategoriesTable,
                            DeviceBrand,
                            $DeviceBrandsTable>(
                        currentTable: table,
                        referencedTable: $$DeviceCategoriesTableReferences
                            ._deviceBrandsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DeviceCategoriesTableReferences(db, table, p0)
                                .deviceBrandsRefs,
                        currentColumn: 'id',
                        referencedColumn: 'category_id',
                        typedResults: items),
                  if (servicesRefs)
                    await $_getPrefetchedDataByColumns<DeviceCategory,
                            $DeviceCategoriesTable, Service, $ServicesTable>(
                        currentTable: table,
                        referencedTable: $$DeviceCategoriesTableReferences
                            ._servicesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DeviceCategoriesTableReferences(db, table, p0)
                                .servicesRefs,
                        currentColumn: 'id',
                        referencedColumn: 'category_id',
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DeviceCategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DeviceCategoriesTable,
    DeviceCategory,
    $$DeviceCategoriesTableFilterComposer,
    $$DeviceCategoriesTableOrderingComposer,
    $$DeviceCategoriesTableAnnotationComposer,
    $$DeviceCategoriesTableCreateCompanionBuilder,
    $$DeviceCategoriesTableUpdateCompanionBuilder,
    (DeviceCategory, $$DeviceCategoriesTableReferences),
    DeviceCategory,
    PrefetchHooks Function({bool deviceBrandsRefs, bool servicesRefs})>;
typedef $$DeviceBrandsTableCreateCompanionBuilder = DeviceBrandsCompanion
    Function({
  Value<int> id,
  required int categoryId,
  required String name,
  Value<bool> isActive,
});
typedef $$DeviceBrandsTableUpdateCompanionBuilder = DeviceBrandsCompanion
    Function({
  Value<int> id,
  Value<int> categoryId,
  Value<String> name,
  Value<bool> isActive,
});

final class $$DeviceBrandsTableReferences
    extends BaseReferences<_$AppDatabase, $DeviceBrandsTable, DeviceBrand> {
  $$DeviceBrandsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DeviceCategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.deviceCategories
          .createAlias('device_brands__category_id__device_categories__id');

  $$DeviceCategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager =
        $$DeviceCategoriesTableTableManager($_db, $_db.deviceCategories)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$DeviceModelsTable, List<DeviceModel>>
      _deviceModelsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.deviceModels,
              aliasName: 'device_brands__id__device_models__brand_id');

  $$DeviceModelsTableProcessedTableManager get deviceModelsRefs {
    final manager = $$DeviceModelsTableTableManager($_db, $_db.deviceModels)
        .filter((f) => f.brandId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_deviceModelsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DeviceBrandsTableFilterComposer
    extends Composer<_$AppDatabase, $DeviceBrandsTable> {
  $$DeviceBrandsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  $$DeviceCategoriesTableFilterComposer get categoryId {
    final $$DeviceCategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.deviceCategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeviceCategoriesTableFilterComposer(
              $db: $db,
              $table: $db.deviceCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> deviceModelsRefs(
      Expression<bool> Function($$DeviceModelsTableFilterComposer f) f) {
    final $$DeviceModelsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.deviceModels,
        getReferencedColumn: (t) => t.brandId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeviceModelsTableFilterComposer(
              $db: $db,
              $table: $db.deviceModels,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DeviceBrandsTableOrderingComposer
    extends Composer<_$AppDatabase, $DeviceBrandsTable> {
  $$DeviceBrandsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  $$DeviceCategoriesTableOrderingComposer get categoryId {
    final $$DeviceCategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.deviceCategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeviceCategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.deviceCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DeviceBrandsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeviceBrandsTable> {
  $$DeviceBrandsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  $$DeviceCategoriesTableAnnotationComposer get categoryId {
    final $$DeviceCategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.deviceCategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeviceCategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.deviceCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> deviceModelsRefs<T extends Object>(
      Expression<T> Function($$DeviceModelsTableAnnotationComposer a) f) {
    final $$DeviceModelsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.deviceModels,
        getReferencedColumn: (t) => t.brandId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeviceModelsTableAnnotationComposer(
              $db: $db,
              $table: $db.deviceModels,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DeviceBrandsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DeviceBrandsTable,
    DeviceBrand,
    $$DeviceBrandsTableFilterComposer,
    $$DeviceBrandsTableOrderingComposer,
    $$DeviceBrandsTableAnnotationComposer,
    $$DeviceBrandsTableCreateCompanionBuilder,
    $$DeviceBrandsTableUpdateCompanionBuilder,
    (DeviceBrand, $$DeviceBrandsTableReferences),
    DeviceBrand,
    PrefetchHooks Function({bool categoryId, bool deviceModelsRefs})> {
  $$DeviceBrandsTableTableManager(_$AppDatabase db, $DeviceBrandsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeviceBrandsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeviceBrandsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeviceBrandsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> categoryId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
          }) =>
              DeviceBrandsCompanion(
            id: id,
            categoryId: categoryId,
            name: name,
            isActive: isActive,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int categoryId,
            required String name,
            Value<bool> isActive = const Value.absent(),
          }) =>
              DeviceBrandsCompanion.insert(
            id: id,
            categoryId: categoryId,
            name: name,
            isActive: isActive,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$DeviceBrandsTable, DeviceBrand>(table),
                    $$DeviceBrandsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {categoryId = false, deviceModelsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (deviceModelsRefs) db.deviceModels],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$DeviceBrandsTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$DeviceBrandsTableReferences._categoryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (deviceModelsRefs)
                    await $_getPrefetchedDataByColumns<
                            DeviceBrand,
                            $DeviceBrandsTable,
                            DeviceModel,
                            $DeviceModelsTable>(
                        currentTable: table,
                        referencedTable: $$DeviceBrandsTableReferences
                            ._deviceModelsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DeviceBrandsTableReferences(db, table, p0)
                                .deviceModelsRefs,
                        currentColumn: 'id',
                        referencedColumn: 'brand_id',
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DeviceBrandsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DeviceBrandsTable,
    DeviceBrand,
    $$DeviceBrandsTableFilterComposer,
    $$DeviceBrandsTableOrderingComposer,
    $$DeviceBrandsTableAnnotationComposer,
    $$DeviceBrandsTableCreateCompanionBuilder,
    $$DeviceBrandsTableUpdateCompanionBuilder,
    (DeviceBrand, $$DeviceBrandsTableReferences),
    DeviceBrand,
    PrefetchHooks Function({bool categoryId, bool deviceModelsRefs})>;
typedef $$DeviceModelsTableCreateCompanionBuilder = DeviceModelsCompanion
    Function({
  Value<int> id,
  required int brandId,
  required String name,
  Value<int> sortOrder,
  Value<String> attributes,
  Value<String?> photoTemplateKey,
  Value<bool> isActive,
});
typedef $$DeviceModelsTableUpdateCompanionBuilder = DeviceModelsCompanion
    Function({
  Value<int> id,
  Value<int> brandId,
  Value<String> name,
  Value<int> sortOrder,
  Value<String> attributes,
  Value<String?> photoTemplateKey,
  Value<bool> isActive,
});

final class $$DeviceModelsTableReferences
    extends BaseReferences<_$AppDatabase, $DeviceModelsTable, DeviceModel> {
  $$DeviceModelsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DeviceBrandsTable _brandIdTable(_$AppDatabase db) =>
      db.deviceBrands.createAlias('device_models__brand_id__device_brands__id');

  $$DeviceBrandsTableProcessedTableManager get brandId {
    final $_column = $_itemColumn<int>('brand_id')!;

    final manager = $$DeviceBrandsTableTableManager($_db, $_db.deviceBrands)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_brandIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$CustomerDevicesTable, List<CustomerDevice>>
      _customerDevicesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.customerDevices,
              aliasName:
                  'device_models__id__customer_devices__device_model_id');

  $$CustomerDevicesTableProcessedTableManager get customerDevicesRefs {
    final manager = $$CustomerDevicesTableTableManager(
            $_db, $_db.customerDevices)
        .filter((f) => f.deviceModelId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_customerDevicesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TicketsTable, List<Ticket>> _ticketsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.tickets,
          aliasName: 'device_models__id__tickets__device_model_id');

  $$TicketsTableProcessedTableManager get ticketsRefs {
    final manager = $$TicketsTableTableManager($_db, $_db.tickets)
        .filter((f) => f.deviceModelId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ticketsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DeviceModelsTableFilterComposer
    extends Composer<_$AppDatabase, $DeviceModelsTable> {
  $$DeviceModelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get attributes => $composableBuilder(
      column: $table.attributes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoTemplateKey => $composableBuilder(
      column: $table.photoTemplateKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  $$DeviceBrandsTableFilterComposer get brandId {
    final $$DeviceBrandsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.brandId,
        referencedTable: $db.deviceBrands,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeviceBrandsTableFilterComposer(
              $db: $db,
              $table: $db.deviceBrands,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> customerDevicesRefs(
      Expression<bool> Function($$CustomerDevicesTableFilterComposer f) f) {
    final $$CustomerDevicesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.customerDevices,
        getReferencedColumn: (t) => t.deviceModelId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomerDevicesTableFilterComposer(
              $db: $db,
              $table: $db.customerDevices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> ticketsRefs(
      Expression<bool> Function($$TicketsTableFilterComposer f) f) {
    final $$TicketsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.deviceModelId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableFilterComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DeviceModelsTableOrderingComposer
    extends Composer<_$AppDatabase, $DeviceModelsTable> {
  $$DeviceModelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get attributes => $composableBuilder(
      column: $table.attributes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoTemplateKey => $composableBuilder(
      column: $table.photoTemplateKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  $$DeviceBrandsTableOrderingComposer get brandId {
    final $$DeviceBrandsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.brandId,
        referencedTable: $db.deviceBrands,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeviceBrandsTableOrderingComposer(
              $db: $db,
              $table: $db.deviceBrands,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DeviceModelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeviceModelsTable> {
  $$DeviceModelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get attributes => $composableBuilder(
      column: $table.attributes, builder: (column) => column);

  GeneratedColumn<String> get photoTemplateKey => $composableBuilder(
      column: $table.photoTemplateKey, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  $$DeviceBrandsTableAnnotationComposer get brandId {
    final $$DeviceBrandsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.brandId,
        referencedTable: $db.deviceBrands,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeviceBrandsTableAnnotationComposer(
              $db: $db,
              $table: $db.deviceBrands,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> customerDevicesRefs<T extends Object>(
      Expression<T> Function($$CustomerDevicesTableAnnotationComposer a) f) {
    final $$CustomerDevicesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.customerDevices,
        getReferencedColumn: (t) => t.deviceModelId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomerDevicesTableAnnotationComposer(
              $db: $db,
              $table: $db.customerDevices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> ticketsRefs<T extends Object>(
      Expression<T> Function($$TicketsTableAnnotationComposer a) f) {
    final $$TicketsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.deviceModelId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableAnnotationComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DeviceModelsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DeviceModelsTable,
    DeviceModel,
    $$DeviceModelsTableFilterComposer,
    $$DeviceModelsTableOrderingComposer,
    $$DeviceModelsTableAnnotationComposer,
    $$DeviceModelsTableCreateCompanionBuilder,
    $$DeviceModelsTableUpdateCompanionBuilder,
    (DeviceModel, $$DeviceModelsTableReferences),
    DeviceModel,
    PrefetchHooks Function(
        {bool brandId, bool customerDevicesRefs, bool ticketsRefs})> {
  $$DeviceModelsTableTableManager(_$AppDatabase db, $DeviceModelsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeviceModelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeviceModelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeviceModelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> brandId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<String> attributes = const Value.absent(),
            Value<String?> photoTemplateKey = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
          }) =>
              DeviceModelsCompanion(
            id: id,
            brandId: brandId,
            name: name,
            sortOrder: sortOrder,
            attributes: attributes,
            photoTemplateKey: photoTemplateKey,
            isActive: isActive,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int brandId,
            required String name,
            Value<int> sortOrder = const Value.absent(),
            Value<String> attributes = const Value.absent(),
            Value<String?> photoTemplateKey = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
          }) =>
              DeviceModelsCompanion.insert(
            id: id,
            brandId: brandId,
            name: name,
            sortOrder: sortOrder,
            attributes: attributes,
            photoTemplateKey: photoTemplateKey,
            isActive: isActive,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$DeviceModelsTable, DeviceModel>(table),
                    $$DeviceModelsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {brandId = false,
              customerDevicesRefs = false,
              ticketsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (customerDevicesRefs) db.customerDevices,
                if (ticketsRefs) db.tickets
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (brandId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.brandId,
                    referencedTable:
                        $$DeviceModelsTableReferences._brandIdTable(db),
                    referencedColumn:
                        $$DeviceModelsTableReferences._brandIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (customerDevicesRefs)
                    await $_getPrefetchedDataByColumns<
                            DeviceModel,
                            $DeviceModelsTable,
                            CustomerDevice,
                            $CustomerDevicesTable>(
                        currentTable: table,
                        referencedTable: $$DeviceModelsTableReferences
                            ._customerDevicesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DeviceModelsTableReferences(db, table, p0)
                                .customerDevicesRefs,
                        currentColumn: 'id',
                        referencedColumn: 'device_model_id',
                        typedResults: items),
                  if (ticketsRefs)
                    await $_getPrefetchedDataByColumns<DeviceModel,
                            $DeviceModelsTable, Ticket, $TicketsTable>(
                        currentTable: table,
                        referencedTable:
                            $$DeviceModelsTableReferences._ticketsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DeviceModelsTableReferences(db, table, p0)
                                .ticketsRefs,
                        currentColumn: 'id',
                        referencedColumn: 'device_model_id',
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DeviceModelsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DeviceModelsTable,
    DeviceModel,
    $$DeviceModelsTableFilterComposer,
    $$DeviceModelsTableOrderingComposer,
    $$DeviceModelsTableAnnotationComposer,
    $$DeviceModelsTableCreateCompanionBuilder,
    $$DeviceModelsTableUpdateCompanionBuilder,
    (DeviceModel, $$DeviceModelsTableReferences),
    DeviceModel,
    PrefetchHooks Function(
        {bool brandId, bool customerDevicesRefs, bool ticketsRefs})>;
typedef $$CustomerDevicesTableCreateCompanionBuilder = CustomerDevicesCompanion
    Function({
  Value<int> id,
  required int customerId,
  Value<int?> deviceModelId,
  Value<String?> deviceName,
  Value<String?> deviceVariant,
  Value<String?> deviceSide,
  Value<String?> serial,
  Value<bool> serialMissing,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$CustomerDevicesTableUpdateCompanionBuilder = CustomerDevicesCompanion
    Function({
  Value<int> id,
  Value<int> customerId,
  Value<int?> deviceModelId,
  Value<String?> deviceName,
  Value<String?> deviceVariant,
  Value<String?> deviceSide,
  Value<String?> serial,
  Value<bool> serialMissing,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$CustomerDevicesTableReferences extends BaseReferences<
    _$AppDatabase, $CustomerDevicesTable, CustomerDevice> {
  $$CustomerDevicesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias('customer_devices__customer_id__customers__id');

  $$CustomersTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<int>('customer_id')!;

    final manager = $$CustomersTableTableManager($_db, $_db.customers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $DeviceModelsTable _deviceModelIdTable(_$AppDatabase db) =>
      db.deviceModels
          .createAlias('customer_devices__device_model_id__device_models__id');

  $$DeviceModelsTableProcessedTableManager? get deviceModelId {
    final $_column = $_itemColumn<int>('device_model_id');
    if ($_column == null) return null;
    final manager = $$DeviceModelsTableTableManager($_db, $_db.deviceModels)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceModelIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TicketsTable, List<Ticket>> _ticketsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.tickets,
          aliasName: 'customer_devices__id__tickets__customer_device_id');

  $$TicketsTableProcessedTableManager get ticketsRefs {
    final manager = $$TicketsTableTableManager($_db, $_db.tickets).filter(
        (f) => f.customerDeviceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ticketsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CustomerDevicesTableFilterComposer
    extends Composer<_$AppDatabase, $CustomerDevicesTable> {
  $$CustomerDevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceName => $composableBuilder(
      column: $table.deviceName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceVariant => $composableBuilder(
      column: $table.deviceVariant, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceSide => $composableBuilder(
      column: $table.deviceSide, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serial => $composableBuilder(
      column: $table.serial, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get serialMissing => $composableBuilder(
      column: $table.serialMissing, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.customerId,
        referencedTable: $db.customers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomersTableFilterComposer(
              $db: $db,
              $table: $db.customers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$DeviceModelsTableFilterComposer get deviceModelId {
    final $$DeviceModelsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.deviceModelId,
        referencedTable: $db.deviceModels,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeviceModelsTableFilterComposer(
              $db: $db,
              $table: $db.deviceModels,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> ticketsRefs(
      Expression<bool> Function($$TicketsTableFilterComposer f) f) {
    final $$TicketsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.customerDeviceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableFilterComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CustomerDevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomerDevicesTable> {
  $$CustomerDevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceName => $composableBuilder(
      column: $table.deviceName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceVariant => $composableBuilder(
      column: $table.deviceVariant,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceSide => $composableBuilder(
      column: $table.deviceSide, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serial => $composableBuilder(
      column: $table.serial, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get serialMissing => $composableBuilder(
      column: $table.serialMissing,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.customerId,
        referencedTable: $db.customers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomersTableOrderingComposer(
              $db: $db,
              $table: $db.customers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$DeviceModelsTableOrderingComposer get deviceModelId {
    final $$DeviceModelsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.deviceModelId,
        referencedTable: $db.deviceModels,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeviceModelsTableOrderingComposer(
              $db: $db,
              $table: $db.deviceModels,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CustomerDevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomerDevicesTable> {
  $$CustomerDevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceName => $composableBuilder(
      column: $table.deviceName, builder: (column) => column);

  GeneratedColumn<String> get deviceVariant => $composableBuilder(
      column: $table.deviceVariant, builder: (column) => column);

  GeneratedColumn<String> get deviceSide => $composableBuilder(
      column: $table.deviceSide, builder: (column) => column);

  GeneratedColumn<String> get serial =>
      $composableBuilder(column: $table.serial, builder: (column) => column);

  GeneratedColumn<bool> get serialMissing => $composableBuilder(
      column: $table.serialMissing, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.customerId,
        referencedTable: $db.customers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomersTableAnnotationComposer(
              $db: $db,
              $table: $db.customers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$DeviceModelsTableAnnotationComposer get deviceModelId {
    final $$DeviceModelsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.deviceModelId,
        referencedTable: $db.deviceModels,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeviceModelsTableAnnotationComposer(
              $db: $db,
              $table: $db.deviceModels,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> ticketsRefs<T extends Object>(
      Expression<T> Function($$TicketsTableAnnotationComposer a) f) {
    final $$TicketsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.customerDeviceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableAnnotationComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CustomerDevicesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CustomerDevicesTable,
    CustomerDevice,
    $$CustomerDevicesTableFilterComposer,
    $$CustomerDevicesTableOrderingComposer,
    $$CustomerDevicesTableAnnotationComposer,
    $$CustomerDevicesTableCreateCompanionBuilder,
    $$CustomerDevicesTableUpdateCompanionBuilder,
    (CustomerDevice, $$CustomerDevicesTableReferences),
    CustomerDevice,
    PrefetchHooks Function(
        {bool customerId, bool deviceModelId, bool ticketsRefs})> {
  $$CustomerDevicesTableTableManager(
      _$AppDatabase db, $CustomerDevicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomerDevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomerDevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomerDevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> customerId = const Value.absent(),
            Value<int?> deviceModelId = const Value.absent(),
            Value<String?> deviceName = const Value.absent(),
            Value<String?> deviceVariant = const Value.absent(),
            Value<String?> deviceSide = const Value.absent(),
            Value<String?> serial = const Value.absent(),
            Value<bool> serialMissing = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              CustomerDevicesCompanion(
            id: id,
            customerId: customerId,
            deviceModelId: deviceModelId,
            deviceName: deviceName,
            deviceVariant: deviceVariant,
            deviceSide: deviceSide,
            serial: serial,
            serialMissing: serialMissing,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int customerId,
            Value<int?> deviceModelId = const Value.absent(),
            Value<String?> deviceName = const Value.absent(),
            Value<String?> deviceVariant = const Value.absent(),
            Value<String?> deviceSide = const Value.absent(),
            Value<String?> serial = const Value.absent(),
            Value<bool> serialMissing = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              CustomerDevicesCompanion.insert(
            id: id,
            customerId: customerId,
            deviceModelId: deviceModelId,
            deviceName: deviceName,
            deviceVariant: deviceVariant,
            deviceSide: deviceSide,
            serial: serial,
            serialMissing: serialMissing,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CustomerDevicesTable, CustomerDevice>(table),
                    $$CustomerDevicesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {customerId = false,
              deviceModelId = false,
              ticketsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (ticketsRefs) db.tickets],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (customerId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.customerId,
                    referencedTable:
                        $$CustomerDevicesTableReferences._customerIdTable(db),
                    referencedColumn: $$CustomerDevicesTableReferences
                        ._customerIdTable(db)
                        .id,
                  ) as T;
                }
                if (deviceModelId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.deviceModelId,
                    referencedTable: $$CustomerDevicesTableReferences
                        ._deviceModelIdTable(db),
                    referencedColumn: $$CustomerDevicesTableReferences
                        ._deviceModelIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ticketsRefs)
                    await $_getPrefetchedDataByColumns<CustomerDevice,
                            $CustomerDevicesTable, Ticket, $TicketsTable>(
                        currentTable: table,
                        referencedTable: $$CustomerDevicesTableReferences
                            ._ticketsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CustomerDevicesTableReferences(db, table, p0)
                                .ticketsRefs,
                        currentColumn: 'id',
                        referencedColumn: 'customer_device_id',
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CustomerDevicesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CustomerDevicesTable,
    CustomerDevice,
    $$CustomerDevicesTableFilterComposer,
    $$CustomerDevicesTableOrderingComposer,
    $$CustomerDevicesTableAnnotationComposer,
    $$CustomerDevicesTableCreateCompanionBuilder,
    $$CustomerDevicesTableUpdateCompanionBuilder,
    (CustomerDevice, $$CustomerDevicesTableReferences),
    CustomerDevice,
    PrefetchHooks Function(
        {bool customerId, bool deviceModelId, bool ticketsRefs})>;
typedef $$PhotoTemplatesTableCreateCompanionBuilder = PhotoTemplatesCompanion
    Function({
  Value<int> id,
  required String key,
  required String name,
});
typedef $$PhotoTemplatesTableUpdateCompanionBuilder = PhotoTemplatesCompanion
    Function({
  Value<int> id,
  Value<String> key,
  Value<String> name,
});

final class $$PhotoTemplatesTableReferences
    extends BaseReferences<_$AppDatabase, $PhotoTemplatesTable, PhotoTemplate> {
  $$PhotoTemplatesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PhotoTemplateSlotsTable, List<PhotoTemplateSlot>>
      _photoTemplateSlotsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.photoTemplateSlots,
              aliasName:
                  'photo_templates__id__photo_template_slots__template_id');

  $$PhotoTemplateSlotsTableProcessedTableManager get photoTemplateSlotsRefs {
    final manager =
        $$PhotoTemplateSlotsTableTableManager($_db, $_db.photoTemplateSlots)
            .filter((f) => f.templateId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_photoTemplateSlotsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PhotoTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $PhotoTemplatesTable> {
  $$PhotoTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  Expression<bool> photoTemplateSlotsRefs(
      Expression<bool> Function($$PhotoTemplateSlotsTableFilterComposer f) f) {
    final $$PhotoTemplateSlotsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.photoTemplateSlots,
        getReferencedColumn: (t) => t.templateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PhotoTemplateSlotsTableFilterComposer(
              $db: $db,
              $table: $db.photoTemplateSlots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PhotoTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $PhotoTemplatesTable> {
  $$PhotoTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$PhotoTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhotoTemplatesTable> {
  $$PhotoTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> photoTemplateSlotsRefs<T extends Object>(
      Expression<T> Function($$PhotoTemplateSlotsTableAnnotationComposer a) f) {
    final $$PhotoTemplateSlotsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.photoTemplateSlots,
            getReferencedColumn: (t) => t.templateId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PhotoTemplateSlotsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.photoTemplateSlots,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$PhotoTemplatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PhotoTemplatesTable,
    PhotoTemplate,
    $$PhotoTemplatesTableFilterComposer,
    $$PhotoTemplatesTableOrderingComposer,
    $$PhotoTemplatesTableAnnotationComposer,
    $$PhotoTemplatesTableCreateCompanionBuilder,
    $$PhotoTemplatesTableUpdateCompanionBuilder,
    (PhotoTemplate, $$PhotoTemplatesTableReferences),
    PhotoTemplate,
    PrefetchHooks Function({bool photoTemplateSlotsRefs})> {
  $$PhotoTemplatesTableTableManager(
      _$AppDatabase db, $PhotoTemplatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhotoTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhotoTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhotoTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> key = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) =>
              PhotoTemplatesCompanion(
            id: id,
            key: key,
            name: name,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String key,
            required String name,
          }) =>
              PhotoTemplatesCompanion.insert(
            id: id,
            key: key,
            name: name,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$PhotoTemplatesTable, PhotoTemplate>(table),
                    $$PhotoTemplatesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({photoTemplateSlotsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (photoTemplateSlotsRefs) db.photoTemplateSlots
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (photoTemplateSlotsRefs)
                    await $_getPrefetchedDataByColumns<
                            PhotoTemplate,
                            $PhotoTemplatesTable,
                            PhotoTemplateSlot,
                            $PhotoTemplateSlotsTable>(
                        currentTable: table,
                        referencedTable: $$PhotoTemplatesTableReferences
                            ._photoTemplateSlotsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PhotoTemplatesTableReferences(db, table, p0)
                                .photoTemplateSlotsRefs,
                        currentColumn: 'id',
                        referencedColumn: 'template_id',
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PhotoTemplatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PhotoTemplatesTable,
    PhotoTemplate,
    $$PhotoTemplatesTableFilterComposer,
    $$PhotoTemplatesTableOrderingComposer,
    $$PhotoTemplatesTableAnnotationComposer,
    $$PhotoTemplatesTableCreateCompanionBuilder,
    $$PhotoTemplatesTableUpdateCompanionBuilder,
    (PhotoTemplate, $$PhotoTemplatesTableReferences),
    PhotoTemplate,
    PrefetchHooks Function({bool photoTemplateSlotsRefs})>;
typedef $$PhotoTemplateSlotsTableCreateCompanionBuilder
    = PhotoTemplateSlotsCompanion Function({
  Value<int> id,
  required int templateId,
  required int sortOrder,
  required String label,
  Value<String?> hint,
  Value<bool> required,
});
typedef $$PhotoTemplateSlotsTableUpdateCompanionBuilder
    = PhotoTemplateSlotsCompanion Function({
  Value<int> id,
  Value<int> templateId,
  Value<int> sortOrder,
  Value<String> label,
  Value<String?> hint,
  Value<bool> required,
});

final class $$PhotoTemplateSlotsTableReferences extends BaseReferences<
    _$AppDatabase, $PhotoTemplateSlotsTable, PhotoTemplateSlot> {
  $$PhotoTemplateSlotsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $PhotoTemplatesTable _templateIdTable(_$AppDatabase db) => db
      .photoTemplates
      .createAlias('photo_template_slots__template_id__photo_templates__id');

  $$PhotoTemplatesTableProcessedTableManager get templateId {
    final $_column = $_itemColumn<int>('template_id')!;

    final manager = $$PhotoTemplatesTableTableManager($_db, $_db.photoTemplates)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_templateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PhotoTemplateSlotsTableFilterComposer
    extends Composer<_$AppDatabase, $PhotoTemplateSlotsTable> {
  $$PhotoTemplateSlotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hint => $composableBuilder(
      column: $table.hint, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get required => $composableBuilder(
      column: $table.required, builder: (column) => ColumnFilters(column));

  $$PhotoTemplatesTableFilterComposer get templateId {
    final $$PhotoTemplatesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.photoTemplates,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PhotoTemplatesTableFilterComposer(
              $db: $db,
              $table: $db.photoTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PhotoTemplateSlotsTableOrderingComposer
    extends Composer<_$AppDatabase, $PhotoTemplateSlotsTable> {
  $$PhotoTemplateSlotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hint => $composableBuilder(
      column: $table.hint, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get required => $composableBuilder(
      column: $table.required, builder: (column) => ColumnOrderings(column));

  $$PhotoTemplatesTableOrderingComposer get templateId {
    final $$PhotoTemplatesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.photoTemplates,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PhotoTemplatesTableOrderingComposer(
              $db: $db,
              $table: $db.photoTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PhotoTemplateSlotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhotoTemplateSlotsTable> {
  $$PhotoTemplateSlotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get hint =>
      $composableBuilder(column: $table.hint, builder: (column) => column);

  GeneratedColumn<bool> get required =>
      $composableBuilder(column: $table.required, builder: (column) => column);

  $$PhotoTemplatesTableAnnotationComposer get templateId {
    final $$PhotoTemplatesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.photoTemplates,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PhotoTemplatesTableAnnotationComposer(
              $db: $db,
              $table: $db.photoTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PhotoTemplateSlotsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PhotoTemplateSlotsTable,
    PhotoTemplateSlot,
    $$PhotoTemplateSlotsTableFilterComposer,
    $$PhotoTemplateSlotsTableOrderingComposer,
    $$PhotoTemplateSlotsTableAnnotationComposer,
    $$PhotoTemplateSlotsTableCreateCompanionBuilder,
    $$PhotoTemplateSlotsTableUpdateCompanionBuilder,
    (PhotoTemplateSlot, $$PhotoTemplateSlotsTableReferences),
    PhotoTemplateSlot,
    PrefetchHooks Function({bool templateId})> {
  $$PhotoTemplateSlotsTableTableManager(
      _$AppDatabase db, $PhotoTemplateSlotsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhotoTemplateSlotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhotoTemplateSlotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhotoTemplateSlotsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> templateId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<String?> hint = const Value.absent(),
            Value<bool> required = const Value.absent(),
          }) =>
              PhotoTemplateSlotsCompanion(
            id: id,
            templateId: templateId,
            sortOrder: sortOrder,
            label: label,
            hint: hint,
            required: required,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int templateId,
            required int sortOrder,
            required String label,
            Value<String?> hint = const Value.absent(),
            Value<bool> required = const Value.absent(),
          }) =>
              PhotoTemplateSlotsCompanion.insert(
            id: id,
            templateId: templateId,
            sortOrder: sortOrder,
            label: label,
            hint: hint,
            required: required,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$PhotoTemplateSlotsTable, PhotoTemplateSlot>(
                        table),
                    $$PhotoTemplateSlotsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({templateId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (templateId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.templateId,
                    referencedTable: $$PhotoTemplateSlotsTableReferences
                        ._templateIdTable(db),
                    referencedColumn: $$PhotoTemplateSlotsTableReferences
                        ._templateIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PhotoTemplateSlotsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PhotoTemplateSlotsTable,
    PhotoTemplateSlot,
    $$PhotoTemplateSlotsTableFilterComposer,
    $$PhotoTemplateSlotsTableOrderingComposer,
    $$PhotoTemplateSlotsTableAnnotationComposer,
    $$PhotoTemplateSlotsTableCreateCompanionBuilder,
    $$PhotoTemplateSlotsTableUpdateCompanionBuilder,
    (PhotoTemplateSlot, $$PhotoTemplateSlotsTableReferences),
    PhotoTemplateSlot,
    PrefetchHooks Function({bool templateId})>;
typedef $$ServicesTableCreateCompanionBuilder = ServicesCompanion Function({
  Value<int> id,
  required String name,
  Value<int?> categoryId,
  Value<int> defaultPriceCents,
  Value<int> defaultMinutes,
  Value<bool> isActive,
});
typedef $$ServicesTableUpdateCompanionBuilder = ServicesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int?> categoryId,
  Value<int> defaultPriceCents,
  Value<int> defaultMinutes,
  Value<bool> isActive,
});

final class $$ServicesTableReferences
    extends BaseReferences<_$AppDatabase, $ServicesTable, Service> {
  $$ServicesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DeviceCategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.deviceCategories
          .createAlias('services__category_id__device_categories__id');

  $$DeviceCategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager =
        $$DeviceCategoriesTableTableManager($_db, $_db.deviceCategories)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TicketItemsTable, List<TicketItem>>
      _ticketItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.ticketItems,
              aliasName: 'services__id__ticket_items__service_id');

  $$TicketItemsTableProcessedTableManager get ticketItemsRefs {
    final manager = $$TicketItemsTableTableManager($_db, $_db.ticketItems)
        .filter((f) => f.serviceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ticketItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ServicesTableFilterComposer
    extends Composer<_$AppDatabase, $ServicesTable> {
  $$ServicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get defaultPriceCents => $composableBuilder(
      column: $table.defaultPriceCents,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get defaultMinutes => $composableBuilder(
      column: $table.defaultMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  $$DeviceCategoriesTableFilterComposer get categoryId {
    final $$DeviceCategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.deviceCategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeviceCategoriesTableFilterComposer(
              $db: $db,
              $table: $db.deviceCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> ticketItemsRefs(
      Expression<bool> Function($$TicketItemsTableFilterComposer f) f) {
    final $$TicketItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.ticketItems,
        getReferencedColumn: (t) => t.serviceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketItemsTableFilterComposer(
              $db: $db,
              $table: $db.ticketItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ServicesTableOrderingComposer
    extends Composer<_$AppDatabase, $ServicesTable> {
  $$ServicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get defaultPriceCents => $composableBuilder(
      column: $table.defaultPriceCents,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get defaultMinutes => $composableBuilder(
      column: $table.defaultMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  $$DeviceCategoriesTableOrderingComposer get categoryId {
    final $$DeviceCategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.deviceCategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeviceCategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.deviceCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ServicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServicesTable> {
  $$ServicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get defaultPriceCents => $composableBuilder(
      column: $table.defaultPriceCents, builder: (column) => column);

  GeneratedColumn<int> get defaultMinutes => $composableBuilder(
      column: $table.defaultMinutes, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  $$DeviceCategoriesTableAnnotationComposer get categoryId {
    final $$DeviceCategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.deviceCategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeviceCategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.deviceCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> ticketItemsRefs<T extends Object>(
      Expression<T> Function($$TicketItemsTableAnnotationComposer a) f) {
    final $$TicketItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.ticketItems,
        getReferencedColumn: (t) => t.serviceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.ticketItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ServicesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ServicesTable,
    Service,
    $$ServicesTableFilterComposer,
    $$ServicesTableOrderingComposer,
    $$ServicesTableAnnotationComposer,
    $$ServicesTableCreateCompanionBuilder,
    $$ServicesTableUpdateCompanionBuilder,
    (Service, $$ServicesTableReferences),
    Service,
    PrefetchHooks Function({bool categoryId, bool ticketItemsRefs})> {
  $$ServicesTableTableManager(_$AppDatabase db, $ServicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int?> categoryId = const Value.absent(),
            Value<int> defaultPriceCents = const Value.absent(),
            Value<int> defaultMinutes = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
          }) =>
              ServicesCompanion(
            id: id,
            name: name,
            categoryId: categoryId,
            defaultPriceCents: defaultPriceCents,
            defaultMinutes: defaultMinutes,
            isActive: isActive,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<int?> categoryId = const Value.absent(),
            Value<int> defaultPriceCents = const Value.absent(),
            Value<int> defaultMinutes = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
          }) =>
              ServicesCompanion.insert(
            id: id,
            name: name,
            categoryId: categoryId,
            defaultPriceCents: defaultPriceCents,
            defaultMinutes: defaultMinutes,
            isActive: isActive,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ServicesTable, Service>(table),
                    $$ServicesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {categoryId = false, ticketItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (ticketItemsRefs) db.ticketItems],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$ServicesTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$ServicesTableReferences._categoryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ticketItemsRefs)
                    await $_getPrefetchedDataByColumns<Service, $ServicesTable,
                            TicketItem, $TicketItemsTable>(
                        currentTable: table,
                        referencedTable:
                            $$ServicesTableReferences._ticketItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ServicesTableReferences(db, table, p0)
                                .ticketItemsRefs,
                        currentColumn: 'id',
                        referencedColumn: 'service_id',
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ServicesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ServicesTable,
    Service,
    $$ServicesTableFilterComposer,
    $$ServicesTableOrderingComposer,
    $$ServicesTableAnnotationComposer,
    $$ServicesTableCreateCompanionBuilder,
    $$ServicesTableUpdateCompanionBuilder,
    (Service, $$ServicesTableReferences),
    Service,
    PrefetchHooks Function({bool categoryId, bool ticketItemsRefs})>;
typedef $$TicketsTableCreateCompanionBuilder = TicketsCompanion Function({
  Value<int> id,
  required String number,
  required int customerId,
  Value<int?> customerDeviceId,
  Value<int?> deviceModelId,
  Value<String?> deviceName,
  Value<String?> deviceVariant,
  Value<String?> deviceSide,
  Value<String?> serial,
  Value<bool> serialMissing,
  Value<String?> shopTag,
  required String complaint,
  Value<String?> diagnosis,
  Value<String?> intakeNotes,
  Value<DateTime?> report1CompletedAt,
  Value<DateTime?> report2CompletedAt,
  Value<DateTime?> report3CompletedAt,
  Value<DateTime?> dropOffAt,
  Value<DateTime?> technicianStartAt,
  Value<DateTime?> partsArriveAt,
  Value<DateTime?> customerContactedAt,
  Value<String?> photoTemplateKey,
  required TicketStatus status,
  Value<int> priority,
  Value<int> estimateCents,
  Value<InvoiceDiscountKind> invoiceDiscountKind,
  Value<int> invoiceDiscountValue,
  Value<String?> notes,
  Value<String> partnerName,
  Value<int> partnerPartsPercent,
  Value<int> partnerLabourPercent,
  Value<int> gstCents,
  Value<int> pstCents,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> dueAt,
  Value<DateTime?> completedAt,
  Value<DateTime?> pickedUpAt,
});
typedef $$TicketsTableUpdateCompanionBuilder = TicketsCompanion Function({
  Value<int> id,
  Value<String> number,
  Value<int> customerId,
  Value<int?> customerDeviceId,
  Value<int?> deviceModelId,
  Value<String?> deviceName,
  Value<String?> deviceVariant,
  Value<String?> deviceSide,
  Value<String?> serial,
  Value<bool> serialMissing,
  Value<String?> shopTag,
  Value<String> complaint,
  Value<String?> diagnosis,
  Value<String?> intakeNotes,
  Value<DateTime?> report1CompletedAt,
  Value<DateTime?> report2CompletedAt,
  Value<DateTime?> report3CompletedAt,
  Value<DateTime?> dropOffAt,
  Value<DateTime?> technicianStartAt,
  Value<DateTime?> partsArriveAt,
  Value<DateTime?> customerContactedAt,
  Value<String?> photoTemplateKey,
  Value<TicketStatus> status,
  Value<int> priority,
  Value<int> estimateCents,
  Value<InvoiceDiscountKind> invoiceDiscountKind,
  Value<int> invoiceDiscountValue,
  Value<String?> notes,
  Value<String> partnerName,
  Value<int> partnerPartsPercent,
  Value<int> partnerLabourPercent,
  Value<int> gstCents,
  Value<int> pstCents,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> dueAt,
  Value<DateTime?> completedAt,
  Value<DateTime?> pickedUpAt,
});

final class $$TicketsTableReferences
    extends BaseReferences<_$AppDatabase, $TicketsTable, Ticket> {
  $$TicketsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias('tickets__customer_id__customers__id');

  $$CustomersTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<int>('customer_id')!;

    final manager = $$CustomersTableTableManager($_db, $_db.customers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $CustomerDevicesTable _customerDeviceIdTable(_$AppDatabase db) =>
      db.customerDevices
          .createAlias('tickets__customer_device_id__customer_devices__id');

  $$CustomerDevicesTableProcessedTableManager? get customerDeviceId {
    final $_column = $_itemColumn<int>('customer_device_id');
    if ($_column == null) return null;
    final manager =
        $$CustomerDevicesTableTableManager($_db, $_db.customerDevices)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerDeviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $DeviceModelsTable _deviceModelIdTable(_$AppDatabase db) =>
      db.deviceModels
          .createAlias('tickets__device_model_id__device_models__id');

  $$DeviceModelsTableProcessedTableManager? get deviceModelId {
    final $_column = $_itemColumn<int>('device_model_id');
    if ($_column == null) return null;
    final manager = $$DeviceModelsTableTableManager($_db, $_db.deviceModels)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceModelIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ShopTagsTable, List<ShopTag>> _shopTagsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.shopTags,
          aliasName: 'tickets__id__shop_tags__ticket_id');

  $$ShopTagsTableProcessedTableManager get shopTagsRefs {
    final manager = $$ShopTagsTableTableManager($_db, $_db.shopTags)
        .filter((f) => f.ticketId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_shopTagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TicketItemsTable, List<TicketItem>>
      _ticketItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.ticketItems,
              aliasName: 'tickets__id__ticket_items__ticket_id');

  $$TicketItemsTableProcessedTableManager get ticketItemsRefs {
    final manager = $$TicketItemsTableTableManager($_db, $_db.ticketItems)
        .filter((f) => f.ticketId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ticketItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TicketPhotosTable, List<TicketPhoto>>
      _ticketPhotosRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.ticketPhotos,
              aliasName: 'tickets__id__ticket_photos__ticket_id');

  $$TicketPhotosTableProcessedTableManager get ticketPhotosRefs {
    final manager = $$TicketPhotosTableTableManager($_db, $_db.ticketPhotos)
        .filter((f) => f.ticketId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ticketPhotosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TicketPhotoSlotsTable, List<TicketPhotoSlot>>
      _ticketPhotoSlotsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.ticketPhotoSlots,
              aliasName: 'tickets__id__ticket_photo_slots__ticket_id');

  $$TicketPhotoSlotsTableProcessedTableManager get ticketPhotoSlotsRefs {
    final manager =
        $$TicketPhotoSlotsTableTableManager($_db, $_db.ticketPhotoSlots)
            .filter((f) => f.ticketId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_ticketPhotoSlotsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TicketReportsTable, List<TicketReport>>
      _ticketReportsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.ticketReports,
              aliasName: 'tickets__id__ticket_reports__ticket_id');

  $$TicketReportsTableProcessedTableManager get ticketReportsRefs {
    final manager = $$TicketReportsTableTableManager($_db, $_db.ticketReports)
        .filter((f) => f.ticketId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ticketReportsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PartMovementsTable, List<PartMovement>>
      _partMovementsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.partMovements,
              aliasName: 'tickets__id__part_movements__ticket_id');

  $$PartMovementsTableProcessedTableManager get partMovementsRefs {
    final manager = $$PartMovementsTableTableManager($_db, $_db.partMovements)
        .filter((f) => f.ticketId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_partMovementsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PaymentsTable, List<Payment>> _paymentsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.payments,
          aliasName: 'tickets__id__payments__ticket_id');

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager($_db, $_db.payments)
        .filter((f) => f.ticketId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TicketsTableFilterComposer
    extends Composer<_$AppDatabase, $TicketsTable> {
  $$TicketsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceName => $composableBuilder(
      column: $table.deviceName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceVariant => $composableBuilder(
      column: $table.deviceVariant, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceSide => $composableBuilder(
      column: $table.deviceSide, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serial => $composableBuilder(
      column: $table.serial, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get serialMissing => $composableBuilder(
      column: $table.serialMissing, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shopTag => $composableBuilder(
      column: $table.shopTag, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get complaint => $composableBuilder(
      column: $table.complaint, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get diagnosis => $composableBuilder(
      column: $table.diagnosis, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get intakeNotes => $composableBuilder(
      column: $table.intakeNotes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get report1CompletedAt => $composableBuilder(
      column: $table.report1CompletedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get report2CompletedAt => $composableBuilder(
      column: $table.report2CompletedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get report3CompletedAt => $composableBuilder(
      column: $table.report3CompletedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dropOffAt => $composableBuilder(
      column: $table.dropOffAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get technicianStartAt => $composableBuilder(
      column: $table.technicianStartAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get partsArriveAt => $composableBuilder(
      column: $table.partsArriveAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get customerContactedAt => $composableBuilder(
      column: $table.customerContactedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoTemplateKey => $composableBuilder(
      column: $table.photoTemplateKey,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<TicketStatus, TicketStatus, int> get status =>
      $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get estimateCents => $composableBuilder(
      column: $table.estimateCents, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<InvoiceDiscountKind, InvoiceDiscountKind, int>
      get invoiceDiscountKind => $composableBuilder(
          column: $table.invoiceDiscountKind,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get invoiceDiscountValue => $composableBuilder(
      column: $table.invoiceDiscountValue,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partnerName => $composableBuilder(
      column: $table.partnerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get partnerPartsPercent => $composableBuilder(
      column: $table.partnerPartsPercent,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get partnerLabourPercent => $composableBuilder(
      column: $table.partnerLabourPercent,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gstCents => $composableBuilder(
      column: $table.gstCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pstCents => $composableBuilder(
      column: $table.pstCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
      column: $table.dueAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get pickedUpAt => $composableBuilder(
      column: $table.pickedUpAt, builder: (column) => ColumnFilters(column));

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.customerId,
        referencedTable: $db.customers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomersTableFilterComposer(
              $db: $db,
              $table: $db.customers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CustomerDevicesTableFilterComposer get customerDeviceId {
    final $$CustomerDevicesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.customerDeviceId,
        referencedTable: $db.customerDevices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomerDevicesTableFilterComposer(
              $db: $db,
              $table: $db.customerDevices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$DeviceModelsTableFilterComposer get deviceModelId {
    final $$DeviceModelsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.deviceModelId,
        referencedTable: $db.deviceModels,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeviceModelsTableFilterComposer(
              $db: $db,
              $table: $db.deviceModels,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> shopTagsRefs(
      Expression<bool> Function($$ShopTagsTableFilterComposer f) f) {
    final $$ShopTagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.shopTags,
        getReferencedColumn: (t) => t.ticketId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ShopTagsTableFilterComposer(
              $db: $db,
              $table: $db.shopTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> ticketItemsRefs(
      Expression<bool> Function($$TicketItemsTableFilterComposer f) f) {
    final $$TicketItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.ticketItems,
        getReferencedColumn: (t) => t.ticketId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketItemsTableFilterComposer(
              $db: $db,
              $table: $db.ticketItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> ticketPhotosRefs(
      Expression<bool> Function($$TicketPhotosTableFilterComposer f) f) {
    final $$TicketPhotosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.ticketPhotos,
        getReferencedColumn: (t) => t.ticketId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketPhotosTableFilterComposer(
              $db: $db,
              $table: $db.ticketPhotos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> ticketPhotoSlotsRefs(
      Expression<bool> Function($$TicketPhotoSlotsTableFilterComposer f) f) {
    final $$TicketPhotoSlotsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.ticketPhotoSlots,
        getReferencedColumn: (t) => t.ticketId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketPhotoSlotsTableFilterComposer(
              $db: $db,
              $table: $db.ticketPhotoSlots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> ticketReportsRefs(
      Expression<bool> Function($$TicketReportsTableFilterComposer f) f) {
    final $$TicketReportsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.ticketReports,
        getReferencedColumn: (t) => t.ticketId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketReportsTableFilterComposer(
              $db: $db,
              $table: $db.ticketReports,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> partMovementsRefs(
      Expression<bool> Function($$PartMovementsTableFilterComposer f) f) {
    final $$PartMovementsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.partMovements,
        getReferencedColumn: (t) => t.ticketId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PartMovementsTableFilterComposer(
              $db: $db,
              $table: $db.partMovements,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> paymentsRefs(
      Expression<bool> Function($$PaymentsTableFilterComposer f) f) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.payments,
        getReferencedColumn: (t) => t.ticketId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentsTableFilterComposer(
              $db: $db,
              $table: $db.payments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TicketsTableOrderingComposer
    extends Composer<_$AppDatabase, $TicketsTable> {
  $$TicketsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceName => $composableBuilder(
      column: $table.deviceName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceVariant => $composableBuilder(
      column: $table.deviceVariant,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceSide => $composableBuilder(
      column: $table.deviceSide, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serial => $composableBuilder(
      column: $table.serial, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get serialMissing => $composableBuilder(
      column: $table.serialMissing,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shopTag => $composableBuilder(
      column: $table.shopTag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get complaint => $composableBuilder(
      column: $table.complaint, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get diagnosis => $composableBuilder(
      column: $table.diagnosis, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get intakeNotes => $composableBuilder(
      column: $table.intakeNotes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get report1CompletedAt => $composableBuilder(
      column: $table.report1CompletedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get report2CompletedAt => $composableBuilder(
      column: $table.report2CompletedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get report3CompletedAt => $composableBuilder(
      column: $table.report3CompletedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dropOffAt => $composableBuilder(
      column: $table.dropOffAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get technicianStartAt => $composableBuilder(
      column: $table.technicianStartAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get partsArriveAt => $composableBuilder(
      column: $table.partsArriveAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get customerContactedAt => $composableBuilder(
      column: $table.customerContactedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoTemplateKey => $composableBuilder(
      column: $table.photoTemplateKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get estimateCents => $composableBuilder(
      column: $table.estimateCents,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get invoiceDiscountKind => $composableBuilder(
      column: $table.invoiceDiscountKind,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get invoiceDiscountValue => $composableBuilder(
      column: $table.invoiceDiscountValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partnerName => $composableBuilder(
      column: $table.partnerName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get partnerPartsPercent => $composableBuilder(
      column: $table.partnerPartsPercent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get partnerLabourPercent => $composableBuilder(
      column: $table.partnerLabourPercent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gstCents => $composableBuilder(
      column: $table.gstCents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pstCents => $composableBuilder(
      column: $table.pstCents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
      column: $table.dueAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get pickedUpAt => $composableBuilder(
      column: $table.pickedUpAt, builder: (column) => ColumnOrderings(column));

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.customerId,
        referencedTable: $db.customers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomersTableOrderingComposer(
              $db: $db,
              $table: $db.customers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CustomerDevicesTableOrderingComposer get customerDeviceId {
    final $$CustomerDevicesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.customerDeviceId,
        referencedTable: $db.customerDevices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomerDevicesTableOrderingComposer(
              $db: $db,
              $table: $db.customerDevices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$DeviceModelsTableOrderingComposer get deviceModelId {
    final $$DeviceModelsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.deviceModelId,
        referencedTable: $db.deviceModels,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeviceModelsTableOrderingComposer(
              $db: $db,
              $table: $db.deviceModels,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TicketsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TicketsTable> {
  $$TicketsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get deviceName => $composableBuilder(
      column: $table.deviceName, builder: (column) => column);

  GeneratedColumn<String> get deviceVariant => $composableBuilder(
      column: $table.deviceVariant, builder: (column) => column);

  GeneratedColumn<String> get deviceSide => $composableBuilder(
      column: $table.deviceSide, builder: (column) => column);

  GeneratedColumn<String> get serial =>
      $composableBuilder(column: $table.serial, builder: (column) => column);

  GeneratedColumn<bool> get serialMissing => $composableBuilder(
      column: $table.serialMissing, builder: (column) => column);

  GeneratedColumn<String> get shopTag =>
      $composableBuilder(column: $table.shopTag, builder: (column) => column);

  GeneratedColumn<String> get complaint =>
      $composableBuilder(column: $table.complaint, builder: (column) => column);

  GeneratedColumn<String> get diagnosis =>
      $composableBuilder(column: $table.diagnosis, builder: (column) => column);

  GeneratedColumn<String> get intakeNotes => $composableBuilder(
      column: $table.intakeNotes, builder: (column) => column);

  GeneratedColumn<DateTime> get report1CompletedAt => $composableBuilder(
      column: $table.report1CompletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get report2CompletedAt => $composableBuilder(
      column: $table.report2CompletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get report3CompletedAt => $composableBuilder(
      column: $table.report3CompletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get dropOffAt =>
      $composableBuilder(column: $table.dropOffAt, builder: (column) => column);

  GeneratedColumn<DateTime> get technicianStartAt => $composableBuilder(
      column: $table.technicianStartAt, builder: (column) => column);

  GeneratedColumn<DateTime> get partsArriveAt => $composableBuilder(
      column: $table.partsArriveAt, builder: (column) => column);

  GeneratedColumn<DateTime> get customerContactedAt => $composableBuilder(
      column: $table.customerContactedAt, builder: (column) => column);

  GeneratedColumn<String> get photoTemplateKey => $composableBuilder(
      column: $table.photoTemplateKey, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TicketStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get estimateCents => $composableBuilder(
      column: $table.estimateCents, builder: (column) => column);

  GeneratedColumnWithTypeConverter<InvoiceDiscountKind, int>
      get invoiceDiscountKind => $composableBuilder(
          column: $table.invoiceDiscountKind, builder: (column) => column);

  GeneratedColumn<int> get invoiceDiscountValue => $composableBuilder(
      column: $table.invoiceDiscountValue, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get partnerName => $composableBuilder(
      column: $table.partnerName, builder: (column) => column);

  GeneratedColumn<int> get partnerPartsPercent => $composableBuilder(
      column: $table.partnerPartsPercent, builder: (column) => column);

  GeneratedColumn<int> get partnerLabourPercent => $composableBuilder(
      column: $table.partnerLabourPercent, builder: (column) => column);

  GeneratedColumn<int> get gstCents =>
      $composableBuilder(column: $table.gstCents, builder: (column) => column);

  GeneratedColumn<int> get pstCents =>
      $composableBuilder(column: $table.pstCents, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get pickedUpAt => $composableBuilder(
      column: $table.pickedUpAt, builder: (column) => column);

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.customerId,
        referencedTable: $db.customers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomersTableAnnotationComposer(
              $db: $db,
              $table: $db.customers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CustomerDevicesTableAnnotationComposer get customerDeviceId {
    final $$CustomerDevicesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.customerDeviceId,
        referencedTable: $db.customerDevices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomerDevicesTableAnnotationComposer(
              $db: $db,
              $table: $db.customerDevices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$DeviceModelsTableAnnotationComposer get deviceModelId {
    final $$DeviceModelsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.deviceModelId,
        referencedTable: $db.deviceModels,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeviceModelsTableAnnotationComposer(
              $db: $db,
              $table: $db.deviceModels,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> shopTagsRefs<T extends Object>(
      Expression<T> Function($$ShopTagsTableAnnotationComposer a) f) {
    final $$ShopTagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.shopTags,
        getReferencedColumn: (t) => t.ticketId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ShopTagsTableAnnotationComposer(
              $db: $db,
              $table: $db.shopTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> ticketItemsRefs<T extends Object>(
      Expression<T> Function($$TicketItemsTableAnnotationComposer a) f) {
    final $$TicketItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.ticketItems,
        getReferencedColumn: (t) => t.ticketId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.ticketItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> ticketPhotosRefs<T extends Object>(
      Expression<T> Function($$TicketPhotosTableAnnotationComposer a) f) {
    final $$TicketPhotosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.ticketPhotos,
        getReferencedColumn: (t) => t.ticketId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketPhotosTableAnnotationComposer(
              $db: $db,
              $table: $db.ticketPhotos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> ticketPhotoSlotsRefs<T extends Object>(
      Expression<T> Function($$TicketPhotoSlotsTableAnnotationComposer a) f) {
    final $$TicketPhotoSlotsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.ticketPhotoSlots,
        getReferencedColumn: (t) => t.ticketId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketPhotoSlotsTableAnnotationComposer(
              $db: $db,
              $table: $db.ticketPhotoSlots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> ticketReportsRefs<T extends Object>(
      Expression<T> Function($$TicketReportsTableAnnotationComposer a) f) {
    final $$TicketReportsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.ticketReports,
        getReferencedColumn: (t) => t.ticketId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketReportsTableAnnotationComposer(
              $db: $db,
              $table: $db.ticketReports,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> partMovementsRefs<T extends Object>(
      Expression<T> Function($$PartMovementsTableAnnotationComposer a) f) {
    final $$PartMovementsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.partMovements,
        getReferencedColumn: (t) => t.ticketId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PartMovementsTableAnnotationComposer(
              $db: $db,
              $table: $db.partMovements,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> paymentsRefs<T extends Object>(
      Expression<T> Function($$PaymentsTableAnnotationComposer a) f) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.payments,
        getReferencedColumn: (t) => t.ticketId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentsTableAnnotationComposer(
              $db: $db,
              $table: $db.payments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TicketsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TicketsTable,
    Ticket,
    $$TicketsTableFilterComposer,
    $$TicketsTableOrderingComposer,
    $$TicketsTableAnnotationComposer,
    $$TicketsTableCreateCompanionBuilder,
    $$TicketsTableUpdateCompanionBuilder,
    (Ticket, $$TicketsTableReferences),
    Ticket,
    PrefetchHooks Function(
        {bool customerId,
        bool customerDeviceId,
        bool deviceModelId,
        bool shopTagsRefs,
        bool ticketItemsRefs,
        bool ticketPhotosRefs,
        bool ticketPhotoSlotsRefs,
        bool ticketReportsRefs,
        bool partMovementsRefs,
        bool paymentsRefs})> {
  $$TicketsTableTableManager(_$AppDatabase db, $TicketsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TicketsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TicketsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TicketsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> number = const Value.absent(),
            Value<int> customerId = const Value.absent(),
            Value<int?> customerDeviceId = const Value.absent(),
            Value<int?> deviceModelId = const Value.absent(),
            Value<String?> deviceName = const Value.absent(),
            Value<String?> deviceVariant = const Value.absent(),
            Value<String?> deviceSide = const Value.absent(),
            Value<String?> serial = const Value.absent(),
            Value<bool> serialMissing = const Value.absent(),
            Value<String?> shopTag = const Value.absent(),
            Value<String> complaint = const Value.absent(),
            Value<String?> diagnosis = const Value.absent(),
            Value<String?> intakeNotes = const Value.absent(),
            Value<DateTime?> report1CompletedAt = const Value.absent(),
            Value<DateTime?> report2CompletedAt = const Value.absent(),
            Value<DateTime?> report3CompletedAt = const Value.absent(),
            Value<DateTime?> dropOffAt = const Value.absent(),
            Value<DateTime?> technicianStartAt = const Value.absent(),
            Value<DateTime?> partsArriveAt = const Value.absent(),
            Value<DateTime?> customerContactedAt = const Value.absent(),
            Value<String?> photoTemplateKey = const Value.absent(),
            Value<TicketStatus> status = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<int> estimateCents = const Value.absent(),
            Value<InvoiceDiscountKind> invoiceDiscountKind =
                const Value.absent(),
            Value<int> invoiceDiscountValue = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> partnerName = const Value.absent(),
            Value<int> partnerPartsPercent = const Value.absent(),
            Value<int> partnerLabourPercent = const Value.absent(),
            Value<int> gstCents = const Value.absent(),
            Value<int> pstCents = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> dueAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime?> pickedUpAt = const Value.absent(),
          }) =>
              TicketsCompanion(
            id: id,
            number: number,
            customerId: customerId,
            customerDeviceId: customerDeviceId,
            deviceModelId: deviceModelId,
            deviceName: deviceName,
            deviceVariant: deviceVariant,
            deviceSide: deviceSide,
            serial: serial,
            serialMissing: serialMissing,
            shopTag: shopTag,
            complaint: complaint,
            diagnosis: diagnosis,
            intakeNotes: intakeNotes,
            report1CompletedAt: report1CompletedAt,
            report2CompletedAt: report2CompletedAt,
            report3CompletedAt: report3CompletedAt,
            dropOffAt: dropOffAt,
            technicianStartAt: technicianStartAt,
            partsArriveAt: partsArriveAt,
            customerContactedAt: customerContactedAt,
            photoTemplateKey: photoTemplateKey,
            status: status,
            priority: priority,
            estimateCents: estimateCents,
            invoiceDiscountKind: invoiceDiscountKind,
            invoiceDiscountValue: invoiceDiscountValue,
            notes: notes,
            partnerName: partnerName,
            partnerPartsPercent: partnerPartsPercent,
            partnerLabourPercent: partnerLabourPercent,
            gstCents: gstCents,
            pstCents: pstCents,
            createdAt: createdAt,
            updatedAt: updatedAt,
            dueAt: dueAt,
            completedAt: completedAt,
            pickedUpAt: pickedUpAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String number,
            required int customerId,
            Value<int?> customerDeviceId = const Value.absent(),
            Value<int?> deviceModelId = const Value.absent(),
            Value<String?> deviceName = const Value.absent(),
            Value<String?> deviceVariant = const Value.absent(),
            Value<String?> deviceSide = const Value.absent(),
            Value<String?> serial = const Value.absent(),
            Value<bool> serialMissing = const Value.absent(),
            Value<String?> shopTag = const Value.absent(),
            required String complaint,
            Value<String?> diagnosis = const Value.absent(),
            Value<String?> intakeNotes = const Value.absent(),
            Value<DateTime?> report1CompletedAt = const Value.absent(),
            Value<DateTime?> report2CompletedAt = const Value.absent(),
            Value<DateTime?> report3CompletedAt = const Value.absent(),
            Value<DateTime?> dropOffAt = const Value.absent(),
            Value<DateTime?> technicianStartAt = const Value.absent(),
            Value<DateTime?> partsArriveAt = const Value.absent(),
            Value<DateTime?> customerContactedAt = const Value.absent(),
            Value<String?> photoTemplateKey = const Value.absent(),
            required TicketStatus status,
            Value<int> priority = const Value.absent(),
            Value<int> estimateCents = const Value.absent(),
            Value<InvoiceDiscountKind> invoiceDiscountKind =
                const Value.absent(),
            Value<int> invoiceDiscountValue = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> partnerName = const Value.absent(),
            Value<int> partnerPartsPercent = const Value.absent(),
            Value<int> partnerLabourPercent = const Value.absent(),
            Value<int> gstCents = const Value.absent(),
            Value<int> pstCents = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> dueAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime?> pickedUpAt = const Value.absent(),
          }) =>
              TicketsCompanion.insert(
            id: id,
            number: number,
            customerId: customerId,
            customerDeviceId: customerDeviceId,
            deviceModelId: deviceModelId,
            deviceName: deviceName,
            deviceVariant: deviceVariant,
            deviceSide: deviceSide,
            serial: serial,
            serialMissing: serialMissing,
            shopTag: shopTag,
            complaint: complaint,
            diagnosis: diagnosis,
            intakeNotes: intakeNotes,
            report1CompletedAt: report1CompletedAt,
            report2CompletedAt: report2CompletedAt,
            report3CompletedAt: report3CompletedAt,
            dropOffAt: dropOffAt,
            technicianStartAt: technicianStartAt,
            partsArriveAt: partsArriveAt,
            customerContactedAt: customerContactedAt,
            photoTemplateKey: photoTemplateKey,
            status: status,
            priority: priority,
            estimateCents: estimateCents,
            invoiceDiscountKind: invoiceDiscountKind,
            invoiceDiscountValue: invoiceDiscountValue,
            notes: notes,
            partnerName: partnerName,
            partnerPartsPercent: partnerPartsPercent,
            partnerLabourPercent: partnerLabourPercent,
            gstCents: gstCents,
            pstCents: pstCents,
            createdAt: createdAt,
            updatedAt: updatedAt,
            dueAt: dueAt,
            completedAt: completedAt,
            pickedUpAt: pickedUpAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$TicketsTable, Ticket>(table),
                    $$TicketsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {customerId = false,
              customerDeviceId = false,
              deviceModelId = false,
              shopTagsRefs = false,
              ticketItemsRefs = false,
              ticketPhotosRefs = false,
              ticketPhotoSlotsRefs = false,
              ticketReportsRefs = false,
              partMovementsRefs = false,
              paymentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (shopTagsRefs) db.shopTags,
                if (ticketItemsRefs) db.ticketItems,
                if (ticketPhotosRefs) db.ticketPhotos,
                if (ticketPhotoSlotsRefs) db.ticketPhotoSlots,
                if (ticketReportsRefs) db.ticketReports,
                if (partMovementsRefs) db.partMovements,
                if (paymentsRefs) db.payments
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (customerId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.customerId,
                    referencedTable:
                        $$TicketsTableReferences._customerIdTable(db),
                    referencedColumn:
                        $$TicketsTableReferences._customerIdTable(db).id,
                  ) as T;
                }
                if (customerDeviceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.customerDeviceId,
                    referencedTable:
                        $$TicketsTableReferences._customerDeviceIdTable(db),
                    referencedColumn:
                        $$TicketsTableReferences._customerDeviceIdTable(db).id,
                  ) as T;
                }
                if (deviceModelId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.deviceModelId,
                    referencedTable:
                        $$TicketsTableReferences._deviceModelIdTable(db),
                    referencedColumn:
                        $$TicketsTableReferences._deviceModelIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (shopTagsRefs)
                    await $_getPrefetchedDataByColumns<Ticket, $TicketsTable,
                            ShopTag, $ShopTagsTable>(
                        currentTable: table,
                        referencedTable:
                            $$TicketsTableReferences._shopTagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TicketsTableReferences(db, table, p0)
                                .shopTagsRefs,
                        currentColumn: 'id',
                        referencedColumn: 'ticket_id',
                        typedResults: items),
                  if (ticketItemsRefs)
                    await $_getPrefetchedDataByColumns<Ticket, $TicketsTable,
                            TicketItem, $TicketItemsTable>(
                        currentTable: table,
                        referencedTable:
                            $$TicketsTableReferences._ticketItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TicketsTableReferences(db, table, p0)
                                .ticketItemsRefs,
                        currentColumn: 'id',
                        referencedColumn: 'ticket_id',
                        typedResults: items),
                  if (ticketPhotosRefs)
                    await $_getPrefetchedDataByColumns<Ticket, $TicketsTable,
                            TicketPhoto, $TicketPhotosTable>(
                        currentTable: table,
                        referencedTable:
                            $$TicketsTableReferences._ticketPhotosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TicketsTableReferences(db, table, p0)
                                .ticketPhotosRefs,
                        currentColumn: 'id',
                        referencedColumn: 'ticket_id',
                        typedResults: items),
                  if (ticketPhotoSlotsRefs)
                    await $_getPrefetchedDataByColumns<Ticket, $TicketsTable,
                            TicketPhotoSlot, $TicketPhotoSlotsTable>(
                        currentTable: table,
                        referencedTable: $$TicketsTableReferences
                            ._ticketPhotoSlotsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TicketsTableReferences(db, table, p0)
                                .ticketPhotoSlotsRefs,
                        currentColumn: 'id',
                        referencedColumn: 'ticket_id',
                        typedResults: items),
                  if (ticketReportsRefs)
                    await $_getPrefetchedDataByColumns<Ticket, $TicketsTable,
                            TicketReport, $TicketReportsTable>(
                        currentTable: table,
                        referencedTable: $$TicketsTableReferences
                            ._ticketReportsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TicketsTableReferences(db, table, p0)
                                .ticketReportsRefs,
                        currentColumn: 'id',
                        referencedColumn: 'ticket_id',
                        typedResults: items),
                  if (partMovementsRefs)
                    await $_getPrefetchedDataByColumns<Ticket, $TicketsTable,
                            PartMovement, $PartMovementsTable>(
                        currentTable: table,
                        referencedTable: $$TicketsTableReferences
                            ._partMovementsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TicketsTableReferences(db, table, p0)
                                .partMovementsRefs,
                        currentColumn: 'id',
                        referencedColumn: 'ticket_id',
                        typedResults: items),
                  if (paymentsRefs)
                    await $_getPrefetchedDataByColumns<Ticket, $TicketsTable,
                            Payment, $PaymentsTable>(
                        currentTable: table,
                        referencedTable:
                            $$TicketsTableReferences._paymentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TicketsTableReferences(db, table, p0)
                                .paymentsRefs,
                        currentColumn: 'id',
                        referencedColumn: 'ticket_id',
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TicketsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TicketsTable,
    Ticket,
    $$TicketsTableFilterComposer,
    $$TicketsTableOrderingComposer,
    $$TicketsTableAnnotationComposer,
    $$TicketsTableCreateCompanionBuilder,
    $$TicketsTableUpdateCompanionBuilder,
    (Ticket, $$TicketsTableReferences),
    Ticket,
    PrefetchHooks Function(
        {bool customerId,
        bool customerDeviceId,
        bool deviceModelId,
        bool shopTagsRefs,
        bool ticketItemsRefs,
        bool ticketPhotosRefs,
        bool ticketPhotoSlotsRefs,
        bool ticketReportsRefs,
        bool partMovementsRefs,
        bool paymentsRefs})>;
typedef $$ShopTagsTableCreateCompanionBuilder = ShopTagsCompanion Function({
  required String tag,
  Value<int?> ticketId,
  Value<DateTime> issuedAt,
  Value<DateTime?> retiredAt,
  Value<int> rowid,
});
typedef $$ShopTagsTableUpdateCompanionBuilder = ShopTagsCompanion Function({
  Value<String> tag,
  Value<int?> ticketId,
  Value<DateTime> issuedAt,
  Value<DateTime?> retiredAt,
  Value<int> rowid,
});

final class $$ShopTagsTableReferences
    extends BaseReferences<_$AppDatabase, $ShopTagsTable, ShopTag> {
  $$ShopTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TicketsTable _ticketIdTable(_$AppDatabase db) =>
      db.tickets.createAlias('shop_tags__ticket_id__tickets__id');

  $$TicketsTableProcessedTableManager? get ticketId {
    final $_column = $_itemColumn<int>('ticket_id');
    if ($_column == null) return null;
    final manager = $$TicketsTableTableManager($_db, $_db.tickets)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ticketIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ShopTagsTableFilterComposer
    extends Composer<_$AppDatabase, $ShopTagsTable> {
  $$ShopTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tag => $composableBuilder(
      column: $table.tag, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get issuedAt => $composableBuilder(
      column: $table.issuedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get retiredAt => $composableBuilder(
      column: $table.retiredAt, builder: (column) => ColumnFilters(column));

  $$TicketsTableFilterComposer get ticketId {
    final $$TicketsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ticketId,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableFilterComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ShopTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShopTagsTable> {
  $$ShopTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tag => $composableBuilder(
      column: $table.tag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get issuedAt => $composableBuilder(
      column: $table.issuedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get retiredAt => $composableBuilder(
      column: $table.retiredAt, builder: (column) => ColumnOrderings(column));

  $$TicketsTableOrderingComposer get ticketId {
    final $$TicketsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ticketId,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableOrderingComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ShopTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShopTagsTable> {
  $$ShopTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  GeneratedColumn<DateTime> get issuedAt =>
      $composableBuilder(column: $table.issuedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get retiredAt =>
      $composableBuilder(column: $table.retiredAt, builder: (column) => column);

  $$TicketsTableAnnotationComposer get ticketId {
    final $$TicketsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ticketId,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableAnnotationComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ShopTagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ShopTagsTable,
    ShopTag,
    $$ShopTagsTableFilterComposer,
    $$ShopTagsTableOrderingComposer,
    $$ShopTagsTableAnnotationComposer,
    $$ShopTagsTableCreateCompanionBuilder,
    $$ShopTagsTableUpdateCompanionBuilder,
    (ShopTag, $$ShopTagsTableReferences),
    ShopTag,
    PrefetchHooks Function({bool ticketId})> {
  $$ShopTagsTableTableManager(_$AppDatabase db, $ShopTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShopTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShopTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShopTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> tag = const Value.absent(),
            Value<int?> ticketId = const Value.absent(),
            Value<DateTime> issuedAt = const Value.absent(),
            Value<DateTime?> retiredAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ShopTagsCompanion(
            tag: tag,
            ticketId: ticketId,
            issuedAt: issuedAt,
            retiredAt: retiredAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String tag,
            Value<int?> ticketId = const Value.absent(),
            Value<DateTime> issuedAt = const Value.absent(),
            Value<DateTime?> retiredAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ShopTagsCompanion.insert(
            tag: tag,
            ticketId: ticketId,
            issuedAt: issuedAt,
            retiredAt: retiredAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ShopTagsTable, ShopTag>(table),
                    $$ShopTagsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({ticketId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (ticketId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ticketId,
                    referencedTable:
                        $$ShopTagsTableReferences._ticketIdTable(db),
                    referencedColumn:
                        $$ShopTagsTableReferences._ticketIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ShopTagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ShopTagsTable,
    ShopTag,
    $$ShopTagsTableFilterComposer,
    $$ShopTagsTableOrderingComposer,
    $$ShopTagsTableAnnotationComposer,
    $$ShopTagsTableCreateCompanionBuilder,
    $$ShopTagsTableUpdateCompanionBuilder,
    (ShopTag, $$ShopTagsTableReferences),
    ShopTag,
    PrefetchHooks Function({bool ticketId})>;
typedef $$PartsTableCreateCompanionBuilder = PartsCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> description,
  Value<String?> sku,
  Value<String?> vendorId,
  Value<String?> vendorSku,
  Value<String?> brand,
  Value<String?> category,
  Value<String?> location,
  Value<int> stock,
  Value<int> costCents,
  Value<int> priceCents,
  Value<PartPurchaseType> purchaseType,
  Value<int> bulkQuantity,
  Value<int> bulkTotalCents,
  Value<bool> chargeShopSupply,
  Value<int> reorderLevel,
  Value<String?> supplier,
  Value<bool> isActive,
});
typedef $$PartsTableUpdateCompanionBuilder = PartsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> description,
  Value<String?> sku,
  Value<String?> vendorId,
  Value<String?> vendorSku,
  Value<String?> brand,
  Value<String?> category,
  Value<String?> location,
  Value<int> stock,
  Value<int> costCents,
  Value<int> priceCents,
  Value<PartPurchaseType> purchaseType,
  Value<int> bulkQuantity,
  Value<int> bulkTotalCents,
  Value<bool> chargeShopSupply,
  Value<int> reorderLevel,
  Value<String?> supplier,
  Value<bool> isActive,
});

final class $$PartsTableReferences
    extends BaseReferences<_$AppDatabase, $PartsTable, Part> {
  $$PartsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TicketItemsTable, List<TicketItem>>
      _ticketItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.ticketItems,
              aliasName: 'parts__id__ticket_items__part_id');

  $$TicketItemsTableProcessedTableManager get ticketItemsRefs {
    final manager = $$TicketItemsTableTableManager($_db, $_db.ticketItems)
        .filter((f) => f.partId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ticketItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PartMovementsTable, List<PartMovement>>
      _partMovementsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.partMovements,
              aliasName: 'parts__id__part_movements__part_id');

  $$PartMovementsTableProcessedTableManager get partMovementsRefs {
    final manager = $$PartMovementsTableTableManager($_db, $_db.partMovements)
        .filter((f) => f.partId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_partMovementsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PartsTableFilterComposer extends Composer<_$AppDatabase, $PartsTable> {
  $$PartsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vendorId => $composableBuilder(
      column: $table.vendorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vendorSku => $composableBuilder(
      column: $table.vendorSku, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get brand => $composableBuilder(
      column: $table.brand, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stock => $composableBuilder(
      column: $table.stock, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get costCents => $composableBuilder(
      column: $table.costCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priceCents => $composableBuilder(
      column: $table.priceCents, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<PartPurchaseType, PartPurchaseType, int>
      get purchaseType => $composableBuilder(
          column: $table.purchaseType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get bulkQuantity => $composableBuilder(
      column: $table.bulkQuantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bulkTotalCents => $composableBuilder(
      column: $table.bulkTotalCents,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get chargeShopSupply => $composableBuilder(
      column: $table.chargeShopSupply,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reorderLevel => $composableBuilder(
      column: $table.reorderLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supplier => $composableBuilder(
      column: $table.supplier, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  Expression<bool> ticketItemsRefs(
      Expression<bool> Function($$TicketItemsTableFilterComposer f) f) {
    final $$TicketItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.ticketItems,
        getReferencedColumn: (t) => t.partId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketItemsTableFilterComposer(
              $db: $db,
              $table: $db.ticketItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> partMovementsRefs(
      Expression<bool> Function($$PartMovementsTableFilterComposer f) f) {
    final $$PartMovementsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.partMovements,
        getReferencedColumn: (t) => t.partId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PartMovementsTableFilterComposer(
              $db: $db,
              $table: $db.partMovements,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PartsTableOrderingComposer
    extends Composer<_$AppDatabase, $PartsTable> {
  $$PartsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vendorId => $composableBuilder(
      column: $table.vendorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vendorSku => $composableBuilder(
      column: $table.vendorSku, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get brand => $composableBuilder(
      column: $table.brand, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stock => $composableBuilder(
      column: $table.stock, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get costCents => $composableBuilder(
      column: $table.costCents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priceCents => $composableBuilder(
      column: $table.priceCents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get purchaseType => $composableBuilder(
      column: $table.purchaseType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bulkQuantity => $composableBuilder(
      column: $table.bulkQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bulkTotalCents => $composableBuilder(
      column: $table.bulkTotalCents,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get chargeShopSupply => $composableBuilder(
      column: $table.chargeShopSupply,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reorderLevel => $composableBuilder(
      column: $table.reorderLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supplier => $composableBuilder(
      column: $table.supplier, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));
}

class $$PartsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartsTable> {
  $$PartsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get vendorId =>
      $composableBuilder(column: $table.vendorId, builder: (column) => column);

  GeneratedColumn<String> get vendorSku =>
      $composableBuilder(column: $table.vendorSku, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<int> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<int> get costCents =>
      $composableBuilder(column: $table.costCents, builder: (column) => column);

  GeneratedColumn<int> get priceCents => $composableBuilder(
      column: $table.priceCents, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PartPurchaseType, int> get purchaseType =>
      $composableBuilder(
          column: $table.purchaseType, builder: (column) => column);

  GeneratedColumn<int> get bulkQuantity => $composableBuilder(
      column: $table.bulkQuantity, builder: (column) => column);

  GeneratedColumn<int> get bulkTotalCents => $composableBuilder(
      column: $table.bulkTotalCents, builder: (column) => column);

  GeneratedColumn<bool> get chargeShopSupply => $composableBuilder(
      column: $table.chargeShopSupply, builder: (column) => column);

  GeneratedColumn<int> get reorderLevel => $composableBuilder(
      column: $table.reorderLevel, builder: (column) => column);

  GeneratedColumn<String> get supplier =>
      $composableBuilder(column: $table.supplier, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  Expression<T> ticketItemsRefs<T extends Object>(
      Expression<T> Function($$TicketItemsTableAnnotationComposer a) f) {
    final $$TicketItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.ticketItems,
        getReferencedColumn: (t) => t.partId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.ticketItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> partMovementsRefs<T extends Object>(
      Expression<T> Function($$PartMovementsTableAnnotationComposer a) f) {
    final $$PartMovementsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.partMovements,
        getReferencedColumn: (t) => t.partId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PartMovementsTableAnnotationComposer(
              $db: $db,
              $table: $db.partMovements,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PartsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PartsTable,
    Part,
    $$PartsTableFilterComposer,
    $$PartsTableOrderingComposer,
    $$PartsTableAnnotationComposer,
    $$PartsTableCreateCompanionBuilder,
    $$PartsTableUpdateCompanionBuilder,
    (Part, $$PartsTableReferences),
    Part,
    PrefetchHooks Function({bool ticketItemsRefs, bool partMovementsRefs})> {
  $$PartsTableTableManager(_$AppDatabase db, $PartsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> sku = const Value.absent(),
            Value<String?> vendorId = const Value.absent(),
            Value<String?> vendorSku = const Value.absent(),
            Value<String?> brand = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<int> stock = const Value.absent(),
            Value<int> costCents = const Value.absent(),
            Value<int> priceCents = const Value.absent(),
            Value<PartPurchaseType> purchaseType = const Value.absent(),
            Value<int> bulkQuantity = const Value.absent(),
            Value<int> bulkTotalCents = const Value.absent(),
            Value<bool> chargeShopSupply = const Value.absent(),
            Value<int> reorderLevel = const Value.absent(),
            Value<String?> supplier = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
          }) =>
              PartsCompanion(
            id: id,
            name: name,
            description: description,
            sku: sku,
            vendorId: vendorId,
            vendorSku: vendorSku,
            brand: brand,
            category: category,
            location: location,
            stock: stock,
            costCents: costCents,
            priceCents: priceCents,
            purchaseType: purchaseType,
            bulkQuantity: bulkQuantity,
            bulkTotalCents: bulkTotalCents,
            chargeShopSupply: chargeShopSupply,
            reorderLevel: reorderLevel,
            supplier: supplier,
            isActive: isActive,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> description = const Value.absent(),
            Value<String?> sku = const Value.absent(),
            Value<String?> vendorId = const Value.absent(),
            Value<String?> vendorSku = const Value.absent(),
            Value<String?> brand = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<int> stock = const Value.absent(),
            Value<int> costCents = const Value.absent(),
            Value<int> priceCents = const Value.absent(),
            Value<PartPurchaseType> purchaseType = const Value.absent(),
            Value<int> bulkQuantity = const Value.absent(),
            Value<int> bulkTotalCents = const Value.absent(),
            Value<bool> chargeShopSupply = const Value.absent(),
            Value<int> reorderLevel = const Value.absent(),
            Value<String?> supplier = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
          }) =>
              PartsCompanion.insert(
            id: id,
            name: name,
            description: description,
            sku: sku,
            vendorId: vendorId,
            vendorSku: vendorSku,
            brand: brand,
            category: category,
            location: location,
            stock: stock,
            costCents: costCents,
            priceCents: priceCents,
            purchaseType: purchaseType,
            bulkQuantity: bulkQuantity,
            bulkTotalCents: bulkTotalCents,
            chargeShopSupply: chargeShopSupply,
            reorderLevel: reorderLevel,
            supplier: supplier,
            isActive: isActive,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$PartsTable, Part>(table),
                    $$PartsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {ticketItemsRefs = false, partMovementsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (ticketItemsRefs) db.ticketItems,
                if (partMovementsRefs) db.partMovements
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ticketItemsRefs)
                    await $_getPrefetchedDataByColumns<Part, $PartsTable,
                            TicketItem, $TicketItemsTable>(
                        currentTable: table,
                        referencedTable:
                            $$PartsTableReferences._ticketItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PartsTableReferences(db, table, p0)
                                .ticketItemsRefs,
                        currentColumn: 'id',
                        referencedColumn: 'part_id',
                        typedResults: items),
                  if (partMovementsRefs)
                    await $_getPrefetchedDataByColumns<Part, $PartsTable,
                            PartMovement, $PartMovementsTable>(
                        currentTable: table,
                        referencedTable:
                            $$PartsTableReferences._partMovementsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PartsTableReferences(db, table, p0)
                                .partMovementsRefs,
                        currentColumn: 'id',
                        referencedColumn: 'part_id',
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PartsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PartsTable,
    Part,
    $$PartsTableFilterComposer,
    $$PartsTableOrderingComposer,
    $$PartsTableAnnotationComposer,
    $$PartsTableCreateCompanionBuilder,
    $$PartsTableUpdateCompanionBuilder,
    (Part, $$PartsTableReferences),
    Part,
    PrefetchHooks Function({bool ticketItemsRefs, bool partMovementsRefs})>;
typedef $$TicketItemsTableCreateCompanionBuilder = TicketItemsCompanion
    Function({
  Value<int> id,
  required int ticketId,
  required TicketItemKind kind,
  Value<int?> serviceId,
  Value<int?> partId,
  required String description,
  Value<int> quantity,
  Value<int> unitPriceCents,
  Value<int?> unitCostCents,
  Value<int> consumedQuantity,
});
typedef $$TicketItemsTableUpdateCompanionBuilder = TicketItemsCompanion
    Function({
  Value<int> id,
  Value<int> ticketId,
  Value<TicketItemKind> kind,
  Value<int?> serviceId,
  Value<int?> partId,
  Value<String> description,
  Value<int> quantity,
  Value<int> unitPriceCents,
  Value<int?> unitCostCents,
  Value<int> consumedQuantity,
});

final class $$TicketItemsTableReferences
    extends BaseReferences<_$AppDatabase, $TicketItemsTable, TicketItem> {
  $$TicketItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TicketsTable _ticketIdTable(_$AppDatabase db) =>
      db.tickets.createAlias('ticket_items__ticket_id__tickets__id');

  $$TicketsTableProcessedTableManager get ticketId {
    final $_column = $_itemColumn<int>('ticket_id')!;

    final manager = $$TicketsTableTableManager($_db, $_db.tickets)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ticketIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ServicesTable _serviceIdTable(_$AppDatabase db) =>
      db.services.createAlias('ticket_items__service_id__services__id');

  $$ServicesTableProcessedTableManager? get serviceId {
    final $_column = $_itemColumn<int>('service_id');
    if ($_column == null) return null;
    final manager = $$ServicesTableTableManager($_db, $_db.services)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_serviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $PartsTable _partIdTable(_$AppDatabase db) =>
      db.parts.createAlias('ticket_items__part_id__parts__id');

  $$PartsTableProcessedTableManager? get partId {
    final $_column = $_itemColumn<int>('part_id');
    if ($_column == null) return null;
    final manager = $$PartsTableTableManager($_db, $_db.parts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_partIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TicketItemsTableFilterComposer
    extends Composer<_$AppDatabase, $TicketItemsTable> {
  $$TicketItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<TicketItemKind, TicketItemKind, int>
      get kind => $composableBuilder(
          column: $table.kind,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unitPriceCents => $composableBuilder(
      column: $table.unitPriceCents,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unitCostCents => $composableBuilder(
      column: $table.unitCostCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get consumedQuantity => $composableBuilder(
      column: $table.consumedQuantity,
      builder: (column) => ColumnFilters(column));

  $$TicketsTableFilterComposer get ticketId {
    final $$TicketsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ticketId,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableFilterComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ServicesTableFilterComposer get serviceId {
    final $$ServicesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.serviceId,
        referencedTable: $db.services,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ServicesTableFilterComposer(
              $db: $db,
              $table: $db.services,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PartsTableFilterComposer get partId {
    final $$PartsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.partId,
        referencedTable: $db.parts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PartsTableFilterComposer(
              $db: $db,
              $table: $db.parts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TicketItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $TicketItemsTable> {
  $$TicketItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unitPriceCents => $composableBuilder(
      column: $table.unitPriceCents,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unitCostCents => $composableBuilder(
      column: $table.unitCostCents,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get consumedQuantity => $composableBuilder(
      column: $table.consumedQuantity,
      builder: (column) => ColumnOrderings(column));

  $$TicketsTableOrderingComposer get ticketId {
    final $$TicketsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ticketId,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableOrderingComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ServicesTableOrderingComposer get serviceId {
    final $$ServicesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.serviceId,
        referencedTable: $db.services,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ServicesTableOrderingComposer(
              $db: $db,
              $table: $db.services,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PartsTableOrderingComposer get partId {
    final $$PartsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.partId,
        referencedTable: $db.parts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PartsTableOrderingComposer(
              $db: $db,
              $table: $db.parts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TicketItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TicketItemsTable> {
  $$TicketItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TicketItemKind, int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get unitPriceCents => $composableBuilder(
      column: $table.unitPriceCents, builder: (column) => column);

  GeneratedColumn<int> get unitCostCents => $composableBuilder(
      column: $table.unitCostCents, builder: (column) => column);

  GeneratedColumn<int> get consumedQuantity => $composableBuilder(
      column: $table.consumedQuantity, builder: (column) => column);

  $$TicketsTableAnnotationComposer get ticketId {
    final $$TicketsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ticketId,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableAnnotationComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ServicesTableAnnotationComposer get serviceId {
    final $$ServicesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.serviceId,
        referencedTable: $db.services,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ServicesTableAnnotationComposer(
              $db: $db,
              $table: $db.services,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PartsTableAnnotationComposer get partId {
    final $$PartsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.partId,
        referencedTable: $db.parts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PartsTableAnnotationComposer(
              $db: $db,
              $table: $db.parts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TicketItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TicketItemsTable,
    TicketItem,
    $$TicketItemsTableFilterComposer,
    $$TicketItemsTableOrderingComposer,
    $$TicketItemsTableAnnotationComposer,
    $$TicketItemsTableCreateCompanionBuilder,
    $$TicketItemsTableUpdateCompanionBuilder,
    (TicketItem, $$TicketItemsTableReferences),
    TicketItem,
    PrefetchHooks Function({bool ticketId, bool serviceId, bool partId})> {
  $$TicketItemsTableTableManager(_$AppDatabase db, $TicketItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TicketItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TicketItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TicketItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> ticketId = const Value.absent(),
            Value<TicketItemKind> kind = const Value.absent(),
            Value<int?> serviceId = const Value.absent(),
            Value<int?> partId = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<int> unitPriceCents = const Value.absent(),
            Value<int?> unitCostCents = const Value.absent(),
            Value<int> consumedQuantity = const Value.absent(),
          }) =>
              TicketItemsCompanion(
            id: id,
            ticketId: ticketId,
            kind: kind,
            serviceId: serviceId,
            partId: partId,
            description: description,
            quantity: quantity,
            unitPriceCents: unitPriceCents,
            unitCostCents: unitCostCents,
            consumedQuantity: consumedQuantity,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int ticketId,
            required TicketItemKind kind,
            Value<int?> serviceId = const Value.absent(),
            Value<int?> partId = const Value.absent(),
            required String description,
            Value<int> quantity = const Value.absent(),
            Value<int> unitPriceCents = const Value.absent(),
            Value<int?> unitCostCents = const Value.absent(),
            Value<int> consumedQuantity = const Value.absent(),
          }) =>
              TicketItemsCompanion.insert(
            id: id,
            ticketId: ticketId,
            kind: kind,
            serviceId: serviceId,
            partId: partId,
            description: description,
            quantity: quantity,
            unitPriceCents: unitPriceCents,
            unitCostCents: unitCostCents,
            consumedQuantity: consumedQuantity,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$TicketItemsTable, TicketItem>(table),
                    $$TicketItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {ticketId = false, serviceId = false, partId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (ticketId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ticketId,
                    referencedTable:
                        $$TicketItemsTableReferences._ticketIdTable(db),
                    referencedColumn:
                        $$TicketItemsTableReferences._ticketIdTable(db).id,
                  ) as T;
                }
                if (serviceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.serviceId,
                    referencedTable:
                        $$TicketItemsTableReferences._serviceIdTable(db),
                    referencedColumn:
                        $$TicketItemsTableReferences._serviceIdTable(db).id,
                  ) as T;
                }
                if (partId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.partId,
                    referencedTable:
                        $$TicketItemsTableReferences._partIdTable(db),
                    referencedColumn:
                        $$TicketItemsTableReferences._partIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TicketItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TicketItemsTable,
    TicketItem,
    $$TicketItemsTableFilterComposer,
    $$TicketItemsTableOrderingComposer,
    $$TicketItemsTableAnnotationComposer,
    $$TicketItemsTableCreateCompanionBuilder,
    $$TicketItemsTableUpdateCompanionBuilder,
    (TicketItem, $$TicketItemsTableReferences),
    TicketItem,
    PrefetchHooks Function({bool ticketId, bool serviceId, bool partId})>;
typedef $$TicketPhotosTableCreateCompanionBuilder = TicketPhotosCompanion
    Function({
  Value<int> id,
  required int ticketId,
  required PhotoSlot slot,
  Value<PhotoStage> stage,
  required String path,
  Value<String?> caption,
  Value<bool> visibleToClient,
  Value<DateTime> takenAt,
});
typedef $$TicketPhotosTableUpdateCompanionBuilder = TicketPhotosCompanion
    Function({
  Value<int> id,
  Value<int> ticketId,
  Value<PhotoSlot> slot,
  Value<PhotoStage> stage,
  Value<String> path,
  Value<String?> caption,
  Value<bool> visibleToClient,
  Value<DateTime> takenAt,
});

final class $$TicketPhotosTableReferences
    extends BaseReferences<_$AppDatabase, $TicketPhotosTable, TicketPhoto> {
  $$TicketPhotosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TicketsTable _ticketIdTable(_$AppDatabase db) =>
      db.tickets.createAlias('ticket_photos__ticket_id__tickets__id');

  $$TicketsTableProcessedTableManager get ticketId {
    final $_column = $_itemColumn<int>('ticket_id')!;

    final manager = $$TicketsTableTableManager($_db, $_db.tickets)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ticketIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TicketPhotosTableFilterComposer
    extends Composer<_$AppDatabase, $TicketPhotosTable> {
  $$TicketPhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<PhotoSlot, PhotoSlot, int> get slot =>
      $composableBuilder(
          column: $table.slot,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<PhotoStage, PhotoStage, int> get stage =>
      $composableBuilder(
          column: $table.stage,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get caption => $composableBuilder(
      column: $table.caption, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get visibleToClient => $composableBuilder(
      column: $table.visibleToClient,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get takenAt => $composableBuilder(
      column: $table.takenAt, builder: (column) => ColumnFilters(column));

  $$TicketsTableFilterComposer get ticketId {
    final $$TicketsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ticketId,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableFilterComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TicketPhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $TicketPhotosTable> {
  $$TicketPhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get slot => $composableBuilder(
      column: $table.slot, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stage => $composableBuilder(
      column: $table.stage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get caption => $composableBuilder(
      column: $table.caption, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get visibleToClient => $composableBuilder(
      column: $table.visibleToClient,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get takenAt => $composableBuilder(
      column: $table.takenAt, builder: (column) => ColumnOrderings(column));

  $$TicketsTableOrderingComposer get ticketId {
    final $$TicketsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ticketId,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableOrderingComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TicketPhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $TicketPhotosTable> {
  $$TicketPhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PhotoSlot, int> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PhotoStage, int> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);

  GeneratedColumn<bool> get visibleToClient => $composableBuilder(
      column: $table.visibleToClient, builder: (column) => column);

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  $$TicketsTableAnnotationComposer get ticketId {
    final $$TicketsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ticketId,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableAnnotationComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TicketPhotosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TicketPhotosTable,
    TicketPhoto,
    $$TicketPhotosTableFilterComposer,
    $$TicketPhotosTableOrderingComposer,
    $$TicketPhotosTableAnnotationComposer,
    $$TicketPhotosTableCreateCompanionBuilder,
    $$TicketPhotosTableUpdateCompanionBuilder,
    (TicketPhoto, $$TicketPhotosTableReferences),
    TicketPhoto,
    PrefetchHooks Function({bool ticketId})> {
  $$TicketPhotosTableTableManager(_$AppDatabase db, $TicketPhotosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TicketPhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TicketPhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TicketPhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> ticketId = const Value.absent(),
            Value<PhotoSlot> slot = const Value.absent(),
            Value<PhotoStage> stage = const Value.absent(),
            Value<String> path = const Value.absent(),
            Value<String?> caption = const Value.absent(),
            Value<bool> visibleToClient = const Value.absent(),
            Value<DateTime> takenAt = const Value.absent(),
          }) =>
              TicketPhotosCompanion(
            id: id,
            ticketId: ticketId,
            slot: slot,
            stage: stage,
            path: path,
            caption: caption,
            visibleToClient: visibleToClient,
            takenAt: takenAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int ticketId,
            required PhotoSlot slot,
            Value<PhotoStage> stage = const Value.absent(),
            required String path,
            Value<String?> caption = const Value.absent(),
            Value<bool> visibleToClient = const Value.absent(),
            Value<DateTime> takenAt = const Value.absent(),
          }) =>
              TicketPhotosCompanion.insert(
            id: id,
            ticketId: ticketId,
            slot: slot,
            stage: stage,
            path: path,
            caption: caption,
            visibleToClient: visibleToClient,
            takenAt: takenAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$TicketPhotosTable, TicketPhoto>(table),
                    $$TicketPhotosTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({ticketId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (ticketId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ticketId,
                    referencedTable:
                        $$TicketPhotosTableReferences._ticketIdTable(db),
                    referencedColumn:
                        $$TicketPhotosTableReferences._ticketIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TicketPhotosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TicketPhotosTable,
    TicketPhoto,
    $$TicketPhotosTableFilterComposer,
    $$TicketPhotosTableOrderingComposer,
    $$TicketPhotosTableAnnotationComposer,
    $$TicketPhotosTableCreateCompanionBuilder,
    $$TicketPhotosTableUpdateCompanionBuilder,
    (TicketPhoto, $$TicketPhotosTableReferences),
    TicketPhoto,
    PrefetchHooks Function({bool ticketId})>;
typedef $$TicketPhotoSlotsTableCreateCompanionBuilder
    = TicketPhotoSlotsCompanion Function({
  Value<int> id,
  required int ticketId,
  required int sortOrder,
  required String label,
  Value<String?> hint,
  Value<bool> required,
  Value<String?> photoPath,
  Value<DateTime?> capturedAt,
});
typedef $$TicketPhotoSlotsTableUpdateCompanionBuilder
    = TicketPhotoSlotsCompanion Function({
  Value<int> id,
  Value<int> ticketId,
  Value<int> sortOrder,
  Value<String> label,
  Value<String?> hint,
  Value<bool> required,
  Value<String?> photoPath,
  Value<DateTime?> capturedAt,
});

final class $$TicketPhotoSlotsTableReferences extends BaseReferences<
    _$AppDatabase, $TicketPhotoSlotsTable, TicketPhotoSlot> {
  $$TicketPhotoSlotsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TicketsTable _ticketIdTable(_$AppDatabase db) =>
      db.tickets.createAlias('ticket_photo_slots__ticket_id__tickets__id');

  $$TicketsTableProcessedTableManager get ticketId {
    final $_column = $_itemColumn<int>('ticket_id')!;

    final manager = $$TicketsTableTableManager($_db, $_db.tickets)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ticketIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TicketPhotoSlotsTableFilterComposer
    extends Composer<_$AppDatabase, $TicketPhotoSlotsTable> {
  $$TicketPhotoSlotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hint => $composableBuilder(
      column: $table.hint, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get required => $composableBuilder(
      column: $table.required, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => ColumnFilters(column));

  $$TicketsTableFilterComposer get ticketId {
    final $$TicketsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ticketId,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableFilterComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TicketPhotoSlotsTableOrderingComposer
    extends Composer<_$AppDatabase, $TicketPhotoSlotsTable> {
  $$TicketPhotoSlotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hint => $composableBuilder(
      column: $table.hint, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get required => $composableBuilder(
      column: $table.required, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => ColumnOrderings(column));

  $$TicketsTableOrderingComposer get ticketId {
    final $$TicketsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ticketId,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableOrderingComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TicketPhotoSlotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TicketPhotoSlotsTable> {
  $$TicketPhotoSlotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get hint =>
      $composableBuilder(column: $table.hint, builder: (column) => column);

  GeneratedColumn<bool> get required =>
      $composableBuilder(column: $table.required, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => column);

  $$TicketsTableAnnotationComposer get ticketId {
    final $$TicketsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ticketId,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableAnnotationComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TicketPhotoSlotsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TicketPhotoSlotsTable,
    TicketPhotoSlot,
    $$TicketPhotoSlotsTableFilterComposer,
    $$TicketPhotoSlotsTableOrderingComposer,
    $$TicketPhotoSlotsTableAnnotationComposer,
    $$TicketPhotoSlotsTableCreateCompanionBuilder,
    $$TicketPhotoSlotsTableUpdateCompanionBuilder,
    (TicketPhotoSlot, $$TicketPhotoSlotsTableReferences),
    TicketPhotoSlot,
    PrefetchHooks Function({bool ticketId})> {
  $$TicketPhotoSlotsTableTableManager(
      _$AppDatabase db, $TicketPhotoSlotsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TicketPhotoSlotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TicketPhotoSlotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TicketPhotoSlotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> ticketId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<String?> hint = const Value.absent(),
            Value<bool> required = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<DateTime?> capturedAt = const Value.absent(),
          }) =>
              TicketPhotoSlotsCompanion(
            id: id,
            ticketId: ticketId,
            sortOrder: sortOrder,
            label: label,
            hint: hint,
            required: required,
            photoPath: photoPath,
            capturedAt: capturedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int ticketId,
            required int sortOrder,
            required String label,
            Value<String?> hint = const Value.absent(),
            Value<bool> required = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<DateTime?> capturedAt = const Value.absent(),
          }) =>
              TicketPhotoSlotsCompanion.insert(
            id: id,
            ticketId: ticketId,
            sortOrder: sortOrder,
            label: label,
            hint: hint,
            required: required,
            photoPath: photoPath,
            capturedAt: capturedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$TicketPhotoSlotsTable, TicketPhotoSlot>(table),
                    $$TicketPhotoSlotsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({ticketId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (ticketId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ticketId,
                    referencedTable:
                        $$TicketPhotoSlotsTableReferences._ticketIdTable(db),
                    referencedColumn:
                        $$TicketPhotoSlotsTableReferences._ticketIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TicketPhotoSlotsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TicketPhotoSlotsTable,
    TicketPhotoSlot,
    $$TicketPhotoSlotsTableFilterComposer,
    $$TicketPhotoSlotsTableOrderingComposer,
    $$TicketPhotoSlotsTableAnnotationComposer,
    $$TicketPhotoSlotsTableCreateCompanionBuilder,
    $$TicketPhotoSlotsTableUpdateCompanionBuilder,
    (TicketPhotoSlot, $$TicketPhotoSlotsTableReferences),
    TicketPhotoSlot,
    PrefetchHooks Function({bool ticketId})>;
typedef $$TicketReportsTableCreateCompanionBuilder = TicketReportsCompanion
    Function({
  Value<int> id,
  required int ticketId,
  required ReportKind kind,
  required ReportStatus status,
  required String author,
  Value<int> revision,
  Value<String?> summary,
  Value<int?> warrantyDays,
  Value<DateTime?> warrantyStartAt,
  Value<String?> warrantyTerms,
  Value<ReportOutcome?> outcome,
  Value<String?> shopTag,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> finalizedAt,
});
typedef $$TicketReportsTableUpdateCompanionBuilder = TicketReportsCompanion
    Function({
  Value<int> id,
  Value<int> ticketId,
  Value<ReportKind> kind,
  Value<ReportStatus> status,
  Value<String> author,
  Value<int> revision,
  Value<String?> summary,
  Value<int?> warrantyDays,
  Value<DateTime?> warrantyStartAt,
  Value<String?> warrantyTerms,
  Value<ReportOutcome?> outcome,
  Value<String?> shopTag,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> finalizedAt,
});

final class $$TicketReportsTableReferences
    extends BaseReferences<_$AppDatabase, $TicketReportsTable, TicketReport> {
  $$TicketReportsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TicketsTable _ticketIdTable(_$AppDatabase db) =>
      db.tickets.createAlias('ticket_reports__ticket_id__tickets__id');

  $$TicketsTableProcessedTableManager get ticketId {
    final $_column = $_itemColumn<int>('ticket_id')!;

    final manager = $$TicketsTableTableManager($_db, $_db.tickets)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ticketIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ReportCosmeticItemsTable,
      List<ReportCosmeticItem>> _reportCosmeticItemsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.reportCosmeticItems,
          aliasName: 'ticket_reports__id__report_cosmetic_items__report_id');

  $$ReportCosmeticItemsTableProcessedTableManager get reportCosmeticItemsRefs {
    final manager =
        $$ReportCosmeticItemsTableTableManager($_db, $_db.reportCosmeticItems)
            .filter((f) => f.reportId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_reportCosmeticItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ReportFindingsTable, List<ReportFinding>>
      _reportFindingsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.reportFindings,
              aliasName: 'ticket_reports__id__report_findings__report_id');

  $$ReportFindingsTableProcessedTableManager get reportFindingsRefs {
    final manager = $$ReportFindingsTableTableManager($_db, $_db.reportFindings)
        .filter((f) => f.reportId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_reportFindingsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TechnicalReportEntriesTable,
      List<TechnicalReportEntry>> _technicalReportEntriesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.technicalReportEntries,
          aliasName: 'ticket_reports__id__technical_report_entries__report_id');

  $$TechnicalReportEntriesTableProcessedTableManager
      get technicalReportEntriesRefs {
    final manager = $$TechnicalReportEntriesTableTableManager(
            $_db, $_db.technicalReportEntries)
        .filter((f) => f.reportId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_technicalReportEntriesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ClientReportEntriesTable, List<ClientReportEntry>>
      _clientReportEntriesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.clientReportEntries,
              aliasName:
                  'ticket_reports__id__client_report_entries__report_id');

  $$ClientReportEntriesTableProcessedTableManager get clientReportEntriesRefs {
    final manager =
        $$ClientReportEntriesTableTableManager($_db, $_db.clientReportEntries)
            .filter((f) => f.reportId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_clientReportEntriesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ReportContactLogTable, List<ReportContactLogData>>
      _reportContactLogRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.reportContactLog,
              aliasName: 'ticket_reports__id__report_contact_log__report_id');

  $$ReportContactLogTableProcessedTableManager get reportContactLogRefs {
    final manager =
        $$ReportContactLogTableTableManager($_db, $_db.reportContactLog)
            .filter((f) => f.reportId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_reportContactLogRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TicketReportsTableFilterComposer
    extends Composer<_$AppDatabase, $TicketReportsTable> {
  $$TicketReportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ReportKind, ReportKind, int> get kind =>
      $composableBuilder(
          column: $table.kind,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<ReportStatus, ReportStatus, int> get status =>
      $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get warrantyDays => $composableBuilder(
      column: $table.warrantyDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get warrantyStartAt => $composableBuilder(
      column: $table.warrantyStartAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get warrantyTerms => $composableBuilder(
      column: $table.warrantyTerms, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ReportOutcome?, ReportOutcome, int>
      get outcome => $composableBuilder(
          column: $table.outcome,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get shopTag => $composableBuilder(
      column: $table.shopTag, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get finalizedAt => $composableBuilder(
      column: $table.finalizedAt, builder: (column) => ColumnFilters(column));

  $$TicketsTableFilterComposer get ticketId {
    final $$TicketsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ticketId,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableFilterComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> reportCosmeticItemsRefs(
      Expression<bool> Function($$ReportCosmeticItemsTableFilterComposer f) f) {
    final $$ReportCosmeticItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.reportCosmeticItems,
        getReferencedColumn: (t) => t.reportId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReportCosmeticItemsTableFilterComposer(
              $db: $db,
              $table: $db.reportCosmeticItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> reportFindingsRefs(
      Expression<bool> Function($$ReportFindingsTableFilterComposer f) f) {
    final $$ReportFindingsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.reportFindings,
        getReferencedColumn: (t) => t.reportId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReportFindingsTableFilterComposer(
              $db: $db,
              $table: $db.reportFindings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> technicalReportEntriesRefs(
      Expression<bool> Function($$TechnicalReportEntriesTableFilterComposer f)
          f) {
    final $$TechnicalReportEntriesTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.technicalReportEntries,
            getReferencedColumn: (t) => t.reportId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TechnicalReportEntriesTableFilterComposer(
                  $db: $db,
                  $table: $db.technicalReportEntries,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<bool> clientReportEntriesRefs(
      Expression<bool> Function($$ClientReportEntriesTableFilterComposer f) f) {
    final $$ClientReportEntriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.clientReportEntries,
        getReferencedColumn: (t) => t.reportId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientReportEntriesTableFilterComposer(
              $db: $db,
              $table: $db.clientReportEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> reportContactLogRefs(
      Expression<bool> Function($$ReportContactLogTableFilterComposer f) f) {
    final $$ReportContactLogTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.reportContactLog,
        getReferencedColumn: (t) => t.reportId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReportContactLogTableFilterComposer(
              $db: $db,
              $table: $db.reportContactLog,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TicketReportsTableOrderingComposer
    extends Composer<_$AppDatabase, $TicketReportsTable> {
  $$TicketReportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get warrantyDays => $composableBuilder(
      column: $table.warrantyDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get warrantyStartAt => $composableBuilder(
      column: $table.warrantyStartAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get warrantyTerms => $composableBuilder(
      column: $table.warrantyTerms,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get outcome => $composableBuilder(
      column: $table.outcome, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shopTag => $composableBuilder(
      column: $table.shopTag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get finalizedAt => $composableBuilder(
      column: $table.finalizedAt, builder: (column) => ColumnOrderings(column));

  $$TicketsTableOrderingComposer get ticketId {
    final $$TicketsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ticketId,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableOrderingComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TicketReportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TicketReportsTable> {
  $$TicketReportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ReportKind, int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ReportStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<int> get warrantyDays => $composableBuilder(
      column: $table.warrantyDays, builder: (column) => column);

  GeneratedColumn<DateTime> get warrantyStartAt => $composableBuilder(
      column: $table.warrantyStartAt, builder: (column) => column);

  GeneratedColumn<String> get warrantyTerms => $composableBuilder(
      column: $table.warrantyTerms, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ReportOutcome?, int> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<String> get shopTag =>
      $composableBuilder(column: $table.shopTag, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finalizedAt => $composableBuilder(
      column: $table.finalizedAt, builder: (column) => column);

  $$TicketsTableAnnotationComposer get ticketId {
    final $$TicketsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ticketId,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableAnnotationComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> reportCosmeticItemsRefs<T extends Object>(
      Expression<T> Function($$ReportCosmeticItemsTableAnnotationComposer a)
          f) {
    final $$ReportCosmeticItemsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.reportCosmeticItems,
            getReferencedColumn: (t) => t.reportId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ReportCosmeticItemsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.reportCosmeticItems,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> reportFindingsRefs<T extends Object>(
      Expression<T> Function($$ReportFindingsTableAnnotationComposer a) f) {
    final $$ReportFindingsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.reportFindings,
        getReferencedColumn: (t) => t.reportId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReportFindingsTableAnnotationComposer(
              $db: $db,
              $table: $db.reportFindings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> technicalReportEntriesRefs<T extends Object>(
      Expression<T> Function($$TechnicalReportEntriesTableAnnotationComposer a)
          f) {
    final $$TechnicalReportEntriesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.technicalReportEntries,
            getReferencedColumn: (t) => t.reportId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TechnicalReportEntriesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.technicalReportEntries,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> clientReportEntriesRefs<T extends Object>(
      Expression<T> Function($$ClientReportEntriesTableAnnotationComposer a)
          f) {
    final $$ClientReportEntriesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.clientReportEntries,
            getReferencedColumn: (t) => t.reportId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ClientReportEntriesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.clientReportEntries,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> reportContactLogRefs<T extends Object>(
      Expression<T> Function($$ReportContactLogTableAnnotationComposer a) f) {
    final $$ReportContactLogTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.reportContactLog,
        getReferencedColumn: (t) => t.reportId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReportContactLogTableAnnotationComposer(
              $db: $db,
              $table: $db.reportContactLog,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TicketReportsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TicketReportsTable,
    TicketReport,
    $$TicketReportsTableFilterComposer,
    $$TicketReportsTableOrderingComposer,
    $$TicketReportsTableAnnotationComposer,
    $$TicketReportsTableCreateCompanionBuilder,
    $$TicketReportsTableUpdateCompanionBuilder,
    (TicketReport, $$TicketReportsTableReferences),
    TicketReport,
    PrefetchHooks Function(
        {bool ticketId,
        bool reportCosmeticItemsRefs,
        bool reportFindingsRefs,
        bool technicalReportEntriesRefs,
        bool clientReportEntriesRefs,
        bool reportContactLogRefs})> {
  $$TicketReportsTableTableManager(_$AppDatabase db, $TicketReportsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TicketReportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TicketReportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TicketReportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> ticketId = const Value.absent(),
            Value<ReportKind> kind = const Value.absent(),
            Value<ReportStatus> status = const Value.absent(),
            Value<String> author = const Value.absent(),
            Value<int> revision = const Value.absent(),
            Value<String?> summary = const Value.absent(),
            Value<int?> warrantyDays = const Value.absent(),
            Value<DateTime?> warrantyStartAt = const Value.absent(),
            Value<String?> warrantyTerms = const Value.absent(),
            Value<ReportOutcome?> outcome = const Value.absent(),
            Value<String?> shopTag = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> finalizedAt = const Value.absent(),
          }) =>
              TicketReportsCompanion(
            id: id,
            ticketId: ticketId,
            kind: kind,
            status: status,
            author: author,
            revision: revision,
            summary: summary,
            warrantyDays: warrantyDays,
            warrantyStartAt: warrantyStartAt,
            warrantyTerms: warrantyTerms,
            outcome: outcome,
            shopTag: shopTag,
            createdAt: createdAt,
            updatedAt: updatedAt,
            finalizedAt: finalizedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int ticketId,
            required ReportKind kind,
            required ReportStatus status,
            required String author,
            Value<int> revision = const Value.absent(),
            Value<String?> summary = const Value.absent(),
            Value<int?> warrantyDays = const Value.absent(),
            Value<DateTime?> warrantyStartAt = const Value.absent(),
            Value<String?> warrantyTerms = const Value.absent(),
            Value<ReportOutcome?> outcome = const Value.absent(),
            Value<String?> shopTag = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> finalizedAt = const Value.absent(),
          }) =>
              TicketReportsCompanion.insert(
            id: id,
            ticketId: ticketId,
            kind: kind,
            status: status,
            author: author,
            revision: revision,
            summary: summary,
            warrantyDays: warrantyDays,
            warrantyStartAt: warrantyStartAt,
            warrantyTerms: warrantyTerms,
            outcome: outcome,
            shopTag: shopTag,
            createdAt: createdAt,
            updatedAt: updatedAt,
            finalizedAt: finalizedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$TicketReportsTable, TicketReport>(table),
                    $$TicketReportsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {ticketId = false,
              reportCosmeticItemsRefs = false,
              reportFindingsRefs = false,
              technicalReportEntriesRefs = false,
              clientReportEntriesRefs = false,
              reportContactLogRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (reportCosmeticItemsRefs) db.reportCosmeticItems,
                if (reportFindingsRefs) db.reportFindings,
                if (technicalReportEntriesRefs) db.technicalReportEntries,
                if (clientReportEntriesRefs) db.clientReportEntries,
                if (reportContactLogRefs) db.reportContactLog
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (ticketId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ticketId,
                    referencedTable:
                        $$TicketReportsTableReferences._ticketIdTable(db),
                    referencedColumn:
                        $$TicketReportsTableReferences._ticketIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (reportCosmeticItemsRefs)
                    await $_getPrefetchedDataByColumns<
                            TicketReport,
                            $TicketReportsTable,
                            ReportCosmeticItem,
                            $ReportCosmeticItemsTable>(
                        currentTable: table,
                        referencedTable: $$TicketReportsTableReferences
                            ._reportCosmeticItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TicketReportsTableReferences(db, table, p0)
                                .reportCosmeticItemsRefs,
                        currentColumn: 'id',
                        referencedColumn: 'report_id',
                        typedResults: items),
                  if (reportFindingsRefs)
                    await $_getPrefetchedDataByColumns<
                            TicketReport,
                            $TicketReportsTable,
                            ReportFinding,
                            $ReportFindingsTable>(
                        currentTable: table,
                        referencedTable: $$TicketReportsTableReferences
                            ._reportFindingsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TicketReportsTableReferences(db, table, p0)
                                .reportFindingsRefs,
                        currentColumn: 'id',
                        referencedColumn: 'report_id',
                        typedResults: items),
                  if (technicalReportEntriesRefs)
                    await $_getPrefetchedDataByColumns<
                            TicketReport,
                            $TicketReportsTable,
                            TechnicalReportEntry,
                            $TechnicalReportEntriesTable>(
                        currentTable: table,
                        referencedTable: $$TicketReportsTableReferences
                            ._technicalReportEntriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TicketReportsTableReferences(db, table, p0)
                                .technicalReportEntriesRefs,
                        currentColumn: 'id',
                        referencedColumn: 'report_id',
                        typedResults: items),
                  if (clientReportEntriesRefs)
                    await $_getPrefetchedDataByColumns<
                            TicketReport,
                            $TicketReportsTable,
                            ClientReportEntry,
                            $ClientReportEntriesTable>(
                        currentTable: table,
                        referencedTable: $$TicketReportsTableReferences
                            ._clientReportEntriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TicketReportsTableReferences(db, table, p0)
                                .clientReportEntriesRefs,
                        currentColumn: 'id',
                        referencedColumn: 'report_id',
                        typedResults: items),
                  if (reportContactLogRefs)
                    await $_getPrefetchedDataByColumns<
                            TicketReport,
                            $TicketReportsTable,
                            ReportContactLogData,
                            $ReportContactLogTable>(
                        currentTable: table,
                        referencedTable: $$TicketReportsTableReferences
                            ._reportContactLogRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TicketReportsTableReferences(db, table, p0)
                                .reportContactLogRefs,
                        currentColumn: 'id',
                        referencedColumn: 'report_id',
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TicketReportsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TicketReportsTable,
    TicketReport,
    $$TicketReportsTableFilterComposer,
    $$TicketReportsTableOrderingComposer,
    $$TicketReportsTableAnnotationComposer,
    $$TicketReportsTableCreateCompanionBuilder,
    $$TicketReportsTableUpdateCompanionBuilder,
    (TicketReport, $$TicketReportsTableReferences),
    TicketReport,
    PrefetchHooks Function(
        {bool ticketId,
        bool reportCosmeticItemsRefs,
        bool reportFindingsRefs,
        bool technicalReportEntriesRefs,
        bool clientReportEntriesRefs,
        bool reportContactLogRefs})>;
typedef $$ReportCosmeticItemsTableCreateCompanionBuilder
    = ReportCosmeticItemsCompanion Function({
  Value<int> id,
  required int reportId,
  required String area,
  required CosmeticCondition condition,
  Value<String?> note,
});
typedef $$ReportCosmeticItemsTableUpdateCompanionBuilder
    = ReportCosmeticItemsCompanion Function({
  Value<int> id,
  Value<int> reportId,
  Value<String> area,
  Value<CosmeticCondition> condition,
  Value<String?> note,
});

final class $$ReportCosmeticItemsTableReferences extends BaseReferences<
    _$AppDatabase, $ReportCosmeticItemsTable, ReportCosmeticItem> {
  $$ReportCosmeticItemsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TicketReportsTable _reportIdTable(_$AppDatabase db) =>
      db.ticketReports
          .createAlias('report_cosmetic_items__report_id__ticket_reports__id');

  $$TicketReportsTableProcessedTableManager get reportId {
    final $_column = $_itemColumn<int>('report_id')!;

    final manager = $$TicketReportsTableTableManager($_db, $_db.ticketReports)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reportIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ReportCosmeticItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ReportCosmeticItemsTable> {
  $$ReportCosmeticItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get area => $composableBuilder(
      column: $table.area, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<CosmeticCondition, CosmeticCondition, int>
      get condition => $composableBuilder(
          column: $table.condition,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  $$TicketReportsTableFilterComposer get reportId {
    final $$TicketReportsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.reportId,
        referencedTable: $db.ticketReports,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketReportsTableFilterComposer(
              $db: $db,
              $table: $db.ticketReports,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReportCosmeticItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReportCosmeticItemsTable> {
  $$ReportCosmeticItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get area => $composableBuilder(
      column: $table.area, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get condition => $composableBuilder(
      column: $table.condition, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  $$TicketReportsTableOrderingComposer get reportId {
    final $$TicketReportsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.reportId,
        referencedTable: $db.ticketReports,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketReportsTableOrderingComposer(
              $db: $db,
              $table: $db.ticketReports,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReportCosmeticItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReportCosmeticItemsTable> {
  $$ReportCosmeticItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get area =>
      $composableBuilder(column: $table.area, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CosmeticCondition, int> get condition =>
      $composableBuilder(column: $table.condition, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$TicketReportsTableAnnotationComposer get reportId {
    final $$TicketReportsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.reportId,
        referencedTable: $db.ticketReports,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketReportsTableAnnotationComposer(
              $db: $db,
              $table: $db.ticketReports,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReportCosmeticItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReportCosmeticItemsTable,
    ReportCosmeticItem,
    $$ReportCosmeticItemsTableFilterComposer,
    $$ReportCosmeticItemsTableOrderingComposer,
    $$ReportCosmeticItemsTableAnnotationComposer,
    $$ReportCosmeticItemsTableCreateCompanionBuilder,
    $$ReportCosmeticItemsTableUpdateCompanionBuilder,
    (ReportCosmeticItem, $$ReportCosmeticItemsTableReferences),
    ReportCosmeticItem,
    PrefetchHooks Function({bool reportId})> {
  $$ReportCosmeticItemsTableTableManager(
      _$AppDatabase db, $ReportCosmeticItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReportCosmeticItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReportCosmeticItemsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReportCosmeticItemsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> reportId = const Value.absent(),
            Value<String> area = const Value.absent(),
            Value<CosmeticCondition> condition = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) =>
              ReportCosmeticItemsCompanion(
            id: id,
            reportId: reportId,
            area: area,
            condition: condition,
            note: note,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int reportId,
            required String area,
            required CosmeticCondition condition,
            Value<String?> note = const Value.absent(),
          }) =>
              ReportCosmeticItemsCompanion.insert(
            id: id,
            reportId: reportId,
            area: area,
            condition: condition,
            note: note,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ReportCosmeticItemsTable, ReportCosmeticItem>(
                        table),
                    $$ReportCosmeticItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({reportId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (reportId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.reportId,
                    referencedTable:
                        $$ReportCosmeticItemsTableReferences._reportIdTable(db),
                    referencedColumn: $$ReportCosmeticItemsTableReferences
                        ._reportIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ReportCosmeticItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReportCosmeticItemsTable,
    ReportCosmeticItem,
    $$ReportCosmeticItemsTableFilterComposer,
    $$ReportCosmeticItemsTableOrderingComposer,
    $$ReportCosmeticItemsTableAnnotationComposer,
    $$ReportCosmeticItemsTableCreateCompanionBuilder,
    $$ReportCosmeticItemsTableUpdateCompanionBuilder,
    (ReportCosmeticItem, $$ReportCosmeticItemsTableReferences),
    ReportCosmeticItem,
    PrefetchHooks Function({bool reportId})>;
typedef $$ReportFindingsTableCreateCompanionBuilder = ReportFindingsCompanion
    Function({
  Value<int> id,
  required int reportId,
  required String area,
  required String symptom,
  Value<String?> cause,
  required Severity severity,
  Value<String?> proposedFix,
});
typedef $$ReportFindingsTableUpdateCompanionBuilder = ReportFindingsCompanion
    Function({
  Value<int> id,
  Value<int> reportId,
  Value<String> area,
  Value<String> symptom,
  Value<String?> cause,
  Value<Severity> severity,
  Value<String?> proposedFix,
});

final class $$ReportFindingsTableReferences
    extends BaseReferences<_$AppDatabase, $ReportFindingsTable, ReportFinding> {
  $$ReportFindingsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TicketReportsTable _reportIdTable(_$AppDatabase db) =>
      db.ticketReports
          .createAlias('report_findings__report_id__ticket_reports__id');

  $$TicketReportsTableProcessedTableManager get reportId {
    final $_column = $_itemColumn<int>('report_id')!;

    final manager = $$TicketReportsTableTableManager($_db, $_db.ticketReports)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reportIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ReportFindingsTableFilterComposer
    extends Composer<_$AppDatabase, $ReportFindingsTable> {
  $$ReportFindingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get area => $composableBuilder(
      column: $table.area, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get symptom => $composableBuilder(
      column: $table.symptom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cause => $composableBuilder(
      column: $table.cause, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Severity, Severity, int> get severity =>
      $composableBuilder(
          column: $table.severity,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get proposedFix => $composableBuilder(
      column: $table.proposedFix, builder: (column) => ColumnFilters(column));

  $$TicketReportsTableFilterComposer get reportId {
    final $$TicketReportsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.reportId,
        referencedTable: $db.ticketReports,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketReportsTableFilterComposer(
              $db: $db,
              $table: $db.ticketReports,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReportFindingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReportFindingsTable> {
  $$ReportFindingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get area => $composableBuilder(
      column: $table.area, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get symptom => $composableBuilder(
      column: $table.symptom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cause => $composableBuilder(
      column: $table.cause, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get severity => $composableBuilder(
      column: $table.severity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get proposedFix => $composableBuilder(
      column: $table.proposedFix, builder: (column) => ColumnOrderings(column));

  $$TicketReportsTableOrderingComposer get reportId {
    final $$TicketReportsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.reportId,
        referencedTable: $db.ticketReports,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketReportsTableOrderingComposer(
              $db: $db,
              $table: $db.ticketReports,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReportFindingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReportFindingsTable> {
  $$ReportFindingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get area =>
      $composableBuilder(column: $table.area, builder: (column) => column);

  GeneratedColumn<String> get symptom =>
      $composableBuilder(column: $table.symptom, builder: (column) => column);

  GeneratedColumn<String> get cause =>
      $composableBuilder(column: $table.cause, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Severity, int> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get proposedFix => $composableBuilder(
      column: $table.proposedFix, builder: (column) => column);

  $$TicketReportsTableAnnotationComposer get reportId {
    final $$TicketReportsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.reportId,
        referencedTable: $db.ticketReports,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketReportsTableAnnotationComposer(
              $db: $db,
              $table: $db.ticketReports,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReportFindingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReportFindingsTable,
    ReportFinding,
    $$ReportFindingsTableFilterComposer,
    $$ReportFindingsTableOrderingComposer,
    $$ReportFindingsTableAnnotationComposer,
    $$ReportFindingsTableCreateCompanionBuilder,
    $$ReportFindingsTableUpdateCompanionBuilder,
    (ReportFinding, $$ReportFindingsTableReferences),
    ReportFinding,
    PrefetchHooks Function({bool reportId})> {
  $$ReportFindingsTableTableManager(
      _$AppDatabase db, $ReportFindingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReportFindingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReportFindingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReportFindingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> reportId = const Value.absent(),
            Value<String> area = const Value.absent(),
            Value<String> symptom = const Value.absent(),
            Value<String?> cause = const Value.absent(),
            Value<Severity> severity = const Value.absent(),
            Value<String?> proposedFix = const Value.absent(),
          }) =>
              ReportFindingsCompanion(
            id: id,
            reportId: reportId,
            area: area,
            symptom: symptom,
            cause: cause,
            severity: severity,
            proposedFix: proposedFix,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int reportId,
            required String area,
            required String symptom,
            Value<String?> cause = const Value.absent(),
            required Severity severity,
            Value<String?> proposedFix = const Value.absent(),
          }) =>
              ReportFindingsCompanion.insert(
            id: id,
            reportId: reportId,
            area: area,
            symptom: symptom,
            cause: cause,
            severity: severity,
            proposedFix: proposedFix,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ReportFindingsTable, ReportFinding>(table),
                    $$ReportFindingsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({reportId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (reportId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.reportId,
                    referencedTable:
                        $$ReportFindingsTableReferences._reportIdTable(db),
                    referencedColumn:
                        $$ReportFindingsTableReferences._reportIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ReportFindingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReportFindingsTable,
    ReportFinding,
    $$ReportFindingsTableFilterComposer,
    $$ReportFindingsTableOrderingComposer,
    $$ReportFindingsTableAnnotationComposer,
    $$ReportFindingsTableCreateCompanionBuilder,
    $$ReportFindingsTableUpdateCompanionBuilder,
    (ReportFinding, $$ReportFindingsTableReferences),
    ReportFinding,
    PrefetchHooks Function({bool reportId})>;
typedef $$TechnicalReportEntriesTableCreateCompanionBuilder
    = TechnicalReportEntriesCompanion Function({
  Value<int> id,
  required int reportId,
  required int sortOrder,
  required TechnicalEntryKind kind,
  Value<int?> parentEntryId,
  Value<String?> body,
  Value<String?> photoPath,
  Value<String?> caption,
});
typedef $$TechnicalReportEntriesTableUpdateCompanionBuilder
    = TechnicalReportEntriesCompanion Function({
  Value<int> id,
  Value<int> reportId,
  Value<int> sortOrder,
  Value<TechnicalEntryKind> kind,
  Value<int?> parentEntryId,
  Value<String?> body,
  Value<String?> photoPath,
  Value<String?> caption,
});

final class $$TechnicalReportEntriesTableReferences extends BaseReferences<
    _$AppDatabase, $TechnicalReportEntriesTable, TechnicalReportEntry> {
  $$TechnicalReportEntriesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TicketReportsTable _reportIdTable(_$AppDatabase db) => db
      .ticketReports
      .createAlias('technical_report_entries__report_id__ticket_reports__id');

  $$TicketReportsTableProcessedTableManager get reportId {
    final $_column = $_itemColumn<int>('report_id')!;

    final manager = $$TicketReportsTableTableManager($_db, $_db.ticketReports)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reportIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TechnicalReportEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $TechnicalReportEntriesTable> {
  $$TechnicalReportEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<TechnicalEntryKind, TechnicalEntryKind, int>
      get kind => $composableBuilder(
          column: $table.kind,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get parentEntryId => $composableBuilder(
      column: $table.parentEntryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get caption => $composableBuilder(
      column: $table.caption, builder: (column) => ColumnFilters(column));

  $$TicketReportsTableFilterComposer get reportId {
    final $$TicketReportsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.reportId,
        referencedTable: $db.ticketReports,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketReportsTableFilterComposer(
              $db: $db,
              $table: $db.ticketReports,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TechnicalReportEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TechnicalReportEntriesTable> {
  $$TechnicalReportEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get parentEntryId => $composableBuilder(
      column: $table.parentEntryId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get caption => $composableBuilder(
      column: $table.caption, builder: (column) => ColumnOrderings(column));

  $$TicketReportsTableOrderingComposer get reportId {
    final $$TicketReportsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.reportId,
        referencedTable: $db.ticketReports,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketReportsTableOrderingComposer(
              $db: $db,
              $table: $db.ticketReports,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TechnicalReportEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TechnicalReportEntriesTable> {
  $$TechnicalReportEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TechnicalEntryKind, int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get parentEntryId => $composableBuilder(
      column: $table.parentEntryId, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);

  $$TicketReportsTableAnnotationComposer get reportId {
    final $$TicketReportsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.reportId,
        referencedTable: $db.ticketReports,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketReportsTableAnnotationComposer(
              $db: $db,
              $table: $db.ticketReports,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TechnicalReportEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TechnicalReportEntriesTable,
    TechnicalReportEntry,
    $$TechnicalReportEntriesTableFilterComposer,
    $$TechnicalReportEntriesTableOrderingComposer,
    $$TechnicalReportEntriesTableAnnotationComposer,
    $$TechnicalReportEntriesTableCreateCompanionBuilder,
    $$TechnicalReportEntriesTableUpdateCompanionBuilder,
    (TechnicalReportEntry, $$TechnicalReportEntriesTableReferences),
    TechnicalReportEntry,
    PrefetchHooks Function({bool reportId})> {
  $$TechnicalReportEntriesTableTableManager(
      _$AppDatabase db, $TechnicalReportEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TechnicalReportEntriesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$TechnicalReportEntriesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TechnicalReportEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> reportId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<TechnicalEntryKind> kind = const Value.absent(),
            Value<int?> parentEntryId = const Value.absent(),
            Value<String?> body = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<String?> caption = const Value.absent(),
          }) =>
              TechnicalReportEntriesCompanion(
            id: id,
            reportId: reportId,
            sortOrder: sortOrder,
            kind: kind,
            parentEntryId: parentEntryId,
            body: body,
            photoPath: photoPath,
            caption: caption,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int reportId,
            required int sortOrder,
            required TechnicalEntryKind kind,
            Value<int?> parentEntryId = const Value.absent(),
            Value<String?> body = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<String?> caption = const Value.absent(),
          }) =>
              TechnicalReportEntriesCompanion.insert(
            id: id,
            reportId: reportId,
            sortOrder: sortOrder,
            kind: kind,
            parentEntryId: parentEntryId,
            body: body,
            photoPath: photoPath,
            caption: caption,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$TechnicalReportEntriesTable,
                        TechnicalReportEntry>(table),
                    $$TechnicalReportEntriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({reportId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (reportId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.reportId,
                    referencedTable: $$TechnicalReportEntriesTableReferences
                        ._reportIdTable(db),
                    referencedColumn: $$TechnicalReportEntriesTableReferences
                        ._reportIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TechnicalReportEntriesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $TechnicalReportEntriesTable,
        TechnicalReportEntry,
        $$TechnicalReportEntriesTableFilterComposer,
        $$TechnicalReportEntriesTableOrderingComposer,
        $$TechnicalReportEntriesTableAnnotationComposer,
        $$TechnicalReportEntriesTableCreateCompanionBuilder,
        $$TechnicalReportEntriesTableUpdateCompanionBuilder,
        (TechnicalReportEntry, $$TechnicalReportEntriesTableReferences),
        TechnicalReportEntry,
        PrefetchHooks Function({bool reportId})>;
typedef $$ClientReportEntriesTableCreateCompanionBuilder
    = ClientReportEntriesCompanion Function({
  Value<int> id,
  required int reportId,
  Value<int?> sourceEntryId,
  Value<int?> parentSourceEntryId,
  required int sortOrder,
  required TechnicalEntryKind kind,
  Value<String?> body,
  Value<String?> photoPath,
  Value<String?> caption,
  Value<bool> contentEdited,
  Value<bool> inclusionEdited,
  Value<bool> included,
});
typedef $$ClientReportEntriesTableUpdateCompanionBuilder
    = ClientReportEntriesCompanion Function({
  Value<int> id,
  Value<int> reportId,
  Value<int?> sourceEntryId,
  Value<int?> parentSourceEntryId,
  Value<int> sortOrder,
  Value<TechnicalEntryKind> kind,
  Value<String?> body,
  Value<String?> photoPath,
  Value<String?> caption,
  Value<bool> contentEdited,
  Value<bool> inclusionEdited,
  Value<bool> included,
});

final class $$ClientReportEntriesTableReferences extends BaseReferences<
    _$AppDatabase, $ClientReportEntriesTable, ClientReportEntry> {
  $$ClientReportEntriesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TicketReportsTable _reportIdTable(_$AppDatabase db) =>
      db.ticketReports
          .createAlias('client_report_entries__report_id__ticket_reports__id');

  $$TicketReportsTableProcessedTableManager get reportId {
    final $_column = $_itemColumn<int>('report_id')!;

    final manager = $$TicketReportsTableTableManager($_db, $_db.ticketReports)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reportIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ClientReportEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ClientReportEntriesTable> {
  $$ClientReportEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sourceEntryId => $composableBuilder(
      column: $table.sourceEntryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get parentSourceEntryId => $composableBuilder(
      column: $table.parentSourceEntryId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<TechnicalEntryKind, TechnicalEntryKind, int>
      get kind => $composableBuilder(
          column: $table.kind,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get caption => $composableBuilder(
      column: $table.caption, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get contentEdited => $composableBuilder(
      column: $table.contentEdited, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get inclusionEdited => $composableBuilder(
      column: $table.inclusionEdited,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get included => $composableBuilder(
      column: $table.included, builder: (column) => ColumnFilters(column));

  $$TicketReportsTableFilterComposer get reportId {
    final $$TicketReportsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.reportId,
        referencedTable: $db.ticketReports,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketReportsTableFilterComposer(
              $db: $db,
              $table: $db.ticketReports,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ClientReportEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientReportEntriesTable> {
  $$ClientReportEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sourceEntryId => $composableBuilder(
      column: $table.sourceEntryId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get parentSourceEntryId => $composableBuilder(
      column: $table.parentSourceEntryId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get caption => $composableBuilder(
      column: $table.caption, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get contentEdited => $composableBuilder(
      column: $table.contentEdited,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get inclusionEdited => $composableBuilder(
      column: $table.inclusionEdited,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get included => $composableBuilder(
      column: $table.included, builder: (column) => ColumnOrderings(column));

  $$TicketReportsTableOrderingComposer get reportId {
    final $$TicketReportsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.reportId,
        referencedTable: $db.ticketReports,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketReportsTableOrderingComposer(
              $db: $db,
              $table: $db.ticketReports,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ClientReportEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientReportEntriesTable> {
  $$ClientReportEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sourceEntryId => $composableBuilder(
      column: $table.sourceEntryId, builder: (column) => column);

  GeneratedColumn<int> get parentSourceEntryId => $composableBuilder(
      column: $table.parentSourceEntryId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TechnicalEntryKind, int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);

  GeneratedColumn<bool> get contentEdited => $composableBuilder(
      column: $table.contentEdited, builder: (column) => column);

  GeneratedColumn<bool> get inclusionEdited => $composableBuilder(
      column: $table.inclusionEdited, builder: (column) => column);

  GeneratedColumn<bool> get included =>
      $composableBuilder(column: $table.included, builder: (column) => column);

  $$TicketReportsTableAnnotationComposer get reportId {
    final $$TicketReportsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.reportId,
        referencedTable: $db.ticketReports,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketReportsTableAnnotationComposer(
              $db: $db,
              $table: $db.ticketReports,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ClientReportEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ClientReportEntriesTable,
    ClientReportEntry,
    $$ClientReportEntriesTableFilterComposer,
    $$ClientReportEntriesTableOrderingComposer,
    $$ClientReportEntriesTableAnnotationComposer,
    $$ClientReportEntriesTableCreateCompanionBuilder,
    $$ClientReportEntriesTableUpdateCompanionBuilder,
    (ClientReportEntry, $$ClientReportEntriesTableReferences),
    ClientReportEntry,
    PrefetchHooks Function({bool reportId})> {
  $$ClientReportEntriesTableTableManager(
      _$AppDatabase db, $ClientReportEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientReportEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientReportEntriesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientReportEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> reportId = const Value.absent(),
            Value<int?> sourceEntryId = const Value.absent(),
            Value<int?> parentSourceEntryId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<TechnicalEntryKind> kind = const Value.absent(),
            Value<String?> body = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<String?> caption = const Value.absent(),
            Value<bool> contentEdited = const Value.absent(),
            Value<bool> inclusionEdited = const Value.absent(),
            Value<bool> included = const Value.absent(),
          }) =>
              ClientReportEntriesCompanion(
            id: id,
            reportId: reportId,
            sourceEntryId: sourceEntryId,
            parentSourceEntryId: parentSourceEntryId,
            sortOrder: sortOrder,
            kind: kind,
            body: body,
            photoPath: photoPath,
            caption: caption,
            contentEdited: contentEdited,
            inclusionEdited: inclusionEdited,
            included: included,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int reportId,
            Value<int?> sourceEntryId = const Value.absent(),
            Value<int?> parentSourceEntryId = const Value.absent(),
            required int sortOrder,
            required TechnicalEntryKind kind,
            Value<String?> body = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<String?> caption = const Value.absent(),
            Value<bool> contentEdited = const Value.absent(),
            Value<bool> inclusionEdited = const Value.absent(),
            Value<bool> included = const Value.absent(),
          }) =>
              ClientReportEntriesCompanion.insert(
            id: id,
            reportId: reportId,
            sourceEntryId: sourceEntryId,
            parentSourceEntryId: parentSourceEntryId,
            sortOrder: sortOrder,
            kind: kind,
            body: body,
            photoPath: photoPath,
            caption: caption,
            contentEdited: contentEdited,
            inclusionEdited: inclusionEdited,
            included: included,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ClientReportEntriesTable, ClientReportEntry>(
                        table),
                    $$ClientReportEntriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({reportId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (reportId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.reportId,
                    referencedTable:
                        $$ClientReportEntriesTableReferences._reportIdTable(db),
                    referencedColumn: $$ClientReportEntriesTableReferences
                        ._reportIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ClientReportEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ClientReportEntriesTable,
    ClientReportEntry,
    $$ClientReportEntriesTableFilterComposer,
    $$ClientReportEntriesTableOrderingComposer,
    $$ClientReportEntriesTableAnnotationComposer,
    $$ClientReportEntriesTableCreateCompanionBuilder,
    $$ClientReportEntriesTableUpdateCompanionBuilder,
    (ClientReportEntry, $$ClientReportEntriesTableReferences),
    ClientReportEntry,
    PrefetchHooks Function({bool reportId})>;
typedef $$ReportContactLogTableCreateCompanionBuilder
    = ReportContactLogCompanion Function({
  Value<int> id,
  required int reportId,
  Value<DateTime> at,
  required ContactMethod method,
  required ContactOutcome outcome,
  Value<String?> note,
});
typedef $$ReportContactLogTableUpdateCompanionBuilder
    = ReportContactLogCompanion Function({
  Value<int> id,
  Value<int> reportId,
  Value<DateTime> at,
  Value<ContactMethod> method,
  Value<ContactOutcome> outcome,
  Value<String?> note,
});

final class $$ReportContactLogTableReferences extends BaseReferences<
    _$AppDatabase, $ReportContactLogTable, ReportContactLogData> {
  $$ReportContactLogTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TicketReportsTable _reportIdTable(_$AppDatabase db) =>
      db.ticketReports
          .createAlias('report_contact_log__report_id__ticket_reports__id');

  $$TicketReportsTableProcessedTableManager get reportId {
    final $_column = $_itemColumn<int>('report_id')!;

    final manager = $$TicketReportsTableTableManager($_db, $_db.ticketReports)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reportIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ReportContactLogTableFilterComposer
    extends Composer<_$AppDatabase, $ReportContactLogTable> {
  $$ReportContactLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get at => $composableBuilder(
      column: $table.at, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ContactMethod, ContactMethod, int>
      get method => $composableBuilder(
          column: $table.method,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<ContactOutcome, ContactOutcome, int>
      get outcome => $composableBuilder(
          column: $table.outcome,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  $$TicketReportsTableFilterComposer get reportId {
    final $$TicketReportsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.reportId,
        referencedTable: $db.ticketReports,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketReportsTableFilterComposer(
              $db: $db,
              $table: $db.ticketReports,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReportContactLogTableOrderingComposer
    extends Composer<_$AppDatabase, $ReportContactLogTable> {
  $$ReportContactLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get at => $composableBuilder(
      column: $table.at, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get outcome => $composableBuilder(
      column: $table.outcome, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  $$TicketReportsTableOrderingComposer get reportId {
    final $$TicketReportsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.reportId,
        referencedTable: $db.ticketReports,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketReportsTableOrderingComposer(
              $db: $db,
              $table: $db.ticketReports,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReportContactLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReportContactLogTable> {
  $$ReportContactLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ContactMethod, int> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ContactOutcome, int> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$TicketReportsTableAnnotationComposer get reportId {
    final $$TicketReportsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.reportId,
        referencedTable: $db.ticketReports,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketReportsTableAnnotationComposer(
              $db: $db,
              $table: $db.ticketReports,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReportContactLogTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReportContactLogTable,
    ReportContactLogData,
    $$ReportContactLogTableFilterComposer,
    $$ReportContactLogTableOrderingComposer,
    $$ReportContactLogTableAnnotationComposer,
    $$ReportContactLogTableCreateCompanionBuilder,
    $$ReportContactLogTableUpdateCompanionBuilder,
    (ReportContactLogData, $$ReportContactLogTableReferences),
    ReportContactLogData,
    PrefetchHooks Function({bool reportId})> {
  $$ReportContactLogTableTableManager(
      _$AppDatabase db, $ReportContactLogTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReportContactLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReportContactLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReportContactLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> reportId = const Value.absent(),
            Value<DateTime> at = const Value.absent(),
            Value<ContactMethod> method = const Value.absent(),
            Value<ContactOutcome> outcome = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) =>
              ReportContactLogCompanion(
            id: id,
            reportId: reportId,
            at: at,
            method: method,
            outcome: outcome,
            note: note,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int reportId,
            Value<DateTime> at = const Value.absent(),
            required ContactMethod method,
            required ContactOutcome outcome,
            Value<String?> note = const Value.absent(),
          }) =>
              ReportContactLogCompanion.insert(
            id: id,
            reportId: reportId,
            at: at,
            method: method,
            outcome: outcome,
            note: note,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ReportContactLogTable, ReportContactLogData>(
                        table),
                    $$ReportContactLogTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({reportId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (reportId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.reportId,
                    referencedTable:
                        $$ReportContactLogTableReferences._reportIdTable(db),
                    referencedColumn:
                        $$ReportContactLogTableReferences._reportIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ReportContactLogTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReportContactLogTable,
    ReportContactLogData,
    $$ReportContactLogTableFilterComposer,
    $$ReportContactLogTableOrderingComposer,
    $$ReportContactLogTableAnnotationComposer,
    $$ReportContactLogTableCreateCompanionBuilder,
    $$ReportContactLogTableUpdateCompanionBuilder,
    (ReportContactLogData, $$ReportContactLogTableReferences),
    ReportContactLogData,
    PrefetchHooks Function({bool reportId})>;
typedef $$PartMovementsTableCreateCompanionBuilder = PartMovementsCompanion
    Function({
  Value<int> id,
  required int partId,
  Value<int?> ticketId,
  required int delta,
  Value<String?> note,
  Value<DateTime> at,
});
typedef $$PartMovementsTableUpdateCompanionBuilder = PartMovementsCompanion
    Function({
  Value<int> id,
  Value<int> partId,
  Value<int?> ticketId,
  Value<int> delta,
  Value<String?> note,
  Value<DateTime> at,
});

final class $$PartMovementsTableReferences
    extends BaseReferences<_$AppDatabase, $PartMovementsTable, PartMovement> {
  $$PartMovementsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $PartsTable _partIdTable(_$AppDatabase db) =>
      db.parts.createAlias('part_movements__part_id__parts__id');

  $$PartsTableProcessedTableManager get partId {
    final $_column = $_itemColumn<int>('part_id')!;

    final manager = $$PartsTableTableManager($_db, $_db.parts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_partIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TicketsTable _ticketIdTable(_$AppDatabase db) =>
      db.tickets.createAlias('part_movements__ticket_id__tickets__id');

  $$TicketsTableProcessedTableManager? get ticketId {
    final $_column = $_itemColumn<int>('ticket_id');
    if ($_column == null) return null;
    final manager = $$TicketsTableTableManager($_db, $_db.tickets)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ticketIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PartMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $PartMovementsTable> {
  $$PartMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get delta => $composableBuilder(
      column: $table.delta, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get at => $composableBuilder(
      column: $table.at, builder: (column) => ColumnFilters(column));

  $$PartsTableFilterComposer get partId {
    final $$PartsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.partId,
        referencedTable: $db.parts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PartsTableFilterComposer(
              $db: $db,
              $table: $db.parts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TicketsTableFilterComposer get ticketId {
    final $$TicketsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ticketId,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableFilterComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PartMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $PartMovementsTable> {
  $$PartMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get delta => $composableBuilder(
      column: $table.delta, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get at => $composableBuilder(
      column: $table.at, builder: (column) => ColumnOrderings(column));

  $$PartsTableOrderingComposer get partId {
    final $$PartsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.partId,
        referencedTable: $db.parts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PartsTableOrderingComposer(
              $db: $db,
              $table: $db.parts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TicketsTableOrderingComposer get ticketId {
    final $$TicketsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ticketId,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableOrderingComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PartMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartMovementsTable> {
  $$PartMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get delta =>
      $composableBuilder(column: $table.delta, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  $$PartsTableAnnotationComposer get partId {
    final $$PartsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.partId,
        referencedTable: $db.parts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PartsTableAnnotationComposer(
              $db: $db,
              $table: $db.parts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TicketsTableAnnotationComposer get ticketId {
    final $$TicketsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ticketId,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableAnnotationComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PartMovementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PartMovementsTable,
    PartMovement,
    $$PartMovementsTableFilterComposer,
    $$PartMovementsTableOrderingComposer,
    $$PartMovementsTableAnnotationComposer,
    $$PartMovementsTableCreateCompanionBuilder,
    $$PartMovementsTableUpdateCompanionBuilder,
    (PartMovement, $$PartMovementsTableReferences),
    PartMovement,
    PrefetchHooks Function({bool partId, bool ticketId})> {
  $$PartMovementsTableTableManager(_$AppDatabase db, $PartMovementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartMovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> partId = const Value.absent(),
            Value<int?> ticketId = const Value.absent(),
            Value<int> delta = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<DateTime> at = const Value.absent(),
          }) =>
              PartMovementsCompanion(
            id: id,
            partId: partId,
            ticketId: ticketId,
            delta: delta,
            note: note,
            at: at,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int partId,
            Value<int?> ticketId = const Value.absent(),
            required int delta,
            Value<String?> note = const Value.absent(),
            Value<DateTime> at = const Value.absent(),
          }) =>
              PartMovementsCompanion.insert(
            id: id,
            partId: partId,
            ticketId: ticketId,
            delta: delta,
            note: note,
            at: at,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$PartMovementsTable, PartMovement>(table),
                    $$PartMovementsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({partId = false, ticketId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (partId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.partId,
                    referencedTable:
                        $$PartMovementsTableReferences._partIdTable(db),
                    referencedColumn:
                        $$PartMovementsTableReferences._partIdTable(db).id,
                  ) as T;
                }
                if (ticketId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ticketId,
                    referencedTable:
                        $$PartMovementsTableReferences._ticketIdTable(db),
                    referencedColumn:
                        $$PartMovementsTableReferences._ticketIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PartMovementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PartMovementsTable,
    PartMovement,
    $$PartMovementsTableFilterComposer,
    $$PartMovementsTableOrderingComposer,
    $$PartMovementsTableAnnotationComposer,
    $$PartMovementsTableCreateCompanionBuilder,
    $$PartMovementsTableUpdateCompanionBuilder,
    (PartMovement, $$PartMovementsTableReferences),
    PartMovement,
    PrefetchHooks Function({bool partId, bool ticketId})>;
typedef $$MerchProductsTableCreateCompanionBuilder = MerchProductsCompanion
    Function({
  Value<int> id,
  required String name,
  Value<String?> category,
  Value<String?> description,
  Value<String?> sku,
  Value<String?> location,
  Value<int> stock,
  Value<int> costCents,
  Value<int> priceCents,
  Value<bool> isActive,
});
typedef $$MerchProductsTableUpdateCompanionBuilder = MerchProductsCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String?> category,
  Value<String?> description,
  Value<String?> sku,
  Value<String?> location,
  Value<int> stock,
  Value<int> costCents,
  Value<int> priceCents,
  Value<bool> isActive,
});

final class $$MerchProductsTableReferences
    extends BaseReferences<_$AppDatabase, $MerchProductsTable, MerchProduct> {
  $$MerchProductsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MerchVariantsTable, List<MerchVariant>>
      _merchVariantsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.merchVariants,
              aliasName: 'merch_products__id__merch_variants__product_id');

  $$MerchVariantsTableProcessedTableManager get merchVariantsRefs {
    final manager = $$MerchVariantsTableTableManager($_db, $_db.merchVariants)
        .filter((f) => f.productId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_merchVariantsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MerchProductsTableFilterComposer
    extends Composer<_$AppDatabase, $MerchProductsTable> {
  $$MerchProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stock => $composableBuilder(
      column: $table.stock, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get costCents => $composableBuilder(
      column: $table.costCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priceCents => $composableBuilder(
      column: $table.priceCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  Expression<bool> merchVariantsRefs(
      Expression<bool> Function($$MerchVariantsTableFilterComposer f) f) {
    final $$MerchVariantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.merchVariants,
        getReferencedColumn: (t) => t.productId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MerchVariantsTableFilterComposer(
              $db: $db,
              $table: $db.merchVariants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MerchProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $MerchProductsTable> {
  $$MerchProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stock => $composableBuilder(
      column: $table.stock, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get costCents => $composableBuilder(
      column: $table.costCents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priceCents => $composableBuilder(
      column: $table.priceCents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));
}

class $$MerchProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MerchProductsTable> {
  $$MerchProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<int> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<int> get costCents =>
      $composableBuilder(column: $table.costCents, builder: (column) => column);

  GeneratedColumn<int> get priceCents => $composableBuilder(
      column: $table.priceCents, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  Expression<T> merchVariantsRefs<T extends Object>(
      Expression<T> Function($$MerchVariantsTableAnnotationComposer a) f) {
    final $$MerchVariantsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.merchVariants,
        getReferencedColumn: (t) => t.productId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MerchVariantsTableAnnotationComposer(
              $db: $db,
              $table: $db.merchVariants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MerchProductsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MerchProductsTable,
    MerchProduct,
    $$MerchProductsTableFilterComposer,
    $$MerchProductsTableOrderingComposer,
    $$MerchProductsTableAnnotationComposer,
    $$MerchProductsTableCreateCompanionBuilder,
    $$MerchProductsTableUpdateCompanionBuilder,
    (MerchProduct, $$MerchProductsTableReferences),
    MerchProduct,
    PrefetchHooks Function({bool merchVariantsRefs})> {
  $$MerchProductsTableTableManager(_$AppDatabase db, $MerchProductsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MerchProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MerchProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MerchProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> sku = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<int> stock = const Value.absent(),
            Value<int> costCents = const Value.absent(),
            Value<int> priceCents = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
          }) =>
              MerchProductsCompanion(
            id: id,
            name: name,
            category: category,
            description: description,
            sku: sku,
            location: location,
            stock: stock,
            costCents: costCents,
            priceCents: priceCents,
            isActive: isActive,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> category = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> sku = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<int> stock = const Value.absent(),
            Value<int> costCents = const Value.absent(),
            Value<int> priceCents = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
          }) =>
              MerchProductsCompanion.insert(
            id: id,
            name: name,
            category: category,
            description: description,
            sku: sku,
            location: location,
            stock: stock,
            costCents: costCents,
            priceCents: priceCents,
            isActive: isActive,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$MerchProductsTable, MerchProduct>(table),
                    $$MerchProductsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({merchVariantsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (merchVariantsRefs) db.merchVariants
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (merchVariantsRefs)
                    await $_getPrefetchedDataByColumns<
                            MerchProduct,
                            $MerchProductsTable,
                            MerchVariant,
                            $MerchVariantsTable>(
                        currentTable: table,
                        referencedTable: $$MerchProductsTableReferences
                            ._merchVariantsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MerchProductsTableReferences(db, table, p0)
                                .merchVariantsRefs,
                        currentColumn: 'id',
                        referencedColumn: 'product_id',
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$MerchProductsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MerchProductsTable,
    MerchProduct,
    $$MerchProductsTableFilterComposer,
    $$MerchProductsTableOrderingComposer,
    $$MerchProductsTableAnnotationComposer,
    $$MerchProductsTableCreateCompanionBuilder,
    $$MerchProductsTableUpdateCompanionBuilder,
    (MerchProduct, $$MerchProductsTableReferences),
    MerchProduct,
    PrefetchHooks Function({bool merchVariantsRefs})>;
typedef $$MerchVariantsTableCreateCompanionBuilder = MerchVariantsCompanion
    Function({
  Value<int> id,
  required int productId,
  required String label,
  Value<String?> sku,
  Value<String?> barcode,
  Value<int> stock,
  Value<int> costCents,
  Value<int> priceCents,
  Value<bool> isActive,
});
typedef $$MerchVariantsTableUpdateCompanionBuilder = MerchVariantsCompanion
    Function({
  Value<int> id,
  Value<int> productId,
  Value<String> label,
  Value<String?> sku,
  Value<String?> barcode,
  Value<int> stock,
  Value<int> costCents,
  Value<int> priceCents,
  Value<bool> isActive,
});

final class $$MerchVariantsTableReferences
    extends BaseReferences<_$AppDatabase, $MerchVariantsTable, MerchVariant> {
  $$MerchVariantsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $MerchProductsTable _productIdTable(_$AppDatabase db) =>
      db.merchProducts
          .createAlias('merch_variants__product_id__merch_products__id');

  $$MerchProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<int>('product_id')!;

    final manager = $$MerchProductsTableTableManager($_db, $_db.merchProducts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$MerchSaleLinesTable, List<MerchSaleLine>>
      _merchSaleLinesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.merchSaleLines,
              aliasName: 'merch_variants__id__merch_sale_lines__variant_id');

  $$MerchSaleLinesTableProcessedTableManager get merchSaleLinesRefs {
    final manager = $$MerchSaleLinesTableTableManager($_db, $_db.merchSaleLines)
        .filter((f) => f.variantId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_merchSaleLinesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MerchVariantsTableFilterComposer
    extends Composer<_$AppDatabase, $MerchVariantsTable> {
  $$MerchVariantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stock => $composableBuilder(
      column: $table.stock, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get costCents => $composableBuilder(
      column: $table.costCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priceCents => $composableBuilder(
      column: $table.priceCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  $$MerchProductsTableFilterComposer get productId {
    final $$MerchProductsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.merchProducts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MerchProductsTableFilterComposer(
              $db: $db,
              $table: $db.merchProducts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> merchSaleLinesRefs(
      Expression<bool> Function($$MerchSaleLinesTableFilterComposer f) f) {
    final $$MerchSaleLinesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.merchSaleLines,
        getReferencedColumn: (t) => t.variantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MerchSaleLinesTableFilterComposer(
              $db: $db,
              $table: $db.merchSaleLines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MerchVariantsTableOrderingComposer
    extends Composer<_$AppDatabase, $MerchVariantsTable> {
  $$MerchVariantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stock => $composableBuilder(
      column: $table.stock, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get costCents => $composableBuilder(
      column: $table.costCents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priceCents => $composableBuilder(
      column: $table.priceCents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  $$MerchProductsTableOrderingComposer get productId {
    final $$MerchProductsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.merchProducts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MerchProductsTableOrderingComposer(
              $db: $db,
              $table: $db.merchProducts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MerchVariantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MerchVariantsTable> {
  $$MerchVariantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<int> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<int> get costCents =>
      $composableBuilder(column: $table.costCents, builder: (column) => column);

  GeneratedColumn<int> get priceCents => $composableBuilder(
      column: $table.priceCents, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  $$MerchProductsTableAnnotationComposer get productId {
    final $$MerchProductsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.merchProducts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MerchProductsTableAnnotationComposer(
              $db: $db,
              $table: $db.merchProducts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> merchSaleLinesRefs<T extends Object>(
      Expression<T> Function($$MerchSaleLinesTableAnnotationComposer a) f) {
    final $$MerchSaleLinesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.merchSaleLines,
        getReferencedColumn: (t) => t.variantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MerchSaleLinesTableAnnotationComposer(
              $db: $db,
              $table: $db.merchSaleLines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MerchVariantsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MerchVariantsTable,
    MerchVariant,
    $$MerchVariantsTableFilterComposer,
    $$MerchVariantsTableOrderingComposer,
    $$MerchVariantsTableAnnotationComposer,
    $$MerchVariantsTableCreateCompanionBuilder,
    $$MerchVariantsTableUpdateCompanionBuilder,
    (MerchVariant, $$MerchVariantsTableReferences),
    MerchVariant,
    PrefetchHooks Function({bool productId, bool merchSaleLinesRefs})> {
  $$MerchVariantsTableTableManager(_$AppDatabase db, $MerchVariantsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MerchVariantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MerchVariantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MerchVariantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> productId = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<String?> sku = const Value.absent(),
            Value<String?> barcode = const Value.absent(),
            Value<int> stock = const Value.absent(),
            Value<int> costCents = const Value.absent(),
            Value<int> priceCents = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
          }) =>
              MerchVariantsCompanion(
            id: id,
            productId: productId,
            label: label,
            sku: sku,
            barcode: barcode,
            stock: stock,
            costCents: costCents,
            priceCents: priceCents,
            isActive: isActive,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int productId,
            required String label,
            Value<String?> sku = const Value.absent(),
            Value<String?> barcode = const Value.absent(),
            Value<int> stock = const Value.absent(),
            Value<int> costCents = const Value.absent(),
            Value<int> priceCents = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
          }) =>
              MerchVariantsCompanion.insert(
            id: id,
            productId: productId,
            label: label,
            sku: sku,
            barcode: barcode,
            stock: stock,
            costCents: costCents,
            priceCents: priceCents,
            isActive: isActive,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$MerchVariantsTable, MerchVariant>(table),
                    $$MerchVariantsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {productId = false, merchSaleLinesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (merchSaleLinesRefs) db.merchSaleLines
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (productId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.productId,
                    referencedTable:
                        $$MerchVariantsTableReferences._productIdTable(db),
                    referencedColumn:
                        $$MerchVariantsTableReferences._productIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (merchSaleLinesRefs)
                    await $_getPrefetchedDataByColumns<
                            MerchVariant,
                            $MerchVariantsTable,
                            MerchSaleLine,
                            $MerchSaleLinesTable>(
                        currentTable: table,
                        referencedTable: $$MerchVariantsTableReferences
                            ._merchSaleLinesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MerchVariantsTableReferences(db, table, p0)
                                .merchSaleLinesRefs,
                        currentColumn: 'id',
                        referencedColumn: 'variant_id',
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$MerchVariantsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MerchVariantsTable,
    MerchVariant,
    $$MerchVariantsTableFilterComposer,
    $$MerchVariantsTableOrderingComposer,
    $$MerchVariantsTableAnnotationComposer,
    $$MerchVariantsTableCreateCompanionBuilder,
    $$MerchVariantsTableUpdateCompanionBuilder,
    (MerchVariant, $$MerchVariantsTableReferences),
    MerchVariant,
    PrefetchHooks Function({bool productId, bool merchSaleLinesRefs})>;
typedef $$MerchSalesTableCreateCompanionBuilder = MerchSalesCompanion Function({
  Value<int> id,
  required String number,
  Value<int?> customerId,
  Value<DateTime> at,
  required PaymentMethod paymentMethod,
  Value<int> totalCents,
  Value<String?> note,
});
typedef $$MerchSalesTableUpdateCompanionBuilder = MerchSalesCompanion Function({
  Value<int> id,
  Value<String> number,
  Value<int?> customerId,
  Value<DateTime> at,
  Value<PaymentMethod> paymentMethod,
  Value<int> totalCents,
  Value<String?> note,
});

final class $$MerchSalesTableReferences
    extends BaseReferences<_$AppDatabase, $MerchSalesTable, MerchSale> {
  $$MerchSalesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias('merch_sales__customer_id__customers__id');

  $$CustomersTableProcessedTableManager? get customerId {
    final $_column = $_itemColumn<int>('customer_id');
    if ($_column == null) return null;
    final manager = $$CustomersTableTableManager($_db, $_db.customers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$MerchSaleLinesTable, List<MerchSaleLine>>
      _merchSaleLinesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.merchSaleLines,
              aliasName: 'merch_sales__id__merch_sale_lines__sale_id');

  $$MerchSaleLinesTableProcessedTableManager get merchSaleLinesRefs {
    final manager = $$MerchSaleLinesTableTableManager($_db, $_db.merchSaleLines)
        .filter((f) => f.saleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_merchSaleLinesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MerchSalesTableFilterComposer
    extends Composer<_$AppDatabase, $MerchSalesTable> {
  $$MerchSalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get at => $composableBuilder(
      column: $table.at, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<PaymentMethod, PaymentMethod, int>
      get paymentMethod => $composableBuilder(
          column: $table.paymentMethod,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get totalCents => $composableBuilder(
      column: $table.totalCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.customerId,
        referencedTable: $db.customers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomersTableFilterComposer(
              $db: $db,
              $table: $db.customers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> merchSaleLinesRefs(
      Expression<bool> Function($$MerchSaleLinesTableFilterComposer f) f) {
    final $$MerchSaleLinesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.merchSaleLines,
        getReferencedColumn: (t) => t.saleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MerchSaleLinesTableFilterComposer(
              $db: $db,
              $table: $db.merchSaleLines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MerchSalesTableOrderingComposer
    extends Composer<_$AppDatabase, $MerchSalesTable> {
  $$MerchSalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get at => $composableBuilder(
      column: $table.at, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalCents => $composableBuilder(
      column: $table.totalCents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.customerId,
        referencedTable: $db.customers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomersTableOrderingComposer(
              $db: $db,
              $table: $db.customers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MerchSalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MerchSalesTable> {
  $$MerchSalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PaymentMethod, int> get paymentMethod =>
      $composableBuilder(
          column: $table.paymentMethod, builder: (column) => column);

  GeneratedColumn<int> get totalCents => $composableBuilder(
      column: $table.totalCents, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.customerId,
        referencedTable: $db.customers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomersTableAnnotationComposer(
              $db: $db,
              $table: $db.customers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> merchSaleLinesRefs<T extends Object>(
      Expression<T> Function($$MerchSaleLinesTableAnnotationComposer a) f) {
    final $$MerchSaleLinesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.merchSaleLines,
        getReferencedColumn: (t) => t.saleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MerchSaleLinesTableAnnotationComposer(
              $db: $db,
              $table: $db.merchSaleLines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MerchSalesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MerchSalesTable,
    MerchSale,
    $$MerchSalesTableFilterComposer,
    $$MerchSalesTableOrderingComposer,
    $$MerchSalesTableAnnotationComposer,
    $$MerchSalesTableCreateCompanionBuilder,
    $$MerchSalesTableUpdateCompanionBuilder,
    (MerchSale, $$MerchSalesTableReferences),
    MerchSale,
    PrefetchHooks Function({bool customerId, bool merchSaleLinesRefs})> {
  $$MerchSalesTableTableManager(_$AppDatabase db, $MerchSalesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MerchSalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MerchSalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MerchSalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> number = const Value.absent(),
            Value<int?> customerId = const Value.absent(),
            Value<DateTime> at = const Value.absent(),
            Value<PaymentMethod> paymentMethod = const Value.absent(),
            Value<int> totalCents = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) =>
              MerchSalesCompanion(
            id: id,
            number: number,
            customerId: customerId,
            at: at,
            paymentMethod: paymentMethod,
            totalCents: totalCents,
            note: note,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String number,
            Value<int?> customerId = const Value.absent(),
            Value<DateTime> at = const Value.absent(),
            required PaymentMethod paymentMethod,
            Value<int> totalCents = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) =>
              MerchSalesCompanion.insert(
            id: id,
            number: number,
            customerId: customerId,
            at: at,
            paymentMethod: paymentMethod,
            totalCents: totalCents,
            note: note,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$MerchSalesTable, MerchSale>(table),
                    $$MerchSalesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {customerId = false, merchSaleLinesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (merchSaleLinesRefs) db.merchSaleLines
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (customerId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.customerId,
                    referencedTable:
                        $$MerchSalesTableReferences._customerIdTable(db),
                    referencedColumn:
                        $$MerchSalesTableReferences._customerIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (merchSaleLinesRefs)
                    await $_getPrefetchedDataByColumns<
                            MerchSale,
                            $MerchSalesTable,
                            MerchSaleLine,
                            $MerchSaleLinesTable>(
                        currentTable: table,
                        referencedTable: $$MerchSalesTableReferences
                            ._merchSaleLinesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MerchSalesTableReferences(db, table, p0)
                                .merchSaleLinesRefs,
                        currentColumn: 'id',
                        referencedColumn: 'sale_id',
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$MerchSalesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MerchSalesTable,
    MerchSale,
    $$MerchSalesTableFilterComposer,
    $$MerchSalesTableOrderingComposer,
    $$MerchSalesTableAnnotationComposer,
    $$MerchSalesTableCreateCompanionBuilder,
    $$MerchSalesTableUpdateCompanionBuilder,
    (MerchSale, $$MerchSalesTableReferences),
    MerchSale,
    PrefetchHooks Function({bool customerId, bool merchSaleLinesRefs})>;
typedef $$MerchSaleLinesTableCreateCompanionBuilder = MerchSaleLinesCompanion
    Function({
  Value<int> id,
  required int saleId,
  required int variantId,
  Value<int> quantity,
  required int unitPriceCents,
  Value<int?> unitCostCents,
});
typedef $$MerchSaleLinesTableUpdateCompanionBuilder = MerchSaleLinesCompanion
    Function({
  Value<int> id,
  Value<int> saleId,
  Value<int> variantId,
  Value<int> quantity,
  Value<int> unitPriceCents,
  Value<int?> unitCostCents,
});

final class $$MerchSaleLinesTableReferences
    extends BaseReferences<_$AppDatabase, $MerchSaleLinesTable, MerchSaleLine> {
  $$MerchSaleLinesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $MerchSalesTable _saleIdTable(_$AppDatabase db) =>
      db.merchSales.createAlias('merch_sale_lines__sale_id__merch_sales__id');

  $$MerchSalesTableProcessedTableManager get saleId {
    final $_column = $_itemColumn<int>('sale_id')!;

    final manager = $$MerchSalesTableTableManager($_db, $_db.merchSales)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_saleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $MerchVariantsTable _variantIdTable(_$AppDatabase db) =>
      db.merchVariants
          .createAlias('merch_sale_lines__variant_id__merch_variants__id');

  $$MerchVariantsTableProcessedTableManager get variantId {
    final $_column = $_itemColumn<int>('variant_id')!;

    final manager = $$MerchVariantsTableTableManager($_db, $_db.merchVariants)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_variantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MerchSaleLinesTableFilterComposer
    extends Composer<_$AppDatabase, $MerchSaleLinesTable> {
  $$MerchSaleLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unitPriceCents => $composableBuilder(
      column: $table.unitPriceCents,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unitCostCents => $composableBuilder(
      column: $table.unitCostCents, builder: (column) => ColumnFilters(column));

  $$MerchSalesTableFilterComposer get saleId {
    final $$MerchSalesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.saleId,
        referencedTable: $db.merchSales,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MerchSalesTableFilterComposer(
              $db: $db,
              $table: $db.merchSales,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$MerchVariantsTableFilterComposer get variantId {
    final $$MerchVariantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.variantId,
        referencedTable: $db.merchVariants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MerchVariantsTableFilterComposer(
              $db: $db,
              $table: $db.merchVariants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MerchSaleLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $MerchSaleLinesTable> {
  $$MerchSaleLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unitPriceCents => $composableBuilder(
      column: $table.unitPriceCents,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unitCostCents => $composableBuilder(
      column: $table.unitCostCents,
      builder: (column) => ColumnOrderings(column));

  $$MerchSalesTableOrderingComposer get saleId {
    final $$MerchSalesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.saleId,
        referencedTable: $db.merchSales,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MerchSalesTableOrderingComposer(
              $db: $db,
              $table: $db.merchSales,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$MerchVariantsTableOrderingComposer get variantId {
    final $$MerchVariantsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.variantId,
        referencedTable: $db.merchVariants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MerchVariantsTableOrderingComposer(
              $db: $db,
              $table: $db.merchVariants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MerchSaleLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MerchSaleLinesTable> {
  $$MerchSaleLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get unitPriceCents => $composableBuilder(
      column: $table.unitPriceCents, builder: (column) => column);

  GeneratedColumn<int> get unitCostCents => $composableBuilder(
      column: $table.unitCostCents, builder: (column) => column);

  $$MerchSalesTableAnnotationComposer get saleId {
    final $$MerchSalesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.saleId,
        referencedTable: $db.merchSales,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MerchSalesTableAnnotationComposer(
              $db: $db,
              $table: $db.merchSales,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$MerchVariantsTableAnnotationComposer get variantId {
    final $$MerchVariantsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.variantId,
        referencedTable: $db.merchVariants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MerchVariantsTableAnnotationComposer(
              $db: $db,
              $table: $db.merchVariants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MerchSaleLinesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MerchSaleLinesTable,
    MerchSaleLine,
    $$MerchSaleLinesTableFilterComposer,
    $$MerchSaleLinesTableOrderingComposer,
    $$MerchSaleLinesTableAnnotationComposer,
    $$MerchSaleLinesTableCreateCompanionBuilder,
    $$MerchSaleLinesTableUpdateCompanionBuilder,
    (MerchSaleLine, $$MerchSaleLinesTableReferences),
    MerchSaleLine,
    PrefetchHooks Function({bool saleId, bool variantId})> {
  $$MerchSaleLinesTableTableManager(
      _$AppDatabase db, $MerchSaleLinesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MerchSaleLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MerchSaleLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MerchSaleLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> saleId = const Value.absent(),
            Value<int> variantId = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<int> unitPriceCents = const Value.absent(),
            Value<int?> unitCostCents = const Value.absent(),
          }) =>
              MerchSaleLinesCompanion(
            id: id,
            saleId: saleId,
            variantId: variantId,
            quantity: quantity,
            unitPriceCents: unitPriceCents,
            unitCostCents: unitCostCents,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int saleId,
            required int variantId,
            Value<int> quantity = const Value.absent(),
            required int unitPriceCents,
            Value<int?> unitCostCents = const Value.absent(),
          }) =>
              MerchSaleLinesCompanion.insert(
            id: id,
            saleId: saleId,
            variantId: variantId,
            quantity: quantity,
            unitPriceCents: unitPriceCents,
            unitCostCents: unitCostCents,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$MerchSaleLinesTable, MerchSaleLine>(table),
                    $$MerchSaleLinesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({saleId = false, variantId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (saleId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.saleId,
                    referencedTable:
                        $$MerchSaleLinesTableReferences._saleIdTable(db),
                    referencedColumn:
                        $$MerchSaleLinesTableReferences._saleIdTable(db).id,
                  ) as T;
                }
                if (variantId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.variantId,
                    referencedTable:
                        $$MerchSaleLinesTableReferences._variantIdTable(db),
                    referencedColumn:
                        $$MerchSaleLinesTableReferences._variantIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$MerchSaleLinesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MerchSaleLinesTable,
    MerchSaleLine,
    $$MerchSaleLinesTableFilterComposer,
    $$MerchSaleLinesTableOrderingComposer,
    $$MerchSaleLinesTableAnnotationComposer,
    $$MerchSaleLinesTableCreateCompanionBuilder,
    $$MerchSaleLinesTableUpdateCompanionBuilder,
    (MerchSaleLine, $$MerchSaleLinesTableReferences),
    MerchSaleLine,
    PrefetchHooks Function({bool saleId, bool variantId})>;
typedef $$PaymentsTableCreateCompanionBuilder = PaymentsCompanion Function({
  Value<int> id,
  required int ticketId,
  Value<DateTime> at,
  required int amountCents,
  required PaymentMethod method,
  required PaymentKind kind,
  Value<String?> note,
});
typedef $$PaymentsTableUpdateCompanionBuilder = PaymentsCompanion Function({
  Value<int> id,
  Value<int> ticketId,
  Value<DateTime> at,
  Value<int> amountCents,
  Value<PaymentMethod> method,
  Value<PaymentKind> kind,
  Value<String?> note,
});

final class $$PaymentsTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentsTable, Payment> {
  $$PaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TicketsTable _ticketIdTable(_$AppDatabase db) =>
      db.tickets.createAlias('payments__ticket_id__tickets__id');

  $$TicketsTableProcessedTableManager get ticketId {
    final $_column = $_itemColumn<int>('ticket_id')!;

    final manager = $$TicketsTableTableManager($_db, $_db.tickets)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ticketIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get at => $composableBuilder(
      column: $table.at, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountCents => $composableBuilder(
      column: $table.amountCents, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<PaymentMethod, PaymentMethod, int>
      get method => $composableBuilder(
          column: $table.method,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<PaymentKind, PaymentKind, int> get kind =>
      $composableBuilder(
          column: $table.kind,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  $$TicketsTableFilterComposer get ticketId {
    final $$TicketsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ticketId,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableFilterComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get at => $composableBuilder(
      column: $table.at, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountCents => $composableBuilder(
      column: $table.amountCents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  $$TicketsTableOrderingComposer get ticketId {
    final $$TicketsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ticketId,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableOrderingComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
      column: $table.amountCents, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PaymentMethod, int> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PaymentKind, int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$TicketsTableAnnotationComposer get ticketId {
    final $$TicketsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ticketId,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableAnnotationComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PaymentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PaymentsTable,
    Payment,
    $$PaymentsTableFilterComposer,
    $$PaymentsTableOrderingComposer,
    $$PaymentsTableAnnotationComposer,
    $$PaymentsTableCreateCompanionBuilder,
    $$PaymentsTableUpdateCompanionBuilder,
    (Payment, $$PaymentsTableReferences),
    Payment,
    PrefetchHooks Function({bool ticketId})> {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> ticketId = const Value.absent(),
            Value<DateTime> at = const Value.absent(),
            Value<int> amountCents = const Value.absent(),
            Value<PaymentMethod> method = const Value.absent(),
            Value<PaymentKind> kind = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) =>
              PaymentsCompanion(
            id: id,
            ticketId: ticketId,
            at: at,
            amountCents: amountCents,
            method: method,
            kind: kind,
            note: note,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int ticketId,
            Value<DateTime> at = const Value.absent(),
            required int amountCents,
            required PaymentMethod method,
            required PaymentKind kind,
            Value<String?> note = const Value.absent(),
          }) =>
              PaymentsCompanion.insert(
            id: id,
            ticketId: ticketId,
            at: at,
            amountCents: amountCents,
            method: method,
            kind: kind,
            note: note,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$PaymentsTable, Payment>(table),
                    $$PaymentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({ticketId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (ticketId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ticketId,
                    referencedTable:
                        $$PaymentsTableReferences._ticketIdTable(db),
                    referencedColumn:
                        $$PaymentsTableReferences._ticketIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PaymentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PaymentsTable,
    Payment,
    $$PaymentsTableFilterComposer,
    $$PaymentsTableOrderingComposer,
    $$PaymentsTableAnnotationComposer,
    $$PaymentsTableCreateCompanionBuilder,
    $$PaymentsTableUpdateCompanionBuilder,
    (Payment, $$PaymentsTableReferences),
    Payment,
    PrefetchHooks Function({bool ticketId})>;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()> {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SettingsTable, Setting>(table),
                    BaseReferences<_$AppDatabase, $SettingsTable, Setting>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$DeviceCategoriesTableTableManager get deviceCategories =>
      $$DeviceCategoriesTableTableManager(_db, _db.deviceCategories);
  $$DeviceBrandsTableTableManager get deviceBrands =>
      $$DeviceBrandsTableTableManager(_db, _db.deviceBrands);
  $$DeviceModelsTableTableManager get deviceModels =>
      $$DeviceModelsTableTableManager(_db, _db.deviceModels);
  $$CustomerDevicesTableTableManager get customerDevices =>
      $$CustomerDevicesTableTableManager(_db, _db.customerDevices);
  $$PhotoTemplatesTableTableManager get photoTemplates =>
      $$PhotoTemplatesTableTableManager(_db, _db.photoTemplates);
  $$PhotoTemplateSlotsTableTableManager get photoTemplateSlots =>
      $$PhotoTemplateSlotsTableTableManager(_db, _db.photoTemplateSlots);
  $$ServicesTableTableManager get services =>
      $$ServicesTableTableManager(_db, _db.services);
  $$TicketsTableTableManager get tickets =>
      $$TicketsTableTableManager(_db, _db.tickets);
  $$ShopTagsTableTableManager get shopTags =>
      $$ShopTagsTableTableManager(_db, _db.shopTags);
  $$PartsTableTableManager get parts =>
      $$PartsTableTableManager(_db, _db.parts);
  $$TicketItemsTableTableManager get ticketItems =>
      $$TicketItemsTableTableManager(_db, _db.ticketItems);
  $$TicketPhotosTableTableManager get ticketPhotos =>
      $$TicketPhotosTableTableManager(_db, _db.ticketPhotos);
  $$TicketPhotoSlotsTableTableManager get ticketPhotoSlots =>
      $$TicketPhotoSlotsTableTableManager(_db, _db.ticketPhotoSlots);
  $$TicketReportsTableTableManager get ticketReports =>
      $$TicketReportsTableTableManager(_db, _db.ticketReports);
  $$ReportCosmeticItemsTableTableManager get reportCosmeticItems =>
      $$ReportCosmeticItemsTableTableManager(_db, _db.reportCosmeticItems);
  $$ReportFindingsTableTableManager get reportFindings =>
      $$ReportFindingsTableTableManager(_db, _db.reportFindings);
  $$TechnicalReportEntriesTableTableManager get technicalReportEntries =>
      $$TechnicalReportEntriesTableTableManager(
          _db, _db.technicalReportEntries);
  $$ClientReportEntriesTableTableManager get clientReportEntries =>
      $$ClientReportEntriesTableTableManager(_db, _db.clientReportEntries);
  $$ReportContactLogTableTableManager get reportContactLog =>
      $$ReportContactLogTableTableManager(_db, _db.reportContactLog);
  $$PartMovementsTableTableManager get partMovements =>
      $$PartMovementsTableTableManager(_db, _db.partMovements);
  $$MerchProductsTableTableManager get merchProducts =>
      $$MerchProductsTableTableManager(_db, _db.merchProducts);
  $$MerchVariantsTableTableManager get merchVariants =>
      $$MerchVariantsTableTableManager(_db, _db.merchVariants);
  $$MerchSalesTableTableManager get merchSales =>
      $$MerchSalesTableTableManager(_db, _db.merchSales);
  $$MerchSaleLinesTableTableManager get merchSaleLines =>
      $$MerchSaleLinesTableTableManager(_db, _db.merchSaleLines);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
