import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character.dart';
import '../models/character_details.dart';
import '../models/planet.dart';
import '../models/planet_details.dart';
import '../models/starship.dart';
import '../models/starship_details.dart';

class ApiService {
  static const String baseUrl = 'https://www.swapi.tech/api';

  Future<List<Character>> getCharacters() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/people'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        return results.map((json) => Character.fromJson(json)).toList();
      } else {
        throw Exception('Błąd serwera: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Nie udało się połączyć z API: $e');
    }
  }

  Future<CharacterDetails> getCharacterDetails(String uid) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/people/$uid'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return CharacterDetails.fromJson(data);
      } else {
        throw Exception('Błąd serwera: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Nie udało się pobrać szczegółów: $e');
    }
  }

  Future<List<Planet>> getPlanets() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/planets'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        return results.map((json) => Planet.fromJson(json)).toList();
      } else {
        throw Exception('Błąd serwera: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Nie udało się połączyć z API: $e');
    }
  }

  Future<PlanetDetails> getPlanetDetails(String uid) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/planets/$uid'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return PlanetDetails.fromJson(data);
      } else {
        throw Exception('Błąd serwera: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Nie udało się pobrać szczegółów: $e');
    }
  }

  Future<List<Starship>> getStarships() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/starships'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        return results.map((json) => Starship.fromJson(json)).toList();
      } else {
        throw Exception('Błąd serwera: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Nie udało się połączyć z API: $e');
    }
  }

  Future<StarshipDetails> getStarshipDetails(String uid) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/starships/$uid'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return StarshipDetails.fromJson(data);
      } else {
        throw Exception('Błąd serwera: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Nie udało się pobrać szczegółów: $e');
    }
  }
}