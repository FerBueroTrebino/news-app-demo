import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser?> getCurrentUser();
  Future<AuthUser?> signInWithGoogle();
  Future<void> signOut();
}
