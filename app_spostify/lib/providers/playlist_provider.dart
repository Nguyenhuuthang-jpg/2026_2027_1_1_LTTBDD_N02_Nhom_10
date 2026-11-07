import 'package:flutter/foundation.dart';

import '../data/remote/supabase_client.dart';
import '../models/playlist.dart';

/// Quản lý danh sách playlist. Phân quyền ghi được kiểm soát bằng RLS ở database.
class PlaylistProvider extends ChangeNotifier {
  List<Playlist> _playlists = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Playlist> get playlists => List.unmodifiable(_playlists);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPlaylists({bool includeHidden = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      var query = AppSupabase.client
          .from('playlists')
          .select('*, playlist_songs(count)');
      if (!includeHidden) query = query.eq('is_visible', true);
      final rows = await query.order('created_at', ascending: false);
      _playlists = rows
          .map((row) => Playlist.fromJson(Map<String, dynamic>.from(row)))
          .toList();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPlaylist({
    required String name,
    String? description,
    String? coverUrl,
    bool isVisible = true,
  }) async {
    if (name.trim().isEmpty || name.trim().length > 60) {
      _errorMessage = 'Tên playlist phải có từ 1 đến 60 ký tự.';
      notifyListeners();
      return false;
    }
    try {
      final row = await AppSupabase.client
          .from('playlists')
          .insert({
            'name': name.trim(),
            'description': description?.trim(),
            'cover_url': coverUrl,
            'is_visible': isVisible,
          })
          .select('*, playlist_songs(count)')
          .single();
      _playlists.insert(0, Playlist.fromJson(Map<String, dynamic>.from(row)));
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> setVisibility(int id, bool visible) async {
    try {
      final row = await AppSupabase.client
          .from('playlists')
          .update({'is_visible': visible})
          .eq('id', id)
          .select('*, playlist_songs(count)')
          .single();
      final updated = Playlist.fromJson(Map<String, dynamic>.from(row));
      _playlists = _playlists.map((item) => item.id == id ? updated : item).toList();
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }
}
