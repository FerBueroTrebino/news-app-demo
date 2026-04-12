import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/entities/article_news_entity.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/get_articles_news_list.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_entity.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

ArticleEntity _articleNewsToArticleEntity(ArticleNewsEntity e) {
  final published = e.publishedAt ?? e.createdAt;
  return ArticleEntity(
    author: e.authorName,
    title: e.title,
    description: e.description,
    content: e.content,
    url: 'article-news://${e.articleUid}',
    urlToImage: e.thumbnailUrl.isEmpty ? null : e.thumbnailUrl,
    publishedAt: published.toIso8601String(),
  );
}

int _publishedAtSortKey(String? iso) {
  if (iso == null || iso.isEmpty) return 0;
  return DateTime.tryParse(iso)?.millisecondsSinceEpoch ?? 0;
}

List<ArticleEntity> _sortArticlesByPublishedDateDesc(
  List<ArticleEntity> articles,
) {
  final sorted = [...articles];
  sorted.sort(
    (a, b) => _publishedAtSortKey(b.publishedAt)
        .compareTo(_publishedAtSortKey(a.publishedAt)),
  );
  return sorted;
}

class GetArticleUseCase
    implements StreamUseCase<DataState<List<ArticleEntity>>, void> {
  GetArticleUseCase(this._articleRepository, this._articlesNewsListUseCase);

  final ArticleRepository _articleRepository;
  final GetArticlesNewsListUseCase _articlesNewsListUseCase;

  @override
  Stream<DataState<List<ArticleEntity>>> call({void params}) {
    Future<DataState<List<ArticleEntity>>>? remoteFuture;
    Future<DataState<List<ArticleEntity>>> loadRemote() {
      remoteFuture ??= _articleRepository.getNewsArticles();
      return remoteFuture!;
    }

    return _articlesNewsListUseCase().asyncMap(
      (newsList) async {
        final remote = await loadRemote();
        final fromNews = newsList.map(_articleNewsToArticleEntity).toList();
        return switch (remote) {
          DataSuccess(:final data) => DataSuccess(
              _sortArticlesByPublishedDateDesc([...fromNews, ...?data]),
            ),
          DataFailed() when fromNews.isEmpty => remote,
          DataFailed() => DataSuccess(
              _sortArticlesByPublishedDateDesc(fromNews),
            ),
        };
      },
    );
  }
}
