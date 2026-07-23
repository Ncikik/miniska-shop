import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';

class OrderProvider extends ChangeNotifier {
  static const _ordersKey = 'app_orders_v1';
  final List<Order> _orders = [];

  /// ทุกออเดอร์ เรียงใหม่สุดก่อน (สำหรับเจ้าของร้าน/พนักงาน)
  List<Order> get allOrders => _orders.reversed.toList();

  /// ออเดอร์ของผู้ใช้คนใดคนหนึ่ง เรียงใหม่สุดก่อน
  List<Order> ordersForUser(String userId) =>
      _orders.where((o) => o.userId == userId).toList().reversed.toList();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_ordersKey);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        _orders
          ..clear()
          ..addAll(
            list.map((e) => Order.fromJson(e as Map<String, dynamic>)),
          );
      } catch (_) {
        _orders.clear();
      }
    }
    notifyListeners();
  }

  Future<void> addOrder(Order order) async {
    _orders.add(order);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _ordersKey,
      jsonEncode(_orders.map((o) => o.toJson()).toList()),
    );
  }

  Future<void> updateStatus(String orderId, OrderStatus status) async {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    _orders[idx] = _orders[idx].copyWith(status: status);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _ordersKey,
      jsonEncode(_orders.map((o) => o.toJson()).toList()),
    );
  }
}
