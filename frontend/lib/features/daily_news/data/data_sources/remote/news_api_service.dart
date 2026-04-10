import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../models/news_response_model.dart';
import '../../../../../core/constants/constants.dart';

part 'news_api_service.g.dart';

@RestApi(baseUrl: newsAPIBaseURL)
abstract class NewsApiService {
  factory NewsApiService(Dio dio) = _NewsApiService;

  @GET('/top-headlines')
  Future<HttpResponse<NewsResponseModel>> getNewsArticles({
    @Query("apiKey") String? apiKey,
    @Query("country") String? country,
    @Query("category") String? category,
  });
}
