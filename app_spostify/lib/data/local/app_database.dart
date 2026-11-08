import 'dart:convert';

import '../../models/playlist.dart';
import '../../models/song.dart';
import 'prefs_store.dart';

/// Cache cục bộ cho bài hát và playlist, dùng khi mất mạng.
///
/// Ghi chú: bản thiết kế dự định dùng drift (SQLite). drift cần sinh code bằng
/// build_runner và cấu hình riêng cho web (sqlite3.wasm), nên tạm thời cache được
/// lưu dạng JSON qua shared_preferences để chạy được trên mọi nền tảng
/// (Android, iOS, Windows, Web). Giao diện lớp giữ nguyên, sau này có thể thay
/// phần cài đặt bên trong bằng drift mà không phải sửa repository.
class AppDatabase {
  AppDatabase(this._store);

  static const _kSongs = 'cache_songs';
  static const _kPlaylists = 'cache_playlists';

  final PrefsStore _store;

  Future<void> cacheSongs(List<Song> songs) => _store.setString(
        _kSongs,
        jsonEncode(songs.map(_songToCache).toList()),
      );

  List<Song> cachedSongs() {
    final raw = _store.getString(_kSongs);
    if (raw == null) return const [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => Song.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> cachePlaylists(List<Playlist> playlists) => _store.setString(
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
    final raw = _store.getString(_kPlaylists);
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
    await _store.remove(_kSongs);
    await _store.remove(_kPlaylists);
  }

  static Map<String, dynamic> _songToCache(Song s) => {
        'id': s.id,
        ...s.toJson(),
        'genres': s.genreName == null ? null : {'name': s.genreName},
        'play_count': s.playCount,
        'created_at': s.createdAt?.toIso8601String(),
      };
}
