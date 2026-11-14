import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/playlist.dart';
import '../../models/song.dart';

class LocalCacheStore {
  LocalCacheStore._(this._prefs);

  static const _kSongs = 'cache_songs';
  static const _kPlaylists = 'cache_playlists';

  final SharedPreferences _prefs;

  static Future<LocalCacheStore> create() async =>
      LocalCacheStore._(await SharedPreferences.getInstance());

  Future<void> cacheSongs(List<Song> songs) => _prefs.setString(
        _kSongs,
        jsonEncode(songs.map(_songToCache).toList()),
      );

  List<Song> cachedSongs() {
    final raw = _prefs.getString(_kSongs);
    if (raw == null) return const [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => Song.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> cachePlaylists(List<Playlist> playlists) => _prefs.setString(
        _kPlaylists,
        jsonEncode(playlists
            .map((p) => {
                  'id': p.id,
                  ...p.toJson(),
                  'playlist_songs': [
                    {'count': p.songCount}
                  ],
                })
            .toList()),
      );

  List<Playlist> cachedPlaylists() {
    final raw = _prefs.getString(_kPlaylists);
    if (raw == null) return const [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => Playlist.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> clear() async {
    await _prefs.remove(_kSongs);
    await _prefs.remove(_kPlaylists);
  }

  static Map<String, dynamic> _songToCache(Song s) => {
        'id': s.id,
        ...s.toJson(),
        'genres': s.genreName == null ? null : {'name': s.genreName},
        'play_count': s.playCount,
        'created_at': s.createdAt?.toIso8601String(),
      };
}
