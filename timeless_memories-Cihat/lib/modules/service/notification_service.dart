import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Bildirim İzni Al
  Future<void> requestPermission() async {
    try {
      final NotificationSettings settings =
          await _messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        log('Bildirim izni verildi.');
      } else {
        log('Bildirim izni reddedildi.');
      }
    } catch (e) {
      log('Bildirim izni alınamadı: $e');
      throw Exception('Permission request failed: $e');
    }
  }

  // FCM Token Al
  Future<String?> getToken() async {
    try {
      final String? token = await _messaging.getToken();
      log('FCM Token: $token');
      return token;
    } catch (e) {
      log('FCM Token alınamadı: $e');
      throw Exception('Getting FCM token failed: $e');
    }
  }

  // FCM Token Yenilemelerini Dinle
  void listenForTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) {
      log('Yeni FCM Token: $newToken');
      // Burada token'ı backend sunucusuna gönderebilirsiniz
    });
  }

  // Bildirimleri Dinle
  void listenNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Yeni bildirim: ${message.notification?.title}');
    });
  }
}
