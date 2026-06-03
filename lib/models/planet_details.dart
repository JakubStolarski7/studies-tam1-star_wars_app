class PlanetDetails {
  final String name;
  final String climate;
  final String terrain;
  final String population;
  final String gravity;

  PlanetDetails({
    required this.name, required this.climate, required this.terrain,
    required this.population, required this.gravity
  });

  factory PlanetDetails.fromJson(Map<String, dynamic> json) {
    final props = json['result']['properties'];
    return PlanetDetails(
      name: props['name'] ?? 'Nieznany',
      climate: props['climate'] ?? 'Brak danych',
      terrain: props['terrain'] ?? 'Brak danych',
      population: props['population'] ?? 'Brak danych',
      gravity: props['gravity'] ?? 'Brak danych',
    );
  }
}