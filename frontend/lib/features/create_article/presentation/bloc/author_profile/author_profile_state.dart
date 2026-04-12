part of 'author_profile_cubit.dart';

enum AuthorArticlesListStatus { initial, loading, success, failure }

class AuthorProfileState extends Equatable {
  const AuthorProfileState({
    this.authorArticlesStatus = AuthorArticlesListStatus.initial,
    this.authorArticles = const [],
    this.authorArticlesError,
  });

  final AuthorArticlesListStatus authorArticlesStatus;
  final List<ArticleNewsEntity> authorArticles;
  final String? authorArticlesError;

  AuthorProfileState copyWith({
    AuthorArticlesListStatus? authorArticlesStatus,
    List<ArticleNewsEntity>? authorArticles,
    String? authorArticlesError,
    bool clearAuthorArticlesError = false,
  }) {
    return AuthorProfileState(
      authorArticlesStatus:
          authorArticlesStatus ?? this.authorArticlesStatus,
      authorArticles: authorArticles ?? this.authorArticles,
      authorArticlesError: clearAuthorArticlesError
          ? null
          : (authorArticlesError ?? this.authorArticlesError),
    );
  }

  @override
  List<Object?> get props =>
      [authorArticlesStatus, authorArticles, authorArticlesError];
}
