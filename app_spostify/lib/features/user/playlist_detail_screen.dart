import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../models/playlist.dart';
import '../../models/song.dart';
import '../../providers/playlist_provider.dart';
import '../../widgets/cover_art.dart';
import '../../widgets/mini_player.dart';
import '../../widgets/song_tile.dart';
import '../../widgets/state_views.dart';

class PlaylistDetailScreen extends StatefulWidget {
  const PlaylistDetailScreen({super.key, required this.playlist});

  final Playlist playlist;

  static Route<void> route(Playlist playlist) =>
      MaterialPageRoute(builder: (_) => PlaylistDetailScreen(playlist: playlist));

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  late Future<List<Song>> _songsFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _songsFuture = context.read<PlaylistProvider>().songsOf(widget.playlist.id);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.playlist;
    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: const MiniPlayer(),
      body: FutureBuilder<List<Song>>(
        future: _songsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorView(
              message: snapshot.error.toString(),
              onRetry: () => setState(_load),
            );
          }
          final songs = (snapshot.data ?? const <Song>[])
              .where((s) => s.isVisible)
              .toList();
          return ListView(
            children: [
              Center(
                child: CoverArt(
                  url: p.coverUrl,
                  seed: p.name,
                  size: 200,
                  radius: 18,
                  icon: Icons.queue_music_rounded,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(p.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
              ),
              if (p.description != null && p.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
                  child: Text(p.description!, textAlign: TextAlign.center),
                ),
              const SizedBox(height: 4),
              Text('${songs.length} ${context.tr('songs_n')}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 16),
              if (songs.isNotEmpty)
                Center(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: AppTheme.darkBackground,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(context.tr('playAll')),
                    onPressed: () => playSongFromList(context, songs.first, songs),
                  ),
                ),
              const SizedBox(height: 8),
              if (songs.isEmpty)
                EmptyView(title: context.tr('noSongsInPl'))
              else
                for (var i = 0; i < songs.length; i++)
                  SongTile(
                    song: songs[i],
                    index: i + 1,
                    onTap: () => playSongFromList(context, songs[i], songs),
                  ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
