import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../models/song.dart';
import '../../providers/history_provider.dart';
import '../../providers/player_provider.dart';
import '../../widgets/cover_art.dart';

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
    final syncedLines = parseLrc(lyrics);

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
        ] else if (lyrics.isEmpty)
          Text(
            context.tr('noLyrics'),
            textAlign: TextAlign.center,
            style: const TextStyle(height: 1.7, fontSize: 15),
          )
        else if (syncedLines.length >= 2)
          _SyncedLyrics(lines: syncedLines)
        else
          Text(
            lyrics,
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

class LrcLine {
  const LrcLine(this.time, this.text);
  final Duration time;
  final String text;
}

List<LrcLine> parseLrc(String raw) {
  final reg = RegExp(r'\[(\d{1,2}):(\d{2})(?:[.:](\d{1,3}))?\]');
  final lines = <LrcLine>[];
  for (final row in raw.split('\n')) {
    final matches = reg.allMatches(row).toList();
    if (matches.isEmpty) continue;
    final text = row.substring(matches.last.end).trim();
    for (final m in matches) {
      final frac = (m.group(3) ?? '0').padRight(3, '0').substring(0, 3);
      lines.add(
        LrcLine(
          Duration(
            minutes: int.parse(m.group(1)!),
            seconds: int.parse(m.group(2)!),
            milliseconds: int.parse(frac),
          ),
          text,
        ),
      );
    }
  }
  lines.sort((a, b) => a.time.compareTo(b.time));
  return lines;
}

class _SyncedLyrics extends StatefulWidget {
  const _SyncedLyrics({required this.lines});

  final List<LrcLine> lines;

  @override
  State<_SyncedLyrics> createState() => _SyncedLyricsState();
}

class _SyncedLyricsState extends State<_SyncedLyrics> {
  static const double _itemHeight = 48;
  static const double _viewHeight = 320;

  final _controller = ScrollController();
  int _current = -1;

  int _indexFor(Duration pos) {
    var idx = -1;
    for (var i = 0; i < widget.lines.length; i++) {
      if (widget.lines[i].time <= pos) {
        idx = i;
      } else {
        break;
      }
    }
    return idx;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final position = context.select<PlayerProvider, Duration>(
      (p) => p.position,
    );
    final idx = _indexFor(position);

    if (idx != _current) {
      _current = idx;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_controller.hasClients || idx < 0) return;
        final target = (idx * _itemHeight - _viewHeight / 2 + _itemHeight / 2)
            .clamp(0.0, _controller.position.maxScrollExtent);
        _controller.animateTo(
          target,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }

    return SizedBox(
      height: _viewHeight,
      child: ListView.builder(
        controller: _controller,
        itemExtent: _itemHeight,
        itemCount: widget.lines.length,
        itemBuilder: (context, i) {
          final active = i == idx;
          return GestureDetector(
            onTap: () =>
                context.read<PlayerProvider>().seek(widget.lines[i].time),
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: active ? 18 : 15,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w400,
                  color: active ? AppTheme.primaryGreen : Colors.white60,
                ),
                child: Text(
                  widget.lines[i].text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
