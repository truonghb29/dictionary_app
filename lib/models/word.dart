class Word {
  final String term;
  final Map<String, String> translations;
  final String? example;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Word({
    required this.term, 
    required this.translations, 
    this.example,
    this.createdAt,
    this.updatedAt,
  });

  // Get the first translation as default meaning (for backward compatibility)
  String get meaning {
    return translations.isNotEmpty ? translations.values.first : '';
  }

  // Convert to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'term': term,
      'translations': translations,
      'example': example,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create from JSON
  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      term: json['term'],
      translations: Map<String, String>.from(json['translations']),
      example: json['example'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
