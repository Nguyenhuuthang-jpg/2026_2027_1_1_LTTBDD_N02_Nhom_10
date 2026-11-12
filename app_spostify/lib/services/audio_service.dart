import 'package:just_audio/just_audio.dart';

/// Lớp bao just_audio; không chứa logic giao diện hay quản lý danh sách bài hát.
class AudioService {
  AudioService({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;
  Stream<ProcessingState> get processingStateStream => _player.processingStateStream;

  bool get isPlaying => _player.playing;
  Duration get position => _player.position;
  Duration? get duration => _player.duration;
  ProcessingState get processingState => _player.processingState;

  /// Tiền tố đường dẫn cho file nhạc đóng gói trong app, ví dụ
  /// `asset:///assets/audio/mot-dem-say.mp3`.
  static const assetPrefix = 'asset:///';

  /// Tải nguồn nhạc: link online (https://...) hoặc file trong thư mục assets.
  Future<Duration?> load(String url) {
    if (url.startsWith(assetPrefix)) {
      return _player.setAsset(url.substring(assetPrefix.length));
    }
    return _player.setUrl(url);
  }
  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> stop() => _player.stop();
  Future<void> seek(Duration position) => _player.seek(position);
  Future<void> dispose() => _player.dispose();
}
