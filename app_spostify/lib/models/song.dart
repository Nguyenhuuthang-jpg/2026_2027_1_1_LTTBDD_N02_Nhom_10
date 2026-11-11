/// Một dòng của bảng `songs` (kèm tên thể loại nếu query có join `genres(name)`).
///
/// Ví dụ query:
///   supabase.from('songs').select('*, genres(name)')
class Song {
  final int id;
  final String title;
  final String artist;
  final int? genreId;
  final String? genreName;
  final int durationSeconds;
  final String? coverUrl;
  final String? audioUrl;
  final String? lyrics;
  final int playCount;
  final bool isVisible;
  final DateTime? createdAt;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    this.genreId,
    this.genreName,
    required this.durationSeconds,
    this.coverUrl,
    this.audioUrl,
    this.lyrics,
    this.playCount = 0,
    this.isVisible = true,
    this.createdAt,
  });

  /// "3:45"
  String get durationLabel {
    final m = durationSeconds ~/ 60;
    final s = (durationSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Chuyển "3:45" (ô nhập của admin) thành số giây. Trả về null nếu sai định dạng.
  static int? parseDuration(String input) {
    final match = RegExp(r'^(\d{1,2}):([0-5]\d)$').firstMatch(input.trim());
    if (match == null) return null;
    final total = int.parse(match.group(1)!) * 60 + int.parse(match.group(2)!);
    return total > 0 ? total : null;
  }

  factory Song.fromJson(Map<String, dynamic> json) {
    final genre = json['genres'];
    return Song(
      id: json['id'] as int,
      title: json['title'] as String,
      artist: json['artist'] as String,
      genreId: json['genre_id'] as int?,
      genreName: genre is Map<String, dynamic>
          ? genre['name'] as String?
          : null,
      durationSeconds: json['duration_seconds'] as int,
      coverUrl: json['cover_url'] as String?,
      audioUrl: json['audio_url'] as String?,
      lyrics: json['lyrics'] as String?,
      playCount: (json['play_count'] as num?)?.toInt() ?? 0,
      isVisible: json['is_visible'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );
  }

  /// Dùng cho insert / update. Không gồm id, play_count, created_at (do DB quản lý).
  Map<String, dynamic> toJson() => {
    'title': title,
    'artist': artist,
    'genre_id': genreId,
    'duration_seconds': durationSeconds,
    'cover_url': coverUrl,
    'audio_url': audioUrl,
    'lyrics': lyrics,
    'is_visible': isVisible,
  };

  Song copyWith({
    String? title,
    String? artist,
    int? genreId,
    String? genreName,
    int? durationSeconds,
    String? coverUrl,
    String? audioUrl,
    String? lyrics,
    int? playCount,
    bool? isVisible,
  }) => Song(
    id: id,
    title: title ?? this.title,
    artist: artist ?? this.artist,
    genreId: genreId ?? this.genreId,
    genreName: genreName ?? this.genreName,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    coverUrl: coverUrl ?? this.coverUrl,
    audioUrl: audioUrl ?? this.audioUrl,
    lyrics: lyrics ?? this.lyrics,
    playCount: playCount ?? this.playCount,
    isVisible: isVisible ?? this.isVisible,
    createdAt: createdAt,
  );
}
