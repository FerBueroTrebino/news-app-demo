abstract class ArticleReader {
  Future<void> prepare();
  Future<void> speak(String text);
  Future<void> stop();
}
