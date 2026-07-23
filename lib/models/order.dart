import 'product.dart';

/// สถานะของคำสั่งซื้อ
enum OrderStatus { pending, paid, shipped, delivered, cancelled }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'รอดำเนินการ';
      case OrderStatus.paid:
        return 'ชำระเงินแล้ว';
      case OrderStatus.shipped:
        return 'จัดส่งแล้ว';
      case OrderStatus.delivered:
        return 'ส่งถึงแล้ว';
      case OrderStatus.cancelled:
        return 'ยกเลิก';
    }
  }
}

/// สินค้า 1 รายการที่ถูกบันทึกไว้ในคำสั่งซื้อ (snapshot ณ เวลาที่ซื้อ)
class OrderItem {
  final String productId;
  final String productName;
  final String imageUrl;
  final String size;
  final String color;
  final int quantity;
  final double unitPrice;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.size,
    required this.color,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'imageUrl': imageUrl,
        'size': size,
        'color': color,
        'quantity': quantity,
        'unitPrice': unitPrice,
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        productId: json['productId'] as String,
        productName: json['productName'] as String,
        imageUrl: json['imageUrl'] as String,
        size: json['size'] as String,
        color: json['color'] as String,
        quantity: json['quantity'] as int,
        unitPrice: (json['unitPrice'] as num).toDouble(),
      );

  factory OrderItem.fromCartItem(CartItem item) => OrderItem(
        productId: item.product.id,
        productName: item.product.name,
        imageUrl: item.product.imageUrl,
        size: item.size,
        color: item.color,
        quantity: item.quantity,
        unitPrice: item.product.price,
      );
}

/// คำสั่งซื้อ 1 ออเดอร์ (ใช้เก็บประวัติการซื้อ)
class Order {
  final String id;
  final String userId;
  final String userName;
  final List<OrderItem> items;
  final double subtotal;
  final double discountAmount;
  final double shippingFee;
  final double total;
  final String? discountCode;
  final String? freeShipCode;
  final String receiverName;
  final String phone;
  final String address;
  final String paymentMethod;
  final DateTime createdAt;
  final OrderStatus status;

  const Order({
    required this.id,
    required this.userId,
    required this.userName,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    required this.shippingFee,
    required this.total,
    this.discountCode,
    this.freeShipCode,
    required this.receiverName,
    required this.phone,
    required this.address,
    required this.paymentMethod,
    required this.createdAt,
    this.status = OrderStatus.pending,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  String get statusLabel => status.label;
  Order copyWith({OrderStatus? status}) => Order(
        id: id,
        userId: userId,
        userName: userName,
        items: items,
        subtotal: subtotal,
        discountAmount: discountAmount,
        shippingFee: shippingFee,
        total: total,
        discountCode: discountCode,
        freeShipCode: freeShipCode,
        receiverName: receiverName,
        phone: phone,
        address: address,
        paymentMethod: paymentMethod,
        createdAt: createdAt,
        status: status ?? this.status,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'items': items.map((e) => e.toJson()).toList(),
        'subtotal': subtotal,
        'discountAmount': discountAmount,
        'shippingFee': shippingFee,
        'total': total,
        'discountCode': discountCode,
        'freeShipCode': freeShipCode,
        'receiverName': receiverName,
        'phone': phone,
        'address': address,
        'paymentMethod': paymentMethod,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String,
        userId: json['userId'] as String,
        userName: json['userName'] as String,
        items: (json['items'] as List)
            .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        subtotal: (json['subtotal'] as num).toDouble(),
        discountAmount: (json['discountAmount'] as num).toDouble(),
        shippingFee: (json['shippingFee'] as num).toDouble(),
        total: (json['total'] as num).toDouble(),
        discountCode: json['discountCode'] as String?,
        freeShipCode: json['freeShipCode'] as String?,
        receiverName: json['receiverName'] as String,
        phone: json['phone'] as String,
        address: json['address'] as String,
        paymentMethod: json['paymentMethod'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        status: OrderStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => OrderStatus.pending,
        ),
      );
}
