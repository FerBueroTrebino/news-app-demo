import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_saved_article.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late GetSavedArticleUseCase getSavedArticleUseCase;
  late MockArticleRepository mockArticleRepository;

  setUp(() {
    mockArticleRepository = MockArticleRepository();
    getSavedArticleUseCase = GetSavedArticleUseCase(mockArticleRepository);
  });

  test(
    'should get saved articles from the repository when articles exist',
    () async {
      // arrange
      when(() => mockArticleRepository.getSavedArticles())
          .thenAnswer((_) async => testArticleList);

      // act
      final result = await getSavedArticleUseCase();

      // assert
      expect(result, equals(testArticleList));
      verify(() => mockArticleRepository.getSavedArticles()).called(1);
      verifyNoMoreInteractions(mockArticleRepository);
    },
  );

  test(
    'should return an empty list when no articles are saved',
    () async {
      // arrange
      when(() => mockArticleRepository.getSavedArticles())
          .thenAnswer((_) async => []);

      // act
      final result = await getSavedArticleUseCase();

      // assert
      expect(result, isEmpty);
      verify(() => mockArticleRepository.getSavedArticles()).called(1);
      verifyNoMoreInteractions(mockArticleRepository);
    },
  );

  test(
    'should throw an exception when the repository fails to fetch saved articles',
    () async {
      // arrange
      when(() => mockArticleRepository.getSavedArticles())
          .thenThrow(Exception('Database Error'));

      // act & assert
      expect(() => getSavedArticleUseCase(), throwsException);
      verify(() => mockArticleRepository.getSavedArticles()).called(1);
      verifyNoMoreInteractions(mockArticleRepository);
    },
  );
}
