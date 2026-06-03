class StarshipDetails {
  final String name;
  final String model;
  final String manufacturer;
  final String costInCredits;
  final String hyperdriveRating;

  StarshipDetails({
    required this.name, required this.model, required this.manufacturer,
    required this.costInCredits, required this.hyperdriveRating
  });

  factory StarshipDetails.fromJson(Map<String, dynamic> json) {
    final props = json['result']['properties'];
    return StarshipDetails(
      name: props['name'] ?? 'Nieznany',
      model: props['model'] ?? 'Brak danych',
      manufacturer: props['manufacturer'] ?? 'Brak danych',
      costInCredits: props['cost_in_credits'] ?? 'Brak danych',
      hyperdriveRating: props['hyperdrive_rating'] ?? 'Brak danych',
    );
  }
}