import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeless_memories/modules/service/auth_service.dart';

// Sadeleştirilmiş login state sınıfı
class LoginState {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isObscured;
  final bool isLoading;

  LoginState({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isObscured,
    required this.isLoading,
  });

  // State güncelleme metodu
  LoginState copyWith({
    GlobalKey<FormState>? formKey,
    TextEditingController? emailController,
    TextEditingController? passwordController,
    bool? isObscured,
    bool? isLoading,
  }) {
    return LoginState(
      formKey: formKey ?? this.formKey,
      emailController: emailController ?? this.emailController,
      passwordController: passwordController ?? this.passwordController,
      isObscured: isObscured ?? this.isObscured,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Sadeleştirilmiş login notifier
class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier(this._authService)
    : super(
        LoginState(
          formKey: GlobalKey<FormState>(),
          emailController: TextEditingController(),
          passwordController: TextEditingController(),
          isObscured: true,
          isLoading: false,
        ),
      );

  final AuthService _authService;

  @override
  void dispose() {
    state.emailController.dispose();
    state.passwordController.dispose();
    super.dispose();
  }

  // Şifre görünürlüğü
  void togglePasswordVisibility() {
    state = state.copyWith(isObscured: !state.isObscured);
  }

  // E-posta doğrulama
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bu alan boş bırakılamaz';
    }
    return null;
  }

  // Şifre doğrulama
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre boş bırakılamaz';
    }
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır';
    }
    return null;
  }

  // Giriş işlemi
  Future<void> handleLogin() async {
    if (state.formKey.currentState?.validate() ?? false) {
      try {
        if (state.emailController.text.isEmpty ||
            state.passwordController.text.isEmpty) {
          throw Exception('Tüm alanları doldurunuz');
        }

        await _authService.loginUser(
          email: state.emailController.text.trim(),
          password: state.passwordController.text,
        );
      } catch (e) {
        debugPrint('❌ Giriş hatası: $e');
        rethrow;
      }
    } else {
      throw Exception('Lütfen tüm alanları doğru şekilde doldurunuz');
    }
  }
}

// Provider tanımı
final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return LoginNotifier(authService);
});
