class Planet {
  final String uid;
  final String name;
  final String url;

  Planet({required this.uid, required this.name, required this.url});

  factory Planet.fromJson(Map<String, dynamic> json) {
    return Planet(
      uid: json['uid'] ?? '',
      name: json['name'] ?? 'Nieznany',
      url: json['url'] ?? '',
    );
  }
}