import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/responsive_center.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _priceController;
  late final TextEditingController _categoryController;
  late final TextEditingController _sizesController;
  late final TextEditingController _colorsController;
  late final TextEditingController _stockController;
  late final TextEditingController _imageController;
  bool _saving = false;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(
      text: p?.price.toStringAsFixed(0) ?? '',
    );
    _categoryController = TextEditingController(text: p?.category ?? 'เสื้อยืด');
    _sizesController = TextEditingController(
      text: p?.sizes.join(', ') ?? 'S, M, L, XL',
    );
    _colorsController = TextEditingController(
      text: p?.colors.join(', ') ?? 'ขาว, ดำ',
    );
    _stockController = TextEditingController(
      text: '${p?.stock ?? 20}',
    );
    _imageController = TextEditingController(
      text: p?.imageUrl ?? 'assets/images/placeholder.png',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _sizesController.dispose();
    _colorsController.dispose();
    _stockController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  List<String> _splitList(String raw) =>
      raw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final provider = context.read<ProductProvider>();
    final product = Product(
      id: widget.product?.id ?? provider.nextId(),
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      imageUrl: _imageController.text.trim(),
      sizes: _splitList(_sizesController.text),
      colors: _splitList(_colorsController.text),
      category: _categoryController.text.trim(),
      stock: int.parse(_stockController.text.trim()),
    );
    if (_isEdit) {
      await provider.updateProduct(product);
    } else {
      await provider.addProduct(product);
    }
    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: Text(_isEdit ? 'แก้ไขสินค้า' : 'เพิ่มสินค้า'),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 600,
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _field(_nameController, 'ชื่อสินค้า', required: true),
                _field(_descController, 'รายละเอียด', maxLines: 3),
                _field(_priceController, 'ราคา (บาท)', required: true,
                    keyboard: TextInputType.number),
                _field(_categoryController, 'หมวดหมู่', required: true),
                _field(_sizesController, 'ไซส์ (คั่นด้วย ,)', required: true),
                _field(_colorsController, 'สี (คั่นด้วย ,)', required: true),
                _field(_stockController, 'สต็อก', required: true,
                    keyboard: TextInputType.number),
                _field(_imageController, 'URL รูปภาพ'),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_isEdit ? 'บันทึก' : 'เพิ่มสินค้า'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboard,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboard,
          decoration: InputDecoration(labelText: label),
          validator: required
              ? (v) => (v == null || v.isEmpty) ? 'กรุณากรอก$label' : null
              : null,
        ),
      );
}
