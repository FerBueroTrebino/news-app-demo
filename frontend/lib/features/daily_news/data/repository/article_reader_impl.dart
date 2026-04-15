import 'package:flutter_tts/flutter_tts.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_reader.dart';

class ArticleReaderImpl implements ArticleReader {
  ArticleReaderImpl(this._flutterTts);

  final FlutterTts _flutterTts;
  bool _isPrepared = false;

  @override
  Future<void> prepare() async {
    if (_isPrepared) return;

    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.setSpeechRate(0.48);
    await _flutterTts.setPitch(1.0);
    _isPrepared = true;
  }

  @override
  Future<void> speak(String text) {
    return _flutterTts.speak(text);
  }

  @override
  Future<void> stop() {
    return _flutterTts.stop();
  }
}
