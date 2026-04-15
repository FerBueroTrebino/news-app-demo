enum NewsCategory {
  general,
  business,
  entertainment,
  health,
  science,
  sport,
  technology;

  String get apiValue => name;

  String get displayName {
    if (this == NewsCategory.sport) return 'Sports';
    return name[0].toUpperCase() + name.substring(1);
  }

  static NewsCategory fromApi(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    if (normalized == 'sports') return NewsCategory.sport;

    return NewsCategory.values.firstWhere(
      (category) => category.apiValue == normalized,
      orElse: () => NewsCategory.general,
    );
  }
}
