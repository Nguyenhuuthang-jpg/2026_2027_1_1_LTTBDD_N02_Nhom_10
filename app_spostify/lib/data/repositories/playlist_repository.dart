import '../../models/playlist.dart';
import '../../models/song.dart';
import '../remote/supabase_client.dart';

/// Truy vấn bảng playlists và playlist_songs. Quyền ghi do RLS (chỉ admin).
class PlaylistRepository {
  static const String _selectWithCount = '*, playlist_songs(count)';

  static String? validateName(String name) {
    final n = name.trim();
    if (n.isEmpty || n.length > 60) return 'Tên playlist phải có từ 1 đến 60 ký tự.';
    return null;
  }

  Future<List<Playlist>> fetchPlaylists({bool includeHidden = false}) async {
    var query = AppSupabase.client.from('playlists').select(_selectWithCount);
    if (!includeHidden) query = query.eq('is_visible', true);
    final rows = await query.order('created_at', ascending: false);
    return rows.map((r) => Playlist.fromJson(Map<String, dynamic>.from(r))).toList();
  }

  Future<Playlist> createPlaylist({
    required String name,
    String? description,
    String? coverUrl,
    bool isVisible = true,
  }) async {
    final error = validateName(name);
    if (error != null) throw ArgumentError(error);
    final row = await AppSupabase.client
        .from('playlists')
        .insert({
          'name': name.trim(),
          'description': _nullIfEmpty(description),
          'cover_url': _nullIfEmpty(coverUrl),
          'is_visible': isVisible,
        })
        .select(_selectWithCount)
        .single();
    return Playlist.fromJson(Map<String, dynamic>.from(row));
  }

  Future<Playlist> updatePlaylist(Playlist playlist) async {
    final error = validateName(playlist.name);
    if (error != null) throw ArgumentError(error);
    final row = await AppSupabase.client
        .from('playlists')
        .update(playlist.toJson())
        .eq('id', playlist.id)
        .select(_selectWithCount)
        .single();
    return Playlist.fromJson(Map<String, dynamic>.from(row));
  }

  Future<Playlist> setVisibility(int id, {required bool isVisible}) async {
    final row = await AppSupabase.client
        .from('playlists')
        .update({'is_visible': isVisible})
        .eq('id', id)
        .select(_selectWithCount)
        .single();
    return Playlist.fromJson(Map<String, dynamic>.from(row));
  }

  Future<void> deletePlaylist(int id) async {
    await AppSupabase.client.from('playlists').delete().eq('id', id);
  }

  /// Danh sách bài hát của một playlist, theo thứ tự `position`.
  Future<List<Song>> fetchSongsOf(int playlistId) async {
    final rows = await AppSupabase.client
        .from('playlist_songs')
        .select('position, songs(*, genres(name))')
        .eq('playlist_id', playlistId)
        .order('position');
    return rows
        .where((r) => r['songs'] != null)
        .map((r) => Song.fromJson(Map<String, dynamic>.from(r['songs'] as Map)))
        .toList();
  }

  /// Thay toàn bộ danh sách bài của playlist (dùng cho màn quản trị).
  Future<void> setSongsOf(int playlistId, List<int> songIds) async {
    await AppSupabase.client
        .from('playlist_songs')
        .delete()
        .eq('playlist_id', playlistId);
    if (songIds.isEmpty) return;
    await AppSupabase.client.from('playlist_songs').insert([
      for (var i = 0; i < songIds.length; i++)
        {'playlist_id': playlistId, 'song_id': songIds[i], 'position': i},
    ]);
  }

  static String? _nullIfEmpty(String? v) =>
      (v == null || v.trim().isEmpty) ? null : v.trim();
}
