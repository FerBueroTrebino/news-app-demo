import 'dart:async';

import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_entity.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_reader.dart';

class ReadArticleParams {
  const ReadArticleParams({required this.article});

  final ArticleEntity article;
}

class ReadArticleUseCase implements UseCase<void, ReadArticleParams> {
  ReadArticleUseCase(this._articleReader);

  final ArticleReader _articleReader;
  int _sessionId = 0;

  @override
  Future<void> call({ReadArticleParams? params}) async {
    final sessionId = ++_sessionId;
    final article = params?.article;
    if (article == null) return;

    final parts = <String>[
      article.title?.trim() ?? '',
      article.description?.trim() ?? '',
      _sanitizeContent(article.content),
    ].where((part) => part.isNotEmpty).toList();

    if (parts.isEmpty) return;

    await _articleReader.prepare();
    await _articleReader.stop();
    for (var i = 0; i < parts.length; i++) {
      if (_isSessionCancelled(sessionId)) return;
      await _articleReader.speak(parts[i]);
      if (_isSessionCancelled(sessionId)) return;
      if (i < parts.length - 1) {
        await Future<void>.delayed(const Duration(seconds: 1));
        if (_isSessionCancelled(sessionId)) return;
      }
    }
  }

  Future<void> stop() async {
    _sessionId++;
    await _articleReader.stop();
  }

  String _sanitizeContent(String? raw) {
    final content = raw?.trim() ?? '';
    if (content.isEmpty) return '';

    // Many APIs append "[+123 chars]" to truncated content; remove it for TTS.
    return content.replaceFirst(RegExp(r'\s*\[\+\d+\s+chars\]\s*$'), '').trim();
  }

  bool _isSessionCancelled(int sessionId) {
    return sessionId != _sessionId;
  }
}
