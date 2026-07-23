/// ข้อมูลบัญชีธนาคาร/พร้อมเพย์ของร้าน สำหรับแสดงตอนลูกค้าเลือกชำระผ่านธนาคาร
/// แก้ไขข้อมูลตรงนี้ให้เป็นบัญชีจริงของร้านได้เลย
class BankInfo {
  static const bankName = 'ธนาคารกสิกรไทย (KBank)';
  static const accountName = 'ShirtShop โดย เจ้าของร้าน';
  static const accountNumber = '123-4-56789-0';
  static const promptPayId = '081-234-5678'; // เบอร์พร้อมเพย์ตัวอย่าง

  /// ข้อความที่เข้ารหัสลง QR ให้ลูกค้าสแกน
  /// หมายเหตุ: เป็น QR ข้อความสำหรับสาธิตเท่านั้น ไม่ใช่ QR พร้อมเพย์มาตรฐาน EMV
  /// ที่แอปธนาคารจะอ่านแล้วตัดเงินอัตโนมัติ ก่อนใช้งานจริงควรเปลี่ยนไปใช้ QR
  /// พร้อมเพย์จริงจากธนาคารหรือผู้ให้บริการชำระเงิน
  static String qrPayload(double amount) =>
      'ShirtShop PromptPay $promptPayId ยอดชำระ ${amount.toStringAsFixed(0)} บาท';

  static String qrImageUrl(double amount) =>
      'https://api.qrserver.com/v1/create-qr-code/?size=260x260&data=${Uri.encodeComponent(qrPayload(amount))}';
}
