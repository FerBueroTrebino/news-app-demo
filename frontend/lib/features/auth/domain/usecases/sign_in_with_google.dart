import '../entities/auth_user.dart';
import '../repository/auth_repository.dart';

class SignInWithGoogleUseCase {
  final AuthRepository _authRepository;

  SignInWithGoogleUseCase(this._authRepository);

  Future<AuthUser?> call() {
    return _authRepository.signInWithGoogle();
  }
}
