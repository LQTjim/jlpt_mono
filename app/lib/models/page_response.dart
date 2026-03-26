class PageResponse<T> {
  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool last;

  PageResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PageResponse(
      content: (json['content'] as List<dynamic>)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int,
      size: json['size'] as int,
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
      last: json['last'] as bool,
    );
  }
}
