import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/app_user.dart';
import 'supabase_client.dart';

/// Làm việc trực tiếp với Supabase Auth và bảng profiles.
class AuthRemote {
  AuthRemote({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;
  SupabaseClient get client => _client ?? AppSupabase.client;

  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  User? get currentAuthUser => client.auth.currentUser;

  Future<AppUser?> getCurrentProfile() async {
    final authUser = client.auth.currentUser;
    if (authUser == null) return null;
    final profile = await _loadProfile(authUser.id);
    if (!profile.isActive) {
      await client.auth.signOut();
      return null;
    }
    return profile;
  }

  Future<AppUser> signIn({required String email, required String password}) async {
    final response = await client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    final user = response.user;
    if (user == null) throw AuthException('Không thể xác định tài khoản.');

    final profile = await _loadProfile(user.id);
    if (!profile.isActive) {
      await client.auth.signOut();
      throw AuthException('Tài khoản đã bị khóa. Vui lòng liên hệ quản trị viên.');
    }
    return profile;
  }

  /// Trả về true nếu Supabase tạo session ngay; false nếu cần xác nhận email.
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'display_name': displayName.trim()},
    );
    return response.session != null;
  }

  Future<void> signOut() => client.auth.signOut();

  Future<AppUser> _loadProfile(String userId) async {
    final data = await client
        .from('profiles')
        .select('id, display_name, email, role, is_active, avatar_url, created_at')
        .eq('id', userId)
        .single();
    return AppUser.fromJson(Map<String, dynamic>.from(data));
  }
}
