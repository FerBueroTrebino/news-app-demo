import 'package:equatable/equatable.dart';

import '../../../../../../core/entities/article_entity.dart';

abstract class LocalArticlesState extends Equatable {
  final List<ArticleEntity>? articles;

  const LocalArticlesState({this.articles});

  @override
  List<Object> get props => [articles!];
}

class LocalArticlesLoading extends LocalArticlesState {
  const LocalArticlesLoading();
}

class LocalArticlesDone extends LocalArticlesState {
  const LocalArticlesDone(List<ArticleEntity> articles)
      : super(articles: articles);
}

class LocalArticleSaved extends LocalArticlesDone {
  const LocalArticleSaved(super.articles);
}

class LocalArticleRemoved extends LocalArticlesDone {
  const LocalArticleRemoved(super.articles);
}

class LocalArticlesError extends LocalArticlesState {
  final String message;

  const LocalArticlesError(this.message);

  @override
  List<Object> get props => [message];
}
