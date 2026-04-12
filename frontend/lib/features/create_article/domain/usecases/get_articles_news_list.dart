import '../entities/article_news_entity.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/article_news_repository.dart';

class GetArticlesNewsListUseCase
    implements StreamUseCase<List<ArticleNewsEntity>, void> {
  GetArticlesNewsListUseCase(this._repository);

  final ArticleNewsRepository _repository;

  @override
  Stream<List<ArticleNewsEntity>> call({void params}) {
    return _repository.watchPublishedArticlesNewsList();
  }
}
