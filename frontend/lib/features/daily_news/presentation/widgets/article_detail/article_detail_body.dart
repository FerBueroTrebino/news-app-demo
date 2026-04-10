import 'package:flutter/material.dart';

import '../../../domain/entities/article.dart';
import 'article_detail_content.dart';
import 'article_detail_header.dart';
import 'article_detail_image.dart';

class ArticleDetailBody extends StatelessWidget {
  final ArticleEntity article;

  const ArticleDetailBody({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ArticleDetailHeader(
            title: article.title,
            publishedAt: article.publishedAt,
          ),
          ArticleDetailImage(imageUrl: article.urlToImage),
          ArticleDetailContent(
            description: article.description,
            content: article.content,
          ),
        ],
      ),
    );
  }
}
