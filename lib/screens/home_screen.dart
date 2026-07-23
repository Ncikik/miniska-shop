import '../widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/responsive_center.dart';
import 'account_screen.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'ทั้งหมด';
  String _searchQuery = '';

  List<String> _categories(List products) => [
        'ทั้งหมด',
        ...{for (final p in products) p.category},
      ];

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().products;
    final filtered = products.where((p) {
      final matchesCategory =
          _selectedCategory == 'ทั้งหมด' || p.category == _selectedCategory;
      final matchesSearch = p.name.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      return matchesCategory && matchesSearch;
    }).toList();

    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: kBackgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ResponsiveCenter(
              maxWidth: 1200,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildTopBar(context, cart, auth),
                  const SizedBox(height: 22),
                  _buildHeroBanner(context),
                  const SizedBox(height: 20),
                  _buildFeatureHighlights(),
                  const SizedBox(height: 32),
                  _buildSearchAndFilter(products),
                  const SizedBox(height: 24),
                  _buildSectionTitle(filtered.length),
                  const SizedBox(height: 16),
                  _buildProductGrid(filtered),
                  const SizedBox(height: 48),
                  _buildFooter(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(
      BuildContext context, CartProvider cart, AuthProvider auth) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: kBrandGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.checkroom_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'miniska shop',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: kBrandDark,
          ),
        ),
        const Spacer(),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccountScreen()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    auth.isLoggedIn ? Icons.person : Icons.person_outline,
                    color: kBrandDark,
                  ),
                  if (auth.isStaff)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: kBrandBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_bag_outlined, color: kBrandDark),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: kBrandGold,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 34, 28, 34),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: kBrandGradient,
        boxShadow: [
          BoxShadow(
            color: kBrandDark.withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -30,
            child: Icon(
              Icons.checkroom_rounded,
              size: 160,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'คอลเลกชันใหม่ประจำซีซั่น',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'ใส่แล้วดูดี\nในทุกวันของคุณ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'เสื้อผ้าคุณภาพดี ดีไซน์เรียบหรู ใส่สบายทุกวัน',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureHighlights() {
    final features = [
      (Icons.local_shipping_outlined, 'จัดส่งฟรี', 'เมื่อใช้โค้ดส่งฟรี'),
      (Icons.verified_outlined, 'ของแท้ 100%', 'รับประกันคุณภาพ'),
      (Icons.autorenew_rounded, 'คืนสินค้าได้', 'ภายใน 7 วัน'),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 340;
        final children = features
            .map(
              (f) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE9E1FB)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: const BoxDecoration(
                          color: kBackground,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(f.$1, color: kBrandDark, size: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        f.$2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        f.$3,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList();
        return isNarrow
            ? Column(
                children: children
                    .map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: c,
                      ),
                    )
                    .toList(),
              )
            : Row(children: children);
      },
    );
  }

  Widget _buildSectionTitle(int count) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 22,
          decoration: BoxDecoration(
            color: kBrandDark,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'สินค้าแนะนำ',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(width: 8),
        Text(
          '($count รายการ)',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9E1FB)),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite, color: kBrandGold, size: 16),
              SizedBox(width: 6),
              Text(
                'miniska shop',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'ร้านเสื้อผ้าออนไลน์ที่ใส่ใจทุกรายละเอียด © 2026',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(List products) {
    final categories = _categories(products);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'ค้นหาเสื้อที่ใช่สำหรับคุณ...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: kBrandDark),
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category == _selectedCategory;
              return ChoiceChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedCategory = category),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid(List filtered) {
    if (filtered.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(child: Text('ไม่พบสินค้าที่ค้นหา')),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 4
            : constraints.maxWidth > 620
                ? 3
                : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            childAspectRatio: 0.64,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final product = filtered[index];
            return ProductCard(
              product: product,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(product: product),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
