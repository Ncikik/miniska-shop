enum PromoType { percentDiscount, fixedDiscount, freeShipping }

class PromoCode {
  final String code;
  final PromoType type;
  final double value;
  final double? minOrder;
  final double? maxDiscount;
  final DateTime? expiresAt;
  final bool isActive;

  const PromoCode({
    required this.code,
    required this.type,
    required this.value,
    this.minOrder,
    this.maxDiscount,
    this.expiresAt,
    this.isActive = true,
  });

  String get typeLabel => switch (type) {
        PromoType.percentDiscount => 'ลด ${value.toInt()}%',
        PromoType.fixedDiscount => 'ลด ฿${value.toInt()}',
        PromoType.freeShipping => 'ส่งฟรี',
      };

  Map<String, dynamic> toJson() => {
        'code': code,
        'type': type.name,
        'value': value,
        'minOrder': minOrder,
        'maxDiscount': maxDiscount,
        'expiresAt': expiresAt?.toIso8601String(),
        'isActive': isActive,
      };

  factory PromoCode.fromJson(Map<String, dynamic> json) => PromoCode(
        code: json['code'] as String,
        type: PromoType.values.byName(json['type'] as String),
        value: (json['value'] as num).toDouble(),
        minOrder: (json['minOrder'] as num?)?.toDouble(),
        maxDiscount: (json['maxDiscount'] as num?)?.toDouble(),
        expiresAt: json['expiresAt'] != null
            ? DateTime.parse(json['expiresAt'] as String)
            : null,
        isActive: json['isActive'] as bool? ?? true,
      );

  PromoCode copyWith({
    String? code,
    PromoType? type,
    double? value,
    double? minOrder,
    double? maxDiscount,
    DateTime? expiresAt,
    bool? isActive,
  }) =>
      PromoCode(
        code: code ?? this.code,
        type: type ?? this.type,
        value: value ?? this.value,
        minOrder: minOrder ?? this.minOrder,
        maxDiscount: maxDiscount ?? this.maxDiscount,
        expiresAt: expiresAt ?? this.expiresAt,
        isActive: isActive ?? this.isActive,
      );
}
