import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/mock_products.dart';
import '../models/product.dart';

/// จัดการสินค้า: รวมสินค้าตั้งต้น (mockProducts) กับสินค้าที่เจ้าของร้าน/พนักงานเพิ่มเอง
/// บันทึกลง SharedPreferences เพื่อให้ข้อมูลอยู่ถาวรในเบราว์เซอร์/เครื่องนั้น ๆ
class ProductProvider extends ChangeNotifier {
  bool _loaded = false;
  bool get isLoaded => _loaded;
  static const _customKey = 'app_custom_products_v1';
  static const _hiddenKey = 'app_hidden_product_ids_v1';

  final List<Product> _customProducts = [];
  final Set<String> _hiddenIds = {};

  List<Product> get products => [
        ...mockProducts.where((p) => !_hiddenIds.contains(p.id)),
        ..._customProducts,
      ];

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_customKey);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        _customProducts
          ..clear()
          ..addAll(
            list.map((e) => Product.fromJson(e as Map<String, dynamic>)),
          );
      } catch (_) {
        _customProducts.clear();
      }
    }
    final hidden = prefs.getStringList(_hiddenKey);
    if (hidden != null) {
      _hiddenIds
        ..clear()
        ..addAll(hidden);
    }
    notifyListeners();
    _loaded = true;
  }

  Future<void> _persist(SharedPreferences prefs) async {
    await prefs.setString(
      _customKey,
      jsonEncode(_customProducts.map((p) => p.toJson()).toList()),
    );
    await prefs.setStringList(_hiddenKey, _hiddenIds.toList());
  }

  String nextId() => 'c_${DateTime.now().millisecondsSinceEpoch}';

  Future<void> addProduct(Product product) async {
    _customProducts.add(product);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await _persist(prefs);
  }

  Future<void> updateProduct(Product product) async {
    final idx = _customProducts.indexWhere((p) => p.id == product.id);
    if (idx != -1) {
      _customProducts[idx] = product;
    } else {
      // เป็นสินค้าตั้งต้น: ซ่อนของเดิม แล้วเก็บฉบับแก้ไขเป็นสินค้าที่กำหนดเองแทน
      _hiddenIds.add(product.id);
      _customProducts.add(product);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await _persist(prefs);
  }

  Future<void> deleteProduct(String id) async {
    _customProducts.removeWhere((p) => p.id == id);
    _hiddenIds.add(id);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await _persist(prefs);
  }
}
