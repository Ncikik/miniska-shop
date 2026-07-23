import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/discount.dart';
import '../providers/discount_provider.dart';
import '../widgets/responsive_center.dart';

class ManageDiscountsScreen extends StatelessWidget {
  const ManageDiscountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final codes = context.watch<DiscountProvider>().codes;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('โค้ดส่วนลด / โค้ดส่งฟรี'),
        backgroundColor: kBackground,
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 700,
          child: codes.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Text(
                      'ยังไม่มีโค้ดส่วนลด',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: codes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final code = codes[index];
                    return _CodeRow(code: code);
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kBrandDark,
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มโค้ด'),
        onPressed: () => _showAddCodeDialog(context),
      ),
    );
  }

  Future<void> _showAddCodeDialog(BuildContext context) async {
    final codeController = TextEditingController();
    final valueController = TextEditingController();
    DiscountType type = DiscountType.percent;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: const Text('เพิ่มโค้ดใหม่'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: codeController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'รหัสโค้ด เช่น SALE20',
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<DiscountType>(
                      value: type,
                      decoration: const InputDecoration(labelText: 'ประเภทโค้ด'),
                      items: DiscountType.values
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t.label)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => type = v ?? type),
                    ),
                    if (type != DiscountType.freeShipping) ...[
                      const SizedBox(height: 14),
                      TextField(
                        controller: valueController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: type == DiscountType.percent
                              ? 'ลดกี่เปอร์เซ็นต์ (%)'
                              : 'ลดกี่บาท',
                        ),
                      ),
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
                    final code = codeController.text.trim().toUpperCase();
                    if (code.isEmpty) return;
                    final value = double.tryParse(valueController.text.trim()) ?? 0;
                    await context.read<DiscountProvider>().addCode(
                      DiscountCode(code: code, type: type, value: value),
                    );
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

class _CodeRow extends StatelessWidget {
  final DiscountCode code;
  const _CodeRow({required this.code});

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
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: kBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              code.type == DiscountType.freeShipping
                  ? Icons.local_shipping_outlined
                  : Icons.sell_outlined,
              color: kBrandDark,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code.code,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  code.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Switch(
            value: code.active,
            activeColor: kBrandDark,
            onChanged: (v) {
              context.read<DiscountProvider>().toggleActive(code.code, v);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            onPressed: () {
              context.read<DiscountProvider>().removeCode(code.code);
            },
          ),
        ],
      ),
    );
  }
}
