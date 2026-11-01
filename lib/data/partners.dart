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
    this.discountPercent = 0,
  });

  final String id;
  final String name;
  final String contact;
  final String phone;
  final String email;
  final String address;

  /// Whole percent taken off every quote and invoice built for this partner.
  final int discountPercent;

  Partner copyWith({
    String? name,
    String? contact,
    String? phone,
    String? email,
    String? address,
    int? discountPercent,
  }) =>
      Partner(
        id: id,
        name: name ?? this.name,
        contact: contact ?? this.contact,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        address: address ?? this.address,
        discountPercent: discountPercent ?? this.discountPercent,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'contact': contact,
        'phone': phone,
        'email': email,
        'address': address,
        'discountPercent': discountPercent,
      };

  static Partner fromJson(Map<String, Object?> json) => Partner(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        contact: json['contact'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        email: json['email'] as String? ?? '',
        address: json['address'] as String? ?? '',
        discountPercent:
            ((json['discountPercent'] as num?)?.toInt() ?? 0).clamp(0, 100),
      );
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
