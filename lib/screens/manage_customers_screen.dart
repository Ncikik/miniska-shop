import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../widgets/responsive_center.dart';

/// เจ้าของร้าน/พนักงาน ดูรายชื่อและเพิ่มบัญชีลูกค้าได้จากหลังบ้าน
class ManageCustomersScreen extends StatelessWidget {
  const ManageCustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customers = context.watch<AuthProvider>().customers;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(title: const Text('จัดการบัญชีลูกค้า'), backgroundColor: kBackground),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 700,
          child: customers.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Text(
                      'ยังไม่มีบัญชีลูกค้า',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: customers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return _CustomerRow(customer: customer);
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kBrandDark,
        icon: const Icon(Icons.person_add_alt),
        label: const Text('เพิ่มลูกค้า'),
        onPressed: () => _showAddCustomerDialog(context),
      ),
    );
  }

  Future<void> _showAddCustomerDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    String? error;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: const Text('เพิ่มบัญชีลูกค้า'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'ชื่อ-นามสกุล'),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(labelText: 'ชื่อผู้ใช้'),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'รหัสผ่าน'),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'เบอร์โทร (ไม่บังคับ)'),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: addressController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'ที่อยู่ (ไม่บังคับ)'),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 10),
                      Text(error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12.5)),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('ยกเลิก'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final result = await context.read<AuthProvider>().addCustomer(
                      username: usernameController.text,
                      password: passwordController.text,
                      displayName: nameController.text,
                      phone: phoneController.text,
                      address: addressController.text,
                    );
                    if (result != null) {
                      setState(() => error = result);
                      return;
                    }
                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                  },
                  child: const Text('บันทึก'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _CustomerRow extends StatelessWidget {
  final AppUser customer;
  const _CustomerRow({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9E1FB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: kBackground,
            child: Text(
              customer.displayName.isNotEmpty ? customer.displayName.substring(0, 1) : '?',
              style: const TextStyle(color: kBrandDark, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
                const SizedBox(height: 2),
                Text(
                  '@${customer.username}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                if (customer.phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    customer.phone,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
                if (customer.address.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    customer.address,
                    style: TextStyle(fontSize: 11.5, color: Colors.grey.shade400),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            onPressed: () {
              context.read<AuthProvider>().removeCustomer(customer.id);
            },
          ),
        ],
      ),
    );
  }
}
