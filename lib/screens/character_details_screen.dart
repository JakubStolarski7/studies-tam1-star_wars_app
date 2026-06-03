import 'package:flutter/material.dart';
import '../models/character_details.dart';
import '../services/api_service.dart';

class CharacterDetailsScreen extends StatefulWidget {
  final String uid;
  final String name;

  const CharacterDetailsScreen({super.key, required this.uid, required this.name});

  @override
  State<CharacterDetailsScreen> createState() => _CharacterDetailsScreenState();
}

class _CharacterDetailsScreenState extends State<CharacterDetailsScreen> {
  late Future<CharacterDetails> _detailsFuture;
  final ApiService _apiService = ApiService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _detailsFuture = _apiService.getCharacterDetails(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.redAccent),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.redAccent.withOpacity(0.3), height: 1.0),
        ),
      ),
      body: FutureBuilder<CharacterDetails>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
          } else if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Brak danych.', style: TextStyle(color: Colors.white54)));
          }

          final details = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Hero(
                    tag: 'hero-char-${widget.uid}',
                    child: Container(
                      width: 200,
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(color: Colors.redAccent.withOpacity(0.3), blurRadius: 20, spreadRadius: 2),
                        ],
                        border: Border.all(color: Colors.redAccent.withOpacity(0.8), width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.network(
                          'https://images.weserv.nl/?url=starwars-visualguide.com/assets/img/characters/${widget.uid}.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFF111111),
                            child: const Icon(Icons.person_off, size: 80, color: Colors.white54),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text("AKTA PERSONALNE", style: TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
                const SizedBox(height: 15),
                _buildInfoRow("Płeć", details.gender),
                _buildInfoRow("Wzrost", "${details.height} cm"),
                _buildInfoRow("Waga", "${details.mass} kg"),
                _buildInfoRow("Kolor włosów", details.hairColor),
                _buildInfoRow("Rok urodzenia", details.birthYear),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _isFavorite ? Colors.redAccent : Colors.grey.shade900,
        foregroundColor: Colors.white,
        onPressed: () {
          setState(() {
            _isFavorite = !_isFavorite;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isFavorite ? 'Dodano do ulubionych!' : 'Usunięto z ulubionych.'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 16)),
          Text(value.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}