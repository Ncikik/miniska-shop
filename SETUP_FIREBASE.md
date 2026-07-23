# วิธีเชื่อมแอปนี้เข้ากับฐานข้อมูลออนไลน์ (Firebase Firestore)

โปรเจกต์นี้ถูกแก้ให้เก็บข้อมูลหลักไว้บน **Cloud Firestore** ของ Firebase แล้ว
(สินค้า / ผู้ใช้ / คำสั่งซื้อ / โค้ดส่วนลด) แทนการเก็บแค่ในเครื่อง (SharedPreferences)
ทำให้เปิดแอปจากเครื่องไหนก็เห็นข้อมูลชุดเดียวกัน

ที่เหลือต้องทำ 4 ขั้นตอนนี้ **บนเครื่องของคุณเอง** (ในนี้ไม่มีอินเทอร์เน็ตให้ผมรันคำสั่งเหล่านี้แทนได้)

## ขั้นตอนที่ 1: สร้างโปรเจกต์ Firebase

1. ไปที่ https://console.firebase.google.com
2. กด "Add project" ตั้งชื่อโปรเจกต์ (เช่น `shirt-shop`) แล้วสร้างให้เสร็จ
3. ในเมนูซ้าย เลือก **Build > Firestore Database** กด "Create database"
   - เลือก Location ที่ใกล้ลูกค้า (เช่น `asia-southeast1`)
   - เริ่มด้วยโหมด **Test mode** ไปก่อนก็ได้ (แก้กติกาความปลอดภัยทีหลังได้)

## ขั้นตอนที่ 2: ติดตั้งเครื่องมือ FlutterFire

เปิด terminal ที่เครื่องคุณ (ต้องมี Flutter SDK และ Node.js ติดตั้งแล้ว):

```bash
npm install -g firebase-tools
firebase login

dart pub global activate flutterfire_cli
```

## ขั้นตอนที่ 3: เชื่อมโปรเจกต์ Flutter กับ Firebase

ที่โฟลเดอร์โปรเจกต์นี้ (`shirt_shop/`) รันคำสั่ง:

```bash
flutterfire configure
```

- เลือกโปรเจกต์ Firebase ที่สร้างไว้ในขั้นตอนที่ 1
- เลือกแพลตฟอร์มที่จะใช้งานจริง (เช่น android, ios, web)
- คำสั่งนี้จะ **เขียนทับไฟล์ `lib/firebase_options.dart`** ที่ผมทำเป็น template ไว้ให้ ด้วยค่าจริงของโปรเจกต์คุณโดยอัตโนมัติ
  (และจะแก้ไฟล์ฝั่ง native เช่น `android/app/google-services.json` ให้เองด้วย)

จากนั้นติดตั้ง dependency ที่เพิ่มเข้ามาใหม่:

```bash
flutter pub get
```

## ขั้นตอนที่ 4: ตั้งกติกาความปลอดภัย (Firestore Rules)

ผมเตรียมไฟล์ `firestore.rules` ไว้ให้แล้ว (เปิดอ่าน/เขียนได้หมด เหมาะกับตอนพัฒนา/ทดสอบเท่านั้น)
นำไปวางใน Firebase Console:

1. Firestore Database > แท็บ **Rules**
2. คัดลอกเนื้อหาจากไฟล์ `firestore.rules` ไปวางแทนของเดิม แล้วกด Publish

> ⚠️ ก่อนเปิดให้ลูกค้าจริงใช้งาน ควรจำกัดสิทธิ์เขียนให้เฉพาะแอดมิน/ผู้ใช้ที่ยืนยันตัวตนแล้วเท่านั้น
> ตอนนี้แอปยังตรวจ username/password เองในแอป (ไม่ได้ผูกกับ Firebase Authentication)
> ถ้าต้องการความปลอดภัยระดับโปรดักชัน แนะนำให้ปรับไปใช้ Firebase Authentication ควบคู่ไปด้วย

## รันแอป

```bash
flutter run
```

รอบแรกที่เปิดแอป ระบบจะสร้างข้อมูลตั้งต้นให้อัตโนมัติใน Firestore:
- สินค้าตัวอย่างจาก `lib/data/mock_products.dart` → collection `products`
- บัญชีทดลอง 3 บัญชี (owner/staff/customer) → collection `users`
- โค้ดส่วนลดตัวอย่าง (WELCOME10, SAVE50, FREESHIP) → collection `discount_codes`

คำสั่งซื้อที่เกิดขึ้นจริงจะถูกบันทึกไว้ใน collection `orders`

## สิ่งที่ยังเก็บไว้ในเครื่อง (ไม่ได้ย้ายขึ้นออนไลน์)

- **ตะกร้าสินค้า (CartProvider)**: ยังเก็บในเครื่อง เพราะเป็นข้อมูลระหว่างกำลังเลือกซื้อของแต่ละคน ไม่จำเป็นต้องซิงก์ข้ามเครื่อง
- **รูปสินค้าที่ override (ImageOverrideProvider)**: ยังเป็นโค้ดเดิม (ยังไม่มีหน้าจอไหนเรียกใช้งานจริงในโปรเจกต์นี้)

ถ้าต้องการให้ทั้งสองส่วนนี้ย้ายขึ้น Firestore/Firebase Storage ด้วย บอกได้เลยครับ ทำเพิ่มให้ได้
