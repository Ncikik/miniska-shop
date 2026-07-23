/// บทบาทผู้ใช้งานในระบบ: เจ้าของร้าน, พนักงาน, ลูกค้า
enum UserRole { owner, employee, customer }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.owner:
        return 'เจ้าของร้าน';
      case UserRole.employee:
        return 'พนักงาน';
      case UserRole.customer:
        return 'ลูกค้า';
    }
  }

  /// เจ้าของร้าน/พนักงาน จัดการหลังบ้านได้
  bool get isStaff => this == UserRole.owner || this == UserRole.employee;
}

class AppUser {
  final String id;
  final String username;
  final String password;
  final String displayName;
  final UserRole role;
  final String phone;
  final String address;

  const AppUser({
    required this.id,
    required this.username,
    required this.password,
    required this.displayName,
    required this.role,
    this.phone = '',
    this.address = '',
  });

  AppUser copyWith({
    String? displayName,
    String? password,
    String? phone,
    String? address,
  }) {
    return AppUser(
      id: id,
      username: username,
      password: password ?? this.password,
      displayName: displayName ?? this.displayName,
      role: role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'password': password,
    'displayName': displayName,
    'role': role.name,
    'phone': phone,
    'address': address,
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String,
    username: json['username'] as String,
    password: json['password'] as String,
    displayName: json['displayName'] as String,
    role: UserRole.values.firstWhere(
      (r) => r.name == json['role'],
      orElse: () => UserRole.customer,
    ),
    phone: json['phone'] as String? ?? '',
    address: json['address'] as String? ?? '',
  );
}
