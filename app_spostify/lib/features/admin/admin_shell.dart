import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/playlist_provider.dart';
import '../../providers/song_provider.dart';
import '../../providers/stats_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/mini_player.dart';
import 'admin_settings_screen.dart';
import 'dashboard_screen.dart';
import 'playlist_manager_screen.dart';
import 'song_form_sheet.dart';
import 'song_manager_screen.dart';
import 'user_manager_screen.dart';

/// Khung quản trị: 4 tab + nút thêm nổi (bài hát / playlist) + nút Cài đặt.
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  static const _titles = ['n_dash', 'n_songs', 'n_pl', 'n_users'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => refreshAdminData(context));
  }

  Widget? _fab(BuildContext context) {
    switch (_index) {
      case 1:
        return FloatingActionButton.extended(
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: AppTheme.darkBackground,
          icon: const Icon(Icons.add),
          label: Text(context.tr('d_add')),
          onPressed: () => showSongFormSheet(context),
        );
      case 2:
        return FloatingActionButton.extended(
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: AppTheme.darkBackground,
          icon: const Icon(Icons.playlist_add),
          label: Text(context.tr('pl_add')),
          onPressed: () => showPlaylistFormDialog(context),
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr(_titles[_index]),
            style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: context.tr('n_set'),
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminSettingsScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: _fab(context),
      body: IndexedStack(
        index: _index,
        children: const [
          DashboardScreen(),
          SongManagerScreen(),
          PlaylistManagerScreen(),
          UserManagerScreen(),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.dashboard_outlined),
                selectedIcon: const Icon(Icons.dashboard_rounded),
                label: context.tr('n_dash'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.music_note_outlined),
                selectedIcon: const Icon(Icons.music_note_rounded),
                label: context.tr('n_songs'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.queue_music_outlined),
                selectedIcon: const Icon(Icons.queue_music_rounded),
                label: context.tr('n_pl'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.people_outline),
                selectedIcon: const Icon(Icons.people_rounded),
                label: context.tr('n_users'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> refreshAdminData(BuildContext context) async {
  final songs = context.read<SongProvider>();
  final playlists = context.read<PlaylistProvider>();
  final stats = context.read<StatsProvider>();
  final users = context.read<UserProvider>();
  await Future.wait([
    songs.loadSongs(),
    songs.loadGenres(),
    playlists.loadPlaylists(includeHidden: true),
    stats.load(),
    users.loadUsers(),
  ]);
}
