import '../../models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/responsive_center.dart';
import '../home_screen.dart';
import 'orders_admin_screen.dart';
import 'product_list_admin_screen.dart';
import 'promo_codes_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;
    final productCount = context.watch<ProductProvider>().products.length;
    final orderCount = context.watch<OrderProvider>().allOrders.length;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: Text('แผงควบคุม · ${user.role.label}'),
        actions: [
          if (user.role.name == 'owner' || user.role.name == 'staff')
            IconButton(
              tooltip: 'ดูหน้าร้าน',
              icon: const Icon(Icons.storefront_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              ),
            ),
          IconButton(
            tooltip: 'ออกจากระบบ',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 900,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: kBrandGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'สวัสดี, ${user.displayName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'จัดการร้าน ShirtShop ได้ที่นี่',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _statChip('$productCount สินค้า'),
                        const SizedBox(width: 10),
                        _statChip('$orderCount ออเดอร์'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'เมนูจัดการ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              _menuTile(
                context,
                icon: Icons.inventory_2_outlined,
                title: 'จัดการสินค้า',
                subtitle: 'เพิ่ม แก้ไข ลบสินค้า',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProductListAdminScreen(),
                  ),
                ),
              ),
              _menuTile(
                context,
                icon: Icons.receipt_long_outlined,
                title: 'ออเดอร์ทั้งหมด',
                subtitle: 'ดูและอัปเดตสถานะออเดอร์',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrdersAdminScreen()),
                ),
              ),
              if (user.role == UserRole.owner)
                _menuTile(
                  context,
                  icon: Icons.local_offer_outlined,
                  title: 'โค้ดส่วนลด / ส่งฟรี',
                  subtitle: 'จัดการโปรโมชัน',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PromoCodesScreen(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE8DEFF)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EEFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: kBrandPurple),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: kBrandPink),
                ],
              ),
            ),
          ),
        ),
      );
}
