import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_strings.dart';
import '../../models/song.dart';
import '../../providers/song_provider.dart';
import '../../widgets/genre_chip.dart';
import '../../widgets/song_tile.dart';
import '../../widgets/state_views.dart';

/// Tìm kiếm theo tên bài / nghệ sĩ và lọc theo thể loại (lọc ngay trên máy).
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  int? _genreId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Song> _filter(List<Song> songs) {
    final q = _query.trim().toLowerCase();
    return songs.where((s) {
      final matchesQuery = q.isEmpty ||
          s.title.toLowerCase().contains(q) ||
          s.artist.toLowerCase().contains(q);
      final matchesGenre = _genreId == null || s.genreId == _genreId;
      return matchesQuery && matchesGenre;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SongProvider>();
    final results = _filter(provider.visibleSongs);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: context.tr('search'),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
            ),
          ),
        ),
        GenreChipBar(
          genres: provider.genres,
          selectedId: _genreId,
          allLabel: context.tr('all'),
          onChanged: (id) => setState(() => _genreId = id),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: provider.isLoading && provider.songs.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : results.isEmpty
                  ? EmptyView(
                      title: context.tr('e_t'),
                      message: context.tr('e_s'),
                      icon: Icons.search_off_rounded,
                    )
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, i) => SongTile(
                        song: results[i],
                        subtitle: [
                          results[i].artist,
                          if (results[i].genreName != null) results[i].genreName!,
                          results[i].durationLabel,
                        ].join(' · '),
                        onTap: () => playSongFromList(context, results[i], results),
                      ),
                    ),
        ),
      ],
    );
  }
}
