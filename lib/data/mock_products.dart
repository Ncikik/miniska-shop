import '../models/product.dart';

/// ข้อมูลสินค้าจำลอง — ในโปรเจกต์จริงควรดึงจาก API/Firestore แทน
/// รูปภาพใช้บริการ placehold.co (เสถียร รองรับ CORS ดี ไม่ค่อยโดนบล็อกจากเครือข่ายมือถือ)
/// เมื่อมีรูปสินค้าจริงแล้ว ให้เปลี่ยน imageUrl เป็นรูปจริงของคุณได้เลย
final List<Product> mockProducts = [
  Product(
    id: 'p1',
    name: 'เสื้อยืดคอกลม Basic',
    description:
        'เสื้อยืดคอกลมผ้าคอตตอน 100% เนื้อนุ่ม ใส่สบาย ระบายอากาศดี เหมาะกับทุกโอกาส',
    price: 259,
    imageUrl: 'assets/images/p1.png',
    sizes: const ['S', 'M', 'L', 'XL'],
    colors: const ['ขาว', 'ดำ', 'เทา'],
    category: 'เสื้อยืด',
  ),
  Product(
    id: 'p2',
    name: 'เสื้อโปโล Premium',
    description: 'เสื้อโปโลผ้าพิเก้อย่างดี ทรงสวย ใส่ทำงานหรือลำลองก็เข้ากัน',
    price: 459,
    imageUrl: 'assets/images/p2.png',
    sizes: const ['M', 'L', 'XL', 'XXL'],
    colors: const ['กรมท่า', 'ขาว', 'แดงเลือดหมู'],
    category: 'เสื้อโปโล',
  ),
  Product(
    id: 'p3',
    name: 'เสื้อฮู้ด Oversize',
    description: 'เสื้อฮู้ดทรงโอเวอร์ไซส์ ผ้าหนานุ่ม กันหนาวได้ดี สไตล์สตรีท',
    price: 690,
    imageUrl: 'assets/images/p3.png',
    sizes: const ['S', 'M', 'L', 'XL'],
    colors: const ['ดำ', 'เบจ', 'เขียวทหาร'],
    category: 'เสื้อฮู้ด',
  ),
  Product(
    id: 'p4',
    name: 'เสื้อเชิ้ตลายสก็อต',
    description: 'เสื้อเชิ้ตแขนยาวลายสก็อต ผ้าค่อนข้างหนา ใส่สบาย ดูมีสไตล์',
    price: 550,
    imageUrl: 'assets/images/p4.png',
    sizes: const ['S', 'M', 'L'],
    colors: const ['แดง-ดำ', 'น้ำเงิน-ขาว'],
    category: 'เสื้อเชิ้ต',
  ),
  Product(
    id: 'p5',
    name: 'เสื้อกล้าม Sport',
    description: 'เสื้อกล้ามผ้าตาข่ายระบายอากาศ เหมาะสำหรับออกกำลังกาย',
    price: 199,
    imageUrl: 'assets/images/p5.png',
    sizes: const ['M', 'L', 'XL'],
    colors: const ['ดำ', 'เทา'],
    category: 'เสื้อกล้าม',
  ),
  Product(
    id: 'p6',
    name: 'เสื้อสเวตเตอร์ไหมพรม',
    description: 'เสื้อไหมพรมถักลาย ใส่กันหนาวได้ดี ดีไซน์เรียบหรู',
    price: 620,
    imageUrl: 'assets/images/p6.png',
    sizes: const ['S', 'M', 'L'],
    colors: const ['ครีม', 'น้ำตาล'],
    category: 'เสื้อสเวตเตอร์',
  ),
];
