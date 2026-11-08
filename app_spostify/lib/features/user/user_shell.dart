import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_strings.dart';
import '../../providers/history_provider.dart';
import '../../providers/playlist_provider.dart';
import '../../providers/song_provider.dart';
import '../../widgets/mini_player.dart';
import 'explore_screen.dart';
import 'home_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';

/// Khung chính phía người dùng: 4 tab + mini player phía trên thanh điều hướng.
class UserShell extends StatefulWidget {
  const UserShell({super.key});

  @override
  State<UserShell> createState() => _UserShellState();
}

class _UserShellState extends State<UserShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => refreshUserData(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _index,
          children: const [
            HomeScreen(),
            ExploreScreen(),
            LibraryScreen(),
            ProfileScreen(),
          ],
        ),
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
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home_rounded),
                label: context.tr('n_home'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.search),
                selectedIcon: const Icon(Icons.manage_search_rounded),
                label: context.tr('n_explore'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.library_music_outlined),
                selectedIcon: const Icon(Icons.library_music_rounded),
                label: context.tr('n_library'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person_rounded),
                label: context.tr('n_profile'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tải lại toàn bộ dữ liệu phía người dùng (dùng cho kéo-để-làm-mới).
Future<void> refreshUserData(BuildContext context) async {
  final songs = context.read<SongProvider>();
  final playlists = context.read<PlaylistProvider>();
  final history = context.read<HistoryProvider>();
  await Future.wait([
    songs.loadSongs(),
    songs.loadGenres(),
    playlists.loadPlaylists(),
    history.load(),
  ]);
}
