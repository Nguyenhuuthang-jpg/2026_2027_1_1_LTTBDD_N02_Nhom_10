import '../../core/utils/validators.dart';
import '../../models/playlist.dart';
import '../../models/song.dart';
import '../local/local_cache_store.dart';
import '../remote/supabase_client.dart';

class PlaylistRepository {
  PlaylistRepository({LocalCacheStore? cache}) : _cache = cache;

  final LocalCacheStore? _cache;

  static const String _selectWithCount = '*, playlist_songs(count)';

  Future<List<Playlist>> fetchPlaylists({bool includeHidden = false}) async {
    var query = AppSupabase.client.from('playlists').select(_selectWithCount);
    if (!includeHidden) query = query.eq('is_visible', true);
    final rows = await query.order('created_at', ascending: false);
    return rows.map((r) => Playlist.fromJson(Map<String, dynamic>.from(r))).toList();
  }

  Future<({List<Playlist> items, bool isFromCache})> loadPlaylistsWithFallback({
    bool includeHidden = false,
  }) async {
    try {
      final playlists = await fetchPlaylists(includeHidden: includeHidden);
      if (!includeHidden) await _cache?.cachePlaylists(playlists);
      return (items: playlists, isFromCache: false);
    } catch (_) {
      final cached = !includeHidden
          ? (_cache?.cachedPlaylists() ?? const <Playlist>[])
          : const <Playlist>[];
      if (cached.isNotEmpty) {
        return (items: cached, isFromCache: true);
      }
      rethrow;
    }
  }

  Future<Playlist> createPlaylist({
    required String name,
    String? description,
    String? coverUrl,
    bool isVisible = true,
  }) async {
    final error = Validators.validatePlaylistName(name);
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
    final error = Validators.validatePlaylistName(playlist.name);
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
