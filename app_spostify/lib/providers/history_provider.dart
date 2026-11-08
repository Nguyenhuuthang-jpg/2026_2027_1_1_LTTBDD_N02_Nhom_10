import 'package:flutter/foundation.dart';

import '../data/repositories/history_repository.dart';
import '../models/song.dart';

/// Bài yêu thích và lịch sử nghe của người dùng hiện tại.
class HistoryProvider extends ChangeNotifier {
  HistoryProvider({HistoryRepository? repository})
      : _repository = repository ?? HistoryRepository();

  final HistoryRepository _repository;

  List<Song> _favorites = [];
  Set<int> _favoriteIds = {};
  List<HistoryEntry> _history = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Song> get favorites => List.unmodifiable(_favorites);
  List<HistoryEntry> get history => List.unmodifiable(_history);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool isFavorite(int songId) => _favoriteIds.contains(songId);

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.fetchFavorites(),
        _repository.fetchHistory(),
      ]);
      _favorites = results[0] as List<Song>;
      _favoriteIds = _favorites.map((s) => s.id).toSet();
      _history = results[1] as List<HistoryEntry>;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cập nhật giao diện ngay, nếu lỗi thì hoàn tác.
  Future<bool> toggleFavorite(Song song) async {
    final wasFavorite = isFavorite(song.id);
    if (wasFavorite) {
      _favoriteIds.remove(song.id);
      _favorites = _favorites.where((s) => s.id != song.id).toList();
    } else {
      _favoriteIds.add(song.id);
      _favorites = [song, ..._favorites];
    }
    notifyListeners();
    try {
      if (wasFavorite) {
        await _repository.removeFavorite(song.id);
      } else {
        await _repository.addFavorite(song.id);
      }
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      await load();
      return false;
    }
  }

  /// Gọi khi bắt đầu phát một bài (PlayerProvider.onSongStarted).
  Future<void> recordPlay(Song song) async {
    try {
      await _repository.recordPlay(song.id);
      _history = [
        HistoryEntry(id: -DateTime.now().millisecondsSinceEpoch, song: song, playedAt: DateTime.now()),
        ..._history,
      ];
      notifyListeners();
    } catch (error) {
      // Không chặn việc phát nhạc nếu ghi lịch sử thất bại.
      debugPrint('recordPlay failed: $error');
    }
  }

  Future<void> clearHistory() async {
    try {
      await _repository.clearHistory();
      _history = [];
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  /// Xóa dữ liệu khi đăng xuất.
  void reset() {
    _favorites = [];
    _favoriteIds = {};
    _history = [];
    _errorMessage = null;
    notifyListeners();
  }
}
