import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../services/analytics_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final DbService _dbService = DbService();
  final AnalyticsService _analytics = AnalyticsService();
  List<Map<dynamic, dynamic>> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _analytics.logViewCategory('favorites');
  }

  void _loadFavorites() {
    setState(() {
      _favorites = _dbService.getAllFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('TAJNE ARCHIWA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.greenAccent),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.greenAccent.withOpacity(0.3), height: 1.0),
        ),
      ),
      body: _favorites.isEmpty
          ? const Center(
        child: Text(
          'Archiwa są puste.\nDodaj elementy do ulubionych.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54, fontSize: 16),
        ),
      )
          : ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final item = _favorites[index];

          IconData iconData;
          String typeLabel;

          switch (item['type']) {
            case 'character':
              iconData = Icons.person;
              typeLabel = 'Postać';
              break;
            case 'planet':
              iconData = Icons.public;
              typeLabel = 'Planeta';
              break;
            case 'starship':
              iconData = Icons.rocket_launch;
              typeLabel = 'Statek';
              break;
            default:
              iconData = Icons.star;
              typeLabel = 'Nieznany';
          }

          return Card(
            color: const Color(0xFF111111),
            elevation: 5,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.greenAccent.withOpacity(0.2), width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(item['name'].toString().toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text('$typeLabel (ID: ${item['uid']})', style: const TextStyle(color: Colors.white54)),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () {
                  _dbService.toggleFavorite(uid: item['uid'], name: item['name'], type: item['type']);

                  _analytics.logToggleFavorite(item['name'], item['type'], false);

                  _loadFavorites();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Usunięto z archiwów.'),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}