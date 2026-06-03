import 'package:flutter/material.dart';
import '../models/starship_details.dart';
import '../services/api_service.dart';
import '../services/db_service.dart';

class StarshipDetailsScreen extends StatefulWidget {
  final String uid;
  final String name;

  const StarshipDetailsScreen({super.key, required this.uid, required this.name});

  @override
  State<StarshipDetailsScreen> createState() => _StarshipDetailsScreenState();
}

class _StarshipDetailsScreenState extends State<StarshipDetailsScreen> {
  late Future<StarshipDetails> _detailsFuture;
  final ApiService _apiService = ApiService();
  final DbService _dbService = DbService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _detailsFuture = _apiService.getStarshipDetails(widget.uid);
    _isFavorite = _dbService.isFavorite(uid: widget.uid, type: 'character');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.blueAccent),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.blueAccent.withOpacity(0.3), height: 1.0),
        ),
      ),
      body: FutureBuilder<StarshipDetails>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
          } else if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error}', style: const TextStyle(color: Colors.blueAccent)));
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
                    tag: 'hero-starship-${widget.uid}',
                    child: Container(
                      width: double.infinity, height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 20, spreadRadius: 2)],
                        border: Border.all(color: Colors.blueAccent.withOpacity(0.8), width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.network(
                          'https://images.weserv.nl/?url=starwars-visualguide.com/assets/img/starships/${widget.uid}.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFF111111),
                            child: const Icon(Icons.rocket_launch, size: 80, color: Colors.white54),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text("SPECYFIKACJA TECHNICZNA", style: TextStyle(color: Colors.blueAccent, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
                const SizedBox(height: 15),
                _buildInfoRow("Model", details.model),
                _buildInfoRow("Producent", details.manufacturer),
                _buildInfoRow("Koszt (Kredyty)", details.costInCredits),
                _buildInfoRow("Klasa Hipernapędu", details.hyperdriveRating),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _isFavorite ? Colors.blueAccent : Colors.grey.shade900,
        foregroundColor: Colors.white,
        onPressed: () {
          _dbService.toggleFavorite(uid: widget.uid, name: widget.name, type: 'planet');

          setState(() {
            _isFavorite = !_isFavorite;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isFavorite ? 'Planeta dodana do ulubionych.' : 'Usunięto z ulubionych.',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              backgroundColor: const Color(0xFFFFE81F),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Icon(_isFavorite ? Icons.star : Icons.star_border),
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
        border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14))),
          Expanded(flex: 3, child: Text(value.toUpperCase(), textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}