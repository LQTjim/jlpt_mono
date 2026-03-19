class User {
  final String email;
  final String name;
  final String? pictureUrl;

  User({
    required this.email,
    required this.name,
    this.pictureUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] as String,
      name: json['name'] as String,
      pictureUrl: json['pictureUrl'] as String?,
    );
  }
}
