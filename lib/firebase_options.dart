// ไฟล์นี้เป็น "template" — ปกติไฟล์นี้จะถูกสร้างอัตโนมัติด้วยคำสั่ง
//   flutterfire configure
// (แนะนำให้รันคำสั่งนี้แทนการแก้เอง ดูขั้นตอนเต็มใน SETUP_FIREBASE.md)
//
// ถ้าไม่สะดวกใช้ flutterfire CLI ให้คัดลอกค่าจาก Firebase Console:
// Project settings -> General -> Your apps -> SDK setup and configuration
// แล้วนำมาแทนที่ค่า YOUR_XXX ด้านล่างให้ครบทุกแพลตฟอร์มที่ใช้งานจริง
//
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] สำหรับใช้กับ Firebase.initializeApp()
///
/// ตัวอย่าง:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAdkBh2DFAq4zxCMKgYMD0zstsOYz7KLIk',
    appId: '1:158065951427:web:a5fe01ec384e438a11d876',
    messagingSenderId: '158065951427',
    projectId: 'shirt-shop-81150',
    authDomain: 'shirt-shop-81150.firebaseapp.com',
    storageBucket: 'shirt-shop-81150.firebasestorage.app',
    measurementId: 'G-XYG16QX653',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD-UVo1ZaS3s8iMYkLNaWzL7tauOBJL5O8',
    appId: '1:158065951427:android:ea877d2f5029b06d11d876',
    messagingSenderId: '158065951427',
    projectId: 'shirt-shop-81150',
    storageBucket: 'shirt-shop-81150.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDt98iLC1Z5DRG66r9tXBkXeMnDwxBrb1I',
    appId: '1:158065951427:ios:cab6287a342f837f11d876',
    messagingSenderId: '158065951427',
    projectId: 'shirt-shop-81150',
    storageBucket: 'shirt-shop-81150.firebasestorage.app',
    iosBundleId: 'com.example.shirtShop',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDt98iLC1Z5DRG66r9tXBkXeMnDwxBrb1I',
    appId: '1:158065951427:ios:cab6287a342f837f11d876',
    messagingSenderId: '158065951427',
    projectId: 'shirt-shop-81150',
    storageBucket: 'shirt-shop-81150.firebasestorage.app',
    iosBundleId: 'com.example.shirtShop',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAdkBh2DFAq4zxCMKgYMD0zstsOYz7KLIk',
    appId: '1:158065951427:web:847ba88f4ff14e0e11d876',
    messagingSenderId: '158065951427',
    projectId: 'shirt-shop-81150',
    authDomain: 'shirt-shop-81150.firebaseapp.com',
    storageBucket: 'shirt-shop-81150.firebasestorage.app',
    measurementId: 'G-1KML30MJZS',
  );
}
