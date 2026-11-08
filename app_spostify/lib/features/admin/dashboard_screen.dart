import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/stats_provider.dart';
import '../../widgets/song_tile.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/state_views.dart';

/// Màn Tổng quan: 4 ô số liệu, biểu đồ 14 ngày, top bài hát.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StatsProvider>();
    final stats = provider.stats;

    if (provider.isLoading && stats.topSongs.isEmpty && stats.songs == 0) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null && stats.songs == 0) {
      return ErrorView(
        message: provider.errorMessage!,
        onRetry: context.read<StatsProvider>().load,
      );
    }

    return RefreshIndicator(
      color: AppTheme.primaryGreen,
      onRefresh: context.read<StatsProvider>().load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          LayoutBuilder(builder: (context, c) {
            final columns = c.maxWidth > 700 ? 4 : 2;
            final width = (c.maxWidth - 12 * (columns - 1)) / columns;
            final cards = [
              StatCard(label: context.tr('st_users'), value: stats.users, icon: Icons.people),
              StatCard(
                  label: context.tr('st_plays'),
                  value: stats.playsToday,
                  icon: Icons.headphones),
              StatCard(
                  label: context.tr('st_songs'), value: stats.songs, icon: Icons.music_note),
              StatCard(
                  label: context.tr('st_pl'),
                  value: stats.playlists,
                  icon: Icons.queue_music),
            ];
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [for (final c in cards) SizedBox(width: width, child: c)],
            );
          }),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr('c_plays'),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  _DailyBarChart(values: stats.dailyPlays, todayLabel: context.tr('today')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(context.tr('c_top'),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (stats.topSongs.isEmpty)
            EmptyView(title: context.tr('e_t'))
          else
            Card(
              child: Column(
                children: [
                  for (var i = 0; i < stats.topSongs.length; i++)
                    SongTile(
                      song: stats.topSongs[i],
                      index: i + 1,
                      showFavorite: false,
                      trailing: Text(
                        '${NumberFormat.decimalPattern('vi').format(stats.topSongs[i].playCount)} '
                        '${context.tr('plays')}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () =>
                          playSongFromList(context, stats.topSongs[i], stats.topSongs),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Biểu đồ cột đơn giản, không cần thư viện ngoài.
class _DailyBarChart extends StatelessWidget {
  const _DailyBarChart({required this.values, required this.todayLabel});

  final List<int> values;
  final String todayLabel;

  @override
  Widget build(BuildContext context) {
    const height = 140.0;
    final maxValue = math.max(1, values.fold<int>(0, math.max));
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
    final today = DateTime.now();

    return SizedBox(
      height: height + 36,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: Tooltip(
                message: '${values[i]}',
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (i == values.length - 1)
                      Text('${values[i]}',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryGreen)),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: math.max(3, values[i] / maxValue * height),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: i == values.length - 1
                            ? AppTheme.primaryGreen
                            : AppTheme.primaryGreen.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      i == values.length - 1
                          ? todayLabel
                          : (i % 3 == 1
                              ? DateFormat('dd/MM')
                                  .format(today.subtract(Duration(days: 13 - i)))
                              : ''),
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                      softWrap: false,
                      style: TextStyle(fontSize: 9, color: muted),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
