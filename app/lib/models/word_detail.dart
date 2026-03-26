import 'category.dart';
import 'example.dart';
import 'related_word.dart';

class WordDetail {
  final int id;
  final String? kanji;
  final String hiragana;
  final String? romaji;
  final String? definitionZh;
  final String? definitionEn;
  final String? partOfSpeech;
  final String? verbType;
  final String? jlptLevel;
  final int? difficultyScore;
  final int? frequencyRank;
  final String? notes;
  final Category? category;
  final List<Example> examples;
  final List<RelatedWord> relations;

  WordDetail({
    required this.id,
    this.kanji,
    required this.hiragana,
    this.romaji,
    this.definitionZh,
    this.definitionEn,
    this.partOfSpeech,
    this.verbType,
    this.jlptLevel,
    this.difficultyScore,
    this.frequencyRank,
    this.notes,
    this.category,
    this.examples = const [],
    this.relations = const [],
  });

  factory WordDetail.fromJson(Map<String, dynamic> json) {
    return WordDetail(
      id: json['id'] as int,
      kanji: json['kanji'] as String?,
      hiragana: json['hiragana'] as String,
      romaji: json['romaji'] as String?,
      definitionZh: json['definitionZh'] as String?,
      definitionEn: json['definitionEn'] as String?,
      partOfSpeech: json['partOfSpeech'] as String?,
      verbType: json['verbType'] as String?,
      jlptLevel: json['jlptLevel'] as String?,
      difficultyScore: json['difficultyScore'] as int?,
      frequencyRank: json['frequencyRank'] as int?,
      notes: json['notes'] as String?,
      category: json['category'] != null
          ? Category.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      examples: (json['examples'] as List<dynamic>?)
              ?.map((e) => Example.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      relations: (json['relations'] as List<dynamic>?)
              ?.map((e) => RelatedWord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
