import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/enums/news_category.dart';

class ArticleNewsEntity extends Equatable {
  static final List<String> allowedCategories =
      NewsCategory.values.map((category) => category.apiValue).toList();

  static const List<String> allowedStatuses = [
    'draft',
    'published',
    'archived',
  ];

  final String articleUid;
  final String title;
  final String description;
  final String content;
  final String category;
  final String status;
  final String thumbnailUrl;
  final String authorUid;
  final String authorName;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final DateTime updatedAt;
  final int viewsCount;

  ArticleNewsEntity copyWith({String? thumbnailUrl}) {
    return ArticleNewsEntity(
      articleUid: articleUid,
      title: title,
      description: description,
      content: content,
      category: category,
      status: status,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      authorUid: authorUid,
      authorName: authorName,
      createdAt: createdAt,
      publishedAt: publishedAt,
      updatedAt: updatedAt,
      viewsCount: viewsCount,
    );
  }

  const ArticleNewsEntity({
    required this.articleUid,
    required this.title,
    required this.description,
    required this.content,
    required this.category,
    required this.status,
    required this.thumbnailUrl,
    required this.authorUid,
    required this.authorName,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
    this.viewsCount = 0,
  });

  @override
  List<Object?> get props => [
        articleUid,
        title,
        description,
        content,
        category,
        status,
        thumbnailUrl,
        authorUid,
        authorName,
        createdAt,
        publishedAt,
        updatedAt,
        viewsCount,
      ];
}
