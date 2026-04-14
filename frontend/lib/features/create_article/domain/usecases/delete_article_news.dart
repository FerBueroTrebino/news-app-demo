import '../../../../core/usecase/usecase.dart';
import '../repository/article_news_repository.dart';

class DeleteArticleNewsUseCase
    implements UseCase<void, DeleteArticleNewsParams> {
  DeleteArticleNewsUseCase(this._repository);

  final ArticleNewsRepository _repository;

  @override
  Future<void> call({DeleteArticleNewsParams? params}) {
    final p = params!;
    return _repository.deleteArticle(p.articleUid);
  }
}

class DeleteArticleNewsParams {
  const DeleteArticleNewsParams({
    required this.articleUid,
  });

  final String articleUid;
}
