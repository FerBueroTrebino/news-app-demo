import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';

import '../../../../../helpers/test_helper.dart';

void main() {
  late NewsApiService newsApiService;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    when(() => mockDio.options).thenReturn(BaseOptions());
    newsApiService = NewsApiService(mockDio);
    registerFallbackValue(RequestOptions(path: ''));
  });

  group('getNewsArticles', () {
    test(
      'should return NewsResponseModel when the response code is 200',
      () async {
        // arrange
        when(() => mockDio.fetch<Map<String, dynamic>>(any())).thenAnswer(
          (_) async => Response(
            data: testNewsResponseMap,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // act
        final result = await newsApiService.getNewsArticles(
          apiKey: 'apiKey',
          country: 'country',
          category: 'category',
        );

        // assert
        expect(result.data.status, testNewsResponseModel.status);
        expect(result.data.totalResults, testNewsResponseModel.totalResults);
      },
    );

    test(
      'should return HttpResponse with 404 status code when the response code is not 200',
      () async {
        // arrange
        when(() => mockDio.fetch<Map<String, dynamic>>(any())).thenAnswer(
          (_) async => Response(
            data: {'message': 'Not Found'},
            statusCode: 404,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // act
        final result = await newsApiService.getNewsArticles(
          apiKey: 'apiKey',
          country: 'country',
          category: 'category',
        );

        // assert
        expect(result.response.statusCode, 404);
      },
    );
  });
}
