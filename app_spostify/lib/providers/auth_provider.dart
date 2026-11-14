import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthException, PostgrestException;

import '../data/repositories/auth_repository.dart';
import '../models/app_user.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;
  StreamSubscription? _authSubscription;

  AppUser? _user;
  bool _isInitializing = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _infoMessage;

  AppUser? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isInitializing => _isInitializing;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get infoMessage => _infoMessage;

  Future<void> initialize() async {
    _authSubscription ??= _repository.authStateChanges.listen((state) async {
      if (state.session == null) {
        _user = null;
      } else {
        try {
          _user = await _repository.restoreSession();
        } catch (_) {
          _user = null;
        }
      }
      _isInitializing = false;
      notifyListeners();
    }, onError: (Object error, StackTrace stackTrace) {
      _errorMessage = _friendlyError(error);
      _isInitializing = false;
      notifyListeners();
    });
    try {
      _user = await _repository.restoreSession();
    } catch (error) {
      _errorMessage = _friendlyError(error);
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    _beginRequest();
    try {
      _user = await _repository.signIn(email: email, password: password);
      _errorMessage = null;
      return true;
    } catch (error) {
      _errorMessage = _friendlyError(error);
      return false;
    } finally {
      _endRequest();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _beginRequest();
    try {
      final hasSession = await _repository.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      _infoMessage = hasSession
          ? 'Đăng ký thành công.'
          : 'Đăng ký thành công. Vui lòng kiểm tra email để xác nhận tài khoản.';
      _errorMessage = null;
      if (hasSession) _user = await _repository.restoreSession();
      return true;
    } catch (error) {
      _errorMessage = _friendlyError(error);
      return false;
    } finally {
      _endRequest();
    }
  }

  Future<void> signOut() async {
    _beginRequest();
    try {
      await _repository.signOut();
      _user = null;
      _errorMessage = null;
    } catch (error) {
      _errorMessage = _friendlyError(error);
    } finally {
      _endRequest();
    }
  }

  void updateLocalUser(AppUser user) {
    if (_user?.id != user.id) return;
    _user = user;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();
  }

  void _beginRequest() {
    _isLoading = true;
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();
  }

  void _endRequest() {
    _isLoading = false;
    notifyListeners();
  }

  String _friendlyError(Object error) {
    if (error is AuthException) {
      final msg = error.message.toLowerCase();
      if (msg.contains('invalid login credentials')) return 'Sai email hoặc mật khẩu.';
      if (msg.contains('email not confirmed')) {
        return 'Email chưa được xác nhận. Vui lòng kiểm tra hộp thư.';
      }
      if (msg.contains('already registered')) return 'Email này đã được dùng.';
      return error.message;
    }
    if (error is PostgrestException) {
      if (error.code == 'PGRST116') {
        return 'Không tìm thấy hồ sơ người dùng. Hãy kiểm tra bảng profiles trên Supabase.';
      }
      if (error.code == '42P01' || error.code == 'PGRST205') {
        return 'Database chưa được khởi tạo. Hãy chạy database/schema.sql trên Supabase.';
      }
      return error.message;
    }
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
