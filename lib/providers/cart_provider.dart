import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  static const _itemsKey = 'app_cart_items_v1';
  static const _selectedKeyPrefKey = 'app_cart_selected_v1';

  final Map<String, CartItem> _items = {};
  final Set<String> _selectedKeys = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  Map<String, CartItem> get items => _items;

  List<CartItem> get itemList => _items.values.toList();

  int get itemCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// โหลดตะกร้าที่เคยบันทึกไว้กลับมา ต้องมีรายการสินค้าทั้งหมด (availableProducts)
  /// เพื่อจับคู่กับ id ที่บันทึกไว้ (สินค้าที่ถูกลบไปแล้วจะถูกข้าม)
  Future<void> init(List<Product> availableProducts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_itemsKey);
      if (raw != null) {
        final byId = {for (final p in availableProducts) p.id: p};
        final list = jsonDecode(raw) as List;
        for (final e in list) {
          final map = e as Map<String, dynamic>;
          final product = byId[map['productId'] as String];
          if (product == null) continue; // สินค้าถูกลบไปแล้ว ข้ามรายการนี้
          final size = map['size'] as String;
          final color = map['color'] as String;
          final quantity = map['quantity'] as int? ?? 1;
          final key = '${product.id}_${size}_$color';
          _items[key] = CartItem(
            product: product,
            size: size,
            color: color,
            quantity: quantity,
          );
        }
      }
      final selected = prefs.getStringList(_selectedKeyPrefKey);
      if (selected != null) {
        _selectedKeys
          ..clear()
          ..addAll(selected.where(_items.containsKey));
      } else {
        // ไม่เคยมีข้อมูลเลือกไว้มาก่อน (เช่นตะกร้าเก่า) ให้เลือกทุกชิ้นเป็นค่าเริ่มต้น
        _selectedKeys
          ..clear()
          ..addAll(_items.keys);
      }
    } catch (_) {
      // ถ้าอ่านข้อมูลเก่าไม่ได้ ก็เริ่มจากตะกร้าว่างแทน
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _items.values
          .map(
            (i) => {
              'productId': i.product.id,
              'size': i.size,
              'color': i.color,
              'quantity': i.quantity,
            },
          )
          .toList();
      await prefs.setString(_itemsKey, jsonEncode(list));
      await prefs.setStringList(_selectedKeyPrefKey, _selectedKeys.toList());
    } catch (_) {
      // บันทึกไม่ได้ก็ยังใช้งานตะกร้าต่อได้ในเซสชันนี้
    }
  }

  // ---------- ระบบเลือกสินค้าที่จะสั่งซื้อ ----------
  // ให้ผู้ใช้เลือกได้ว่าจะสั่งซื้อสินค้าชิ้นไหนในตะกร้าบ้าง ก่อนไปหน้าชำระเงิน

  bool isSelected(String key) => _selectedKeys.contains(key);

  void toggleSelected(String key) {
    if (_selectedKeys.contains(key)) {
      _selectedKeys.remove(key);
    } else {
      _selectedKeys.add(key);
    }
    notifyListeners();
    _persist();
  }

  void selectAll() {
    _selectedKeys
      ..clear()
      ..addAll(_items.keys);
    notifyListeners();
    _persist();
  }

  void deselectAll() {
    _selectedKeys.clear();
    notifyListeners();
    _persist();
  }

  bool get isAllSelected =>
      _items.isNotEmpty && _selectedKeys.length == _items.length;

  List<CartItem> get selectedItems =>
      _items.values.where((i) => _selectedKeys.contains(i.key)).toList();

  double get selectedTotal =>
      selectedItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  int get selectedCount =>
      selectedItems.fold(0, (sum, item) => sum + item.quantity);

  /// ลบเฉพาะสินค้าที่ถูกเลือกออกจากตะกร้า (เรียกหลังชำระเงินสำเร็จ)
  void removeSelected() {
    for (final key in _selectedKeys.toList()) {
      _items.remove(key);
    }
    _selectedKeys.clear();
    notifyListeners();
    _persist();
  }

  // ---------- จัดการตะกร้าปกติ ----------

  void addItem(Product product, String size, String color, {int qty = 1}) {
    final key = '${product.id}_${size}_$color';
    if (_items.containsKey(key)) {
      _items[key]!.quantity += qty;
    } else {
      _items[key] = CartItem(
        product: product,
        size: size,
        color: color,
        quantity: qty,
      );
    }
    // เพิ่มสินค้าใหม่แล้วเลือกให้อัตโนมัติ เพื่อให้พร้อมสั่งซื้อได้ทันที
    _selectedKeys.add(key);
    notifyListeners();
    _persist();
  }

  void removeItem(String key) {
    _items.remove(key);
    _selectedKeys.remove(key);
    notifyListeners();
    _persist();
  }

  void updateQuantity(String key, int qty) {
    if (!_items.containsKey(key)) return;
    if (qty <= 0) {
      removeItem(key);
    } else {
      _items[key]!.quantity = qty;
      notifyListeners();
      _persist();
    }
  }

  void clear() {
    _items.clear();
    _selectedKeys.clear();
    notifyListeners();
    _persist();
  }
}
