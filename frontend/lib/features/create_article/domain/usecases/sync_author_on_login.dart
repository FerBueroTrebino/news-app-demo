import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';

import '../repository/author_repository.dart';

class SyncAuthorOnLoginUseCase {
  SyncAuthorOnLoginUseCase(this._authorRepository);

  final AuthorRepository _authorRepository;

  Future<void> call(AuthUser authUser) {
    return _authorRepository.syncAuthorOnLogin(authUser);
  }
}
