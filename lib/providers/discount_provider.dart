import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/discount.dart';

class DiscountProvider extends ChangeNotifier {
  static const _key = 'app_discount_codes_v1';
  final List<DiscountCode> _codes = [];

  List<DiscountCode> get codes => List.unmodifiable(_codes);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        _codes
          ..clear()
          ..addAll(
            list.map((e) => DiscountCode.fromJson(e as Map<String, dynamic>)),
          );
      } catch (_) {
        _codes.clear();
      }
    }
    if (_codes.isEmpty) {
      _codes.addAll([
        DiscountCode(code: 'WELCOME10', type: DiscountType.percent, value: 10),
        DiscountCode(code: 'SAVE50', type: DiscountType.fixed, value: 50),
        DiscountCode(code: 'FREESHIP', type: DiscountType.freeShipping),
      ]);
      await _persist(prefs);
    }
    notifyListeners();
  }

  Future<void> _persist(SharedPreferences prefs) async {
    await prefs.setString(
      _key,
      jsonEncode(_codes.map((c) => c.toJson()).toList()),
    );
  }

  /// ค้นหาโค้ดที่ยังใช้งานได้ (case-insensitive)
  DiscountCode? findValid(String code) {
    final trimmed = code.trim().toUpperCase();
    if (trimmed.isEmpty) return null;
    final match = _codes.where(
      (c) => c.code.toUpperCase() == trimmed && c.active,
    );
    return match.isEmpty ? null : match.first;
  }

  Future<void> addCode(DiscountCode code) async {
    _codes.removeWhere((c) => c.code.toUpperCase() == code.code.toUpperCase());
    _codes.add(code);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await _persist(prefs);
  }

  Future<void> removeCode(String code) async {
    _codes.removeWhere((c) => c.code.toUpperCase() == code.toUpperCase());
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await _persist(prefs);
  }

  Future<void> toggleActive(String code, bool active) async {
    final idx = _codes.indexWhere(
      (c) => c.code.toUpperCase() == code.toUpperCase(),
    );
    if (idx == -1) return;
    _codes[idx].active = active;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await _persist(prefs);
  }
}
