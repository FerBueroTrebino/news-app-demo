import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';

import '../../widgets/article_tile.dart';
import '../../../domain/entities/article.dart';
import '../../../../../core/widgets/snackbar_widget.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildPage();
  }

  AppBar _buildAppbar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Daily News',
        style: TextStyle(color: Colors.black),
      ),
      actions: [
        GestureDetector(
          onTap: () => _onShowSavedArticlesViewTapped(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.bookmark, color: Colors.black),
          ),
        ),
      ],
    );
  }

  BlocConsumer<RemoteArticlesBloc, RemoteArticlesState> _buildPage() {
    return BlocConsumer<RemoteArticlesBloc, RemoteArticlesState>(
      listener: (context, state) {
        if (state is RemoteArticlesError && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            buildSnackBar(
              state.error?.message ?? 'An unknown error occurred.',
              type: AppSnackBarType.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is RemoteArticlesLoading) {
          return Scaffold(
              appBar: _buildAppbar(context),
              body: const Center(child: CupertinoActivityIndicator()));
        }
        if (state is RemoteArticlesError) {
          return Scaffold(
              appBar: _buildAppbar(context),
              body: const Center(child: Icon(Icons.refresh)));
        }
        if (state is RemoteArticlesDone) {
          return _buildArticlesPage(context, state.articles!);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildArticlesPage(
      BuildContext context, List<ArticleEntity> articles) {
    return Scaffold(
      appBar: _buildAppbar(context),
      body: ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return ArticleWidget(
            article: article,
            onArticlePressed: (article) => _onArticlePressed(context, article),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRouteName.createArticle.path);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(
      context,
      AppRouteName.articleDetails.path,
      arguments: article,
    );
  }

  void _onShowSavedArticlesViewTapped(BuildContext context) {
    Navigator.pushNamed(context, AppRouteName.savedArticles.path);
  }
}
