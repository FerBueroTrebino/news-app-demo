import 'package:flutter/material.dart';

import '../../features/daily_news/domain/entities/article_entity.dart';
import '../../features/daily_news/presentation/pages/home/daily_news.dart';
import '../../features/create_article/presentation/pages/edit_article.dart';
import '../../features/create_article/presentation/pages/author_profile.dart';
import '../../features/create_article/domain/entities/article_news_entity.dart';
import '../../features/daily_news/presentation/pages/saved_article/saved_article.dart';
import '../../features/daily_news/presentation/pages/article_detail/article_detail.dart';
import '../../features/create_article/presentation/pages/create_article_auth_wrapper.dart';

enum AppRouteName {
  home,
  articleDetails,
  savedArticles,
  createArticle,
  editArticle,
  authorProfile;

  String get path {
    switch (this) {
      case AppRouteName.home:
        return '/';
      case AppRouteName.articleDetails:
        return '/ArticleDetails';
      case AppRouteName.savedArticles:
        return '/SavedArticles';
      case AppRouteName.createArticle:
        return '/CreateArticle';
      case AppRouteName.editArticle:
        return '/EditArticle';
      case AppRouteName.authorProfile:
        return '/AuthorProfile';
    }
  }

  static AppRouteName fromPath(String? path) {
    return AppRouteName.values.firstWhere(
      (route) => route.path == path,
      orElse: () => AppRouteName.home,
    );
  }
}

class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (AppRouteName.fromPath(settings.name)) {
      case AppRouteName.home:
        return _materialRoute(const DailyNews());
      case AppRouteName.articleDetails:
        return _materialRoute(
            ArticleDetailsView(article: settings.arguments as ArticleEntity));
      case AppRouteName.savedArticles:
        return _materialRoute(const SavedArticles());
      case AppRouteName.createArticle:
        return _materialRoute(const CreateArticleAuthWrapper());
      case AppRouteName.editArticle:
        final article = settings.arguments as ArticleNewsEntity;
        return _materialRoute(EditArticle.route(article: article));
      case AppRouteName.authorProfile:
        return _materialRoute(const AuthorProfile());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
