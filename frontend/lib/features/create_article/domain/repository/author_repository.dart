import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';

abstract class AuthorRepository {
  Future<void> syncAuthorOnLogin(AuthUser authUser);
}
