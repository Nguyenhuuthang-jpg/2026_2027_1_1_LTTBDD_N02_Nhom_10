import 'package:flutter/foundation.dart';

import '../data/local/app_database.dart';
import '../data/repositories/song_repository.dart';
import '../models/genre.dart';
import '../models/song.dart';

class SongProvider extends ChangeNotifier {
  SongProvider({SongRepository? repository, AppDatabase? cache})
      : _repository = repository ?? SongRepository(),
        _db = cache;

  final SongRepository _repository;
  final AppDatabase? _db;
  List<Song> _songs = [];
  List<Genre> _genres = [];
  bool _isLoading = false;
  bool _fromCache = false;
  String? _errorMessage;
  String _search = '';
  int? _genreId;

  List<Song> get songs => List.unmodifiable(_songs);
  List<Song> get visibleSongs => _songs.where((s) => s.isVisible).toList();
  List<Genre> get genres => List.unmodifiable(_genres);
  bool get isLoading => _isLoading;
  bool get isFromCache => _fromCache;
  String? get errorMessage => _errorMessage;
  String get search => _search;
  int? get genreId => _genreId;

  /// Bài nghe nhiều nhất (đã sắp theo play_count).
  List<Song> get topSongs {
    final list = visibleSongs..sort((a, b) => b.playCount.compareTo(a.playCount));
    return list.take(5).toList();
  }

  Future<void> loadSongs({String? search, int? genreId}) async {
    _search = search ?? '';
    _genreId = genreId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _songs = await _repository.fetchSongs(search: search, genreId: genreId);
      _fromCache = false;
      final isUnfiltered = (search ?? '').trim().isEmpty && genreId == null;
      if (isUnfiltered) await _db?.cacheSongs(_songs);
    } catch (error) {
      _errorMessage = error.toString();
      final cached = _db?.cachedSongs() ?? const [];
      if (cached.isNotEmpty && _songs.isEmpty) {
        _songs = cached;
        _fromCache = true;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadGenres() async {
    try {
      _genres = await _repository.fetchGenres();
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<bool> addSong(Song song) => _runMutation(() async {
        final created = await _repository.createSong(song);
        _songs = [created, ..._songs];
      });

  Future<bool> editSong(Song song) => _runMutation(() async {
        final updated = await _repository.updateSong(song);
        _songs = _songs.map((item) => item.id == updated.id ? updated : item).toList();
      });

  Future<bool> removeSong(int id) => _runMutation(() async {
        await _repository.deleteSong(id);
        _songs = _songs.where((song) => song.id != id).toList();
      });

  Future<bool> setVisibility(int id, bool visible) => _runMutation(() async {
        final updated = await _repository.setVisibility(id, isVisible: visible);
        _songs = _songs.map((item) => item.id == id ? updated : item).toList();
      });

  Future<bool> _runMutation(Future<void> Function() action) async {
    _errorMessage = null;
    try {
      await action();
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = error is ArgumentError ? '${error.message}' : error.toString();
      notifyListeners();
      return false;
    }
  }
}
