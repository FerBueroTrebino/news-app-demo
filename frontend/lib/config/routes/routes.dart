import 'package:flutter/material.dart';

import '../../features/daily_news/domain/entities/article.dart';
import '../../features/daily_news/presentation/pages/article_detail/article_detail.dart';
import '../../features/daily_news/presentation/pages/create_article/create_article.dart';
import '../../features/daily_news/presentation/pages/home/daily_news.dart';
import '../../features/daily_news/presentation/pages/saved_article/saved_article.dart';

enum AppRouteName {
  home,
  articleDetails,
  savedArticles,
  createArticle;

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
        return _materialRoute(const CreateArticle());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
