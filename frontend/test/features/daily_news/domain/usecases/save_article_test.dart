import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_article.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late SaveArticleUseCase saveArticleUseCase;
  late MockArticleRepository mockArticleRepository;

  setUp(() {
    mockArticleRepository = MockArticleRepository();
    saveArticleUseCase = SaveArticleUseCase(mockArticleRepository);
  });

  test(
    'should call saveArticle from the repository',
    () async {
      // arrange
      when(() => mockArticleRepository.saveArticle(testArticleEntity))
          .thenAnswer((_) async => Future.value());

      // act
      await saveArticleUseCase(params: testArticleEntity);

      // assert
      verify(() => mockArticleRepository.saveArticle(testArticleEntity))
          .called(1);
      verifyNoMoreInteractions(mockArticleRepository);
    },
  );

  test(
    'should throw an exception when the repository fails to save',
    () async {
      // arrange
      when(() => mockArticleRepository.saveArticle(testArticleEntity))
          .thenThrow(Exception('Database Error'));

      // act & assert
      expect(
        () => saveArticleUseCase(params: testArticleEntity),
        throwsException,
      );
      verify(() => mockArticleRepository.saveArticle(testArticleEntity))
          .called(1);
      verifyNoMoreInteractions(mockArticleRepository);
    },
  );

  test(
    'should throw a TypeError when params are null',
    () async {
      // act & assert
      // The use case uses `params!` which triggers a TypeError (or Null Check Error) when null
      expect(() => saveArticleUseCase(params: null), throwsA(isA<TypeError>()));
      
      verifyZeroInteractions(mockArticleRepository);
    },
  );
}
