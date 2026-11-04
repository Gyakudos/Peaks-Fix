import 'dart:convert';

import 'package:drift/drift.dart';

import 'database.dart';

const _inventoryFormat = 'peaksfix-inventory';

/// What an import did.
class InventoryImportResult {
  const InventoryImportResult({
    required this.added,
    required this.updated,
    required this.skipped,
  });

  final int added;
  final int updated;
  final int skipped;

  @override
  String toString() =>
      '$added added, $updated updated${skipped > 0 ? ', $skipped skipped' : ''}';
}

String? _text(Object? value) {
  final text = (value as String?)?.trim();
  return text == null || text.isEmpty ? null : text;
}

int _int(Object? value, [int fallback = 0]) =>
    value is num ? value.toInt() : fallback;

/// Writes the shop's Parts, Labour, Shop Supplies and Merch (everything that
/// is still active) to one JSON file another Peaks Fix install can import.
/// Quantities on hand are left out unless [includeStock] is set.
Future<String> exportInventory(
  AppDatabase database, {
  bool includeStock = false,
}) async {
  final partRows = await (database.select(database.parts)
        ..where((part) => part.isActive.equals(true))
        ..orderBy([(part) => OrderingTerm.asc(part.sku)]))
      .get();
  final merchRows = await (database.select(database.merchProducts)
        ..where((item) => item.isActive.equals(true))
        ..orderBy([(item) => OrderingTerm.asc(item.sku)]))
      .get();
  final skuById = {for (final part in partRows) part.id: part.sku};
  final labourRaw = await database.readSetting('labour_included_parts', '');
  final labourParts = <Map<String, Object?>>[];
  if (labourRaw.isNotEmpty) {
    try {
      final decoded = jsonDecode(labourRaw) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        final labourSku = skuById[int.tryParse(entry.key)];
        if (labourSku == null) continue;
        final included = [
          for (final item in entry.value as List<dynamic>)
            if (skuById[(item as Map<String, dynamic>)['p']] != null)
              {'sku': skuById[item['p']], 'quantity': item['q']},
        ];
        if (included.isNotEmpty) {
          labourParts.add({'labour': labourSku, 'parts': included});
        }
      }
    } catch (_) {}
  }
  return const JsonEncoder.withIndent('  ').convert({
    'format': _inventoryFormat,
    'version': 1,
    'includesStock': includeStock,
    'parts': [
      for (final part in partRows)
        {
          'sku': part.sku,
          'name': part.name,
          'description': part.description,
          'vendorId': part.vendorId,
          'vendorSku': part.vendorSku,
          'brand': part.brand,
          'jobLevel': part.jobLevel,
          'category': part.category,
          'location': part.location,
          if (includeStock) 'stock': part.stock,
          'costCents': part.costCents,
          'priceCents': part.priceCents,
          'purchaseType': part.purchaseType.index,
          'bulkQuantity': part.bulkQuantity,
          'bulkTotalCents': part.bulkTotalCents,
          'chargeShopSupply': part.chargeShopSupply,
          'minimumStock': part.reorderLevel,
        },
    ],
    'merch': [
      for (final item in merchRows)
        {
          'sku': item.sku,
          'name': item.name,
          'description': item.description,
          'category': item.category,
          'location': item.location,
          if (includeStock) 'stock': item.stock,
          'costCents': item.costCents,
          'priceCents': item.priceCents,
        },
    ],
    'labourParts': labourParts,
  });
}

