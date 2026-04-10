import '../../../../../features/auth/domain/entities/auth_user.dart';
import '../../../../../features/auth/domain/repository/auth_repository.dart';
import '../../../../../features/auth/data/data_sources/firebase_auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _firebaseAuthService;

  AuthRepositoryImpl(this._firebaseAuthService);

  @override
  Future<AuthUser?> getCurrentUser() {
    return _firebaseAuthService.getCurrentUser();
  }

  @override
  Future<AuthUser?> signInWithGoogle() {
    return _firebaseAuthService.signInWithGoogle();
  }

  @override
  Future<void> signOut() {
    return _firebaseAuthService.signOut();
  }
}
