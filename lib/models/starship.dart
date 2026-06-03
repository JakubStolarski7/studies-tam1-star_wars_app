class Starship {
  final String uid;
  final String name;
  final String url;

  Starship({required this.uid, required this.name, required this.url});

  factory Starship.fromJson(Map<String, dynamic> json) {
    return Starship(
      uid: json['uid'] ?? '',
      name: json['name'] ?? 'Nieznany',
      url: json['url'] ?? '',
    );
  }
}