import 'package:flutter/material.dart';

/// จำกัดความกว้างของเนื้อหาและจัดให้อยู่กึ่งกลางหน้าจอ
/// ใช้สำหรับตอนเปิดบนเว็บ/จอกว้าง ๆ ไม่ให้เนื้อหายืดเต็มจอจนดูโล่ง
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 1100,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}

/// ครอบทั้งหน้าจอด้วยพื้นหลังไล่สีอ่อน ๆ แล้วจัดเนื้อหาไว้กึ่งกลาง
/// ใช้แทน body ปกติของ Scaffold ในแต่ละหน้า
class PageBackground extends StatelessWidget {
  final Widget child;
  final bool scrollable;

  const PageBackground({
    super.key,
    required this.child,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF5F8), Color(0xFFFCE4EC)],
        ),
      ),
      child: child,
    );
    return content;
  }
}
