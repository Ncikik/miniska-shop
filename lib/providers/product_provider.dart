import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';

/// จัดการสินค้า: ดึง/เพิ่ม/แก้ไข/ลบ ข้อมูลจาก Cloud Firestore (collection "products")
/// โดยตรง แทนที่การใช้ mock_products + SharedPreferences แบบเดิม
class ProductProvider extends ChangeNotifier {
  final CollectionReference<Map<String, dynamic>> _productsRef =
      FirebaseFirestore.instance.collection('products');

  bool _loaded = false;
  bool get isLoaded => _loaded;

  List<Product> _products = [];
  List<Product> get products => _products;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  /// เริ่มฟังข้อมูลจาก Firestore แบบ real-time
  /// เรียกครั้งเดียวตอนแอพเริ่มทำงาน (เช่นใน main.dart หรือตอนสร้าง provider)
  Future<void> init() async {
    // ยกเลิกการฟังเดิมถ้ามี (กันการเรียกซ้ำ)
    await _subscription?.cancel();

    _subscription = _productsRef.snapshots().listen(
      (snapshot) {
        _products = snapshot.docs.map((doc) {
          final data = doc.data();
          // กันเคสข้อมูลเก่าที่ไม่มี field 'id' เก็บไว้ในตัวเอกสาร
          data['id'] = doc.id;
          return Product.fromJson(data);
        }).toList();

        _loaded = true;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('ProductProvider: error listening to products: $error');
        _loaded = true;
        notifyListeners();
      },
    );

    // รอให้ได้ข้อมูลชุดแรกก่อน (กัน UI โชว์ค่าว่างตอนเปิดแอพครั้งแรก)
    await _productsRef.get();
  }

  String nextId() => _productsRef.doc().id;

  Future<void> addProduct(Product product) async {
    await _productsRef.doc(product.id).set(product.toJson());
    // ไม่ต้อง notifyListeners() เอง เพราะ stream listener ด้านบนจะอัปเดตให้อัตโนมัติ
  }

  Future<void> updateProduct(Product product) async {
    await _productsRef.doc(product.id).set(
          product.toJson(),
          SetOptions(merge: true),
        );
  }

  Future<void> deleteProduct(String id) async {
    await _productsRef.doc(id).delete();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
