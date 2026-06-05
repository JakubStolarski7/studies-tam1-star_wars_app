import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logViewCategory(String categoryName) async {
    await _analytics.logEvent(
      name: 'view_category',
      parameters: {'category_id': categoryName},
    );
  }

  Future<void> logToggleFavorite(String itemName, String type, bool isAdded) async {
    await _analytics.logEvent(
      name: 'toggle_favorite',
      parameters: {
        'item_name': itemName,
        'item_type': type,
        'action': isAdded ? 'add' : 'remove',
      },
    );
  }

  Future<void> logManualRefresh(String categoryName) async {
    await _analytics.logEvent(
      name: 'manual_refresh',
      parameters: {'category_name': categoryName},
    );
  }

  void logNonFatalError(dynamic error, StackTrace stack) {
    debugPrint("Firebase Crashlytics przechwycił błąd: $error");
    if (!kIsWeb) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
    }
  }
}