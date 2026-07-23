import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_image.dart';
import '../widgets/responsive_center.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late String _selectedSize = widget.product.sizes.first;
  late String _selectedColor = widget.product.colors.first;
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final priceFormat = NumberFormat.currency(
      locale: 'th_TH',
      symbol: '฿',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveCenter(
            maxWidth: 1100,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 760;
                final image = ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: AspectRatio(
                    aspectRatio: isWide ? 0.85 : 1.0,
                    child: ProductImage(product: product),
                  ),
                );
                final details = _buildDetails(product, priceFormat);

                if (isWide) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: image),
                        const SizedBox(width: 40),
                        Expanded(flex: 4, child: details),
                      ],
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      image,
                      const SizedBox(height: 20),
                      details,
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetails(Product product, NumberFormat priceFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: kBrandGold.withOpacity(0.14),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            product.category,
            style: const TextStyle(
              color: kBrandGold,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          product.name,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          priceFormat.format(product.price),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: kBrandDark,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          product.description,
          style: TextStyle(
            color: Colors.grey.shade600,
            height: 1.6,
            fontSize: 14.5,
          ),
        ),
        const SizedBox(height: 28),
        _label('ไซส์'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: product.sizes.map((size) {
            final isSelected = size == _selectedSize;
            return _optionChip(
              label: size,
              selected: isSelected,
              onTap: () => setState(() => _selectedSize = size),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        _label('สี'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: product.colors.map((color) {
            final isSelected = color == _selectedColor;
            return _optionChip(
              label: color,
              selected: isSelected,
              onTap: () => setState(() => _selectedColor = color),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        _label('จำนวน'),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  if (_quantity > 1) setState(() => _quantity--);
                },
                icon: const Icon(Icons.remove, size: 18),
              ),
              SizedBox(
                width: 32,
                child: Text(
                  '$_quantity',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _quantity++),
                icon: const Icon(Icons.add, size: 18),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.shopping_bag_outlined, size: 18),
            label: const Text('เพิ่มลงตะกร้า'),
            onPressed: () {
              context.read<CartProvider>().addItem(
                    product,
                    _selectedSize,
                    _selectedColor,
                    qty: _quantity,
                  );

              // เคลียร์ SnackBar เดิมที่อาจกำลัง animate ค้างอยู่ก่อนโชว์อันใหม่
              // ป้องกัน error "Floating SnackBar presented off screen"
              // ที่เกิดเวลากดปุ่มซ้ำๆ เร็วๆ หรือมีการ navigate ทับขณะ SnackBar ยังไม่ animate เสร็จ
              final messenger = ScaffoldMessenger.of(context);
              messenger.hideCurrentSnackBar();
              messenger.showSnackBar(
                SnackBar(
                  // เอา behavior: SnackBarBehavior.floating ออก เพราะเป็นสาเหตุของ
                  // error "Floating SnackBar presented off screen" ที่วนซ้ำจนแอปค้าง
                  // ใช้ค่า default (fixed) แทน ซึ่งเสถียรกว่าบน Flutter web
                  backgroundColor: kBrandDark,
                  content: Text('เพิ่ม "${product.name}" ลงตะกร้าแล้ว'),
                  action: SnackBarAction(
                    label: 'ดูตะกร้า',
                    textColor: kBrandGold,
                    onPressed: () {
                      // ปิด SnackBar ก่อนเปลี่ยนหน้าเสมอ ไม่ให้มันค้าง animate อยู่บน
                      // Scaffold ที่กำลังจะถูกซ้อนทับ/เปลี่ยนขนาดจาก Navigator.push
                      messenger.hideCurrentSnackBar();
                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      );

  Widget _optionChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? kBrandDark : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? kBrandDark : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
