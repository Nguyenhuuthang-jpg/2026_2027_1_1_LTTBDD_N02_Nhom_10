import 'package:app_spostify/data/repositories/song_repository.dart';
import 'package:app_spostify/models/genre.dart';
import 'package:app_spostify/models/song.dart';
import 'package:app_spostify/providers/song_provider.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repository giả: lưu trong bộ nhớ, không gọi Supabase.
class FakeSongRepository extends SongRepository {
  FakeSongRepository(this.data);

  final List<Song> data;
  bool failNext = false;
  int _nextId = 100;

  void _maybeFail() {
    if (failNext) {
      failNext = false;
      throw Exception('network down');
    }
  }

  @override
  Future<List<Song>> fetchSongs({String? search, int? genreId, bool newestFirst = true}) async {
    _maybeFail();
    return data.where((s) => genreId == null || s.genreId == genreId).toList();
  }

  @override
  Future<List<Genre>> fetchGenres() async => const [Genre(id: 1, name: 'Pop')];

  @override
  Future<Song> createSong(Song song) async {
    _maybeFail();
    final error = SongRepository.validateSongInput(
      title: song.title,
      artist: song.artist,
      durationSeconds: song.durationSeconds,
    );
    if (error != null) throw ArgumentError(error);
    return Song(
      id: _nextId++,
      title: song.title,
      artist: song.artist,
      durationSeconds: song.durationSeconds,
    );
  }

  @override
  Future<Song> updateSong(Song song) async => song;

  @override
  Future<void> deleteSong(int id) async => _maybeFail();

  @override
  Future<Song> setVisibility(int id, {required bool isVisible}) async =>
      data.firstWhere((s) => s.id == id).copyWith(isVisible: isVisible);
}

const _songs = [
  Song(id: 1, title: 'Có em', artist: 'Madihu', genreId: 1, durationSeconds: 201, playCount: 50),
  Song(id: 2, title: 'Một đêm say', artist: 'Thịnh Suy', durationSeconds: 228, playCount: 90),
  Song(
      id: 3,
      title: 'Acoustic Việt',
      artist: 'Tuyển chọn',
      durationSeconds: 280,
      playCount: 999,
      isVisible: false),
];

void main() {
  late FakeSongRepository repo;
  late SongProvider provider;

  setUp(() {
    repo = FakeSongRepository(List.of(_songs));
    provider = SongProvider(repository: repo);
  });

  test('loadSongs tải danh sách và tắt trạng thái loading', () async {
    final future = provider.loadSongs();
    expect(provider.isLoading, isTrue);
    await future;
    expect(provider.isLoading, isFalse);
    expect(provider.songs, hasLength(3));
    expect(provider.errorMessage, isNull);
  });

  test('visibleSongs và topSongs bỏ qua bài đã ẩn, sắp theo lượt nghe', () async {
    await provider.loadSongs();
    expect(provider.visibleSongs.map((s) => s.id), [1, 2]);
    expect(provider.topSongs.first.id, 2);
  });

  test('lọc theo thể loại', () async {
    await provider.loadSongs(genreId: 1);
    expect(provider.songs.single.title, 'Có em');
    expect(provider.genreId, 1);
  });

  test('loadSongs báo lỗi khi repository thất bại', () async {
    repo.failNext = true;
    await provider.loadSongs();
    expect(provider.errorMessage, contains('network down'));
    expect(provider.isLoading, isFalse);
  });

  test('addSong thêm bài lên đầu danh sách', () async {
    await provider.loadSongs();
    final ok = await provider.addSong(
      const Song(id: 0, title: 'Bài mới', artist: 'Ai đó', durationSeconds: 120),
    );
    expect(ok, isTrue);
    expect(provider.songs.first.title, 'Bài mới');
    expect(provider.songs, hasLength(4));
  });

  test('addSong trả về false và thông báo khi dữ liệu không hợp lệ', () async {
    final ok = await provider.addSong(
      const Song(id: 0, title: '', artist: 'Ai đó', durationSeconds: 120),
    );
    expect(ok, isFalse);
    expect(provider.errorMessage, 'Tên bài hát không được để trống.');
  });

  test('removeSong và setVisibility cập nhật danh sách', () async {
    await provider.loadSongs();
    expect(await provider.removeSong(1), isTrue);
    expect(provider.songs.any((s) => s.id == 1), isFalse);

    expect(await provider.setVisibility(3, true), isTrue);
    expect(provider.songs.firstWhere((s) => s.id == 3).isVisible, isTrue);
  });

  test('loadGenres', () async {
    await provider.loadGenres();
    expect(provider.genres.single.name, 'Pop');
  });
}
