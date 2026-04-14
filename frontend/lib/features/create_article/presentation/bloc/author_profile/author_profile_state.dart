part of 'author_profile_cubit.dart';

enum AuthorArticlesListStatus { initial, loading, success, failure }
enum AuthorArticlePublishStatus { initial, loading, success, failure }
enum AuthorArticleEditActionStatus { initial, navigate }

class AuthorProfileState extends Equatable {
  const AuthorProfileState({
    this.authorArticlesStatus = AuthorArticlesListStatus.initial,
    this.authorArticles = const [],
    this.authorArticlesError,
    this.publishStatus = AuthorArticlePublishStatus.initial,
    this.publishError,
    this.editActionStatus = AuthorArticleEditActionStatus.initial,
    this.selectedArticleForEdit,
  });

  final AuthorArticlesListStatus authorArticlesStatus;
  final List<ArticleNewsEntity> authorArticles;
  final String? authorArticlesError;
  final AuthorArticlePublishStatus publishStatus;
  final String? publishError;
  final AuthorArticleEditActionStatus editActionStatus;
  final ArticleNewsEntity? selectedArticleForEdit;

  AuthorProfileState copyWith({
    AuthorArticlesListStatus? authorArticlesStatus,
    List<ArticleNewsEntity>? authorArticles,
    String? authorArticlesError,
    AuthorArticlePublishStatus? publishStatus,
    String? publishError,
    AuthorArticleEditActionStatus? editActionStatus,
    ArticleNewsEntity? selectedArticleForEdit,
    bool clearAuthorArticlesError = false,
    bool clearPublishError = false,
    bool clearSelectedArticleForEdit = false,
  }) {
    return AuthorProfileState(
      authorArticlesStatus:
          authorArticlesStatus ?? this.authorArticlesStatus,
      authorArticles: authorArticles ?? this.authorArticles,
      authorArticlesError: clearAuthorArticlesError
          ? null
          : (authorArticlesError ?? this.authorArticlesError),
      publishStatus: publishStatus ?? this.publishStatus,
      publishError: clearPublishError ? null : (publishError ?? this.publishError),
      editActionStatus: editActionStatus ?? this.editActionStatus,
      selectedArticleForEdit: clearSelectedArticleForEdit
          ? null
          : (selectedArticleForEdit ?? this.selectedArticleForEdit),
    );
  }

  @override
  List<Object?> get props =>
      [
        authorArticlesStatus,
        authorArticles,
        authorArticlesError,
        publishStatus,
        publishError,
        editActionStatus,
        selectedArticleForEdit,
      ];
}