/// Merges an exported inventory file into this shop's inventory. Items match
/// by SKU (or by name when the file has no SKU): matches are updated, the rest
/// are added. Quantities on hand only change when the file includes them.
/// Throws [FormatException] when [source] is not an inventory file.
Future<InventoryImportResult> importInventory(
  AppDatabase database,
  String source,
) async {
  final Map<String, dynamic> data;
  try {
    data = jsonDecode(source) as Map<String, dynamic>;
  } catch (_) {
    throw const FormatException('That is not a Peaks Fix inventory file.');
  }
  if (data['format'] != _inventoryFormat) {
    throw const FormatException('That is not a Peaks Fix inventory file.');
  }
  final includesStock = data['includesStock'] == true;
  var added = 0, updated = 0, skipped = 0;

  await database.transaction(() async {
    for (final raw in (data['parts'] as List<dynamic>? ?? const [])) {
      final item = raw as Map<String, dynamic>;
      final name = _text(item['name']);
      if (name == null) {
        skipped++;
        continue;
      }
      final sku = _text(item['sku']);
      final rows = await database.select(database.parts).get();
      final match = rows
          .where(
            (row) => sku != null
                ? row.sku == sku
                : row.name.toLowerCase() == name.toLowerCase(),
          )
          .firstOrNull;
      final typeIndex = _int(item['purchaseType']);
      final type = typeIndex >= 0 && typeIndex < PartPurchaseType.values.length
          ? PartPurchaseType.values[typeIndex]
          : PartPurchaseType.single;
      final bulkQuantity = _int(item['bulkQuantity'], 1).clamp(1, 1 << 30);
      final bulkTotal = _int(item['bulkTotalCents']).clamp(0, 1 << 30);
      final cost = _int(item['costCents']).clamp(0, 1 << 30);
      final price = _int(item['priceCents']).clamp(0, 1 << 30);
      final stock = _int(item['stock']).clamp(0, 1 << 30);
      if (match == null) {
        await database.createInventoryPart(
          name: name,
          description: _text(item['description']),
          sku: sku,
          vendorId: _text(item['vendorId']),
          vendorSku: _text(item['vendorSku']),
          brand: _text(item['brand']),
          jobLevel: item['jobLevel'] as int?,
          category: _text(item['category']),
          location: _text(item['location']),
          startingStock: includesStock ? stock : 0,
          rawCostCents: cost,
          retailPriceCents: price,
          purchaseType: type,
          bulkQuantity: bulkQuantity,
          bulkTotalCents: bulkTotal,
          minimumStock: _int(item['minimumStock']),
          chargeShopSupply: item['chargeShopSupply'] == true,
        );
        added++;
      } else {
        await database.updateInventoryPart(
          partId: match.id,
          name: name,
          description: _text(item['description']),
          sku: sku,
          vendorId: _text(item['vendorId']),
          vendorSku: _text(item['vendorSku']),
          brand: _text(item['brand']),
          jobLevel: item['jobLevel'] as int?,
          category: _text(item['category']),
          location: _text(item['location']),
          stock: includesStock ? stock : match.stock,
          rawCostCents: cost,
          retailPriceCents: price,
          purchaseType: type,
          bulkQuantity: bulkQuantity,
          bulkTotalCents: bulkTotal,
          minimumStock: _int(item['minimumStock']),
          chargeShopSupply: item['chargeShopSupply'] == true,
        );
        if (!match.isActive) {
          await (database.update(database.parts)
                ..where((row) => row.id.equals(match.id)))
              .write(const PartsCompanion(isActive: Value(true)));
        }
        updated++;
      }
    }

    for (final raw in (data['merch'] as List<dynamic>? ?? const [])) {
      final item = raw as Map<String, dynamic>;
      final name = _text(item['name']);
      if (name == null) {
        skipped++;
        continue;
      }
      final sku = _text(item['sku']);
      final rows = await database.select(database.merchProducts).get();
      final match = rows
          .where(
            (row) => sku != null
                ? row.sku == sku
                : row.name.toLowerCase() == name.toLowerCase(),
          )
          .firstOrNull;
      final cost = _int(item['costCents']).clamp(0, 1 << 30);
      final price = _int(item['priceCents']).clamp(0, 1 << 30);
      final stock = _int(item['stock']).clamp(0, 1 << 30);
      if (match == null) {
        await database.createMerchItem(
          name: name,
          description: _text(item['description']),
          sku: sku,
          category: _text(item['category']),
          location: _text(item['location']),
          startingStock: includesStock ? stock : 0,
          costCents: cost,
          priceCents: price,
        );
        added++;
      } else {
        await database.updateMerchItem(
          itemId: match.id,
          name: name,
          description: _text(item['description']),
          sku: sku,
          category: _text(item['category']),
          location: _text(item['location']),
          stock: includesStock ? stock : match.stock,
          costCents: cost,
          priceCents: price,
        );
        if (!match.isActive) {
          await (database.update(database.merchProducts)
                ..where((row) => row.id.equals(match.id)))
              .write(const MerchProductsCompanion(isActive: Value(true)));
        }
        updated++;
      }
    }

    final idBySku = {
      for (final part in await database.select(database.parts).get())
        if (part.sku != null) part.sku!: part.id,
    };
    for (final raw in (data['labourParts'] as List<dynamic>? ?? const [])) {
      final entry = raw as Map<String, dynamic>;
      final labourId = idBySku[entry['labour']];
      if (labourId == null) continue;
      await database.setLabourIncludedParts(labourId, [
        for (final part in entry['parts'] as List<dynamic>)
          if (idBySku[(part as Map<String, dynamic>)['sku']] != null)
            LabourIncludedPart(
              partId: idBySku[part['sku']]!,
              quantity: _int(part['quantity'], 1),
            ),
      ]);
    }
  });
  return InventoryImportResult(
    added: added,
    updated: updated,
    skipped: skipped,
  );
}
