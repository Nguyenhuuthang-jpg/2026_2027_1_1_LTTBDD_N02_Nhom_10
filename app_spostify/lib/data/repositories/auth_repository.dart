import 'package:supabase_flutter/supabase_flutter.dart' show AuthState;

import '../../models/app_user.dart';
import '../remote/auth_remote.dart';

class AuthRepository {
  AuthRepository({AuthRemote? remote}) : _remote = remote ?? AuthRemote();

  final AuthRemote _remote;

  Stream<AuthState> get authStateChanges => _remote.authStateChanges;

  Future<AppUser?> restoreSession() => _remote.getCurrentProfile();

  Future<AppUser> signIn({required String email, required String password}) =>
      _remote.signIn(email: email, password: password);

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) =>
      _remote.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );

  Future<void> signOut() => _remote.signOut();
}
