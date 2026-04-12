import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/article_news_entity.dart';
import '../../../domain/usecases/get_articles_news_of_author.dart';

part 'author_profile_state.dart';

class AuthorProfileCubit extends Cubit<AuthorProfileState> {
  AuthorProfileCubit(this._getArticlesNewsOfAuthorUseCase)
      : super(const AuthorProfileState());

  final GetArticlesNewsOfAuthorUseCase _getArticlesNewsOfAuthorUseCase;
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

  @override
  Future<void> close() {
    unawaited(_authorArticlesSub?.cancel());
    return super.close();
  }
}
