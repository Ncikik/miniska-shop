import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/product_image.dart';
import '../../widgets/responsive_center.dart';
import 'product_form_screen.dart';

class ProductListAdminScreen extends StatelessWidget {
  const ProductListAdminScreen({super.key});

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
      appBar: AppBar(title: const Text('จัดการสินค้า')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kBrandPink,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProductFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มสินค้า'),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 900,
          child: products.isEmpty
              ? const Center(child: Text('ยังไม่มีสินค้า'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _ProductAdminTile(
                      product: product,
                      priceFormat: priceFormat,
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _ProductAdminTile extends StatelessWidget {
  final Product product;
  final NumberFormat priceFormat;

  const _ProductAdminTile({
    required this.product,
    required this.priceFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8DEFF)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 64,
              height: 76,
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
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  '${priceFormat.format(product.price)} · สต็อก ${product.stock}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: kBrandBlue),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductFormScreen(product: product),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('ลบสินค้า?'),
                  content: Text('ต้องการลบ "${product.name}" ใช่หรือไม่?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('ยกเลิก'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('ลบ'),
                    ),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                await context.read<ProductProvider>().deleteProduct(product.id);
              }
            },
          ),
        ],
      ),
    );
  }
}
