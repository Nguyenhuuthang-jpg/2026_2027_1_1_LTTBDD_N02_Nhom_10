import 'package:flutter/foundation.dart';

import '../data/repositories/user_repository.dart';
import '../models/app_user.dart';

/// Danh sách người dùng cho admin + cập nhật hồ sơ cá nhân.
class UserProvider extends ChangeNotifier {
  UserProvider({UserRepository? repository})
      : _repository = repository ?? UserRepository();

  final UserRepository _repository;

  List<AppUser> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AppUser> get users => List.unmodifiable(_users);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadUsers({String? search}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _users = await _repository.fetchUsers(search: search);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleActive(AppUser user) async {
    try {
      final updated = await _repository.setActive(user.id, isActive: !user.isActive);
      _users = _users.map((u) => u.id == updated.id ? updated : u).toList();
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }

  /// Trả về hồ sơ mới, hoặc null nếu lỗi.
  Future<AppUser?> updateProfile(AppUser user) async {
    try {
      final updated = await _repository.updateProfile(user);
      _errorMessage = null;
      return updated;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      return null;
    }
  }
}
