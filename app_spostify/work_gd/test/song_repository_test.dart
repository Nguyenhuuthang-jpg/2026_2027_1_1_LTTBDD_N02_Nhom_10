import 'package:flutter_test/flutter_test.dart';
import 'package:app_spostify/data/repositories/song_repository.dart';

void main() {
  group('SongRepository.validateSongInput', () {
    test('chấp nhận thông tin bài hát hợp lệ', () {
      expect(
        SongRepository.validateSongInput(
          title: 'Một đêm say',
          artist: 'Thịnh Suy',
          durationSeconds: 228,
        ),
        isNull,
      );
    });

    test('từ chối tên bài hát rỗng hoặc quá 60 ký tự', () {
      expect(
        SongRepository.validateSongInput(title: ' ', artist: 'Ca sĩ', durationSeconds: 100),
        isNotNull,
      );
      expect(
        SongRepository.validateSongInput(title: List.filled(61, 'a').join(), artist: 'Ca sĩ', durationSeconds: 100),
        isNotNull,
      );
    });

    test('từ chối nghệ sĩ rỗng hoặc quá 40 ký tự', () {
      expect(
        SongRepository.validateSongInput(title: 'Bài hát', artist: '', durationSeconds: 100),
        isNotNull,
      );
      expect(
        SongRepository.validateSongInput(title: 'Bài hát', artist: List.filled(41, 'a').join(), durationSeconds: 100),
        isNotNull,
      );
    });

    test('thời lượng phải lớn hơn 0', () {
      expect(
        SongRepository.validateSongInput(title: 'Bài hát', artist: 'Ca sĩ', durationSeconds: 0),
        isNotNull,
      );
    });
  });
}
