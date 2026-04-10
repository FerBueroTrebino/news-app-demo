import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/remove_article.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late RemoveArticleUseCase removeArticleUseCase;
  late MockArticleRepository mockArticleRepository;

  setUp(() {
    mockArticleRepository = MockArticleRepository();
    removeArticleUseCase = RemoveArticleUseCase(mockArticleRepository);
  });

  test(
    'should call removeArticle from the repository',
    () async {
      // arrange
      when(() => mockArticleRepository.removeArticle(testArticleEntity))
          .thenAnswer((_) async => Future.value());

      // act
      await removeArticleUseCase(params: testArticleEntity);

      // assert
      verify(() => mockArticleRepository.removeArticle(testArticleEntity))
          .called(1);
      verifyNoMoreInteractions(mockArticleRepository);
    },
  );

  test(
    'should throw an exception when the repository fails to remove',
    () async {
      // arrange
      when(() => mockArticleRepository.removeArticle(testArticleEntity))
          .thenThrow(Exception('Database Error'));

      // act & assert
      expect(
        () => removeArticleUseCase(params: testArticleEntity),
        throwsException,
      );
      verify(() => mockArticleRepository.removeArticle(testArticleEntity))
          .called(1);
      verifyNoMoreInteractions(mockArticleRepository);
    },
  );

  test(
    'should throw a TypeError when params are null',
    () async {
      // act & assert
      expect(
        () => removeArticleUseCase(params: null),
        throwsA(isA<TypeError>()),
      );
      verifyZeroInteractions(mockArticleRepository);
    },
  );
}
