import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  static const _usersKey = 'app_users_v1';
  static const _sessionKey = 'app_session_user_id_v1';

  final List<AppUser> _users = [];
  AppUser? _currentUser;
  bool _loaded = false;

  bool get isLoaded => _loaded;
  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isOwner => _currentUser?.role == UserRole.owner;
  bool get isEmployee => _currentUser?.role == UserRole.employee;
  bool get isStaff => isOwner || isEmployee;
  List<AppUser> get users => List.unmodifiable(_users);
  List<AppUser> get employees =>
      _users.where((u) => u.role == UserRole.employee).toList();
  List<AppUser> get customers =>
      _users.where((u) => u.role == UserRole.customer).toList();

  List<AppUser> _defaultUsers() => const [
    AppUser(
      id: 'owner1',
      username: 'owner',
      password: 'owner123',
      displayName: 'เจ้าของร้าน',
      role: UserRole.owner,
    ),
    AppUser(
      id: 'staff1',
      username: 'staff',
      password: 'staff123',
      displayName: 'พนักงานร้าน',
      role: UserRole.employee,
    ),
    AppUser(
      id: 'cust1',
      username: 'customer',
      password: 'customer123',
      displayName: 'ลูกค้าทดลอง',
      role: UserRole.customer,
    ),
  ];

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        _users
          ..clear()
          ..addAll(
            list.map((e) => AppUser.fromJson(e as Map<String, dynamic>)),
          );
      } catch (_) {
        _users.clear();
      }
    }
    if (_users.isEmpty) {
      _users.addAll(_defaultUsers());
      await _persist(prefs);
    }
    final sessionId = prefs.getString(_sessionKey);
    if (sessionId != null) {
      final match = _users.where((u) => u.id == sessionId);
      if (match.isNotEmpty) _currentUser = match.first;
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist(SharedPreferences prefs) async {
    await prefs.setString(
      _usersKey,
      jsonEncode(_users.map((u) => u.toJson()).toList()),
    );
  }

  Future<String?> login(String username, String password) async {
    final uname = username.trim().toLowerCase();
    final match = _users.where(
      (u) => u.username.toLowerCase() == uname && u.password == password,
    );
    if (match.isEmpty) return 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง';
    _currentUser = match.first;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, _currentUser!.id);
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    notifyListeners();
  }

  bool _usernameTaken(String username) => _users.any(
    (u) => u.username.toLowerCase() == username.trim().toLowerCase(),
  );

  /// สมัครสมาชิกสำหรับลูกค้าทั่วไป
  Future<String?> registerCustomer({
    required String username,
    required String password,
    required String displayName,
  }) async {
    if (username.trim().isEmpty ||
        password.isEmpty ||
        displayName.trim().isEmpty) {
      return 'กรุณากรอกข้อมูลให้ครบทุกช่อง';
    }
    if (password.length < 4) return 'รหัสผ่านต้องมีอย่างน้อย 4 ตัวอักษร';
    if (_usernameTaken(username)) return 'มีชื่อผู้ใช้นี้ในระบบแล้ว';

    final user = AppUser(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      username: username.trim(),
      password: password,
      displayName: displayName.trim(),
      role: UserRole.customer,
    );
    _users.add(user);
    final prefs = await SharedPreferences.getInstance();
    await _persist(prefs);
    _currentUser = user;
    await prefs.setString(_sessionKey, user.id);
    notifyListeners();
    return null;
  }

  /// เจ้าของร้านเพิ่มบัญชีพนักงานใหม่
  Future<String?> addEmployee({
    required String username,
    required String password,
    required String displayName,
  }) async {
    if (!isOwner) return 'เฉพาะเจ้าของร้านเท่านั้นที่เพิ่มพนักงานได้';
    if (username.trim().isEmpty ||
        password.isEmpty ||
        displayName.trim().isEmpty) {
      return 'กรุณากรอกข้อมูลให้ครบทุกช่อง';
    }
    if (_usernameTaken(username)) return 'มีชื่อผู้ใช้นี้ในระบบแล้ว';

    _users.add(
      AppUser(
        id: 'u_${DateTime.now().millisecondsSinceEpoch}',
        username: username.trim(),
        password: password,
        displayName: displayName.trim(),
        role: UserRole.employee,
      ),
    );
    final prefs = await SharedPreferences.getInstance();
    await _persist(prefs);
    notifyListeners();
    return null;
  }

  /// ผู้ใช้ที่ล็อกอินอยู่แก้ไขข้อมูลส่วนตัวของตัวเอง (ชื่อ/เบอร์โทร/ที่อยู่)
  Future<String?> updateProfile({
    String? displayName,
    String? phone,
    String? address,
  }) async {
    final user = _currentUser;
    if (user == null) return 'กรุณาเข้าสู่ระบบก่อน';
    if (displayName != null && displayName.trim().isEmpty) {
      return 'กรุณากรอกชื่อ-นามสกุล';
    }
    final updated = user.copyWith(
      displayName: displayName?.trim(),
      phone: phone?.trim(),
      address: address?.trim(),
    );
    final idx = _users.indexWhere((u) => u.id == user.id);
    if (idx != -1) _users[idx] = updated;
    _currentUser = updated;
    final prefs = await SharedPreferences.getInstance();
    await _persist(prefs);
    notifyListeners();
    return null;
  }

  /// เจ้าของร้าน/พนักงาน เพิ่มบัญชีลูกค้าให้เองจากหลังบ้าน
  Future<String?> addCustomer({
    required String username,
    required String password,
    required String displayName,
    String phone = '',
    String address = '',
  }) async {
    if (!isStaff) return 'เฉพาะเจ้าของร้านหรือพนักงานเท่านั้นที่เพิ่มลูกค้าได้';
    if (username.trim().isEmpty ||
        password.isEmpty ||
        displayName.trim().isEmpty) {
      return 'กรุณากรอกข้อมูลให้ครบทุกช่อง';
    }
    if (_usernameTaken(username)) return 'มีชื่อผู้ใช้นี้ในระบบแล้ว';

    _users.add(
      AppUser(
        id: 'u_${DateTime.now().millisecondsSinceEpoch}',
        username: username.trim(),
        password: password,
        displayName: displayName.trim(),
        role: UserRole.customer,
        phone: phone.trim(),
        address: address.trim(),
      ),
    );
    final prefs = await SharedPreferences.getInstance();
    await _persist(prefs);
    notifyListeners();
    return null;
  }

  Future<void> removeCustomer(String id) async {
    if (!isStaff) return;
    _users.removeWhere((u) => u.id == id && u.role == UserRole.customer);
    final prefs = await SharedPreferences.getInstance();
    await _persist(prefs);
    notifyListeners();
  }

  Future<void> removeEmployee(String id) async {
    if (!isOwner) return;
    _users.removeWhere((u) => u.id == id && u.role == UserRole.employee);
    final prefs = await SharedPreferences.getInstance();
    await _persist(prefs);
    notifyListeners();
  }
}
