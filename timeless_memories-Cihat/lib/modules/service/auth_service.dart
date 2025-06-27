import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sadeleştirilmiş auth servisi
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Validation methods
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ad Soyad alanı boş bırakılamaz';
    }
    if (value.length < 2) {
      return 'Ad Soyad en az 2 karakter olmalıdır';
    }
    return null;
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kullanıcı adı boş bırakılamaz';
    }
    if (value.length < 3) {
      return 'Kullanıcı adı en az 3 karakter olmalıdır';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta adresi boş bırakılamaz';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Geçerli bir e-posta adresi giriniz';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre boş bırakılamaz';
    }
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır';
    }
    return null;
  }

  // Kullanıcı oluşturma metodu
  Future<UserCredential> createUser({
    required String email,
    required String password,
    required String name,
    required String username,
    required String confirmPassword,
  }) async {
    try {
      debugPrint('👤 Kullanıcı oluşturma başladı');

      // Form validasyonları
      final nameError = validateName(name);
      if (nameError != null) throw Exception(nameError);

      final usernameError = validateUsername(username);
      if (usernameError != null) throw Exception(usernameError);

      final emailError = validateEmail(email);
      if (emailError != null) throw Exception(emailError);

      final passwordError = validatePassword(password);
      if (passwordError != null) throw Exception(passwordError);

      if (password != confirmPassword) {
        throw Exception('Şifreler eşleşmiyor');
      }

      // Email ve username kontrolü
      final emailExists = await checkEmailExists(email);
      if (emailExists) {
        throw Exception('Bu email adresi zaten kullanımda');
      }

      final normalizedUsername = _normalizeUsername(username);
      final usernameExists = await checkUsernameExists(normalizedUsername);
      if (usernameExists) {
        throw Exception('Bu kullanıcı adı zaten kullanımda');
      }

      // Kullanıcı oluştur
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.toLowerCase().trim(),
        password: password,
      );

      // Email doğrulama gönder
      await userCredential.user?.sendEmailVerification();

      // Firestore'a kullanıcı bilgilerini kaydet
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': email.toLowerCase().trim(),
        'name': name.trim(),
        'username': normalizedUsername,
        'displayUsername': username.trim(), // Original username for display
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'emailVerified': false,
      });

      debugPrint(
        '✅ Kullanıcı başarıyla oluşturuldu: ${userCredential.user?.uid}',
      );
      return userCredential;
    } catch (e) {
      debugPrint('❌ Kullanıcı oluşturma hatası: $e');
      rethrow;
    }
  }

  // Kullanıcı adı normalize etme (Latin karakterlere çevirme)
  String _normalizeUsername(String username) {
    // Simply lowercase and trim
    final normalized = username.toLowerCase().trim();

    // Remove any non-alphanumeric characters
    final sanitized = normalized.replaceAll(RegExp(r'[^a-z0-9_]'), '');

    return sanitized;
  }

  // Email kontrol
  Future<bool> checkEmailExists(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(
        email.toLowerCase().trim(),
      );
      return methods.isNotEmpty;
    } catch (e) {
      debugPrint('Email kontrol hatası: $e');
      return false;
    }
  }

  // Kullanıcı adı kontrol
  Future<bool> checkUsernameExists(String username) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('users')
              .where('username', isEqualTo: username.toLowerCase().trim())
              .limit(1)
              .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Username kontrol hatası: $e');
      return false;
    }
  }

  // Giriş metodu
  Future<UserCredential> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('👤 Giriş işlemi başladı');

      String loginEmail = email.toLowerCase().trim();

      // Kullanıcı adı ile giriş
      if (!loginEmail.contains('@')) {
        debugPrint('🔍 Username ile giriş deneniyor...');

        // Kullanıcı adını normalize et (Türkçe karakterler için)
        final normalizedUsername = _normalizeUsername(loginEmail);

        final userDoc =
            await _firestore
                .collection('users')
                .where('username', isEqualTo: normalizedUsername)
                .limit(1)
                .get();

        if (userDoc.docs.isEmpty) {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'Kullanıcı bulunamadı',
          );
        }
        loginEmail = userDoc.docs.first.get('email');
      }

      // Giriş işlemi
      debugPrint('🔐 Kimlik doğrulama yapılıyor...');
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: loginEmail,
        password: password,
      );

      // Email doğrulama kontrolü
      if (!userCredential.user!.emailVerified) {
        debugPrint('📧 Email doğrulanmamış');
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message:
              'Email adresinizi doğrulayın. Giriş yapmak için önce email doğrulaması yapmalısınız.',
        );
      }

      debugPrint('✅ Giriş başarılı: ${userCredential.user?.uid}');

      // Giriş kaydı
      await _updateLoginInfo(userCredential.user!.uid);

      return userCredential;
    } catch (e) {
      debugPrint('❌ Giriş hatası: $e');
      rethrow;
    }
  }

  // Giriş bilgilerini güncelle
  Future<void> _updateLoginInfo(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
        'emailVerified': true,
      });
    } catch (e) {
      debugPrint('⚠️ Giriş bilgileri güncellenemedi: $e');
      // Kritik olmayan hata, devam et
    }
  }

  // Aktif kullanıcı verisi
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        return doc.data();
      }
      return null;
    } catch (e) {
      debugPrint('⚠️ Kullanıcı veri hatası: $e');
      return null;
    }
  }

  // Çıkış
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('⚠️ Çıkış hatası: $e');
      rethrow;
    }
  }
}

// Providers
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final userDataProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getCurrentUserData();
});
