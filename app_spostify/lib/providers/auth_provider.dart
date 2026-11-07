import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/remote/auth_remote.dart';
import '../data/repositories/auth_repository.dart';
import '../models/app_user.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repository, AuthRemote? remote})
      : _remote = remote ?? AuthRemote(),
        _repository = repository ?? AuthRepository(remote: remote ?? AuthRemote());

  final AuthRepository _repository;
  final AuthRemote _remote;
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
    _authSubscription ??= _remote.authStateChanges.listen((state) async {
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
    final message = error.toString().replaceFirst('Exception: ', '');
    return message.replaceFirst('AuthException(message: ', '').replaceAll(')', '');
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
