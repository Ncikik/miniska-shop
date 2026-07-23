class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> sizes;
  final List<String> colors;
  final String category;
  final int stock;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.sizes,
    required this.colors,
    required this.category,
    this.stock = 20,
  });

  Product copyWith({
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    List<String>? sizes,
    List<String>? colors,
    String? category,
    int? stock,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      category: category ?? this.category,
      stock: stock ?? this.stock,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'imageUrl': imageUrl,
    'sizes': sizes,
    'colors': colors,
    'category': category,
    'stock': stock,
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    price: (json['price'] as num).toDouble(),
    imageUrl: json['imageUrl'] as String,
    sizes: List<String>.from(json['sizes'] as List),
    colors: List<String>.from(json['colors'] as List),
    category: json['category'] as String,
    stock: json['stock'] as int? ?? 20,
  );
}

/// รายการสินค้าที่ถูกเลือกไซส์/สี แล้วเพิ่มลงตะกร้า
class CartItem {
  final Product product;
  final String size;
  final String color;
  int quantity;

  CartItem({
    required this.product,
    required this.size,
    required this.color,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;

  /// ใช้เป็น key เทียบว่าเป็นสินค้าตัวเดียวกัน (สินค้า+ไซส์+สี เดียวกัน)
  String get key => '${product.id}_${size}_$color';
}
