import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../models/song.dart';
import '../../providers/history_provider.dart';
import '../../providers/player_provider.dart';
import '../../widgets/cover_art.dart';

/// Màn phát nhạc toàn màn hình.
class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  static Route<void> route() => MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => const PlayerScreen(),
  );

  static String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final song = player.currentSong;
    if (song == null) {
      return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
    }
    final isFav = context.select<HistoryProvider, bool>(
      (h) => h.isFavorite(song.id),
    );

    // Nếu stream chưa báo thời lượng thì dùng thời lượng lưu trong database.
    final total = player.duration > Duration.zero
        ? player.duration
        : Duration(seconds: song.durationSeconds);
    final position = player.position > total ? total : player.position;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          context.tr('nowPlaying'),
          style: const TextStyle(fontSize: 14),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final coverSize = (constraints.maxWidth - 64).clamp(160.0, 360.0);
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Column(
                children: [
                  Hero(
                    tag: 'cover-${song.id}',
                    child: CoverArt(
                      url: song.coverUrl,
                      seed: song.title,
                      size: coverSize,
                      radius: 20,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              [
                                song.artist,
                                if (song.genreName != null) song.genreName!,
                              ].join(' · '),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        iconSize: 28,
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? AppTheme.primaryGreen : null,
                        ),
                        onPressed: () => context
                            .read<HistoryProvider>()
                            .toggleFavorite(song),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: position.inMilliseconds.toDouble(),
                    max: total.inMilliseconds.toDouble().clamp(
                      1,
                      double.infinity,
                    ),
                    activeColor: AppTheme.primaryGreen,
                    onChanged: (v) =>
                        player.seek(Duration(milliseconds: v.round())),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text(_fmt(position)), Text(_fmt(total))],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        iconSize: 40,
                        icon: const Icon(Icons.skip_previous_rounded),
                        onPressed: player.playPrevious,
                      ),
                      SizedBox(
                        width: 76,
                        height: 76,
                        child: player.isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(),
                              )
                            : IconButton.filled(
                                iconSize: 44,
                                style: IconButton.styleFrom(
                                  backgroundColor: AppTheme.primaryGreen,
                                  foregroundColor: AppTheme.darkBackground,
                                ),
                                icon: Icon(
                                  player.isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                ),
                                onPressed: player.togglePlayPause,
                              ),
                      ),
                      IconButton(
                        iconSize: 40,
                        icon: const Icon(Icons.skip_next_rounded),
                        onPressed: player.hasNext ? player.playNext : null,
                      ),
                    ],
                  ),
                  if (player.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      player.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: _SongDetailTabs(song: song),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Hai tab "Thông tin" và "Lời bài hát" của bài đang phát (không lưu link riêng).
class _SongDetailTabs extends StatefulWidget {
  const _SongDetailTabs({required this.song});

  final Song song;

  @override
  State<_SongDetailTabs> createState() => _SongDetailTabsState();
}

class _SongDetailTabsState extends State<_SongDetailTabs> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final song = widget.song;
    final lyrics = song.lyrics?.trim() ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<int>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: 0, label: Text(context.tr('tabInfo'))),
            ButtonSegment(value: 1, label: Text(context.tr('tabLyrics'))),
          ],
          selected: {_tab},
          onSelectionChanged: (s) => setState(() => _tab = s.first),
        ),
        const SizedBox(height: 16),
        if (_tab == 0) ...[
          _InfoRow(context.tr('infoArtist'), song.artist),
          _InfoRow(context.tr('infoGenre'), song.genreName ?? '—'),
          _InfoRow(context.tr('infoDuration'), song.durationLabel),
          _InfoRow(context.tr('infoPlays'), '${song.playCount}'),
        ] else
          Text(
            lyrics.isEmpty ? context.tr('noLyrics') : lyrics,
            textAlign: TextAlign.center,
            style: const TextStyle(height: 1.7, fontSize: 15),
          ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white.withValues(alpha: .6)),
          ),
          Flexible(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
