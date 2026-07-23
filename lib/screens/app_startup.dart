import '../models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../providers/product_provider.dart';
import '../providers/promo_provider.dart';
import '../theme/app_theme.dart';
import 'admin/admin_dashboard.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class AppStartup extends StatefulWidget {
  const AppStartup({super.key});

  @override
  State<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<AppStartup> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.wait([
      context.read<AuthProvider>().init(),
      context.read<ProductProvider>().init(),
      context.read<OrderProvider>().init(),
      context.read<PromoProvider>().init(),
    ]);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final products = context.watch<ProductProvider>();
    if (!auth.isLoaded || !products.isLoaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: kBrandPink),
        ),
      );
    }
    if (!auth.isLoggedIn) return const LoginScreen();
    if (auth.currentUser!.role.isStaff) return const AdminDashboard();
    return const HomeScreen();
  }
}
