import 'package:flutter/material.dart';
import '../models/planet.dart';
import '../services/api_service.dart';
import 'planet_details_screen.dart';

class PlanetsScreen extends StatefulWidget {
  const PlanetsScreen({super.key});

  @override
  State<PlanetsScreen> createState() => _PlanetsScreenState();
}

class _PlanetsScreenState extends State<PlanetsScreen> {
  late Future<List<Planet>> _planetsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _planetsFuture = _apiService.getPlanets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('ATLAS PLANET', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Color(0xFFFFE81F)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFFFE81F).withOpacity(0.3), height: 1.0),
        ),
      ),
      body: FutureBuilder<List<Planet>>(
        future: _planetsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFFE81F)));
          } else if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error}', style: const TextStyle(color: Color(0xFFFFE81F))));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Archiwa są puste.', style: TextStyle(color: Colors.white54)));
          }

          final planets = snapshot.data!;

          return RefreshIndicator(
            color: const Color(0xFFFFE81F),
            backgroundColor: Colors.black,
            onRefresh: () async {
              _fetchData();
              await _planetsFuture;
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.all(16),
              itemCount: planets.length,
              itemBuilder: (context, index) {
                final planet = planets[index];
                return Card(
                  color: const Color(0xFF111111),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: const Color(0xFFFFE81F).withOpacity(0.2), width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Hero(
                      tag: 'hero-planet-${planet.uid}',
                      child: Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFFFE81F), width: 1)),
                        child: ClipOval(
                          child: Image.network(
                            'https://images.weserv.nl/?url=starwars-visualguide.com/assets/img/planets/${planet.uid}.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.public, color: Colors.white54),
                          ),
                        ),
                      ),
                    ),
                    title: Text(planet.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text('ID Rekordu: ${planet.uid}', style: const TextStyle(color: Colors.white54)),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFFFE81F), size: 18),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => PlanetDetailsScreen(uid: planet.uid, name: planet.name),
                      ));
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}