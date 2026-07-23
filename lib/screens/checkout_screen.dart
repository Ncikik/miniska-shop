import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../data/bank_info.dart';
import '../main.dart';
import '../models/discount.dart';
import '../models/order.dart' as order_model;
import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/discount_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/product_image.dart';
import '../widgets/responsive_center.dart';
import 'home_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> items;
  const CheckoutScreen({super.key, required this.items});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _discountController = TextEditingController();
  final _freeShipController = TextEditingController();
  String _paymentMethod = 'โอนผ่านธนาคาร';

  DiscountCode? _appliedDiscount;
  DiscountCode? _appliedFreeShip;
  String? _discountError;
  String? _freeShipError;

  static const _shippingFee = 50.0;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _nameController.text = user.displayName;
      _phoneController.text = user.phone;
      _addressController.text = user.address;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _discountController.dispose();
    _freeShipController.dispose();
    super.dispose();
  }

  double get _subtotal =>
      widget.items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get _discountAmount {
    final d = _appliedDiscount;
    if (d == null) return 0;
    if (d.type == DiscountType.percent) {
      return _subtotal * (d.value / 100);
    }
    if (d.type == DiscountType.fixed) {
      return d.value > _subtotal ? _subtotal : d.value;
    }
    return 0;
  }

  bool get _isFreeShipping => _appliedFreeShip != null;

  double get _shippingFeeCharged => _isFreeShipping ? 0 : _shippingFee;

  double get _grandTotal => _subtotal - _discountAmount + _shippingFeeCharged;

  void _applyDiscountCode() {
    setState(() => _discountError = null);
    final code = context.read<DiscountProvider>().findValid(
          _discountController.text,
        );
    if (code == null) {
      setState(() {
        _discountError = 'ไม่พบโค้ดนี้ หรือโค้ดหมดอายุแล้ว';
        _appliedDiscount = null;
      });
      return;
    }
    if (code.type == DiscountType.freeShipping) {
      setState(() {
        _discountError =
            'โค้ดนี้เป็นโค้ดส่งฟรี กรุณากรอกในช่องโค้ดส่งฟรีด้านล่าง';
        _appliedDiscount = null;
      });
      return;
    }
    setState(() => _appliedDiscount = code);
  }

  void _applyFreeShipCode() {
    setState(() => _freeShipError = null);
    final code = context.read<DiscountProvider>().findValid(
          _freeShipController.text,
        );
    if (code == null) {
      setState(() {
        _freeShipError = 'ไม่พบโค้ดนี้ หรือโค้ดหมดอายุแล้ว';
        _appliedFreeShip = null;
      });
      return;
    }
    if (code.type != DiscountType.freeShipping) {
      setState(() {
        _freeShipError =
            'โค้ดนี้ไม่ใช่โค้ดส่งฟรี กรุณากรอกในช่องโค้ดส่วนลดด้านบน';
        _appliedFreeShip = null;
      });
      return;
    }
    setState(() => _appliedFreeShip = code);
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    final order = order_model.Order(
      id: 'ord_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      userName: user.displayName,
      items: widget.items
          .map((i) => order_model.OrderItem.fromCartItem(i))
          .toList(),
      subtotal: _subtotal,
      discountAmount: _discountAmount,
      shippingFee: _shippingFeeCharged,
      total: _grandTotal,
      discountCode: _appliedDiscount?.code,
      freeShipCode: _appliedFreeShip?.code,
      receiverName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      paymentMethod: _paymentMethod,
      createdAt: DateTime.now(),
    );

    await context.read<OrderProvider>().addOrder(order);
    if (!mounted) return;
    // บันทึกชื่อ/เบอร์โทร/ที่อยู่ที่กรอกล่าสุด ไว้ใช้กรอกอัตโนมัติในครั้งถัดไป
    await context.read<AuthProvider>().updateProfile(
          displayName: _nameController.text,
          phone: _phoneController.text,
          address: _addressController.text,
        );
    if (!mounted) return;
    context.read<CartProvider>().removeSelected();
    _showSuccessDialog(context, _grandTotal);
  }

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat.currency(
      locale: 'th_TH',
      symbol: '฿',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('ชำระเงิน'),
        backgroundColor: kBackground,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ResponsiveCenter(
            maxWidth: 800,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _sectionTitle(
                  Icons.shopping_bag_outlined,
                  'รายการสินค้าที่สั่งซื้อ (${widget.items.length})',
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE9E1FB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < widget.items.length; i++) ...[
                        if (i > 0)
                          const Divider(height: 1, indent: 16, endIndent: 16),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: 62,
                                  height: 74,
                                  child: ProductImage(
                                    product: widget.items[i].product,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.items[i].product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'ไซส์ ${widget.items[i].size} · สี ${widget.items[i].color} · x${widget.items[i].quantity}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                priceFormat.format(widget.items[i].totalPrice),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: kBrandDark,
                                  fontSize: 13.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _sectionTitle(Icons.local_shipping_outlined, 'ที่อยู่จัดส่ง'),
                _card(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'ชื่อ-นามสกุล',
                          border: InputBorder.none,
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'กรุณากรอกชื่อ' : null,
                      ),
                      const Divider(height: 1),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'เบอร์โทรศัพท์',
                          border: InputBorder.none,
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'กรุณากรอกเบอร์โทร'
                            : null,
                      ),
                      const Divider(height: 1),
                      TextFormField(
                        controller: _addressController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'ที่อยู่จัดส่ง',
                          border: InputBorder.none,
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'กรุณากรอกที่อยู่'
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _sectionTitle(
                    Icons.local_offer_outlined, 'โค้ดส่วนลด / โค้ดส่งฟรี'),
                _card(
                  child: Column(
                    children: [
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _discountController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: const InputDecoration(
                                labelText: 'โค้ดส่วนลด',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _applyDiscountCode,
                            child: const Text('ใช้โค้ด'),
                          ),
                        ],
                      ),
                      if (_discountError != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _discountError!,
                            style: const TextStyle(
                                color: Colors.redAccent, fontSize: 12),
                          ),
                        ),
                      if (_appliedDiscount != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'ใช้โค้ด "${_appliedDiscount!.code}" แล้ว (${_appliedDiscount!.description})',
                            style: const TextStyle(
                                color: Color(0xFF1E9E5A), fontSize: 12),
                          ),
                        ),
                      const Divider(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _freeShipController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: const InputDecoration(
                                labelText: 'โค้ดส่งฟรี',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _applyFreeShipCode,
                            child: const Text('ใช้โค้ด'),
                          ),
                        ],
                      ),
                      if (_freeShipError != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _freeShipError!,
                            style: const TextStyle(
                                color: Colors.redAccent, fontSize: 12),
                          ),
                        ),
                      if (_appliedFreeShip != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'ใช้โค้ด "${_appliedFreeShip!.code}" แล้ว (ส่งฟรี)',
                            style: const TextStyle(
                                color: Color(0xFF1E9E5A), fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _sectionTitle(Icons.payment_outlined, 'วิธีชำระเงิน'),
                _card(
                  child: Column(
                    children: [
                      'โอนผ่านธนาคาร',
                      'บัตรเครดิต/เดบิต',
                      'เก็บเงินปลายทาง',
                    ]
                        .map(
                          (method) => RadioListTile<String>(
                            title: Text(
                              method,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            value: method,
                            groupValue: _paymentMethod,
                            activeColor: kBrandDark,
                            onChanged: (value) =>
                                setState(() => _paymentMethod = value!),
                          ),
                        )
                        .toList(),
                  ),
                ),
                _buildBankTransferCard(priceFormat),
                const SizedBox(height: 20),
                _sectionTitle(Icons.receipt_long_outlined, 'สรุปยอดชำระ'),
                _card(
                  child: Column(
                    children: [
                      _summaryRow(
                        'ยอดสินค้า',
                        priceFormat.format(_subtotal),
                      ),
                      if (_appliedDiscount != null) ...[
                        const SizedBox(height: 6),
                        _summaryRow(
                          'ส่วนลด (${_appliedDiscount!.code})',
                          '-${priceFormat.format(_discountAmount)}',
                        ),
                      ],
                      const SizedBox(height: 6),
                      _summaryRow(
                        'ค่าจัดส่ง',
                        _isFreeShipping
                            ? 'ส่งฟรี'
                            : priceFormat.format(_shippingFeeCharged),
                      ),
                      const Divider(height: 24),
                      _summaryRow(
                        'ยอดชำระทั้งหมด',
                        priceFormat.format(_grandTotal),
                        bold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 800,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16, top: 8),
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: widget.items.isEmpty ? null : _placeOrder,
                child: Text(
                  'ยืนยันคำสั่งซื้อ · ${priceFormat.format(_grandTotal)}',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, double total) {
    final priceFormat = NumberFormat.currency(
      locale: 'th_TH',
      symbol: '฿',
      decimalDigits: 0,
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite,
                color: kBrandDark,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'สั่งซื้อสำเร็จ!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'ยอดชำระทั้งหมด ${priceFormat.format(total)}\nขอบคุณที่อุดหนุนค่ะ 💕',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _receiptRow(
                      Icons.person_outline, _nameController.text.trim()),
                  const SizedBox(height: 8),
                  _receiptRow(
                      Icons.call_outlined, _phoneController.text.trim()),
                  const SizedBox(height: 8),
                  _receiptRow(
                    Icons.location_on_outlined,
                    _addressController.text.trim(),
                  ),
                  const SizedBox(height: 8),
                  _receiptRow(Icons.payment_outlined, _paymentMethod),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              },
              child: const Text('กลับหน้าหลัก'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankTransferCard(NumberFormat priceFormat) {
    if (_paymentMethod != 'โอนผ่านธนาคาร') return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        _sectionTitle(Icons.qr_code_2_outlined, 'ข้อมูลการโอนเงิน'),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    BankInfo.qrImageUrl(_grandTotal),
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return SizedBox(
                        width: 200,
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kBrandDark,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 200,
                      height: 200,
                      color: kBackground,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.qr_code_2,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'สแกนเพื่อโอนเงิน ${priceFormat.format(_grandTotal)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
              const Divider(height: 28),
              _bankInfoRow('ธนาคาร', BankInfo.bankName),
              const SizedBox(height: 10),
              _bankInfoRow('ชื่อบัญชี', BankInfo.accountName),
              const SizedBox(height: 10),
              _bankInfoRow('เลขบัญชี', BankInfo.accountNumber, copyable: true),
              const SizedBox(height: 10),
              _bankInfoRow('พร้อมเพย์', BankInfo.promptPayId, copyable: true),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: kBrandDark),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'หลังโอนเงินแล้ว กดยืนยันคำสั่งซื้อด้านล่างได้เลย ทางร้านจะตรวจสอบยอดและจัดส่งสินค้าให้ค่ะ',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bankInfoRow(String label, String value, {bool copyable = false}) {
    return Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
          ),
        ),
        if (copyable)
          IconButton(
            icon: const Icon(Icons.copy_outlined, size: 17),
            color: kBrandDark,
            onPressed: () => _copyToClipboard(value),
          ),
      ],
    );
  }

  void _copyToClipboard(String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // เอา behavior: SnackBarBehavior.floating ออก เพราะเป็นสาเหตุของ
        // error "Floating SnackBar presented off screen" ที่วนซ้ำจนแอปค้าง
        backgroundColor: kBrandDark,
        content: Text('คัดลอก "$value" แล้ว'),
      ),
    );
  }

  Widget _receiptRow(IconData icon, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: kBrandDark),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(fontSize: 12.5, height: 1.4),
            ),
          ),
        ],
      );

  Widget _sectionTitle(IconData icon, String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 4, left: 4),
        child: Row(
          children: [
            Icon(icon, size: 16, color: kBrandDark),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ],
        ),
      );

  Widget _card({required Widget child}) => Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE9E1FB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      );

  Widget _summaryRow(String label, String value, {bool bold = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 15 : 13.5,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 16 : 13.5,
              color: bold ? kBrandDark : Colors.black87,
            ),
          ),
        ],
      );
}
