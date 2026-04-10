import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/entities/article_entity.dart';
import '../../../../../core/widgets/snackbar_widget.dart';
import '../../../../../injection_container.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';
import '../../bloc/article/local/local_article_state.dart';
import '../../widgets/article_detail/article_detail_app_bar.dart';
import '../../widgets/article_detail/article_detail_body.dart';
import '../../widgets/article_detail/article_detail_save_button.dart';

class ArticleDetailsView extends StatelessWidget {
  final ArticleEntity? article;

  const ArticleDetailsView({super.key, this.article});

  @override
  Widget build(BuildContext context) {
    final selectedArticle = article;
    if (selectedArticle == null) {
      return const Scaffold(
        body: Center(child: Text('No article available.')),
      );
    }

    return BlocProvider(
      create: (_) => sl<LocalArticleBloc>()..add(const GetSavedArticles()),
      child: Builder(
        builder: (innerContext) {
          return BlocListener<LocalArticleBloc, LocalArticlesState>(
            listener: (context, state) {
              if (state is LocalArticleSaved) {
                ScaffoldMessenger.of(context).showSnackBar(
                  buildSnackBar(
                    'Article saved successfully.',
                    type: AppSnackBarType.success,
                  ),
                );
              } else if (state is LocalArticlesError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  buildSnackBar(
                    'There was an error saving the article.',
                    type: AppSnackBarType.error,
                  ),
                );
              }
            },
            child: Scaffold(
              appBar: ArticleDetailAppBar(
                onBackPressed: () => _onBackButtonTapped(innerContext),
              ),
              body: ArticleDetailBody(article: selectedArticle),
              floatingActionButton:
                  BlocBuilder<LocalArticleBloc, LocalArticlesState>(
                builder: (context, state) {
                  if (state is LocalArticlesLoading) {
                    return const SizedBox.shrink();
                  }

                  final isAlreadySaved = state is LocalArticlesDone &&
                      _isArticleSaved(state.articles ?? [], selectedArticle);

                  if (isAlreadySaved) return const SizedBox.shrink();

                  return ArticleDetailSaveButton(
                    onPressed: () =>
                        _onFloatingActionButtonPressed(innerContext),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _onBackButtonTapped(BuildContext context) {
    Navigator.pop(context);
  }

  void _onFloatingActionButtonPressed(BuildContext context) {
    final selectedArticle = article;
    if (selectedArticle == null) return;

    BlocProvider.of<LocalArticleBloc>(context)
        .add(SaveArticle(selectedArticle));
  }

  bool _isArticleSaved(
      List<ArticleEntity> savedArticles, ArticleEntity article) {
    return savedArticles.any((savedArticle) {
      if (savedArticle.id != null && article.id != null) {
        return savedArticle.id == article.id;
      }

      if (savedArticle.url != null && article.url != null) {
        return savedArticle.url == article.url;
      }

      return false;
    });
  }
}
