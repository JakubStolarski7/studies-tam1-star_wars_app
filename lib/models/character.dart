class Character {
  final String uid;
  final String name;
  final String url;

  Character({
    required this.uid,
    required this.name,
    required this.url,
  });

  // Fabryka do parsowania JSON-a z API
  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      uid: json['uid'] ?? '',
      name: json['name'] ?? 'Nieznany',
      url: json['url'] ?? '',
    );
  }
}