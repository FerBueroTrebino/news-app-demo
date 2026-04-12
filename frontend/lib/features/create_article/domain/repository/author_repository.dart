import '../../../../features/auth/domain/entities/auth_user.dart';

abstract class AuthorRepository {
  Future<void> syncAuthorOnLogin(AuthUser authUser);
}
