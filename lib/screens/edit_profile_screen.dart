import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../widgets/responsive_center.dart';

/// หน้าให้ผู้ใช้ที่ล็อกอินอยู่ กรอก/แก้ไขข้อมูลส่วนตัว (ชื่อ, เบอร์โทร, ที่อยู่)
/// ข้อมูลนี้จะถูกใช้กรอกอัตโนมัติตอนไปหน้าชำระเงินในครั้งถัดไป
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final error = await context.read<AuthProvider>().updateProfile(
          displayName: _nameController.text,
          phone: _phoneController.text,
          address: _addressController.text,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // เอา behavior: SnackBarBehavior.floating ออก เพราะเป็นสาเหตุของ
        // error "Floating SnackBar presented off screen" ที่วนซ้ำจนแอปค้าง
        backgroundColor: kBrandDark,
        content: const Text('บันทึกข้อมูลส่วนตัวเรียบร้อยแล้ว'),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
          title: const Text('ข้อมูลส่วนตัว'), backgroundColor: kBackground),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveCenter(
            maxWidth: 520,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  if (user != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE9E1FB)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.alternate_email,
                              size: 16, color: Colors.grey.shade500),
                          const SizedBox(width: 8),
                          Text(
                            '${user.username} · ${user.role.label}',
                            style: TextStyle(
                                fontSize: 12.5, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'ชื่อ-นามสกุล',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'กรุณากรอกชื่อ-นามสกุล'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'เบอร์โทรศัพท์',
                      prefixIcon: Icon(Icons.call_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _addressController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'ที่อยู่จัดส่ง',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _error!,
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    'ข้อมูลนี้จะถูกกรอกให้อัตโนมัติในครั้งถัดไปที่คุณสั่งซื้อสินค้า',
                    style:
                        TextStyle(fontSize: 11.5, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.4,
                              ),
                            )
                          : const Text('บันทึกข้อมูล'),
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
