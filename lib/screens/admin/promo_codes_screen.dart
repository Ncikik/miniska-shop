import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/promo_code.dart';
import '../../providers/promo_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/responsive_center.dart';

class PromoCodesScreen extends StatefulWidget {
  const PromoCodesScreen({super.key});

  @override
  State<PromoCodesScreen> createState() => _PromoCodesScreenState();
}

class _PromoCodesScreenState extends State<PromoCodesScreen> {
  @override
  Widget build(BuildContext context) {
    final promos = context.watch<PromoProvider>().promos;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(title: const Text('โค้ดส่วนลด / ส่งฟรี')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kBrandPurple,
        onPressed: () => _showForm(context),
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มโค้ด'),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 700,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: promos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final promo = promos[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8DEFF)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            promo.code,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: kBrandPink,
                            ),
                          ),
                          Text(
                            promo.typeLabel,
                            style: const TextStyle(fontSize: 13),
                          ),
                          if (promo.minOrder != null)
                            Text(
                              'ยอดขั้นต่ำ ฿${promo.minOrder!.toInt()}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Switch(
                      value: promo.isActive,
                      activeColor: kBrandPurple,
                      onChanged: (v) => context
                          .read<PromoProvider>()
                          .updatePromo(promo.copyWith(isActive: v)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.redAccent),
                      onPressed: () => context
                          .read<PromoProvider>()
                          .deletePromo(promo.code),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showForm(BuildContext context) async {
    final codeController = TextEditingController();
    var type = PromoType.percentDiscount;
    final valueController = TextEditingController(text: '10');
    final minOrderController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('เพิ่มโค้ด'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: 'รหัสโค้ด'),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<PromoType>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'ประเภท'),
                  items: const [
                    DropdownMenuItem(
                      value: PromoType.percentDiscount,
                      child: Text('ลดเปอร์เซ็นต์'),
                    ),
                    DropdownMenuItem(
                      value: PromoType.fixedDiscount,
                      child: Text('ลดคงที่ (บาท)'),
                    ),
                    DropdownMenuItem(
                      value: PromoType.freeShipping,
                      child: Text('ส่งฟรี'),
                    ),
                  ],
                  onChanged: (v) => setDialogState(() => type = v!),
                ),
                if (type != PromoType.freeShipping) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: valueController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: type == PromoType.percentDiscount
                          ? 'เปอร์เซ็นต์'
                          : 'จำนวนเงิน (บาท)',
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                TextField(
                  controller: minOrderController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'ยอดขั้นต่ำ (ไม่บังคับ)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (codeController.text.trim().isEmpty) return;
                final promo = PromoCode(
                  code: codeController.text.trim().toUpperCase(),
                  type: type,
                  value: type == PromoType.freeShipping
                      ? 0
                      : double.tryParse(valueController.text) ?? 0,
                  minOrder: double.tryParse(minOrderController.text),
                );
                await context.read<PromoProvider>().addPromo(promo);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('เพิ่ม'),
            ),
          ],
        ),
      ),
    );
  }
}
