import '../../models/song.dart';
import '../remote/supabase_client.dart';

/// Truy vấn và cập nhật bảng songs. Quyền admin/user được RLS của Supabase bảo vệ.
class SongRepository {
  SongRepository();

  static const String _selectWithGenre = '*, genres(name)';

  /// Trả về thông báo lỗi dữ liệu; null nghĩa là dữ liệu hợp lệ.
  static String? validateSongInput({
    required String title,
    required String artist,
    required int durationSeconds,
  }) {
    if (title.trim().isEmpty) return 'Tên bài hát không được để trống.';
    if (title.trim().length > 60) return 'Tên bài hát tối đa 60 ký tự.';
    if (artist.trim().isEmpty) return 'Tên nghệ sĩ không được để trống.';
    if (artist.trim().length > 40) return 'Tên nghệ sĩ tối đa 40 ký tự.';
    if (durationSeconds <= 0) return 'Thời lượng phải lớn hơn 0.';
    return null;
  }

  Future<List<Song>> fetchSongs({
    String? search,
    int? genreId,
    bool newestFirst = true,
  }) async {
    var query = AppSupabase.client.from('songs').select(_selectWithGenre);
    final normalizedSearch = search?.trim();
    if (normalizedSearch != null && normalizedSearch.isNotEmpty) {
      query = query.or('title.ilike.%$normalizedSearch%,artist.ilike.%$normalizedSearch%');
    }
    if (genreId != null) query = query.eq('genre_id', genreId);
    final rows = await query.order('created_at', ascending: !newestFirst);
    return rows.map((row) => Song.fromJson(Map<String, dynamic>.from(row))).toList();
  }

  Future<Song> createSong(Song song) async {
    final validation = validateSongInput(
      title: song.title,
      artist: song.artist,
      durationSeconds: song.durationSeconds,
    );
    if (validation != null) throw ArgumentError(validation);
    final row = await AppSupabase.client
        .from('songs')
        .insert(song.toJson())
        .select(_selectWithGenre)
        .single();
    return Song.fromJson(Map<String, dynamic>.from(row));
  }

  Future<Song> updateSong(Song song) async {
    final validation = validateSongInput(
      title: song.title,
      artist: song.artist,
      durationSeconds: song.durationSeconds,
    );
    if (validation != null) throw ArgumentError(validation);
    final row = await AppSupabase.client
        .from('songs')
        .update(song.toJson())
        .eq('id', song.id)
        .select(_selectWithGenre)
        .single();
    return Song.fromJson(Map<String, dynamic>.from(row));
  }

  Future<void> deleteSong(int id) async {
    await AppSupabase.client.from('songs').delete().eq('id', id);
  }

  Future<Song> setVisibility(int id, {required bool isVisible}) async {
    final row = await AppSupabase.client
        .from('songs')
        .update({'is_visible': isVisible})
        .eq('id', id)
        .select(_selectWithGenre)
        .single();
    return Song.fromJson(Map<String, dynamic>.from(row));
  }
}
