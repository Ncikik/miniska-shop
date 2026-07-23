import 'package:flutter/material.dart';

// โทนสีชมพู-ฟ้า-ม่วง
const kBrandPink = Color(0xFFE91E8C);
const kBrandBlue = Color(0xFF5B8DEF);
const kBrandPurple = Color(0xFF9B59F5);

// สีหลักที่ใช้ทั่วแอป (backward compat)
const kBrandDark = kBrandPink;
const kBrandGold = kBrandBlue;
const kBrandDeep = kBrandPurple;
const kBackground = Color(0xFFF8F4FF);

const kBrandGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kBrandPink, kBrandPurple, kBrandBlue],
);

const kPageGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFFF8F4FF), Color(0xFFEDE7FF)],
);
