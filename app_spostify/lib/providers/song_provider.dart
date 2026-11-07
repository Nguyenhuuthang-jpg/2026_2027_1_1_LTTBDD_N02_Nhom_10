import 'package:flutter/foundation.dart';

import '../data/repositories/song_repository.dart';
import '../models/song.dart';

class SongProvider extends ChangeNotifier {
  SongProvider({SongRepository? repository})
      : _repository = repository ?? SongRepository();

  final SongRepository _repository;
  List<Song> _songs = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Song> get songs => List.unmodifiable(_songs);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadSongs({String? search, int? genreId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _songs = await _repository.fetchSongs(search: search, genreId: genreId);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
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
      _errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }
}
