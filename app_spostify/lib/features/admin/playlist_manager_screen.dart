import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/playlist_repository.dart';
import '../../models/playlist.dart';
import '../../providers/playlist_provider.dart';
import '../../providers/song_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/cover_art.dart';
import '../../widgets/state_views.dart';

/// Quản lý playlist: tạo, sửa, chọn bài, ẩn/hiện ở "Dành riêng cho bạn", xóa.
class PlaylistManagerScreen extends StatelessWidget {
  const PlaylistManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlaylistProvider>();
    final playlists = provider.playlists;

    if (provider.isLoading && playlists.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null && playlists.isEmpty) {
      return ErrorView(
        message: provider.errorMessage!,
        onRetry: () => context.read<PlaylistProvider>().loadPlaylists(includeHidden: true),
      );
    }
    if (playlists.isEmpty) {
      return EmptyView(title: context.tr('pl_add'), icon: Icons.queue_music_rounded);
    }

    return RefreshIndicator(
      onRefresh: () => context.read<PlaylistProvider>().loadPlaylists(includeHidden: true),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 96),
        itemCount: playlists.length,
        itemBuilder: (context, i) => _PlaylistRow(playlist: playlists[i]),
      ),
    );
  }
}

class _PlaylistRow extends StatelessWidget {
  const _PlaylistRow({required this.playlist});

  final Playlist playlist;

  Future<void> _onMenu(BuildContext context, String action) async {
    final provider = context.read<PlaylistProvider>();
    final messenger = ScaffoldMessenger.of(context);
    switch (action) {
      case 'edit':
        await showPlaylistFormDialog(context, playlist: playlist);
      case 'songs':
        await showPlaylistSongsSheet(context, playlist);
      case 'delete':
        final ok = await showConfirmDialog(
          context,
          title: playlist.name,
          message: context.trNow('delPlQ'),
          confirmLabel: context.trNow('delete'),
          destructive: true,
        );
        if (!ok || !context.mounted) return;
        final msg = context.trNow('t_del');
        final done = await provider.deletePlaylist(playlist.id);
        messenger.showSnackBar(
            SnackBar(content: Text(done ? msg : provider.errorMessage ?? '')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => showPlaylistSongsSheet(context, playlist),
      leading: CoverArt(
        url: playlist.coverUrl,
        seed: playlist.name,
        icon: Icons.queue_music_rounded,
      ),
      title: Text(playlist.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        '${playlist.songCount} ${context.tr('songs_n')} · '
        '${context.tr(playlist.isVisible ? 'shown' : 'hidden')}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: playlist.isVisible,
            activeThumbColor: AppTheme.primaryGreen,
            onChanged: (v) =>
                context.read<PlaylistProvider>().setVisibility(playlist.id, v),
          ),
          PopupMenuButton<String>(
            onSelected: (a) => _onMenu(context, a),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'edit', child: Text(context.tr('edit'))),
              PopupMenuItem(value: 'songs', child: Text(context.tr('pl_songs'))),
              PopupMenuItem(value: 'delete', child: Text(context.tr('delete'))),
            ],
          ),
        ],
      ),
    );
  }
}

/// Hộp thoại tạo (playlist == null) hoặc sửa playlist.
Future<void> showPlaylistFormDialog(BuildContext context, {Playlist? playlist}) async {
  final provider = context.read<PlaylistProvider>();
  final messenger = ScaffoldMessenger.of(context);
  final name = TextEditingController(text: playlist?.name ?? '');
  final desc = TextEditingController(text: playlist?.description ?? '');
  final cover = TextEditingController(text: playlist?.coverUrl ?? '');
  final formKey = GlobalKey<FormState>();

  final saved = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.tr(playlist == null ? 'pl_add' : 'pl_edit')),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: name,
                autofocus: true,
                maxLength: 60,
                decoration: InputDecoration(labelText: context.tr('pl_name')),
                validator: (v) => PlaylistRepository.validateName(v ?? ''),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: desc,
                maxLines: 2,
                decoration: InputDecoration(labelText: context.tr('pl_desc')),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: cover,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(labelText: context.tr('f_cover')),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.tr('cancel')),
        ),
        FilledButton(
          onPressed: () async {
            if (!formKey.currentState!.validate()) return;
            final navigator = Navigator.of(context);
            final ok = playlist == null
                ? await provider.createPlaylist(
                    name: name.text,
                    description: desc.text,
                    coverUrl: cover.text,
                  )
                : await provider.updatePlaylist(playlist.copyWith(
                    name: name.text.trim(),
                    description: desc.text.trim(),
                    coverUrl: cover.text.trim(),
                  ));
            if (ok) navigator.pop(true);
            if (!ok) {
              messenger.showSnackBar(SnackBar(content: Text(provider.errorMessage ?? '')));
            }
          },
          child: Text(context.tr('save')),
        ),
      ],
    ),
  );
  name.dispose();
  desc.dispose();
  cover.dispose();
  if (saved == true && context.mounted) {
    messenger.showSnackBar(SnackBar(content: Text(context.trNow('saved'))));
  }
}

/// Bảng chọn bài hát cho playlist (tick để thêm / bỏ).
Future<void> showPlaylistSongsSheet(BuildContext context, Playlist playlist) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _PlaylistSongsSheet(playlist: playlist),
  );
}

class _PlaylistSongsSheet extends StatefulWidget {
  const _PlaylistSongsSheet({required this.playlist});

  final Playlist playlist;

  @override
  State<_PlaylistSongsSheet> createState() => _PlaylistSongsSheetState();
}

class _PlaylistSongsSheetState extends State<_PlaylistSongsSheet> {
  List<int>? _selected; // giữ thứ tự chọn
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    context.read<PlaylistProvider>().songsOf(widget.playlist.id).then((songs) {
      if (mounted) setState(() => _selected = songs.map((s) => s.id).toList());
    }).catchError((Object e) {
      if (mounted) setState(() => _error = e.toString());
    });
  }

  Future<void> _save() async {
    final provider = context.read<PlaylistProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final msg = context.trNow('saved');
    setState(() => _saving = true);
    final ok = await provider.setSongsOf(widget.playlist, _selected!);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) navigator.pop();
    messenger.showSnackBar(SnackBar(content: Text(ok ? msg : provider.errorMessage ?? '')));
  }

  @override
  Widget build(BuildContext context) {
    final songs = context.watch<SongProvider>().songs;
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              '${context.tr('pl_songs')} · ${widget.playlist.name}',
              style:
                  Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(
            child: _error != null
                ? Center(child: Text(_error!))
                : _selected == null
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        children: [
                          for (final s in songs)
                            CheckboxListTile(
                              value: _selected!.contains(s.id),
                              activeColor: AppTheme.primaryGreen,
                              title: Text(s.title),
                              subtitle: Text('${s.artist} · ${s.durationLabel}'),
                              secondary: CoverArt(url: s.coverUrl, seed: s.title, size: 40),
                              onChanged: (v) => setState(() {
                                v == true ? _selected!.add(s.id) : _selected!.remove(s.id);
                              }),
                            ),
                        ],
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _selected == null || _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('${context.tr('save')} (${_selected?.length ?? 0})'),
            ),
          ),
        ],
      ),
    );
  }
}
