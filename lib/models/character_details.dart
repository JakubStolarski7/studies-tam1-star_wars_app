class CharacterDetails {
  final String name;
  final String height;
  final String mass;
  final String hairColor;
  final String birthYear;
  final String gender;

  CharacterDetails({
    required this.name,
    required this.height,
    required this.mass,
    required this.hairColor,
    required this.birthYear,
    required this.gender,
  });

  factory CharacterDetails.fromJson(Map<String, dynamic> json) {
    final props = json['result']['properties'];

    return CharacterDetails(
      name: props['name'] ?? 'Nieznany',
      height: props['height'] ?? 'Brak',
      mass: props['mass'] ?? 'Brak',
      hairColor: props['hair_color'] ?? 'Brak',
      birthYear: props['birth_year'] ?? 'Brak',
      gender: props['gender'] ?? 'Brak',
    );
  }
}