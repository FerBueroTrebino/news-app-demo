import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';

import '../../domain/repository/author_repository.dart';
import '../data_sources/firestore_authors_service.dart';

class AuthorRepositoryImpl implements AuthorRepository {
  AuthorRepositoryImpl(this._firestoreAuthorsService);

  final FirestoreAuthorsService _firestoreAuthorsService;

  @override
  Future<void> syncAuthorOnLogin(AuthUser authUser) {
    return _firestoreAuthorsService.syncAuthorOnLogin(authUser);
  }
}
