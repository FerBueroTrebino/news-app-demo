import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/article_entity.dart';
import '../../../../../core/widgets/snackbar_widget.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article_reader/article_reader_cubit.dart';
import '../../../../../config/di/injection_container.dart';
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

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<LocalArticleBloc>()..add(const GetSavedArticles()),
        ),
        BlocProvider(
          create: (_) => sl<ArticleReaderCubit>(),
        ),
      ],
      child: Builder(
        builder: (innerContext) => MultiBlocListener(
          listeners: [
            BlocListener<LocalArticleBloc, LocalArticlesState>(
              listener: (context, state) {
                if (state is LocalArticleSaved) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    buildSnackBar(
                      context,
                      'Article saved successfully.',
                      type: AppSnackBarType.success,
                    ),
                  );
                } else if (state is LocalArticlesError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    buildSnackBar(
                      context,
                      'There was an error saving the article.',
                      type: AppSnackBarType.error,
                    ),
                  );
                }
              },
            ),
            BlocListener<ArticleReaderCubit, ArticleReaderState>(
              listenWhen: (previous, current) =>
                  previous.errorMessage != current.errorMessage &&
                  current.errorMessage != null,
              listener: (context, state) {
                ScaffoldMessenger.of(context).showSnackBar(
                  buildSnackBar(
                    context,
                    state.errorMessage!,
                    type: AppSnackBarType.error,
                  ),
                );
                context.read<ArticleReaderCubit>().acknowledgeError();
              },
            ),
          ],
          child: PopScope(
            onPopInvokedWithResult: (_, __) {
              innerContext.read<ArticleReaderCubit>().stopReading();
            },
            child: BlocBuilder<ArticleReaderCubit, ArticleReaderState>(
              builder: (context, readerState) {
                return Scaffold(
                  appBar: ArticleDetailAppBar(
                    onBackPressed: () => _onBackButtonTapped(innerContext),
                    isReading: readerState.isReading,
                    onReadTogglePressed: () =>
                        _onReadTogglePressed(innerContext),
                  ),
                  body: ArticleDetailBody(
                    article: selectedArticle,
                  ),
                  floatingActionButton:
                      BlocBuilder<LocalArticleBloc, LocalArticlesState>(
                    builder: (context, state) {
                      if (state is LocalArticlesLoading) {
                        return const SizedBox.shrink();
                      }

                      final isAlreadySaved = state is LocalArticlesDone &&
                          _isArticleSaved(
                              state.articles ?? [], selectedArticle);

                      if (isAlreadySaved) return const SizedBox.shrink();

                      return ArticleDetailSaveButton(
                        onPressed: () =>
                            _onFloatingActionButtonPressed(innerContext),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _onBackButtonTapped(BuildContext context) {
    context.read<ArticleReaderCubit>().stopReading();
    Navigator.pop(context);
  }

  void _onFloatingActionButtonPressed(BuildContext context) {
    final selectedArticle = article;
    if (selectedArticle == null) return;

    BlocProvider.of<LocalArticleBloc>(context)
        .add(SaveArticle(selectedArticle));
  }

  Future<void> _onReadTogglePressed(BuildContext context) async {
    final selectedArticle = article;
    if (selectedArticle == null) return;
    await context.read<ArticleReaderCubit>().toggleRead(selectedArticle);
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
