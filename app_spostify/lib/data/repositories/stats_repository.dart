import '../../models/song.dart';
import '../remote/supabase_client.dart';

/// Số liệu cho màn Tổng quan của admin.
class DashboardStats {
  final int users;
  final int songs;
  final int playlists;
  final int playsToday;

  /// 14 phần tử, phần tử cuối là hôm nay.
  final List<int> dailyPlays;
  final List<Song> topSongs;

  const DashboardStats({
    required this.users,
    required this.songs,
    required this.playlists,
    required this.playsToday,
    required this.dailyPlays,
    required this.topSongs,
  });

  static const empty = DashboardStats(
    users: 0,
    songs: 0,
    playlists: 0,
    playsToday: 0,
    dailyPlays: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    topSongs: [],
  );
}

class StatsRepository {
  Future<DashboardStats> fetchDashboard() async {
    final client = AppSupabase.client;
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    final results = await Future.wait<dynamic>([
      client.from('profiles').count(),
      client.from('songs').count(),
      client.from('playlists').count(),
      client
          .from('listening_history')
          .count()
          .gte('played_at', startOfToday.toUtc().toIso8601String()),
      client.rpc('admin_daily_plays'),
      client
          .from('songs')
          .select('*, genres(name)')
          .order('play_count', ascending: false)
          .limit(5),
    ]);

    // Ghép dữ liệu theo ngày vào đúng 14 ô (ngày không có lượt nghe = 0).
    final byDay = <String, int>{};
    for (final row in (results[4] as List)) {
      byDay[(row['day'] as String).substring(0, 10)] = (row['plays'] as num).toInt();
    }
    final daily = List<int>.generate(14, (i) {
      final d = startOfToday.subtract(Duration(days: 13 - i));
      final key = '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      return byDay[key] ?? 0;
    });

    return DashboardStats(
      users: results[0] as int,
      songs: results[1] as int,
      playlists: results[2] as int,
      playsToday: results[3] as int,
      dailyPlays: daily,
      topSongs: (results[5] as List)
          .map((r) => Song.fromJson(Map<String, dynamic>.from(r as Map)))
          .toList(),
    );
  }
}
