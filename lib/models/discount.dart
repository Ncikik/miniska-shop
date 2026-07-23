/// ประเภทของโค้ด: ลดเป็น %, ลดเป็นจำนวนเงินคงที่, หรือส่งฟรี
enum DiscountType { percent, fixed, freeShipping }

extension DiscountTypeX on DiscountType {
  String get label {
    switch (this) {
      case DiscountType.percent:
        return 'ลดเปอร์เซ็นต์ (%)';
      case DiscountType.fixed:
        return 'ลดเป็นจำนวนเงิน (บาท)';
      case DiscountType.freeShipping:
        return 'ส่งฟรี';
    }
  }
}

class DiscountCode {
  final String code;
  final DiscountType type;
  final double value; // ใช้กับ percent / fixed เท่านั้น
  bool active;

  DiscountCode({
    required this.code,
    required this.type,
    this.value = 0,
    this.active = true,
  });

  String get description {
    switch (type) {
      case DiscountType.percent:
        return 'ลดราคา ${value.toStringAsFixed(0)}%';
      case DiscountType.fixed:
        return 'ลดราคา ${value.toStringAsFixed(0)} บาท';
      case DiscountType.freeShipping:
        return 'ส่งฟรีทั้งออเดอร์';
    }
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'type': type.name,
    'value': value,
    'active': active,
  };

  factory DiscountCode.fromJson(Map<String, dynamic> json) => DiscountCode(
    code: json['code'] as String,
    type: DiscountType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => DiscountType.percent,
    ),
    value: (json['value'] as num?)?.toDouble() ?? 0,
    active: json['active'] as bool? ?? true,
  );
}
