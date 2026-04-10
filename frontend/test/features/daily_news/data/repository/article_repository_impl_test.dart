import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retrofit/retrofit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/error/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late ArticleRepositoryImpl repository;
  late MockNewsApiService mockNewsApiService;
  late MockAppDatabase mockAppDatabase;
  late MockArticleDao mockArticleDao;

  setUp(() {
    mockNewsApiService = MockNewsApiService();
    mockAppDatabase = MockAppDatabase();
    mockArticleDao = MockArticleDao();

    when(() => mockAppDatabase.articleDAO).thenReturn(mockArticleDao);

    repository = ArticleRepositoryImpl(mockNewsApiService, mockAppDatabase);
  });

  setUpAll(() {
    registerFallbackValue(testArticleModel);
  });

  group('getNewsArticles', () {
    test(
      'should return DataSuccess when the response is 200',
      () async {
        // arrange
        final response = Response(
          data: testNewsResponseMap,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );
        final httpResponse = HttpResponse(testNewsResponseModel, response);

        when(() => mockNewsApiService.getNewsArticles(
              apiKey: any(named: 'apiKey'),
              country: any(named: 'country'),
              category: any(named: 'category'),
            )).thenAnswer((_) async => httpResponse);

        // act
        final result = await repository.getNewsArticles();

        // assert
        expect(result, isA<DataSuccess>());
        expect(result.data, testArticleModelList);
      },
    );

    test(
      'should return DataFailed when the response is not 200',
      () async {
        // arrange
        final response = Response(
          data: {'message': 'Not Found'},
          statusCode: 404,
          statusMessage: 'Not Found',
          requestOptions: RequestOptions(path: ''),
        );
        final httpResponse = HttpResponse(testNewsResponseModel, response);

        when(() => mockNewsApiService.getNewsArticles(
              apiKey: any(named: 'apiKey'),
              country: any(named: 'country'),
              category: any(named: 'category'),
            )).thenAnswer((_) async => httpResponse);

        // act
        final result = await repository.getNewsArticles();

        // assert
        expect(result, isA<DataFailed<List<ArticleEntity>>>());
        expect(result.error, isA<ServerFailure>());
        expect(result.error!.message, 'Not Found');
      },
    );

    test(
      'should return DataFailed when a DioException occurs',
      () async {
        // arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: ''),
          error: 'Connection Error',
          message: 'Connection Error',
        );

        when(() => mockNewsApiService.getNewsArticles(
              apiKey: any(named: 'apiKey'),
              country: any(named: 'country'),
              category: any(named: 'category'),
            )).thenThrow(dioException);

        // act
        final result = await repository.getNewsArticles();

        // assert
        expect(result, isA<DataFailed<List<ArticleEntity>>>());
        expect(result.error, isA<ConnectionFailure>());
        expect(result.error!.message, 'Connection Error');
      },
    );
  });

  group('local database operations', () {
    test('should return saved articles from the database', () async {
      // arrange
      when(() => mockArticleDao.getArticles())
          .thenAnswer((_) async => testArticleModelList);

      // act
      final result = await repository.getSavedArticles();

      // assert
      expect(result, testArticleModelList);
      verify(() => mockArticleDao.getArticles()).called(1);
    });

    test('should call insertArticle on the database', () async {
      // arrange
      when(() => mockArticleDao.insertArticle(any()))
          .thenAnswer((_) async => Future.value());

      // act
      await repository.saveArticle(testArticleEntity);

      // assert
      verify(() => mockArticleDao.insertArticle(any())).called(1);
    });

    test('should call deleteArticle on the database', () async {
      // arrange
      when(() => mockArticleDao.deleteArticle(any()))
          .thenAnswer((_) async => Future.value());

      // act
      await repository.removeArticle(testArticleEntity);

      // assert
      verify(() => mockArticleDao.deleteArticle(any())).called(1);
    });
  });
}
