import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/song.dart';
import '../services/audio_service.dart';

class PlayerProvider extends ChangeNotifier {
  PlayerProvider({AudioService? audioService})
    : _audioService = audioService ?? AudioService() {
    _subscriptions.add(
      _audioService.playerStateStream.listen((state) {
        _isPlaying = state.playing;
        final justCompleted =
            state.processingState == ProcessingState.completed &&
            _processingState != ProcessingState.completed;
        _processingState = state.processingState;
        notifyListeners();
        if (justCompleted) playNext();
      }),
    );
    _subscriptions.add(
      _audioService.positionStream.listen((value) {
        _position = value;
        notifyListeners();
      }),
    );
    _subscriptions.add(
      _audioService.durationStream.listen((value) {
        _duration = value ?? Duration.zero;
        notifyListeners();
      }),
    );
  }

  final AudioService _audioService;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  List<Song> _queue = [];
  int _currentIndex = -1;
  Song? _currentSong;
  bool _isPlaying = false;
  bool _isLoading = false;
  String? _errorMessage;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  ProcessingState _processingState = ProcessingState.idle;

  Song? get currentSong => _currentSong;
  List<Song> get queue => List.unmodifiable(_queue);
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Duration get position => _position;
  Duration get duration => _duration;
  ProcessingState get processingState => _processingState;
  bool get hasNext => _currentIndex >= 0 && _currentIndex + 1 < _queue.length;
  bool get hasPrevious => _currentIndex > 0;

  /// Được gọi mỗi khi một bài bắt đầu phát (dùng để ghi lịch sử nghe).
  void Function(Song song)? onSongStarted;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> playSong(Song song, {List<Song>? queue}) async {
    if (song.audioUrl == null || song.audioUrl!.trim().isEmpty) {
      _errorMessage = 'Bài hát chưa có đường dẫn âm thanh.';
      notifyListeners();
      return;
    }
    if (queue != null) {
      _queue = List.of(queue);
      _currentIndex = _queue.indexWhere((item) => item.id == song.id);
    } else {
      _queue = [song];
      _currentIndex = 0;
    }
    _currentSong = song;
    _isLoading = true;
    _errorMessage = null;
    _position = Duration.zero;
    notifyListeners();
    try {
      await _audioService.load(song.audioUrl!);
      onSongStarted?.call(song);
      // play() chỉ hoàn thành khi dừng phát, nên không await để tránh treo trạng thái loading.
      unawaited(
        _audioService.play().catchError((Object _) {
          _errorMessage = 'Không thể phát bài hát.';
          notifyListeners();
        }),
      );
    } catch (_) {
      _errorMessage = 'Không thể phát bài hát.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Dừng hẳn và xóa hàng đợi (ví dụ khi đăng xuất).
  Future<void> stop() async {
    await _audioService.stop();
    _queue = [];
    _currentIndex = -1;
    _currentSong = null;
    _position = Duration.zero;
    _duration = Duration.zero;
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioService.pause();
      } else if (_currentSong != null) {
        if (_processingState == ProcessingState.completed) {
          await _audioService.seek(Duration.zero);
        }
        unawaited(_audioService.play());
      }
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> seek(Duration value) => _audioService.seek(value);

  Future<void> playNext() async {
    if (_currentIndex < 0 || _currentIndex + 1 >= _queue.length) return;
    await playSong(_queue[_currentIndex + 1], queue: _queue);
  }

  Future<void> playPrevious() async {
    if (_currentIndex <= 0) {
      await seek(Duration.zero);
      return;
    }
    await playSong(_queue[_currentIndex - 1], queue: _queue);
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _audioService.dispose();
    super.dispose();
  }
}
