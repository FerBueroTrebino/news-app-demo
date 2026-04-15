class ReadingTimeEstimator {
  const ReadingTimeEstimator();

  static const int _wordsPerMinute = 200;

  static int estimateMinutes({
    String? title,
    String? description,
    String? content,
  }) {
    final combined = [title, description, content]
        .where((part) => part != null && part.trim().isNotEmpty)
        .join(' ');

    final wordsCount = _countWords(combined);
    if (wordsCount == 0) {
      return 1;
    }

    return (wordsCount / _wordsPerMinute).ceil();
  }

  static String formatLabel({
    String? title,
    String? description,
    String? content,
  }) {
    final minutes = estimateMinutes(
      title: title,
      description: description,
      content: content,
    );
    return '$minutes min read';
  }

  static int _countWords(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }
}
