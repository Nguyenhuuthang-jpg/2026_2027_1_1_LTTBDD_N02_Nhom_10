import 'package:just_audio/just_audio.dart';

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

  static const assetPrefix = 'asset:///';

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
