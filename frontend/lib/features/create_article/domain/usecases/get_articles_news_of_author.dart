import '../entities/article_news_entity.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/article_news_repository.dart';

class GetArticlesNewsOfAuthorUseCase
    implements StreamUseCase<List<ArticleNewsEntity>, String> {
  GetArticlesNewsOfAuthorUseCase(this._repository);

  final ArticleNewsRepository _repository;

  @override
  Stream<List<ArticleNewsEntity>> call({String? params}) {
    final authorUid = params;

    if (authorUid == null || authorUid.isEmpty) {
      throw ArgumentError.value(authorUid, 'params', 'authorUid is required');
    }

    return _repository.watchArticlesNewsOfAuthor(authorUid);
  }
}
