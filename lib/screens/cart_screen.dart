import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/responsive_center.dart';
import '../widgets/product_image.dart';
import 'checkout_screen.dart';
import 'login_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _goToCheckout(BuildContext context, CartProvider cart) async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      final ok = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (ok != true) return;
    }
    if (!context.mounted) return;
    final selected = cart.selectedItems;
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('กรุณาเลือกสินค้าที่ต้องการสั่งซื้ออย่างน้อย 1 รายการ')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CheckoutScreen(items: selected)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final priceFormat = NumberFormat.currency(
      locale: 'th_TH',
      symbol: '฿',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('ตะกร้าสินค้า'),
        backgroundColor: kBackground,
        actions: [
          if (cart.itemList.isNotEmpty)
            TextButton(
              onPressed: () {
                cart.isAllSelected ? cart.deselectAll() : cart.selectAll();
              },
              child:
                  Text(cart.isAllSelected ? 'ยกเลิกทั้งหมด' : 'เลือกทั้งหมด'),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ResponsiveCenter(
                maxWidth: 900,
                child: cart.itemList.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 80),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'ยังไม่มีสินค้าในตะกร้า',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: cart.itemList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = cart.itemList[index];
                          final selected = cart.isSelected(item.key);
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: selected
                                    ? kBrandDark.withOpacity(0.5)
                                    : Colors.transparent,
                                width: 1.4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: selected,
                                  activeColor: kBrandDark,
                                  onChanged: (_) =>
                                      cart.toggleSelected(item.key),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: SizedBox(
                                    width: 74,
                                    height: 88,
                                    child: ProductImage(product: item.product),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'ไซส์ ${item.size} · สี ${item.color}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          _qtyButton(
                                            icon: Icons.remove,
                                            onTap: () => context
                                                .read<CartProvider>()
                                                .updateQuantity(
                                                  item.key,
                                                  item.quantity - 1,
                                                ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            child: Text(
                                              '${item.quantity}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          _qtyButton(
                                            icon: Icons.add,
                                            onTap: () => context
                                                .read<CartProvider>()
                                                .updateQuantity(
                                                  item.key,
                                                  item.quantity + 1,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      priceFormat.format(item.totalPrice),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: kBrandDark,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                        size: 20,
                                      ),
                                      onPressed: () => context
                                          .read<CartProvider>()
                                          .removeItem(item.key),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: cart.itemList.isEmpty
          ? null
          : SafeArea(
              child: ResponsiveCenter(
                maxWidth: 900,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16, top: 8),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'เลือกแล้ว ${cart.selectedCount} ชิ้น',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12.5,
                              ),
                            ),
                            Text(
                              priceFormat.format(cart.selectedTotal),
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: cart.selectedItems.isEmpty
                            ? null
                            : () => _goToCheckout(context, cart),
                        child: const Text('สั่งซื้อสินค้าที่เลือก'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14),
      ),
    );
  }
}
