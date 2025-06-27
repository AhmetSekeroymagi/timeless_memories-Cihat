import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless_memories/modules/home/home.dart';
import 'package:timeless_memories/modules/service/app_check_service.dart';
import 'package:timeless_memories/modules/user/login/state.dart';
import 'package:timeless_memories/modules/user/signup/singup_screen.dart';

/// Giriş ekranı widget'ı
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // State ve notifier referanslarını al
    final state = ref.watch(loginProvider);
    final notifier = ref.read(loginProvider.notifier);

    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: state.formKey,
            child: Column(
              children: [
                // Logo ve başlık
                _buildLogo(),
                _buildTitle(),
                const SizedBox(height: 30),

                // Form alanları
                _buildEmailField(state, notifier),
                const SizedBox(height: 16),
                _buildPasswordField(state, notifier),
                const SizedBox(height: 24),

                // Giriş ve yardımcı butonlar
                _buildLoginButton(context, state, notifier, ref),
                const SizedBox(height: 8),
                _buildForgotPasswordButton(context),

                const Divider(color: Colors.black54, thickness: 1, height: 40),

                // Kayıt ol bölümü
                _buildSignupSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Uygulama çubuğu
  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Timeless Memories',
        style: TextStyle(
          fontSize: 24,
          fontFamily: GoogleFonts.inter().fontFamily,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF07B183), Color(0xFF0D7055)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  /// Logo widget'ı
  Widget _buildLogo() {
    return Image.asset(
      'assets/images/timeless_logo.png',
      width: 100,
      height: 100,
      color: Colors.black,
    );
  }

  /// Başlık
  Widget _buildTitle() {
    return Text(
      'Giriş Yap',
      style: TextStyle(
        fontSize: 24,
        fontFamily: GoogleFonts.inter().fontFamily,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// E-posta/kullanıcı adı alanı
  Widget _buildEmailField(LoginState state, LoginNotifier notifier) {
    return TextFormField(
      controller: state.emailController,
      cursorColor: Colors.black,
      decoration: _inputDecoration('Kullanıcı Adı veya E-posta'),
      validator: notifier.validateEmail,
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
      textInputAction: TextInputAction.next,
      enableSuggestions: true,
      autocorrect: false,
    );
  }

  /// Şifre alanı
  Widget _buildPasswordField(LoginState state, LoginNotifier notifier) {
    return TextFormField(
      controller: state.passwordController,
      cursorColor: Colors.black,
      decoration: _inputDecoration('Şifre').copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            state.isObscured ? Icons.visibility_off : Icons.visibility,
            color: Colors.black,
          ),
          onPressed: notifier.togglePasswordVisibility,
        ),
      ),
      obscureText: state.isObscured,
      validator: notifier.validatePassword,
      textInputAction: TextInputAction.done,
      enableSuggestions: false,
      autocorrect: false,
    );
  }

  /// Form dekorasyonu
  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: Colors.black),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: Colors.black),
      ),
      labelText: labelText,
      labelStyle: TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      hintStyle: TextStyle(
        color: Colors.grey.shade600,
        fontSize: 16,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
    );
  }

  /// Giriş butonu
  Widget _buildLoginButton(
    BuildContext context,
    LoginState state,
    LoginNotifier notifier,
    WidgetRef ref,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: _loginButtonStyle(),
        onPressed:
            state.isLoading ? null : () => _handleLogin(context, notifier, ref),
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF07B183), Color(0xFF0D7055)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.all(Radius.circular(13)),
          ),
          child: Container(
            alignment: Alignment.center,
            child:
                state.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                      'Giriş Yap',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: GoogleFonts.inter().fontFamily,
                      ),
                    ),
          ),
        ),
      ),
    );
  }

  /// Giriş butonu stili
  ButtonStyle _loginButtonStyle() {
    return ElevatedButton.styleFrom(
      padding: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ).copyWith(backgroundColor: MaterialStateProperty.all(Colors.transparent));
  }

  /// Şifremi unuttum butonu
  Widget _buildForgotPasswordButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.of(context).pushNamed('/forgot-password'),
      child: Text(
        'Şifreni mi unuttun?',
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontFamily: GoogleFonts.inter().fontFamily,
        ),
      ),
    );
  }

  /// Kayıt ol bölümü
  Widget _buildSignupSection(BuildContext context) {
    return Column(
      children: [
        Text(
          'Hesabın yok mu?',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: GoogleFonts.inter().fontFamily,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed:
                () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const SignupScreen()),
                ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF0D7055), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Yeni hesap oluştur",
              style: TextStyle(
                color: const Color(0xFF0D7055),
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: GoogleFonts.inter().fontFamily,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Giriş işlemi
  Future<void> _handleLogin(
    BuildContext context,
    LoginNotifier notifier,
    WidgetRef ref,
  ) async {
    if (!context.mounted) return;

    try {
      if (notifier.state.formKey.currentState?.validate() ?? false) {
        notifier.state = notifier.state.copyWith(isLoading: true);

        // Giriş işlemi
        await notifier.handleLogin();

        if (!context.mounted) return;

        // Ana sayfaya yönlendir
        if (context.mounted) {
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth hatası: ${e.code}');

      // App Check hatalarını kontrol et
      if ((e.code == 'app-check-token-error') ||
          e.message?.toLowerCase().contains('too many attempts') == true) {
        // Rate limiting çözümü
        await ref.read(appCheckServiceProvider).handleRateLimitingError();
      }

      if (!context.mounted) return;

      // Email doğrulama hatası için özel mesaj
      if (e.code == 'email-not-verified') {
        _showVerificationMessage(
          context,
          e.message ?? 'Email adresinizi doğrulayın.',
        );
      } else {
        _showErrorSnackbar(context, _getErrorMessage(e));
      }
    } catch (e) {
      debugPrint('❌ Genel hata: $e');

      if (!context.mounted) return;
      _showErrorSnackbar(context, 'Bir hata oluştu, lütfen tekrar deneyin');
    } finally {
      if (notifier.mounted) {
        notifier.state = notifier.state.copyWith(isLoading: false);
      }
    }
  }

  /// Email doğrulama mesajı gösterimi
  void _showVerificationMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Tamam',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Hata mesajı gösterimi
  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Hata mesajlarını anlaşılır hale getir
  String _getErrorMessage(Object error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('user-not-found')) {
      return 'Kullanıcı bulunamadı';
    } else if (errorStr.contains('wrong-password')) {
      return 'Hatalı şifre';
    } else if (errorStr.contains('invalid-email')) {
      return 'Geçersiz email formatı';
    } else if (errorStr.contains('email-not-verified')) {
      return 'Email adresinizi doğrulayın. Giriş yapmak için önce email doğrulaması yapmalısınız.';
    } else if (errorStr.contains('too-many-requests') ||
        errorStr.contains('too many attempts')) {
      return 'Çok fazla deneme yapıldı. Lütfen birkaç dakika bekleyip tekrar deneyin.';
    } else if (errorStr.contains('network-request-failed')) {
      return 'İnternet bağlantınızı kontrol edin';
    } else if (errorStr.contains('invalid-credential')) {
      return 'Geçersiz kullanıcı bilgileri';
    }

    return 'Bir hata oluştu, lütfen tekrar deneyin';
  }
}
