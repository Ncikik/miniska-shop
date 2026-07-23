import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../widgets/responsive_center.dart';

class ManageEmployeesScreen extends StatelessWidget {
  const ManageEmployeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final employees = context.watch<AuthProvider>().employees;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(title: const Text('จัดการบัญชีพนักงาน'), backgroundColor: kBackground),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 700,
          child: employees.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Text(
                      'ยังไม่มีบัญชีพนักงาน',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: employees.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final emp = employees[index];
                    return _EmployeeRow(employee: emp);
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kBrandDark,
        icon: const Icon(Icons.person_add_alt),
        label: const Text('เพิ่มพนักงาน'),
        onPressed: () => _showAddEmployeeDialog(context),
      ),
    );
  }

  Future<void> _showAddEmployeeDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    String? error;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: const Text('เพิ่มบัญชีพนักงาน'),
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
                    final result = await context.read<AuthProvider>().addEmployee(
                      username: usernameController.text,
                      password: passwordController.text,
                      displayName: nameController.text,
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

class _EmployeeRow extends StatelessWidget {
  final AppUser employee;
  const _EmployeeRow({required this.employee});

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
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: kBackground,
            child: Text(
              employee.displayName.isNotEmpty ? employee.displayName.substring(0, 1) : '?',
              style: const TextStyle(color: kBrandDark, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
                const SizedBox(height: 2),
                Text(
                  '@${employee.username}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            onPressed: () {
              context.read<AuthProvider>().removeEmployee(employee.id);
            },
          ),
        ],
      ),
    );
  }
}
