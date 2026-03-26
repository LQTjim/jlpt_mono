class Category {
  final int id;
  final String? nameJp;
  final String? nameZh;
  final String? nameEn;
  final List<Category> children;

  Category({
    required this.id,
    this.nameJp,
    this.nameZh,
    this.nameEn,
    this.children = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      nameJp: json['nameJp'] as String?,
      nameZh: json['nameZh'] as String?,
      nameEn: json['nameEn'] as String?,
      children: (json['children'] as List<dynamic>?)
              ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
