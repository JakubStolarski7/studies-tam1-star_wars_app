import 'package:flutter/material.dart';
import '../models/character.dart';
import '../services/api_service.dart';
import 'character_details_screen.dart';
import '../services/analytics_service.dart';


class CharactersScreen extends StatefulWidget {
  const CharactersScreen({super.key});

  @override
  State<CharactersScreen> createState() => _CharactersScreenState();
}

class _CharactersScreenState extends State<CharactersScreen> {
  late Future<List<Character>> _charactersFuture;
  final ApiService _apiService = ApiService();
  final AnalyticsService _analytics = AnalyticsService();

  @override
  void initState() {
    super.initState();
    _fetchData();
    _analytics.logViewCategory('characters');
  }

  void _fetchData() {
    setState(() {
      _charactersFuture = _apiService.getCharacters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'BAZA POSTACI',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.redAccent),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.redAccent.withOpacity(0.3), height: 1.0),
        ),
      ),
      body: FutureBuilder<List<Character>>(
        future: _charactersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            );
          }

          else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Zakłócenia w Mocy:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _fetchData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Spróbuj ponownie'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.black,
                    ),
                  )
                ],
              ),
            );
          }
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Archiwa Jedi są puste.', style: TextStyle(color: Colors.white54)),
            );
          }

          final characters = snapshot.data!;

          return RefreshIndicator(
            color: Colors.redAccent,
            backgroundColor: Colors.black,
            onRefresh: () async {
              _analytics.logManualRefresh('characters');
              _fetchData();
              await _charactersFuture;
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.all(16),
              itemCount: characters.length,
              itemBuilder: (context, index) {
                final char = characters[index];
                return Card(
                  color: const Color(0xFF111111),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.redAccent.withOpacity(0.2), width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(char.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text('ID Rekordu: ${char.uid}', style: const TextStyle(color: Colors.white54)),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.redAccent, size: 18),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CharacterDetailsScreen(uid: char.uid, name: char.name)));
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