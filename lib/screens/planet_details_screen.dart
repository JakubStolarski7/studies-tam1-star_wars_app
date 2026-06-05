import 'package:flutter/material.dart';
import '../models/planet_details.dart';
import '../services/api_service.dart';
import '../services/db_service.dart';
import '../services/analytics_service.dart';

class PlanetDetailsScreen extends StatefulWidget {
  final String uid;
  final String name;

  const PlanetDetailsScreen({super.key, required this.uid, required this.name});

  @override
  State<PlanetDetailsScreen> createState() => _PlanetDetailsScreenState();
}

class _PlanetDetailsScreenState extends State<PlanetDetailsScreen> {
  late Future<PlanetDetails> _detailsFuture;
  final ApiService _apiService = ApiService();
  final DbService _dbService = DbService();
  final AnalyticsService _analytics = AnalyticsService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _detailsFuture = _apiService.getPlanetDetails(widget.uid);
    _isFavorite = _dbService.isFavorite(uid: widget.uid, type: 'planet');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Color(0xFFFFE81F)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFFFE81F).withOpacity(0.3), height: 1.0),
        ),
      ),
      body: FutureBuilder<PlanetDetails>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFFE81F)));
          } else if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error}', style: const TextStyle(color: Color(0xFFFFE81F))));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Brak danych.', style: TextStyle(color: Colors.white54)));
          }

          final details = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("DANE PLANETARNE", style: TextStyle(color: Color(0xFFFFE81F), fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
                const SizedBox(height: 15),
                _buildInfoRow("Klimat", details.climate),
                _buildInfoRow("Teren", details.terrain),
                _buildInfoRow("Populacja", details.population),
                _buildInfoRow("Grawitacja", details.gravity),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _isFavorite ? const Color(0xFFFFE81F) : Colors.grey.shade900,
        foregroundColor: _isFavorite ? Colors.black : Colors.white,
        onPressed: () {
          _dbService.toggleFavorite(uid: widget.uid, name: widget.name, type: 'planet');

          setState(() {
            _isFavorite = !_isFavorite;
          });

          _analytics.logToggleFavorite(widget.name, 'planet', _isFavorite);

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
        border: Border.all(color: const Color(0xFFFFE81F).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 16)),
          Flexible(child: Text(value.toUpperCase(), textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}