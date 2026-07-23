import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/image_override_provider.dart';

/// แสดงรูปสินค้า — ถ้าผู้ใช้เคยอัปโหลดรูปใหม่มาแทน จะแสดงรูปนั้นแทนรูป default อัตโนมัติ
class ProductImage extends StatelessWidget {
  final Product product;
  final BoxFit fit;

  const ProductImage(
      {super.key, required this.product, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    final overrideBytes = context.watch<ImageOverrideProvider>().getImage(
          product.id,
        );

    if (overrideBytes != null) {
      return Image.memory(
        overrideBytes,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
      );
    }

    final url = product.imageUrl;
    final isNetwork = url.startsWith('http://') || url.startsWith('https://');

    // รูป default ของสินค้าเป็นไฟล์ที่แนบมากับแอป (assets/images) โหลดได้ทันที
    // ไม่ต้องพึ่งอินเทอร์เน็ต ส่วนถ้าเป็นลิงก์ http/https (เช่น แอดมินใส่เอง) ค่อยโหลดผ่านเน็ต
    if (!isNetwork) {
      return Image.asset(
        url,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => const ColoredBox(
          color: Color(0xFFFCE4EC),
          child: Icon(Icons.checkroom, size: 48, color: Colors.grey),
        ),
      );
    }

    return Image.network(
      url,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const ColoredBox(
          color: Color(0xFFFCE4EC),
          child: Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => const ColoredBox(
        color: Color(0xFFFCE4EC),
        child: Icon(Icons.checkroom, size: 48, color: Colors.grey),
      ),
    );
  }
}
