import '../entities/auth_user.dart';
import '../repository/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  Future<AuthUser?> call() {
    return _authRepository.getCurrentUser();
  }
}
