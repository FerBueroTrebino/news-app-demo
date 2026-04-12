import '../../domain/repository/author_repository.dart';
import '../data_sources/firestore_authors_service.dart';
import '../../../../features/auth/domain/entities/auth_user.dart';

class AuthorRepositoryImpl implements AuthorRepository {
  AuthorRepositoryImpl(this._firestoreAuthorsService);

  final FirestoreAuthorsService _firestoreAuthorsService;

  @override
  Future<void> syncAuthorOnLogin(AuthUser authUser) {
    return _firestoreAuthorsService.syncAuthorOnLogin(authUser);
  }
}
