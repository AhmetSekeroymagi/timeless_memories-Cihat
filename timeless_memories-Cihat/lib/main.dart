import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeless_memories/modules/splash.view.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeless_memories/modules/service/memory_service.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Uygulama navigasyon anahtarı
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('tr_TR');

    // Türkçe klavye girişini etkinleştir
    SystemChannels.textInput.invokeMethod('TextInput.setImeOptions', {
      'enablePersonalizedLearning': true,
      'enableSuggestions': true,
      'enableIMEPersonalizedLearning': true,
    });

    // Firebase'i başlat
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Firestore için çevrimdışı desteği etkinleştir
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );

    // App Check'i başlat
    try {
      await FirebaseAppCheck.instance.activate(
        webProvider: ReCaptchaV3Provider('YOUR_RECAPTCHA_SITE_KEY'),
        androidProvider:
            kReleaseMode
                ? AndroidProvider.playIntegrity
                : AndroidProvider.debug,
        appleProvider: AppleProvider.appAttest,
      );
      debugPrint('✅ App Check başarıyla etkinleştirildi.');

      // Hata ayıklama jetonunu almak ve yazdırmak için.
      // Bu jetonu kopyalayıp Firebase projenizdeki App Check ayarlarına ekleyin.
      if (kDebugMode) {
        FirebaseAppCheck.instance.getToken(true).then((token) {
          debugPrint('🔒 Firebase App Check Debug Token: $token');
        });
      }
    } catch (e) {
      debugPrint('❌ App Check etkinleştirilemedi: $e');
    }

    // Beklemedeki anıları senkronize et (arka planda, beklemeden)
    MemoryService().syncPendingMemories();

    // Kullanıcı oturum durumu dinleyicisini başlat
    _setupAuthStateListener();

    runApp(const ProviderScope(child: MyApp()));
  } catch (e) {
    debugPrint('❌ Başlatma hatası: $e');
  }
}

/// Kullanıcı oturum durumu takipçisi
void _setupAuthStateListener() {
  FirebaseAuth.instance.authStateChanges().listen(
    (User? user) => debugPrint(
      user != null
          ? '👤 Kullanıcı oturum durumu: ${user.uid} (${user.emailVerified ? "Doğrulanmış" : "Doğrulanmamış"})'
          : '👤 Kullanıcı oturumu kapalı',
    ),
    onError: (error) => debugPrint('❌ Oturum hatası: $error'),
  );
}

/// Ana uygulama widget'ı
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Timeless Memories',
      theme: _buildTheme(),
      home: const SplashView(),
    );
  }
}

/// Uygulama temasını oluştur
ThemeData _buildTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF07B183)),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
    ),
  );
}
