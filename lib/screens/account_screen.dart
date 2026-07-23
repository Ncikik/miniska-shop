import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../widgets/responsive_center.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'manage_customers_screen.dart';
import 'manage_discounts_screen.dart';
import 'manage_employees_screen.dart';
import 'manage_products_screen.dart';
import 'purchase_history_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(title: const Text('บัญชีของฉัน'), backgroundColor: kBackground),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveCenter(
            maxWidth: 640,
            child: user == null
                ? _buildLoggedOut(context)
                : _buildLoggedIn(context, user),
          ),
        ),
      ),
    );
  }

  Widget _buildLoggedOut(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_outline, size: 48, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          Text(
            'ยังไม่ได้เข้าสู่ระบบ',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 220,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text('เข้าสู่ระบบ / สมัครสมาชิก'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedIn(BuildContext context, AppUser user) {
    final auth = context.read<AuthProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: kBrandGradient,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  child: Text(
                    user.displayName.isNotEmpty
                        ? user.displayName.substring(0, 1)
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.role.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _menuTile(
            context,
            icon: Icons.person_outline,
            title: 'ข้อมูลส่วนตัว (ชื่อ/เบอร์โทร/ที่อยู่)',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
          ),
          const SizedBox(height: 10),
          _menuTile(
            context,
            icon: Icons.receipt_long_outlined,
            title: 'ประวัติการสั่งซื้อ',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PurchaseHistoryScreen()),
            ),
          ),
          if (user.role.isStaff) ...[
            const SizedBox(height: 10),
            _sectionLabel('เมนูสำหรับร้านค้า'),
            const SizedBox(height: 10),
            _menuTile(
              context,
              icon: Icons.people_outline,
              title: 'จัดการบัญชีลูกค้า',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageCustomersScreen()),
              ),
            ),
            const SizedBox(height: 10),
            _menuTile(
              context,
              icon: Icons.inventory_2_outlined,
              title: 'จัดการสินค้า',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageProductsScreen()),
              ),
            ),
            const SizedBox(height: 10),
            _menuTile(
              context,
              icon: Icons.local_offer_outlined,
              title: 'จัดการโค้ดส่วนลด / โค้ดส่งฟรี',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageDiscountsScreen()),
              ),
            ),
          ],
          if (user.role == UserRole.owner) ...[
            const SizedBox(height: 10),
            _menuTile(
              context,
              icon: Icons.badge_outlined,
              title: 'จัดการบัญชีพนักงาน',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageEmployeesScreen()),
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('ออกจากระบบ'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () async {
                await auth.logout();
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade500,
      ),
    ),
  );

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
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
                child: Icon(icon, color: kBrandDark, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
