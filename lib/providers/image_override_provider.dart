import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// จัดการรูปสินค้าที่ผู้ใช้อัปโหลดเองมาแทนรูป default
/// รูปจะถูกเก็บเป็น base64 ใน localStorage ของเบราว์เซอร์ (เฉพาะเครื่อง/เบราว์เซอร์นั้น ๆ)
/// หมายเหตุ: เพราะยังไม่มี backend กลาง รูปที่เปลี่ยนจะไม่ถูกแชร์ไปยังผู้ใช้คนอื่น
class ImageOverrideProvider extends ChangeNotifier {
  final Map<String, Uint8List> _overrides = {};
  static const _prefsPrefix = 'product_image_';

  Uint8List? getImage(String productId) => _overrides[productId];

  bool hasOverride(String productId) => _overrides.containsKey(productId);

  Future<void> setImage(String productId, Uint8List bytes) async {
    _overrides[productId] = bytes;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefsPrefix$productId', base64Encode(bytes));
    } catch (_) {
      // ถ้าบันทึกลง localStorage ไม่ได้ (เช่น พื้นที่เต็ม) ก็ยังใช้รูปได้ในเซสชันนี้
    }
  }

  Future<void> clearImage(String productId) async {
    _overrides.remove(productId);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_prefsPrefix$productId');
    } catch (_) {}
  }

  /// เรียกตอนเปิดแอปเพื่อโหลดรูปที่เคยเปลี่ยนไว้กลับมา
  Future<void> loadAll(List<String> productIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final id in productIds) {
        final data = prefs.getString('$_prefsPrefix$id');
        if (data != null) {
          _overrides[id] = base64Decode(data);
        }
      }
      notifyListeners();
    } catch (_) {
      // ไม่มี localStorage ให้ใช้งาน ก็ข้ามไป ใช้รูป default แทน
    }
  }
}
