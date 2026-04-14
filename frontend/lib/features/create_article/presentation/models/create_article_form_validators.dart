final class CreateArticleFormValidators {
  CreateArticleFormValidators._();

  static String? title(String? value) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) return 'Enter a title';
    if (t.length < 3) return 'Title must be at least 3 characters';
    if (t.length > 120) return 'Title must be at most 120 characters';
    return null;
  }

  static String? description(String? value) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) return 'Enter a description';
    if (t.length < 3) return 'Description must be at least 90 characters';
    if (t.length > 250) return 'Description must be at most 250 characters';
    return null;
  }

  static String? content(String? value) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) return 'Enter the article body';
    if (t.length < 3) return 'Content must be at least 100 characters';
    if (t.length > 20000) return 'Content must be at most 20,000 characters';
    return null;
  }
}
