import 'package:drift/drift.dart' as drift;

import 'database.dart';
import 'warranty.dart';

/// One device inside a brand, as the catalog editor shows it.
///
/// The same row is what the intake form calls a model. Hiding a device keeps
/// its history but takes it out of the intake picker.
class CatalogDevice {
  const CatalogDevice({
    required this.id,
    required this.name,
    required this.isActive,
  });

  final int id;
  final String name;
  final bool isActive;
}

/// One brand heading inside a category, e.g. `Sony` under `Consoles`.
class CatalogBrand {
  const CatalogBrand({
    required this.id,
    required this.name,
    required this.devices,
    this.isActive = true,
  });

  final int id;
  final String name;
  final bool isActive;
  final List<CatalogDevice> devices;
}

/// One device category with everything filed under it.
class CatalogCategory {
  const CatalogCategory({
    required this.id,
    required this.name,
    required this.isActive,
    required this.warrantyDays,
    required this.brands,
  });

  final int id;
  final String name;
  final bool isActive;

  /// Warranty length that Report 3 offers for devices in this category.
  final int warrantyDays;
  final List<CatalogBrand> brands;

  int get deviceCount =>
      brands.fold<int>(0, (total, brand) => total + brand.devices.length);
}

/// A catalog name or value was blank, too long, out of range, or already taken.
///
/// The message is ready for a snackbar, so the pages do not have to repeat the
/// same wording.
class CatalogNameError implements Exception {
  const CatalogNameError(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Reads and edits the category → brand → device tree used by intake.
///
/// Deleting always clears the catalog link on tickets and customer devices
/// first. Those rows keep their recorded `deviceName`, so removing a device
/// from the picker never rewrites old jobs.
class DeviceCatalog {
  const DeviceCatalog(this._db);

  final AppDatabase _db;

  static const int maxCategoryLength = 60;
  static const int maxBrandLength = 60;
  static const int maxDeviceLength = 80;

  /// Every category, brand and device, in intake order.
  Stream<List<CatalogCategory>> watch() {
    final query = _db.select(_db.deviceCategories).join([
      drift.leftOuterJoin(
        _db.deviceBrands,
        _db.deviceBrands.categoryId.equalsExp(_db.deviceCategories.id),
      ),
      drift.leftOuterJoin(
        _db.deviceModels,
        _db.deviceModels.brandId.equalsExp(_db.deviceBrands.id),
      ),
    ])
      ..orderBy([
        drift.OrderingTerm.asc(_db.deviceCategories.sortOrder),
        drift.OrderingTerm.asc(_db.deviceCategories.name),
        drift.OrderingTerm.asc(_db.deviceBrands.name),
        drift.OrderingTerm.asc(_db.deviceModels.sortOrder),
        drift.OrderingTerm.asc(_db.deviceModels.name),
      ]);
    return query.watch().map(_group);
  }

  /// One category for its own page, or null once it has been deleted.
  Stream<CatalogCategory?> watchCategory(int categoryId) => watch().map(
        (categories) {
          for (final category in categories) {
            if (category.id == categoryId) return category;
          }
          return null;
        },
      );

  List<CatalogCategory> _group(List<drift.TypedResult> rows) {
    final categories = <int, _CategoryBuilder>{};
    for (final row in rows) {
      final category = row.readTable(_db.deviceCategories);
      final builder = categories.putIfAbsent(
        category.id,
        () => _CategoryBuilder(
          id: category.id,
          name: category.name,
          isActive: category.isActive,
          warrantyDays: category.warrantyDays,
        ),
      );
      final brand = row.readTableOrNull(_db.deviceBrands);
      if (brand == null) continue;
      final brandBuilder = builder.brands.putIfAbsent(
        brand.id,
        () => _BrandBuilder(
          id: brand.id,
          name: brand.name,
          isActive: brand.isActive,
        ),
      );
      final device = row.readTableOrNull(_db.deviceModels);
      if (device == null) continue;
      brandBuilder.devices.add(
        CatalogDevice(
          id: device.id,
          name: device.name,
          isActive: device.isActive,
        ),
      );
    }
    // Map insertion order follows the query, which is already in intake order
    // (category sort order, then name).
    return [for (final category in categories.values) category.build()];
  }

  // ---------------------------------------------------------------- categories

  Future<int> addCategory(String name) async {
    final clean = _cleanName(name, maxCategoryLength, 'category');
    await _ensureCategoryName(clean);
    final rows = await _db.select(_db.deviceCategories).get();
    final nextOrder = rows.fold<int>(
      0,
      (maxOrder, category) =>
          category.sortOrder >= maxOrder ? category.sortOrder + 1 : maxOrder,
    );
    return _db.into(_db.deviceCategories).insert(
          DeviceCategoriesCompanion.insert(
            name: clean,
            sortOrder: drift.Value(nextOrder),
          ),
        );
  }

  Future<void> renameCategory(int categoryId, String name) async {
    final clean = _cleanName(name, maxCategoryLength, 'category');
    await _ensureCategoryName(clean, exceptId: categoryId);
    await (_db.update(_db.deviceCategories)
          ..where((category) => category.id.equals(categoryId)))
        .write(DeviceCategoriesCompanion(name: drift.Value(clean)));
  }

  Future<void> setCategoryActive(int categoryId, bool isActive) async {
    await (_db.update(_db.deviceCategories)
          ..where((category) => category.id.equals(categoryId)))
        .write(DeviceCategoriesCompanion(isActive: drift.Value(isActive)));
  }

  Future<void> setCategoryWarrantyDays(int categoryId, int days) async {
    try {
      WarrantyConfig.requireDays(days);
    } on ArgumentError {
      throw const CatalogNameError(
        'Warranty period must be between 1 and '
        '${WarrantyConfig.maxDays} days.',
      );
    }
    await (_db.update(_db.deviceCategories)
          ..where((category) => category.id.equals(categoryId)))
        .write(DeviceCategoriesCompanion(warrantyDays: drift.Value(days)));
  }

  /// Removes the category and every brand and device under it.
  Future<void> deleteCategory(int categoryId) => _db.transaction(() async {
        final brands = await (_db.select(_db.deviceBrands)
              ..where((brand) => brand.categoryId.equals(categoryId)))
            .get();
        for (final brand in brands) {
          await _deleteBrandRows(brand.id);
        }
        await (_db.delete(_db.deviceBrands)
              ..where((brand) => brand.categoryId.equals(categoryId)))
            .go();
        await (_db.delete(_db.deviceCategories)
              ..where((category) => category.id.equals(categoryId)))
            .go();
      });

  // -------------------------------------------------------------------- brands

  Future<int> addBrand(int categoryId, String name) async {
    final clean = _cleanName(name, maxBrandLength, 'heading');
    await _ensureBrandName(categoryId, clean);
    return _db.into(_db.deviceBrands).insert(
          DeviceBrandsCompanion.insert(categoryId: categoryId, name: clean),
        );
  }

  Future<void> renameBrand(int brandId, String name) async {
    final clean = _cleanName(name, maxBrandLength, 'heading');
    final brand = await _brandById(brandId);
    await _ensureBrandName(brand.categoryId, clean, exceptId: brandId);
    await (_db.update(_db.deviceBrands)..where((row) => row.id.equals(brandId)))
        .write(DeviceBrandsCompanion(name: drift.Value(clean)));
  }

  Future<void> setBrandActive(int brandId, bool isActive) async {
    await (_db.update(_db.deviceBrands)..where((row) => row.id.equals(brandId)))
        .write(DeviceBrandsCompanion(isActive: drift.Value(isActive)));
  }

  /// Removes a brand heading and every device under it.
  Future<void> deleteBrand(int brandId) => _db.transaction(() async {
        await _deleteBrandRows(brandId);
        await (_db.delete(_db.deviceBrands)
              ..where((brand) => brand.id.equals(brandId)))
            .go();
      });

  // ------------------------------------------------------------------- devices

  Future<int> addDevice(int brandId, String name) async {
    final clean = _cleanName(name, maxDeviceLength, 'device');
    await _ensureDeviceName(brandId, clean);
    final rows = await (_db.select(_db.deviceModels)
          ..where((device) => device.brandId.equals(brandId)))
        .get();
    final nextOrder = rows.fold<int>(
      0,
      (maxOrder, device) =>
          device.sortOrder >= maxOrder ? device.sortOrder + 1 : maxOrder,
    );
    return _db.into(_db.deviceModels).insert(
          DeviceModelsCompanion.insert(
            brandId: brandId,
            name: clean,
            sortOrder: drift.Value(nextOrder),
          ),
        );
  }

  Future<void> renameDevice(int deviceId, String name) async {
    final clean = _cleanName(name, maxDeviceLength, 'device');
    final device = await _deviceById(deviceId);
    await _ensureDeviceName(device.brandId, clean, exceptId: deviceId);
    await (_db.update(_db.deviceModels)
          ..where((row) => row.id.equals(deviceId)))
        .write(DeviceModelsCompanion(name: drift.Value(clean)));
  }

  Future<void> setDeviceActive(int deviceId, bool isActive) async {
    await (_db.update(_db.deviceModels)
          ..where((device) => device.id.equals(deviceId)))
        .write(DeviceModelsCompanion(isActive: drift.Value(isActive)));
  }

  Future<void> deleteDevice(int deviceId) => _db.transaction(() async {
        await _clearDeviceReferences([deviceId]);
        await (_db.delete(_db.deviceModels)
              ..where((device) => device.id.equals(deviceId)))
            .go();
      });

  // -------------------------------------------------------------------- shared

  Future<void> _deleteBrandRows(int brandId) async {
    final devices = await (_db.select(_db.deviceModels)
          ..where((device) => device.brandId.equals(brandId)))
        .get();
    await _clearDeviceReferences([for (final device in devices) device.id]);
    await (_db.delete(_db.deviceModels)
          ..where((device) => device.brandId.equals(brandId)))
        .go();
  }

  /// Detaches tickets and saved customer devices from catalog rows that are
  /// about to disappear. Both keep their own device name text.
  Future<void> _clearDeviceReferences(List<int> deviceIds) async {
    if (deviceIds.isEmpty) return;
    await (_db.update(_db.tickets)
          ..where((ticket) => ticket.deviceModelId.isIn(deviceIds)))
        .write(
      const TicketsCompanion(deviceModelId: drift.Value<int?>(null)),
    );
    await (_db.update(_db.customerDevices)
          ..where((device) => device.deviceModelId.isIn(deviceIds)))
        .write(
      const CustomerDevicesCompanion(
        deviceModelId: drift.Value<int?>(null),
      ),
    );
  }

  Future<void> _ensureCategoryName(String name, {int? exceptId}) async {
    final query = _db.select(_db.deviceCategories)
      ..where((category) => category.name.equals(name));
    if (exceptId != null) {
      query.where((category) => category.id.equals(exceptId).not());
    }
    if (await query.getSingleOrNull() != null) {
      throw CatalogNameError('"$name" is already a category.');
    }
  }

  Future<void> _ensureBrandName(
    int categoryId,
    String name, {
    int? exceptId,
  }) async {
    final query = _db.select(_db.deviceBrands)
      ..where(
        (brand) =>
            brand.categoryId.equals(categoryId) & brand.name.equals(name),
      );
    if (exceptId != null) {
      query.where((brand) => brand.id.equals(exceptId).not());
    }
    if (await query.getSingleOrNull() != null) {
      throw CatalogNameError('"$name" is already a heading in this category.');
    }
  }

  Future<void> _ensureDeviceName(
    int brandId,
    String name, {
    int? exceptId,
  }) async {
    final query = _db.select(_db.deviceModels)
      ..where((device) =>
          device.brandId.equals(brandId) & device.name.equals(name));
    if (exceptId != null) {
      query.where((device) => device.id.equals(exceptId).not());
    }
    if (await query.getSingleOrNull() != null) {
      throw CatalogNameError('"$name" is already listed in this heading.');
    }
  }

  Future<DeviceBrand> _brandById(int brandId) async {
    final brand = await (_db.select(_db.deviceBrands)
          ..where((row) => row.id.equals(brandId)))
        .getSingleOrNull();
    if (brand == null) {
      throw const CatalogNameError('That heading no longer exists.');
    }
    return brand;
  }

  Future<DeviceModel> _deviceById(int deviceId) async {
    final device = await (_db.select(_db.deviceModels)
          ..where((row) => row.id.equals(deviceId)))
        .getSingleOrNull();
    if (device == null) {
      throw const CatalogNameError('That device no longer exists.');
    }
    return device;
  }

  /// Trims, collapses inner spaces, and enforces the column limits.
  String _cleanName(String raw, int maxLength, String kind) {
    final clean = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (clean.isEmpty) {
      throw CatalogNameError('Enter a $kind name.');
    }
    if (clean.length > maxLength) {
      throw CatalogNameError(
        'A $kind name can be at most $maxLength characters.',
      );
    }
    return clean;
  }
}

class _CategoryBuilder {
  _CategoryBuilder({
    required this.id,
    required this.name,
    required this.isActive,
    required this.warrantyDays,
  });

  final int id;
  final String name;
  final bool isActive;
  final int warrantyDays;
  final Map<int, _BrandBuilder> brands = {};

  CatalogCategory build() => CatalogCategory(
        id: id,
        name: name,
        isActive: isActive,
        warrantyDays: warrantyDays,
        brands: [
          for (final brand in brands.values) brand.build()
        ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())),
      );
}

class _BrandBuilder {
  _BrandBuilder({required this.id, required this.name, required this.isActive});

  final int id;
  final String name;
  final bool isActive;
  final List<CatalogDevice> devices = [];

  CatalogBrand build() => CatalogBrand(
        id: id,
        name: name,
        isActive: isActive,
        devices: devices,
      );
}
