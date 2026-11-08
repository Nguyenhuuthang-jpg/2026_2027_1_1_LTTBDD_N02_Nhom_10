import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../models/playlist.dart';
import '../../models/song.dart';
import '../../providers/auth_provider.dart';
import '../../providers/playlist_provider.dart';
import '../../providers/song_provider.dart';
import '../../widgets/cover_art.dart';
import '../../widgets/song_tile.dart';
import '../../widgets/state_views.dart';
import 'playlist_detail_screen.dart';
import 'user_shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greetingKey() {
    final h = DateTime.now().hour;
    if (h < 11) return 'goodMorning';
    if (h < 18) return 'goodAfternoon';
    return 'goodEvening';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final songProvider = context.watch<SongProvider>();
    final playlists = context.watch<PlaylistProvider>().playlists;

    final visible = songProvider.visibleSongs;
    final top = songProvider.topSongs;
    final newest = [...visible]
      ..sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));

    Widget body;
    if (songProvider.isLoading && visible.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (songProvider.errorMessage != null && visible.isEmpty) {
      body = ErrorView(
        message: songProvider.errorMessage!,
        onRetry: () => refreshUserData(context),
      );
    } else {
      body = RefreshIndicator(
        color: AppTheme.primaryGreen,
        onRefresh: () => refreshUserData(context),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                '${context.tr(_greetingKey())}, ${user?.name ?? ''}',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            if (songProvider.isFromCache)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.wifi_off_rounded),
                    title: Text(context.tr('offline')),
                  ),
                ),
              ),
            if (playlists.isNotEmpty) ...[
              SectionHeader(context.tr('forYou')),
              SizedBox(
                height: 196,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: playlists.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (context, i) => _PlaylistCard(playlist: playlists[i]),
                ),
              ),
            ],
            if (top.isNotEmpty) ...[
              SectionHeader(context.tr('hot')),
              _HotBanner(song: top.first, queue: top),
              for (var i = 0; i < top.length; i++)
                SongTile(
                  song: top[i],
                  index: i + 1,
                  onTap: () => playSongFromList(context, top[i], top),
                ),
            ],
            if (newest.isNotEmpty) ...[
              SectionHeader(context.tr('newSongs')),
              for (final s in newest.take(5))
                SongTile(song: s, onTap: () => playSongFromList(context, s, newest)),
            ],
            if (visible.isEmpty && playlists.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: EmptyView(title: context.tr('e_t')),
              ),
          ],
        ),
      );
    }
    return body;
  }
}

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({required this.playlist});

  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.of(context).push(PlaylistDetailScreen.route(playlist)),
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CoverArt(
              url: playlist.coverUrl,
              seed: playlist.name,
              size: 140,
              radius: 14,
              icon: Icons.queue_music_rounded,
            ),
            const SizedBox(height: 8),
            Text(playlist.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            Text('${playlist.songCount} ${context.tr('songs_n')}',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// Thẻ nổi bật cho bài đang được nghe nhiều nhất.
class _HotBanner extends StatelessWidget {
  const _HotBanner({required this.song, required this.queue});

  final Song song;
  final List<Song> queue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF1ED760), Color(0xFF0B6E4F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            CoverArt(url: song.coverUrl, seed: song.title, size: 64, radius: 12),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text('${song.artist} · ${song.playCount} ${context.tr('plays')}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            IconButton.filled(
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.darkBackground,
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              onPressed: () => playSongFromList(context, song, queue),
            ),
          ],
        ),
      ),
    );
  }
}
