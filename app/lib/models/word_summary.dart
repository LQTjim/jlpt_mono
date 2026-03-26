class WordSummary {
  final int id;
  final String? kanji;
  final String hiragana;
  final String? romaji;
  final String? definitionZh;
  final String? definitionEn;
  final String? partOfSpeech;
  final String? jlptLevel;

  WordSummary({
    required this.id,
    this.kanji,
    required this.hiragana,
    this.romaji,
    this.definitionZh,
    this.definitionEn,
    this.partOfSpeech,
    this.jlptLevel,
  });

  factory WordSummary.fromJson(Map<String, dynamic> json) {
    return WordSummary(
      id: json['id'] as int,
      kanji: json['kanji'] as String?,
      hiragana: json['hiragana'] as String,
      romaji: json['romaji'] as String?,
      definitionZh: json['definitionZh'] as String?,
      definitionEn: json['definitionEn'] as String?,
      partOfSpeech: json['partOfSpeech'] as String?,
      jlptLevel: json['jlptLevel'] as String?,
    );
  }
}
