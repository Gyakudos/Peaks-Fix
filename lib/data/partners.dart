import 'dart:convert';

import 'database.dart';

/// A drop-off location the shop does repairs for, with a standing discount.
class Partner {
  const Partner({
    required this.id,
    required this.name,
    this.contact = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.partsDiscountPercent = 0,
    this.labourDiscountPercent = 0,
    this.logoPath = '',
  });

  /// Path of the partner's logo image, copied into the app's own folder.
  final String logoPath;

  final String id;
  final String name;
  final String contact;
  final String phone;
  final String email;
  final String address;

  /// Whole percent taken off the parts on every quote and invoice built for
  /// this partner.
  final int partsDiscountPercent;

  /// Whole percent taken off the labour.
  final int labourDiscountPercent;

  bool get hasDiscount => partsDiscountPercent > 0 || labourDiscountPercent > 0;

  /// Short label such as "Parts 10% / Labour 5%".
  String get discountLabel => [
        if (partsDiscountPercent > 0) 'Parts $partsDiscountPercent%',
        if (labourDiscountPercent > 0) 'Labour $labourDiscountPercent%',
      ].join(' / ');

  Partner copyWith({
    String? name,
    String? contact,
    String? phone,
    String? email,
    String? address,
    int? partsDiscountPercent,
    int? labourDiscountPercent,
    String? logoPath,
  }) =>
      Partner(
        id: id,
        name: name ?? this.name,
        contact: contact ?? this.contact,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        address: address ?? this.address,
        logoPath: logoPath ?? this.logoPath,
        partsDiscountPercent: partsDiscountPercent ?? this.partsDiscountPercent,
        labourDiscountPercent:
            labourDiscountPercent ?? this.labourDiscountPercent,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'contact': contact,
        'phone': phone,
        'email': email,
        'address': address,
        'logoPath': logoPath,
        'partsDiscountPercent': partsDiscountPercent,
        'labourDiscountPercent': labourDiscountPercent,
      };

  /// Older saves held one `discountPercent`; it applies to both.
  static Partner fromJson(Map<String, Object?> json) {
    final legacy = (json['discountPercent'] as num?)?.toInt() ?? 0;
    int read(String key) =>
        ((json[key] as num?)?.toInt() ?? legacy).clamp(0, 100);
    return Partner(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      contact: json['contact'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      address: json['address'] as String? ?? '',
      logoPath: json['logoPath'] as String? ?? '',
      partsDiscountPercent: read('partsDiscountPercent'),
      labourDiscountPercent: read('labourDiscountPercent'),
    );
  }
}

const _partnersKey = 'partners';

Future<List<Partner>> loadPartners(AppDatabase database) async {
  try {
    final decoded = jsonDecode(await database.readSetting(_partnersKey, '[]'));
    final partners = [
      for (final item in decoded as List<dynamic>)
        Partner.fromJson((item as Map).cast<String, Object?>()),
    ];
    partners.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return partners;
  } catch (_) {
    return const [];
  }
}

Future<void> savePartners(AppDatabase database, List<Partner> partners) =>
    database.writeSetting(
      _partnersKey,
      jsonEncode([for (final partner in partners) partner.toJson()]),
    );
