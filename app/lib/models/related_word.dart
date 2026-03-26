class RelatedWord {
  final int id;
  final String? kanji;
  final String hiragana;
  final String? definitionZh;
  final String? definitionEn;
  final String relationType;

  RelatedWord({
    required this.id,
    this.kanji,
    required this.hiragana,
    this.definitionZh,
    this.definitionEn,
    required this.relationType,
  });

  factory RelatedWord.fromJson(Map<String, dynamic> json) {
    return RelatedWord(
      id: json['id'] as int,
      kanji: json['kanji'] as String?,
      hiragana: json['hiragana'] as String,
      definitionZh: json['definitionZh'] as String?,
      definitionEn: json['definitionEn'] as String?,
      relationType: json['relationType'] as String,
    );
  }
}
