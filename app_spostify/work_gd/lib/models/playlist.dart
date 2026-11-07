/// Một dòng của bảng `playlists`.
///
/// Số bài lấy từ query có đếm:
///   supabase.from('playlists').select('*, playlist_songs(count)')
class Playlist {
  final int id;
  final String name;
  final String? description;
  final String? coverUrl;
  final bool isVisible;
  final int songCount;

  const Playlist({
    required this.id,
    required this.name,
    this.description,
    this.coverUrl,
    this.isVisible = true,
    this.songCount = 0,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    // playlist_songs(count) trả về [{"count": 18}]
    final counts = json['playlist_songs'];
    final songCount = counts is List && counts.isNotEmpty
        ? (counts.first['count'] as num?)?.toInt() ?? 0
        : 0;
    return Playlist(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      coverUrl: json['cover_url'] as String?,
      isVisible: json['is_visible'] as bool? ?? true,
      songCount: songCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'cover_url': coverUrl,
        'is_visible': isVisible,
      };

  Playlist copyWith({
    String? name,
    String? description,
    String? coverUrl,
    bool? isVisible,
    int? songCount,
  }) =>
      Playlist(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        coverUrl: coverUrl ?? this.coverUrl,
        isVisible: isVisible ?? this.isVisible,
        songCount: songCount ?? this.songCount,
      );
}
