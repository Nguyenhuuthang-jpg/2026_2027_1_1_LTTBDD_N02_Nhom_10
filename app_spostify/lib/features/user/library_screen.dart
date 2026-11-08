import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/history_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/song_tile.dart';
import '../../widgets/state_views.dart';

/// Thư viện: bài yêu thích + lịch sử nghe.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>();
    final favorites = history.favorites;
    final entries = history.history;
    final timeFormat = DateFormat('HH:mm · dd/MM');

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(context.tr('n_library'),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800)),
                ),
                if (entries.isNotEmpty)
                  TextButton.icon(
                    icon: const Icon(Icons.delete_sweep_outlined),
                    label: Text(context.tr('clearHist')),
                    onPressed: () async {
                      final provider = context.read<HistoryProvider>();
                      final ok = await showConfirmDialog(
                        context,
                        title: context.trNow('clearHist'),
                        message: context.trNow('clearHistQ'),
                        destructive: true,
                      );
                      if (ok) await provider.clearHistory();
                    },
                  ),
              ],
            ),
          ),
          TabBar(
            indicatorColor: AppTheme.primaryGreen,
            labelColor: AppTheme.primaryGreen,
            tabs: [
              Tab(text: '${context.tr('favorites')} (${favorites.length})'),
              Tab(text: context.tr('history')),
            ],
          ),
          Expanded(
            child: history.isLoading && favorites.isEmpty && entries.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    children: [
                      RefreshIndicator(
                        onRefresh: context.read<HistoryProvider>().load,
                        child: favorites.isEmpty
                            ? ListView(children: [
                                const SizedBox(height: 80),
                                EmptyView(
                                    title: context.tr('noFav'),
                                    icon: Icons.favorite_border),
                              ])
                            : ListView.builder(
                                itemCount: favorites.length,
                                itemBuilder: (context, i) => SongTile(
                                  song: favorites[i],
                                  onTap: () =>
                                      playSongFromList(context, favorites[i], favorites),
                                ),
                              ),
                      ),
                      RefreshIndicator(
                        onRefresh: context.read<HistoryProvider>().load,
                        child: entries.isEmpty
                            ? ListView(children: [
                                const SizedBox(height: 80),
                                EmptyView(
                                    title: context.tr('noHist'), icon: Icons.history),
                              ])
                            : ListView.builder(
                                itemCount: entries.length,
                                itemBuilder: (context, i) {
                                  final e = entries[i];
                                  return SongTile(
                                    song: e.song,
                                    subtitle:
                                        '${e.song.artist} · ${timeFormat.format(e.playedAt)}',
                                    onTap: () => playSongFromList(
                                        context, e.song, entries.map((x) => x.song).toList()),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
