import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../widgets/product_image.dart';
import '../widgets/responsive_center.dart';
import 'product_form_screen.dart';

class ManageProductsScreen extends StatelessWidget {
  const ManageProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().products;
    final priceFormat = NumberFormat.currency(
      locale: 'th_TH',
      symbol: '฿',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(title: const Text('จัดการสินค้า'), backgroundColor: kBackground),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 800,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final product = products[index];
              return _ProductRow(
                product: product,
                priceFormat: priceFormat,
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kBrandDark,
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มสินค้า'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductFormScreen()),
          );
        },
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final Product product;
  final NumberFormat priceFormat;

  const _ProductRow({required this.product, required this.priceFormat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9E1FB)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 56,
              height: 68,
              child: ProductImage(product: product),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${product.category} · สต็อก ${product.stock}',
                  style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 3),
                Text(
                  priceFormat.format(product.price),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: kBrandDark),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductFormScreen(existing: product),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text('ลบสินค้า'),
                  content: Text('ต้องการลบ "${product.name}" ใช่หรือไม่?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('ยกเลิก'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text('ลบ', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await context.read<ProductProvider>().deleteProduct(product.id);
              }
            },
          ),
        ],
      ),
    );
  }
}
