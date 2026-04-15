import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widgets/article_tile.dart';
import '../../../../../config/routes/routes.dart';
import '../../../../../core/enums/news_category.dart';
import '../../../domain/entities/article_entity.dart';
import '../../../../../core/widgets/snackbar_widget.dart';
import '../../bloc/article/remote/remote_article_event.dart';
import '../../bloc/article/remote/remote_article_bloc.dart';
import '../../bloc/article/remote/remote_article_state.dart';

class DailyNews extends StatefulWidget {
  const DailyNews({super.key});

  @override
  State<DailyNews> createState() => _DailyNewsState();
}

class _DailyNewsState extends State<DailyNews> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  NewsCategory _selectedCategory = NewsCategory.general;
  static const List<NewsCategory> _categories = NewsCategory.values;

  @override
  Widget build(BuildContext context) => _buildPage();

  AppBar _buildAppbar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Daily News',
        style: TextStyle(color: Colors.black),
      ),
      actions: [
        IconButton(
          onPressed: _openCategoryDrawer,
          icon: const Icon(Icons.menu, color: Colors.black),
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
            key: _scaffoldKey,
            appBar: _buildAppbar(context),
            endDrawer: _buildCategoryDrawer(context),
            body: const Center(child: CupertinoActivityIndicator()),
          );
        }
        if (state is RemoteArticlesError) {
          return Scaffold(
            key: _scaffoldKey,
            appBar: _buildAppbar(context),
            endDrawer: _buildCategoryDrawer(context),
            body: const Center(child: Icon(Icons.refresh)),
          );
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
      key: _scaffoldKey,
      appBar: _buildAppbar(context),
      endDrawer: _buildCategoryDrawer(context),
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

  Drawer _buildCategoryDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.bookmark_border),
            title: const Text(
              'Saved Articles',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              _onShowSavedArticlesViewTapped(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.newspaper),
            title: const Text(
              'News Categories',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ..._categories.map(
            (category) => ListTile(
              title: Text(category.displayName),
              trailing: _selectedCategory == category
                  ? const Icon(Icons.check)
                  : null,
              onTap: () => _onCategorySelected(context, category),
            ),
          ),
        ],
      ),
    );
  }

  void _onCategorySelected(BuildContext context, NewsCategory category) {
    Navigator.pop(context);
    if (_selectedCategory == category) return;

    setState(() {
      _selectedCategory = category;
    });
    context
        .read<RemoteArticlesBloc>()
        .add(GetArticles(category: category.apiValue));
  }

  void _openCategoryDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }
}
