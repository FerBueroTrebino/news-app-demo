import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/article_news_entity.dart';
import '../../../domain/usecases/delete_article_news.dart';
import '../../../domain/usecases/get_articles_news_of_author.dart';
import '../../../domain/usecases/update_article_news.dart';

part 'author_profile_state.dart';

class AuthorProfileCubit extends Cubit<AuthorProfileState> {
  AuthorProfileCubit(
    this._getArticlesNewsOfAuthorUseCase,
    this._updateArticleNewsUseCase,
    this._deleteArticleNewsUseCase,
  )
      : super(const AuthorProfileState());

  final GetArticlesNewsOfAuthorUseCase _getArticlesNewsOfAuthorUseCase;
  final UpdateArticleNewsUseCase _updateArticleNewsUseCase;
  final DeleteArticleNewsUseCase _deleteArticleNewsUseCase;
  StreamSubscription<List<ArticleNewsEntity>>? _authorArticlesSub;

  void loadAuthorArticles(String authorUid) {
    unawaited(_authorArticlesSub?.cancel());
    _authorArticlesSub = null;

    emit(state.copyWith(
      authorArticlesStatus: AuthorArticlesListStatus.loading,
      clearAuthorArticlesError: true,
    ));

    try {
      final stream = _getArticlesNewsOfAuthorUseCase(params: authorUid);
      _authorArticlesSub = stream.listen(
        (articles) {
          final sorted = [...articles]
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          emit(state.copyWith(
            authorArticlesStatus: AuthorArticlesListStatus.success,
            authorArticles: sorted,
          ));
        },
        onError: (_) {
          emit(state.copyWith(
            authorArticlesStatus: AuthorArticlesListStatus.failure,
            authorArticlesError:
                'Could not load your articles. Please try again.',
          ));
        },
      );
    } catch (_) {
      emit(state.copyWith(
        authorArticlesStatus: AuthorArticlesListStatus.failure,
        authorArticlesError:
            'Could not load your articles. Please try again.',
      ));
    }
  }

  Future<void> publishAuthorArticle(ArticleNewsEntity article) async {
    if (article.status.trim().toLowerCase() == 'published') return;
    emit(state.copyWith(
      publishStatus: AuthorArticlePublishStatus.loading,
      clearPublishError: true,
    ));
    final now = DateTime.now();
    final updated = ArticleNewsEntity(
      articleUid: article.articleUid,
      title: article.title,
      description: article.description,
      content: article.content,
      category: article.category,
      status: 'published',
      thumbnailUrl: article.thumbnailUrl,
      authorUid: article.authorUid,
      authorName: article.authorName,
      createdAt: article.createdAt,
      publishedAt: article.publishedAt ?? now,
      updatedAt: now,
      viewsCount: article.viewsCount,
    );
    try {
      await _updateArticleNewsUseCase(
        params: UpdateArticleNewsParams(article: updated),
      );
      final updatedList = state.authorArticles
          .map((item) => item.articleUid == updated.articleUid ? updated : item)
          .toList();
      emit(state.copyWith(
        authorArticles: updatedList,
        publishStatus: AuthorArticlePublishStatus.success,
      ));
    } catch (_) {
      emit(state.copyWith(
        publishStatus: AuthorArticlePublishStatus.failure,
        publishError: 'Could not publish the article. Please try again.',
      ));
    }
  }

  void acknowledgePublishResult() {
    emit(state.copyWith(
      publishStatus: AuthorArticlePublishStatus.initial,
      clearPublishError: true,
    ));
  }

  void requestEditArticle(ArticleNewsEntity article) {
    emit(state.copyWith(
      editActionStatus: AuthorArticleEditActionStatus.navigate,
      selectedArticleForEdit: article,
    ));
  }

  void acknowledgeEditNavigation() {
    emit(state.copyWith(
      editActionStatus: AuthorArticleEditActionStatus.initial,
      clearSelectedArticleForEdit: true,
    ));
  }

  Future<bool> deleteAuthorArticle(String articleUid) async {
    try {
      await _deleteArticleNewsUseCase(
        params: DeleteArticleNewsParams(articleUid: articleUid),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> close() {
    unawaited(_authorArticlesSub?.cancel());
    return super.close();
  }
}
