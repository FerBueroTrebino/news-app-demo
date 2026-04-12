import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_helper.dart';
import 'package:news_app_clean_architecture/features/create_article/data/repository/author_repository_impl.dart';

void main() {
  late AuthorRepositoryImpl repository;
  late MockFirestoreAuthorsService mockFirestoreAuthorsService;

  setUp(() {
    mockFirestoreAuthorsService = MockFirestoreAuthorsService();
    repository = AuthorRepositoryImpl(mockFirestoreAuthorsService);
  });

  test('syncAuthorOnLogin delegates to FirestoreAuthorsService', () async {
    when(() => mockFirestoreAuthorsService.syncAuthorOnLogin(testAuthUser))
        .thenAnswer((_) async {});

    await repository.syncAuthorOnLogin(testAuthUser);

    verify(() => mockFirestoreAuthorsService.syncAuthorOnLogin(testAuthUser))
        .called(1);
  });
}
