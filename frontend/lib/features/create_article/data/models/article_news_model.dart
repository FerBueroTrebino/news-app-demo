import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/article_news_entity.dart';

class ArticleNewsModel extends Equatable {
  const ArticleNewsModel({
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

  final String articleUid;
  final String title;
  final String description;
  final String content;
  final String category;
  final String status;
  final String thumbnailUrl;
  final String authorUid;
  final String authorName;
  final DateTime? createdAt;
  final DateTime? publishedAt;
  final DateTime? updatedAt;
  final int viewsCount;

  factory ArticleNewsModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw StateError('Article document ${snapshot.id} has no data');
    }
    return ArticleNewsModel.fromMap(data, documentId: snapshot.id);
  }

  factory ArticleNewsModel.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    final articleUid = (map['articleUid'] as String?) ?? documentId ?? '';
    return ArticleNewsModel(
      articleUid: articleUid,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      content: map['content'] as String? ?? '',
      category: map['category'] as String? ?? '',
      status: map['status'] as String? ?? '',
      thumbnailUrl: (map['thumbnailUrl'] as String?)?.isNotEmpty == true
          ? map['thumbnailUrl'] as String
          : (map['thumbnailPath'] as String? ?? ''),
      authorUid: map['authorUid'] as String? ?? '',
      authorName: map['authorName'] as String? ?? '',
      createdAt: _timestampToDateTime(map['createdAt']),
      publishedAt: _timestampToDateTime(map['publishedAt']),
      updatedAt: _timestampToDateTime(map['updatedAt']),
      viewsCount: (map['viewsCount'] as num?)?.toInt() ?? 0,
    );
  }

  factory ArticleNewsModel.fromEntity(ArticleNewsEntity entity) {
    return ArticleNewsModel(
      articleUid: entity.articleUid,
      title: entity.title,
      description: entity.description,
      content: entity.content,
      category: entity.category,
      status: entity.status,
      thumbnailUrl: entity.thumbnailUrl,
      authorUid: entity.authorUid,
      authorName: entity.authorName,
      createdAt: entity.createdAt,
      publishedAt: entity.publishedAt,
      updatedAt: entity.updatedAt,
      viewsCount: entity.viewsCount,
    );
  }

  Map<String, dynamic> toFirestoreCreateMap() {
    return {
      'articleUid': articleUid,
      'title': title,
      'description': description,
      'content': content,
      'category': category,
      'status': status,
      'thumbnailUrl': thumbnailUrl,
      'authorUid': authorUid,
      'authorName': authorName,
      'createdAt': FieldValue.serverTimestamp(),
      'publishedAt':
          publishedAt != null ? Timestamp.fromDate(publishedAt!) : null,
      'updatedAt': FieldValue.serverTimestamp(),
      'viewsCount': viewsCount,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'articleUid': articleUid,
      'title': title,
      'description': description,
      'content': content,
      'category': category,
      'status': status,
      'thumbnailUrl': thumbnailUrl,
      'authorUid': authorUid,
      'authorName': authorName,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'publishedAt':
          publishedAt != null ? Timestamp.fromDate(publishedAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'viewsCount': viewsCount,
    };
  }

  static Map<String, dynamic> withServerUpdatedAt(
    Map<String, dynamic> fields,
  ) {
    return {
      ...fields,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  ArticleNewsEntity toEntity() {
    final fallback = DateTime.fromMillisecondsSinceEpoch(0);
    return ArticleNewsEntity(
      articleUid: articleUid,
      title: title,
      description: description,
      content: content,
      category: category,
      status: status,
      thumbnailUrl: thumbnailUrl,
      authorUid: authorUid,
      authorName: authorName,
      createdAt: createdAt ?? fallback,
      publishedAt: publishedAt,
      updatedAt: updatedAt ?? fallback,
      viewsCount: viewsCount,
    );
  }

  static DateTime? _timestampToDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

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
