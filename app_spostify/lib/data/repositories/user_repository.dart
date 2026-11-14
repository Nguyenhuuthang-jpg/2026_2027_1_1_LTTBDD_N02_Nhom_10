import '../../models/app_user.dart';
import '../remote/supabase_client.dart';

class UserRepository {
  static const String _columns =
      'id, display_name, email, role, is_active, avatar_url, created_at';

  Future<List<AppUser>> fetchUsers({String? search}) async {
    var query = AppSupabase.client.from('profiles').select(_columns);
    final s = search?.trim();
    if (s != null && s.isNotEmpty) {
      query = query.or('display_name.ilike.%$s%,email.ilike.%$s%');
    }
    final rows = await query.order('created_at', ascending: false);
    return rows.map((r) => AppUser.fromJson(Map<String, dynamic>.from(r))).toList();
  }

  Future<AppUser> setActive(String userId, {required bool isActive}) async {
    final row = await AppSupabase.client
        .from('profiles')
        .update({'is_active': isActive})
        .eq('id', userId)
        .select(_columns)
        .single();
    return AppUser.fromJson(Map<String, dynamic>.from(row));
  }

  Future<AppUser> updateProfile(AppUser user) async {
    final row = await AppSupabase.client
        .from('profiles')
        .update(user.toJson())
        .eq('id', user.id)
        .select(_columns)
        .single();
    return AppUser.fromJson(Map<String, dynamic>.from(row));
  }
}
