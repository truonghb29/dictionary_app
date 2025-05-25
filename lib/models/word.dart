class Word {
  final String term;
  final Map<String, String> translations;
  final String? example;

  Word({required this.term, required this.translations, this.example});

  // Get the first translation as default meaning (for backward compatibility)
  String get meaning {
    return translations.isNotEmpty ? translations.values.first : '';
  }
}
