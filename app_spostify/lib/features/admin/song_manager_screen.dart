import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../models/song.dart';
import '../../providers/song_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/cover_art.dart';
import '../../widgets/genre_chip.dart';
import '../../widgets/state_views.dart';
import 'song_form_sheet.dart';

/// Quản lý bài hát: tìm kiếm, lọc thể loại, sửa, ẩn/hiện, xóa.
class SongManagerScreen extends StatefulWidget {
  const SongManagerScreen({super.key});

  @override
  State<SongManagerScreen> createState() => _SongManagerScreenState();
}

class _SongManagerScreenState extends State<SongManagerScreen> {
  String _query = '';
  int? _genreId;

  List<Song> _filter(List<Song> songs) {
    final q = _query.trim().toLowerCase();
    return songs.where((s) {
      final okQuery =
          q.isEmpty || s.title.toLowerCase().contains(q) || s.artist.toLowerCase().contains(q);
      return okQuery && (_genreId == null || s.genreId == _genreId);
    }).toList();
  }

  Future<void> _toggleVisibility(Song song) async {
    final provider = context.read<SongProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final msg = context.trNow('t_vis');
    final ok = await provider.setVisibility(song.id, !song.isVisible);
    messenger.showSnackBar(SnackBar(content: Text(ok ? msg : provider.errorMessage ?? '')));
  }

  Future<void> _delete(Song song) async {
    final provider = context.read<SongProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final msg = context.trNow('t_del');
    final confirmed = await showConfirmDialog(
      context,
      title: song.title,
      message: context.trNow('delSongQ'),
      confirmLabel: context.trNow('delete'),
      destructive: true,
    );
    if (!confirmed) return;
    final ok = await provider.removeSong(song.id);
    messenger.showSnackBar(SnackBar(content: Text(ok ? msg : provider.errorMessage ?? '')));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SongProvider>();
    final songs = _filter(provider.songs);
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: context.tr('search'),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
        GenreChipBar(
          genres: provider.genres,
          selectedId: _genreId,
          allLabel: context.tr('all'),
          onChanged: (id) => setState(() => _genreId = id),
        ),
        Expanded(
          child: provider.isLoading && provider.songs.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : provider.errorMessage != null && provider.songs.isEmpty
                  ? ErrorView(
                      message: provider.errorMessage!,
                      onRetry: () => context.read<SongProvider>().loadSongs(),
                    )
                  : songs.isEmpty
                      ? EmptyView(title: context.tr('e_t'), message: context.tr('e_s'))
                      : RefreshIndicator(
                          onRefresh: () => context.read<SongProvider>().loadSongs(),
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 96),
                            itemCount: songs.length,
                            itemBuilder: (context, i) {
                              final s = songs[i];
                              return Opacity(
                                opacity: s.isVisible ? 1 : 0.55,
                                child: ListTile(
                                  onTap: () => showSongFormSheet(context, song: s),
                                  leading: CoverArt(url: s.coverUrl, seed: s.title),
                                  title: Text(s.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: Text(
                                    '${s.artist} · ${s.durationLabel} · '
                                    '${s.isVisible ? (s.genreName ?? context.tr('shown')) : context.tr('hidden')}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: muted),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: context.tr('vis'),
                                        icon: Icon(
                                          s.isVisible
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: s.isVisible ? AppTheme.primaryGreen : null,
                                        ),
                                        onPressed: () => _toggleVisibility(s),
                                      ),
                                      IconButton(
                                        tooltip: context.tr('delete'),
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () => _delete(s),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }
}
