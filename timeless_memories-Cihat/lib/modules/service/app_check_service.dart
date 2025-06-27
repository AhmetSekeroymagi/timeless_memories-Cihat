import 'dart:async';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Basitleştirilmiş Firebase App Check yönetimi
class AppCheckService {
  // Temel önbellek için değişkenler
  DateTime? _lastTokenTime;
  String? _cachedToken;
  bool _isGettingToken = false;

  /// Token yenileme aralığı (saniye)
  final int _tokenCacheTime = 30;

  /// Yeni bir token al veya önbellekten kullan
  Future<String?> getToken({bool forceRefresh = false}) async {
    // Eğer zaten token alınıyorsa bekle
    if (_isGettingToken) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _cachedToken;
    }

    try {
      _isGettingToken = true;

      // Önbellekten token kontrolü
      final now = DateTime.now();
      if (!forceRefresh &&
          _cachedToken != null &&
          _lastTokenTime != null &&
          now.difference(_lastTokenTime!).inSeconds < _tokenCacheTime) {
        return _cachedToken;
      }

      // Yeni token al
      final token = await FirebaseAppCheck.instance.getToken();

      // Önbelleğe al
      _cachedToken = token;
      _lastTokenTime = now;

      return token;
    } catch (e) {
      debugPrint('❌ App Check token hatası: $e');
      if (kDebugMode) return null; // Debug modunda hatayı yoksay
      rethrow;
    } finally {
      _isGettingToken = false;
    }
  }

  /// Rate limiting hatası durumunda gecikme sağla
  Future<void> handleRateLimitingError() async {
    // Basit bir gecikme uygula
    await Future.delayed(const Duration(seconds: 2));
  }
}

final appCheckServiceProvider = Provider<AppCheckService>(
  (ref) => AppCheckService(),
);
