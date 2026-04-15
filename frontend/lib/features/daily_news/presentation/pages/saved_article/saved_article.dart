import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:ionicons/ionicons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';

import '../../widgets/article_tile.dart';
import '../../../domain/entities/article_entity.dart';
import '../../../../../config/di/injection_container.dart';
import '../../../../../core/widgets/snackbar_widget.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';
import '../../bloc/article/local/local_article_state.dart';

class SavedArticles extends HookWidget {
  const SavedArticles({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LocalArticleBloc>()..add(const GetSavedArticles()),
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      leading: Builder(
        builder: (context) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onBackButtonTapped(context),
          child: const Icon(Ionicons.chevron_back),
        ),
      ),
      title: Text(
        'Saved Articles',
        style: theme.textTheme.titleLarge,
      ),
    );
  }

  Widget _buildBody() {
    return BlocConsumer<LocalArticleBloc, LocalArticlesState>(
      listener: (context, state) {
        if (state is LocalArticleRemoved) {
          ScaffoldMessenger.of(context).showSnackBar(
            buildSnackBar(
              context,
              'Article removed from saved.',
              type: AppSnackBarType.message,
            ),
          );
        } else if (state is LocalArticlesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            buildSnackBar(
              context,
              state.message,
              type: AppSnackBarType.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is LocalArticlesLoading) {
          return const Center(child: CupertinoActivityIndicator());
        } else if (state is LocalArticlesDone) {
          return _buildArticlesList(context, state.articles!);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildArticlesList(BuildContext context, List<ArticleEntity> articles) {
    final theme = Theme.of(context);

    if (articles.isEmpty) {
      return Center(
        child: Text(
          'NO SAVED ARTICLES',
          style: theme.textTheme.titleSmall,
        ),
      );
    }

    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        return ArticleWidget(
          article: articles[index],
          isRemovable: true,
          onRemove: (article) => _onRemoveArticle(context, article),
          onArticlePressed: (article) => _onArticlePressed(context, article),
        );
      },
    );
  }

  void _onBackButtonTapped(BuildContext context) {
    Navigator.pop(context);
  }

  void _onRemoveArticle(BuildContext context, ArticleEntity article) {
    BlocProvider.of<LocalArticleBloc>(context).add(RemoveArticle(article));
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(
      context,
      AppRouteName.articleDetails.path,
      arguments: article,
    );
  }
}
