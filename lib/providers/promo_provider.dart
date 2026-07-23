import 'package:flutter/foundation.dart';
import '../models/promo_code.dart';
import '../services/storage_service.dart';

const _promosKey = 'app_promos';

final List<PromoCode> _defaultPromos = [
  const PromoCode(
    code: 'SAVE10',
    type: PromoType.percentDiscount,
    value: 10,
    maxDiscount: 100,
    minOrder: 300,
  ),
  const PromoCode(
    code: 'SAVE50',
    type: PromoType.fixedDiscount,
    value: 50,
    minOrder: 500,
  ),
  const PromoCode(
    code: 'FREESHIP',
    type: PromoType.freeShipping,
    value: 0,
    minOrder: 590,
  ),
];

class PromoResult {
  final PromoCode promo;
  final double discountAmount;
  final bool freeShipping;

  const PromoResult({
    required this.promo,
    required this.discountAmount,
    required this.freeShipping,
  });
}

class PromoProvider extends ChangeNotifier {
  List<PromoCode> _promos = [];
  bool _loaded = false;

  List<PromoCode> get promos => List.unmodifiable(_promos);
  bool get isLoaded => _loaded;

  Future<void> init() async {
    final stored = await StorageService.loadList(_promosKey);
    if (stored.isEmpty) {
      _promos = List.from(_defaultPromos);
      await _persist();
    } else {
      _promos = stored.map(PromoCode.fromJson).toList();
    }
    _loaded = true;
    notifyListeners();
  }

  PromoResult? validate(String code, double subtotal) {
    final promo = _promos
        .where((p) => p.code.toUpperCase() == code.toUpperCase().trim())
        .firstOrNull;
    if (promo == null) return null;
    if (!promo.isActive) return null;
    if (promo.expiresAt != null && DateTime.now().isAfter(promo.expiresAt!)) {
      return null;
    }
    if (promo.minOrder != null && subtotal < promo.minOrder!) return null;

    double discount = 0;
    var freeShipping = false;

    switch (promo.type) {
      case PromoType.percentDiscount:
        discount = subtotal * promo.value / 100;
        if (promo.maxDiscount != null && discount > promo.maxDiscount!) {
          discount = promo.maxDiscount!;
        }
      case PromoType.fixedDiscount:
        discount = promo.value;
      case PromoType.freeShipping:
        freeShipping = true;
    }

    return PromoResult(
      promo: promo,
      discountAmount: discount,
      freeShipping: freeShipping,
    );
  }

  Future<void> addPromo(PromoCode promo) async {
    if (_promos.any(
      (p) => p.code.toUpperCase() == promo.code.toUpperCase(),
    )) {
      return;
    }
    _promos.add(promo);
    await _persist();
    notifyListeners();
  }

  Future<void> updatePromo(PromoCode promo) async {
    final idx = _promos.indexWhere(
      (p) => p.code.toUpperCase() == promo.code.toUpperCase(),
    );
    if (idx < 0) return;
    _promos[idx] = promo;
    await _persist();
    notifyListeners();
  }

  Future<void> deletePromo(String code) async {
    _promos.removeWhere(
      (p) => p.code.toUpperCase() == code.toUpperCase(),
    );
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    await StorageService.saveList(
      _promosKey,
      _promos.map((p) => p.toJson()).toList(),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}
