import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/song_repository.dart';
import '../../models/song.dart';
import '../../providers/song_provider.dart';

/// Mở bảng trượt thêm (song == null) hoặc sửa bài hát.
Future<void> showSongFormSheet(BuildContext context, {Song? song}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => SongFormSheet(song: song),
  );
}

class SongFormSheet extends StatefulWidget {
  const SongFormSheet({super.key, this.song});

  final Song? song;

  @override
  State<SongFormSheet> createState() => _SongFormSheetState();
}

class _SongFormSheetState extends State<SongFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _artist;
  late final TextEditingController _duration;
  late final TextEditingController _cover;
  late final TextEditingController _audio;
  int? _genreId;
  bool _visible = true;
  bool _saving = false;

  bool get _isEdit => widget.song != null;

  @override
  void initState() {
    super.initState();
    final s = widget.song;
    _title = TextEditingController(text: s?.title ?? '');
    _artist = TextEditingController(text: s?.artist ?? '');
    _duration = TextEditingController(text: s?.durationLabel ?? '');
    _cover = TextEditingController(text: s?.coverUrl ?? '');
    _audio = TextEditingController(text: s?.audioUrl ?? '');
    _genreId = s?.genreId;
    _visible = s?.isVisible ?? true;
  }

  @override
  void dispose() {
    for (final c in [_title, _artist, _duration, _cover, _audio]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _nullIfEmpty(String v) => v.trim().isEmpty ? null : v.trim();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final seconds = Song.parseDuration(_duration.text)!;
    final provider = context.read<SongProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final savedMsg = context.trNow('t_saved');

    final base = Song(
      id: widget.song?.id ?? 0,
      title: _title.text.trim(),
      artist: _artist.text.trim(),
      genreId: _genreId,
      durationSeconds: seconds,
      coverUrl: _nullIfEmpty(_cover.text),
      audioUrl: _nullIfEmpty(_audio.text),
      isVisible: _visible,
      playCount: widget.song?.playCount ?? 0,
    );

    setState(() => _saving = true);
    final ok = _isEdit ? await provider.editSong(base) : await provider.addSong(base);
    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(savedMsg)));
    } else {
      messenger.showSnackBar(SnackBar(content: Text(provider.errorMessage ?? 'Error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final genres = context.watch<SongProvider>().genres;
    // Nếu thể loại cũ không còn trong danh sách thì bỏ chọn để tránh lỗi Dropdown.
    final genreValue = genres.any((g) => g.id == _genreId) ? _genreId : null;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(context.tr(_isEdit ? 'd_edit' : 'd_add'),
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _title,
                maxLength: 60,
                decoration: InputDecoration(labelText: context.tr('f_title')),
                validator: (v) => SongRepository.validateSongInput(
                  title: v ?? '',
                  artist: 'x',
                  durationSeconds: 1,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _artist,
                maxLength: 40,
                decoration: InputDecoration(labelText: context.tr('f_artist')),
                validator: (v) => SongRepository.validateSongInput(
                  title: 'x',
                  artist: v ?? '',
                  durationSeconds: 1,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int?>(
                      initialValue: genreValue,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: context.tr('f_genre')),
                      items: [
                        DropdownMenuItem<int?>(
                            value: null, child: Text(context.tr('noGenre'))),
                        for (final g in genres)
                          DropdownMenuItem<int?>(value: g.id, child: Text(g.name)),
                      ],
                      onChanged: (v) => setState(() => _genreId = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _duration,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        labelText: context.tr('f_dur'),
                        hintText: '3:45',
                      ),
                      validator: (v) =>
                          Song.parseDuration(v ?? '') == null ? context.trNow('e_dur') : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cover,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(labelText: context.tr('f_cover')),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _audio,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(labelText: context.tr('f_audio')),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.tr('f_visible')),
                value: _visible,
                activeThumbColor: AppTheme.primaryGreen,
                onChanged: (v) => setState(() => _visible = v),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(context.tr('save')),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.tr('cancel')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
