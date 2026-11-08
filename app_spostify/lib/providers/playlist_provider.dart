import 'package:flutter/foundation.dart';

import '../data/local/app_database.dart';
import '../data/repositories/playlist_repository.dart';
import '../models/playlist.dart';
import '../models/song.dart';

/// Quản lý danh sách playlist. Phân quyền ghi được kiểm soát bằng RLS ở database.
class PlaylistProvider extends ChangeNotifier {
  PlaylistProvider({PlaylistRepository? repository, AppDatabase? cache})
      : _repository = repository ?? PlaylistRepository(),
        _db = cache;

  final PlaylistRepository _repository;
  final AppDatabase? _db;
  List<Playlist> _playlists = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Playlist> get playlists => List.unmodifiable(_playlists);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPlaylists({bool includeHidden = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _playlists = await _repository.fetchPlaylists(includeHidden: includeHidden);
      if (!includeHidden) await _db?.cachePlaylists(_playlists);
    } catch (error) {
      _errorMessage = error.toString();
      if (_playlists.isEmpty && !includeHidden) {
        _playlists = _db?.cachedPlaylists() ?? const [];
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPlaylist({
    required String name,
    String? description,
    String? coverUrl,
    bool isVisible = true,
  }) =>
      _run(() async {
        final created = await _repository.createPlaylist(
          name: name,
          description: description,
          coverUrl: coverUrl,
          isVisible: isVisible,
        );
        _playlists = [created, ..._playlists];
      });

  Future<bool> updatePlaylist(Playlist playlist) => _run(() async {
        final updated = await _repository.updatePlaylist(playlist);
        _replace(updated);
      });

  Future<bool> setVisibility(int id, bool visible) => _run(() async {
        final updated = await _repository.setVisibility(id, isVisible: visible);
        _replace(updated);
      });

  Future<bool> deletePlaylist(int id) => _run(() async {
        await _repository.deletePlaylist(id);
        _playlists = _playlists.where((p) => p.id != id).toList();
      });

  Future<List<Song>> songsOf(int playlistId) => _repository.fetchSongsOf(playlistId);

  Future<bool> setSongsOf(Playlist playlist, List<int> songIds) => _run(() async {
        await _repository.setSongsOf(playlist.id, songIds);
        _replace(playlist.copyWith(songCount: songIds.length));
      });

  void _replace(Playlist updated) {
    _playlists = _playlists.map((p) => p.id == updated.id ? updated : p).toList();
  }

  Future<bool> _run(Future<void> Function() action) async {
    try {
      await action();
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = error is ArgumentError ? '${error.message}' : error.toString();
      notifyListeners();
      return false;
    }
  }
}
