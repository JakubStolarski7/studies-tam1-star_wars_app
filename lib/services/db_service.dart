import 'package:hive_flutter/hive_flutter.dart';

class DbService {
  final Box _box = Hive.box('favorites');

  void toggleFavorite({required String uid, required String name, required String type}) {
    final String key = '${type}_$uid';

    if (_box.containsKey(key)) {
      _box.delete(key);
    } else {
      _box.put(key, {
        'uid': uid,
        'name': name,
        'type': type,
      });
    }
  }

  bool isFavorite({required String uid, required String type}) {
    final String key = '${type}_$uid';
    return _box.containsKey(key);
  }

  List<Map<dynamic, dynamic>> getAllFavorites() {
    return _box.values.toList().cast<Map<dynamic, dynamic>>();
  }
}