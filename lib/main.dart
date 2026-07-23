import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/mock_products.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/discount_provider.dart';
import 'providers/image_override_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ShirtShopApp());
}

// สีหลักของแบรนด์ — โทนชมพู ฟ้า ม่วง หวานสดใส ดูมีชีวิตชีวา
const kBrandDark = Color(0xFF8B5CF6); // ม่วง ใช้เป็นสีหลัก
const kBrandGold = Color(0xFFEC4899); // ชมพู ใช้เป็นสีรอง/ไฮไลต์
const kBrandDeep = Color(0xFF5B21B6); // ม่วงเข้ม ใช้ไล่สีกับ kBrandDark
const kBrandBlue = Color(0xFF3B82F6); // ฟ้า ใช้เป็นสีแต้มที่สาม
const kBackground = Color(0xFFF6F4FE); // พื้นหลังม่วงอ่อนมาก

/// ไล่สีหลักของแอป: ชมพู -> ม่วง -> ฟ้า ใช้กับพื้นหลัง/แบนเนอร์
const kBrandGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kBrandGold, kBrandDark, kBrandBlue],
);

const kBackgroundGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFFFDF4FA), Color(0xFFF3EEFE), Color(0xFFEFF5FE)],
);

class ShirtShopApp extends StatelessWidget {
  const ShirtShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => DiscountProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => ImageOverrideProvider()),
      ],
      child: MaterialApp(
        title: 'ShirtShop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: kBackground,
          colorScheme: ColorScheme.fromSeed(
            seedColor: kBrandDark,
            primary: kBrandDark,
            secondary: kBrandGold,
            tertiary: kBrandBlue,
            surface: Colors.white,
          ),
          textTheme: const TextTheme(
            headlineSmall: TextStyle(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            titleLarge: TextStyle(fontWeight: FontWeight.w700),
            titleMedium: TextStyle(fontWeight: FontWeight.w600),
            bodyMedium: TextStyle(height: 1.5),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            foregroundColor: kBrandDark,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              color: kBrandDark,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: kBrandDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 6,
              shadowColor: kBrandDark.withOpacity(0.4),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          chipTheme: ChipThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            backgroundColor: Colors.white,
            selectedColor: kBrandDark,
            labelStyle: const TextStyle(fontWeight: FontWeight.w500),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: kBrandDark, width: 1.5),
            ),
          ),
        ),
        home: const _AppStartup(),
      ),
    );
  }
}

/// โหลดข้อมูลทั้งหมด (ผู้ใช้ / สินค้า / ออเดอร์ / โค้ดส่วนลด / รูปสินค้า)
/// ก่อนแสดงหน้าหลัก เพื่อให้ทุก Provider พร้อมใช้งาน
class _AppStartup extends StatefulWidget {
  const _AppStartup();

  @override
  State<_AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<_AppStartup> {
  late final Future<void> _ready;

  @override
  void initState() {
    super.initState();
    _ready = _init();
  }

  Future<void> _init() async {
    final productProvider = context.read<ProductProvider>();
    await Future.wait([
      context.read<AuthProvider>().init(),
      context.read<OrderProvider>().init(),
      context.read<DiscountProvider>().init(),
      productProvider.init(),
    ]);
    final ids = [
      ...mockProducts.map((p) => p.id),
      ...productProvider.products.map((p) => p.id),
    ].toSet().toList();
    await Future.wait([
      context.read<ImageOverrideProvider>().loadAll(ids),
      context.read<CartProvider>().init(productProvider.products),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _ready,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _SplashScreen();
        }
        return const HomeScreen();
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: kBackgroundGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: kBrandGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.checkroom_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(color: kBrandDark),
            ],
          ),
        ),
      ),
    );
  }
}
