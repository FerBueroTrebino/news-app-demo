import '../repository/author_repository.dart';
import '../../../../features/auth/domain/entities/auth_user.dart';

class SyncAuthorOnLoginUseCase {
  SyncAuthorOnLoginUseCase(this._authorRepository);

  final AuthorRepository _authorRepository;

  Future<void> call(AuthUser authUser) {
    return _authorRepository.syncAuthorOnLogin(authUser);
  }
}
