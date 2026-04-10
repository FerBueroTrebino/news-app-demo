import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:news_app_clean_architecture/core/error/failure.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/entities/article_entity.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late GetArticleUseCase getArticleUseCase;
  late MockArticleRepository mockArticleRepository;

  setUp(() {
    mockArticleRepository = MockArticleRepository();
    getArticleUseCase = GetArticleUseCase(mockArticleRepository);
  });

  test(
    'should get a list of articles from the repository when successful',
    () async {
      // arrange
      when(() => mockArticleRepository.getNewsArticles())
          .thenAnswer((_) async => DataSuccess(testArticleList));

      // act
      final result = await getArticleUseCase();

      // assert
      expect(result, isA<DataSuccess<List<ArticleEntity>>>());
      expect(result.data, equals(testArticleList));

      verify(() => mockArticleRepository.getNewsArticles()).called(1);
      verifyNoMoreInteractions(mockArticleRepository);
    },
  );

  test(
    'should return an empty list when successful and no articles are found',
    () async {
      // arrange
      when(() => mockArticleRepository.getNewsArticles())
          .thenAnswer((_) async => const DataSuccess(<ArticleEntity>[]));

      // act
      final result = await getArticleUseCase();

      // assert
      expect(result, isA<DataSuccess<List<ArticleEntity>>>());
      expect(result.data, isEmpty);

      verify(() => mockArticleRepository.getNewsArticles()).called(1);
      verifyNoMoreInteractions(mockArticleRepository);
    },
  );

  test(
    'should return a failed data state when the repository fails',
    () async {
      // arrange
      const tFailure = ServerFailure("An unexpected error occurred");
      when(() => mockArticleRepository.getNewsArticles())
          .thenAnswer((_) async => const DataFailed(tFailure));

      // act
      final result = await getArticleUseCase();

      // assert
      expect(result, isA<DataFailed<List<ArticleEntity>>>());
      expect(result.error, equals(tFailure));

      verify(() => mockArticleRepository.getNewsArticles()).called(1);
      verifyNoMoreInteractions(mockArticleRepository);
    },
  );
}
