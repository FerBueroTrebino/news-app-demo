import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/sync_author_on_login.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late SyncAuthorOnLoginUseCase useCase;
  late MockAuthorRepository mockAuthorRepository;

  setUp(() {
    mockAuthorRepository = MockAuthorRepository();
    useCase = SyncAuthorOnLoginUseCase(mockAuthorRepository);
  });

  test('delegates to AuthorRepository', () async {
    const user = AuthUser(uid: 'u1', email: 'a@b.com');
    when(() => mockAuthorRepository.syncAuthorOnLogin(user))
        .thenAnswer((_) async {});

    await useCase(user);

    verify(() => mockAuthorRepository.syncAuthorOnLogin(user)).called(1);
  });

  test('rethrows exceptions from the repository', () async {
    const user = AuthUser(uid: 'u1');
    when(() => mockAuthorRepository.syncAuthorOnLogin(user))
        .thenThrow(Exception('network'));

    expect(() => useCase(user), throwsException);
    verify(() => mockAuthorRepository.syncAuthorOnLogin(user)).called(1);
  });
}
