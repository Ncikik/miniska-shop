import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../widgets/responsive_center.dart';

/// ฟอร์มเพิ่ม/แก้ไขสินค้า ใช้โดยเจ้าของร้านและพนักงาน
class ProductFormScreen extends StatefulWidget {
  final Product? existing;
  const ProductFormScreen({super.key, this.existing});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageController;
  late final TextEditingController _categoryController;
  late final TextEditingController _sizesController;
  late final TextEditingController _colorsController;
  late final TextEditingController _stockController;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(
      text: p != null ? p.price.toStringAsFixed(0) : '',
    );
    _imageController = TextEditingController(text: p?.imageUrl ?? '');
    _categoryController = TextEditingController(text: p?.category ?? '');
    _sizesController = TextEditingController(text: p?.sizes.join(', ') ?? 'S, M, L, XL');
    _colorsController = TextEditingController(text: p?.colors.join(', ') ?? 'ดำ, ขาว');
    _stockController = TextEditingController(
      text: p != null ? p.stock.toString() : '20',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _categoryController.dispose();
    _sizesController.dispose();
    _colorsController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  List<String> _parseList(String raw) => raw
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final sizes = _parseList(_sizesController.text);
    final colors = _parseList(_colorsController.text);
    if (sizes.isEmpty || colors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกไซส์และสีอย่างน้อย 1 รายการ')),
      );
      return;
    }
    setState(() => _saving = true);
    final provider = context.read<ProductProvider>();
    final imageUrl = _imageController.text.trim().isEmpty
        ? 'https://placehold.co/600x700/EDE4FE/5B21B6/png?text=${Uri.encodeComponent(_nameController.text.trim())}'
        : _imageController.text.trim();

    final product = Product(
      id: widget.existing?.id ?? provider.nextId(),
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0,
      imageUrl: imageUrl,
      sizes: sizes,
      colors: colors,
      category: _categoryController.text.trim(),
      stock: int.tryParse(_stockController.text.trim()) ?? 20,
    );

    if (_isEditing) {
      await provider.updateProduct(product);
    } else {
      await provider.addProduct(product);
    }
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: Text(_isEditing ? 'แก้ไขสินค้า' : 'เพิ่มสินค้าใหม่'),
        backgroundColor: kBackground,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveCenter(
            maxWidth: 640,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'ชื่อสินค้า'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'กรุณากรอกชื่อสินค้า' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'รายละเอียดสินค้า'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'กรุณากรอกรายละเอียด' : null,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'ราคา (บาท)'),
                          validator: (v) {
                            final n = double.tryParse((v ?? '').trim());
                            if (n == null || n <= 0) return 'กรอกราคาให้ถูกต้อง';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _stockController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'จำนวนสต็อก'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(labelText: 'หมวดหมู่ เช่น เสื้อยืด'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'กรุณากรอกหมวดหมู่' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _imageController,
                    decoration: const InputDecoration(
                      labelText: 'ลิงก์รูปภาพ (เว้นว่างได้)',
                      hintText: 'https://...',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _sizesController,
                    decoration: const InputDecoration(
                      labelText: 'ไซส์ (คั่นด้วยจุลภาค)',
                      hintText: 'S, M, L, XL',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _colorsController,
                    decoration: const InputDecoration(
                      labelText: 'สี (คั่นด้วยจุลภาค)',
                      hintText: 'ดำ, ขาว, เทา',
                    ),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _submit,
                      child: _saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.4,
                              ),
                            )
                          : Text(_isEditing ? 'บันทึกการแก้ไข' : 'เพิ่มสินค้า'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
