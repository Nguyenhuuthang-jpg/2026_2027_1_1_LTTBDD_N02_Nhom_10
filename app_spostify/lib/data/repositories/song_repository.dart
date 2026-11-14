import '../../core/utils/validators.dart';
import '../../models/genre.dart';
import '../../models/song.dart';
import '../local/local_cache_store.dart';
import '../remote/supabase_client.dart';

class SongRepository {
  SongRepository({LocalCacheStore? cache}) : _cache = cache;

  final LocalCacheStore? _cache;

  static const String _selectWithGenre = '*, genres(name)';

  Future<List<Genre>> fetchGenres() async {
    final rows = await AppSupabase.client.from('genres').select('id, name').order('name');
    return rows.map((r) => Genre.fromJson(Map<String, dynamic>.from(r))).toList();
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

  Future<({List<Song> items, bool isFromCache})> loadSongsWithFallback({
    String? search,
    int? genreId,
    bool newestFirst = true,
  }) async {
    final isUnfiltered = (search ?? '').trim().isEmpty && genreId == null;
    try {
      final songs = await fetchSongs(
        search: search,
        genreId: genreId,
        newestFirst: newestFirst,
      );
      if (isUnfiltered) await _cache?.cacheSongs(songs);
      return (items: songs, isFromCache: false);
    } catch (_) {
      final cached = isUnfiltered ? (_cache?.cachedSongs() ?? const <Song>[]) : const <Song>[];
      if (cached.isNotEmpty) {
        return (items: cached, isFromCache: true);
      }
      rethrow;
    }
  }

  Future<Song> createSong(Song song) async {
    final validation = Validators.validateSongInput(
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
    final validation = Validators.validateSongInput(
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
