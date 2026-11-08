import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../features/user/player_screen.dart';
import '../providers/player_provider.dart';
import 'cover_art.dart';

/// Thanh phát nhạc thu gọn phía trên thanh điều hướng. Ẩn khi chưa phát bài nào.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final song = player.currentSong;
    if (song == null) return const SizedBox.shrink();

    final total = player.duration.inMilliseconds;
    final progress =
        total == 0 ? 0.0 : (player.position.inMilliseconds / total).clamp(0.0, 1.0);

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: () => Navigator.of(context).push(PlayerScreen.route()),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: progress,
              minHeight: 2,
              color: AppTheme.primaryGreen,
              backgroundColor: Colors.transparent,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
              child: Row(
                children: [
                  Hero(
                    tag: 'cover-${song.id}',
                    child: CoverArt(url: song.coverUrl, seed: song.title, size: 42, radius: 8),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  if (player.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                          width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  else
                    IconButton(
                      iconSize: 32,
                      icon: Icon(player.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_fill),
                      color: AppTheme.primaryGreen,
                      onPressed: player.togglePlayPause,
                    ),
                  IconButton(
                    icon: const Icon(Icons.skip_next_rounded),
                    onPressed: player.hasNext ? player.playNext : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
