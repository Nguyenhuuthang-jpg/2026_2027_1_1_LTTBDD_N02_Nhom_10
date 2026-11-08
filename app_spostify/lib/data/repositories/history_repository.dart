import '../../models/song.dart';
import '../remote/supabase_client.dart';

/// Một lượt nghe trong lịch sử.
class HistoryEntry {
  final int id;
  final Song song;
  final DateTime playedAt;

  const HistoryEntry({required this.id, required this.song, required this.playedAt});
}

/// Lịch sử nghe (listening_history) và bài yêu thích (favorites).
class HistoryRepository {
  String? get _uid => AppSupabase.client.auth.currentUser?.id;

  /// Ghi nhận một lượt nghe: thêm lịch sử + tăng play_count (hàm record_play).
  Future<void> recordPlay(int songId) async {
    await AppSupabase.client.rpc('record_play', params: {'p_song_id': songId});
  }

  Future<List<HistoryEntry>> fetchHistory({int limit = 50}) async {
    final uid = _uid;
    if (uid == null) return const [];
    final rows = await AppSupabase.client
        .from('listening_history')
        .select('id, played_at, songs(*, genres(name))')
        .eq('user_id', uid)
        .order('played_at', ascending: false)
        .limit(limit);
    return rows
        .where((r) => r['songs'] != null)
        .map((r) => HistoryEntry(
              id: (r['id'] as num).toInt(),
              song: Song.fromJson(Map<String, dynamic>.from(r['songs'] as Map)),
              playedAt: DateTime.parse(r['played_at'] as String).toLocal(),
            ))
        .toList();
  }

  Future<void> clearHistory() async {
    final uid = _uid;
    if (uid == null) return;
    await AppSupabase.client.from('listening_history').delete().eq('user_id', uid);
  }

  Future<List<Song>> fetchFavorites() async {
    final uid = _uid;
    if (uid == null) return const [];
    final rows = await AppSupabase.client
        .from('favorites')
        .select('created_at, songs(*, genres(name))')
        .eq('user_id', uid)
        .order('created_at', ascending: false);
    return rows
        .where((r) => r['songs'] != null)
        .map((r) => Song.fromJson(Map<String, dynamic>.from(r['songs'] as Map)))
        .toList();
  }

  Future<void> addFavorite(int songId) async {
    final uid = _uid;
    if (uid == null) throw StateError('Chưa đăng nhập.');
    await AppSupabase.client
        .from('favorites')
        .upsert({'user_id': uid, 'song_id': songId});
  }

  Future<void> removeFavorite(int songId) async {
    final uid = _uid;
    if (uid == null) return;
    await AppSupabase.client
        .from('favorites')
        .delete()
        .eq('user_id', uid)
        .eq('song_id', songId);
  }
}
