class Example {
  final int id;
  final String sentenceJp;
  final String? sentenceZh;
  final String? sentenceEn;

  Example({
    required this.id,
    required this.sentenceJp,
    this.sentenceZh,
    this.sentenceEn,
  });

  factory Example.fromJson(Map<String, dynamic> json) {
    return Example(
      id: json['id'] as int,
      sentenceJp: json['sentenceJp'] as String,
      sentenceZh: json['sentenceZh'] as String?,
      sentenceEn: json['sentenceEn'] as String?,
    );
  }
}
