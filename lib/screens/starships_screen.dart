import 'package:flutter/material.dart';
import '../models/starship.dart';
import '../services/api_service.dart';
import 'starship_details_screen.dart';

class StarshipsScreen extends StatefulWidget {
  const StarshipsScreen({super.key});

  @override
  State<StarshipsScreen> createState() => _StarshipsScreenState();
}

class _StarshipsScreenState extends State<StarshipsScreen> {
  late Future<List<Starship>> _starshipsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _starshipsFuture = _apiService.getStarships();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('FLOTA GWIEZDNA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.blueAccent),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.blueAccent.withOpacity(0.3), height: 1.0),
        ),
      ),
      body: FutureBuilder<List<Starship>>(
        future: _starshipsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
          } else if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error}', style: const TextStyle(color: Colors.blueAccent)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Hangar jest pusty.', style: TextStyle(color: Colors.white54)));
          }

          final starships = snapshot.data!;

          return RefreshIndicator(
            color: Colors.blueAccent,
            backgroundColor: Colors.black,
            onRefresh: () async {
              _fetchData();
              await _starshipsFuture;
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.all(16),
              itemCount: starships.length,
              itemBuilder: (context, index) {
                final ship = starships[index];
                return Card(
                  color: const Color(0xFF111111),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.blueAccent.withOpacity(0.2), width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Hero(
                      tag: 'hero-starship-${ship.uid}',
                      child: Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.blueAccent, width: 1)),
                        child: ClipOval(
                          child: Image.network(
                            'https://images.weserv.nl/?url=starwars-visualguide.com/assets/img/starships/${ship.uid}.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.rocket_launch, color: Colors.white54),
                          ),
                        ),
                      ),
                    ),
                    title: Text(ship.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text('ID Rekordu: ${ship.uid}', style: const TextStyle(color: Colors.white54)),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent, size: 18),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => StarshipDetailsScreen(uid: ship.uid, name: ship.name),
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