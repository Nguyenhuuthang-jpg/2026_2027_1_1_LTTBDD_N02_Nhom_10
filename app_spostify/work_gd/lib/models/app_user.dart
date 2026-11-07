enum UserRole {
  user,
  admin;

  static UserRole fromString(String? value) =>
      value == 'admin' ? UserRole.admin : UserRole.user;
}

/// Một dòng của bảng `profiles`.
class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool isActive;
  final String? avatarUrl;
  final DateTime? createdAt;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.user,
    this.isActive = true,
    this.avatarUrl,
    this.createdAt,
  });

  bool get isAdmin => role == UserRole.admin;

  /// Chữ cái đầu dùng cho avatar mặc định.
  String get initial =>
      name.isEmpty ? '?' : String.fromCharCode(name.runes.first).toUpperCase();

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        name: json['display_name'] as String,
        email: json['email'] as String,
        role: UserRole.fromString(json['role'] as String?),
        isActive: json['is_active'] as bool? ?? true,
        avatarUrl: json['avatar_url'] as String?,
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at'] as String),
      );

  /// Chỉ gồm các cột được phép cập nhật từ app.
  Map<String, dynamic> toJson() => {
        'display_name': name,
        'avatar_url': avatarUrl,
      };

  AppUser copyWith({
    String? name,
    UserRole? role,
    bool? isActive,
    String? avatarUrl,
  }) =>
      AppUser(
        id: id,
        name: name ?? this.name,
        email: email,
        role: role ?? this.role,
        isActive: isActive ?? this.isActive,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        createdAt: createdAt,
      );
}
