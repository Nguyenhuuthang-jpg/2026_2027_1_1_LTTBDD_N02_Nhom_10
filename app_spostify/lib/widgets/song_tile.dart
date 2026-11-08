import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/song.dart';
import '../providers/history_provider.dart';
import '../providers/player_provider.dart';
import 'cover_art.dart';

/// Một dòng bài hát. Bài đang phát được tô màu xanh chủ đạo.
class SongTile extends StatelessWidget {
  const SongTile({
    super.key,
    required this.song,
    this.onTap,
    this.trailing,
    this.showFavorite = true,
    this.index,
    this.subtitle,
  });

  final Song song;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showFavorite;

  /// Số thứ tự hiển thị bên trái (ví dụ bảng xếp hạng). Null = không hiện.
  final int? index;

  /// Ghi đè dòng phụ mặc định "Nghệ sĩ · 3:45".
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final isCurrent = context.select<PlayerProvider, bool>(
      (p) => p.currentSong?.id == song.id,
    );
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (index != null)
            SizedBox(
              width: 26,
              child: Text('$index',
                  style: theme.textTheme.titleMedium?.copyWith(color: muted)),
            ),
          CoverArt(url: song.coverUrl, seed: song.title, size: 48),
        ],
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isCurrent ? AppTheme.primaryGreen : null,
        ),
      ),
      subtitle: Text(
        subtitle ?? '${song.artist} · ${song.durationLabel}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: muted),
      ),
      trailing: trailing ?? (showFavorite ? _FavoriteButton(song: song) : null),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.song});

  final Song song;

  @override
  Widget build(BuildContext context) {
    final fav = context.select<HistoryProvider, bool>((h) => h.isFavorite(song.id));
    return IconButton(
      icon: Icon(fav ? Icons.favorite : Icons.favorite_border,
          color: fav ? AppTheme.primaryGreen : null),
      onPressed: () => context.read<HistoryProvider>().toggleFavorite(song),
    );
  }
}

/// Phát [song] trong hàng đợi [queue] và báo lỗi bằng SnackBar nếu có.
Future<void> playSongFromList(BuildContext context, Song song, List<Song> queue) async {
  final player = context.read<PlayerProvider>();
  final messenger = ScaffoldMessenger.of(context);
  await player.playSong(song, queue: queue);
  final error = player.errorMessage;
  if (error != null) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(error)));
  }
}
