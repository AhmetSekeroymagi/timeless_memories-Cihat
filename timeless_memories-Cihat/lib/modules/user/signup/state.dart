import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeless_memories/modules/service/auth_service.dart';

// Signup durumu için state sınıfı
class SignupState {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController nameController;
  final TextEditingController usernameController;
  final bool isObscured;
  final bool isLoading;

  SignupState({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.nameController,
    required this.usernameController,
    required this.isObscured,
    required this.isLoading,
  });

  // State'i güncellemek için copyWith metodu
  SignupState copyWith({
    GlobalKey<FormState>? formKey,
    TextEditingController? emailController,
    TextEditingController? passwordController,
    TextEditingController? confirmPasswordController,
    TextEditingController? nameController,
    TextEditingController? usernameController,
    bool? isObscured,
    bool? isLoading,
  }) {
    return SignupState(
      formKey: formKey ?? this.formKey,
      emailController: emailController ?? this.emailController,
      passwordController: passwordController ?? this.passwordController,
      confirmPasswordController:
          confirmPasswordController ?? this.confirmPasswordController,
      nameController: nameController ?? this.nameController,
      usernameController: usernameController ?? this.usernameController,
      isObscured: isObscured ?? this.isObscured,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Signup işlemlerini yöneten Notifier sınıfı
class SignupNotifier extends StateNotifier<SignupState> {
  SignupNotifier(this._authService)
    : super(
        SignupState(
          formKey: GlobalKey<FormState>(),
          emailController: TextEditingController(),
          passwordController: TextEditingController(),
          confirmPasswordController: TextEditingController(),
          nameController: TextEditingController(),
          usernameController: TextEditingController(),
          isObscured: true,
          isLoading: false,
        ),
      );

  final AuthService _authService;

  // Kayıt işlemini handle eden metod
  Future<void> handleSignup() async {
    if (state.formKey.currentState?.validate() ?? false) {
      try {
        state = state.copyWith(isLoading: true);

        if (state.passwordController.text !=
            state.confirmPasswordController.text) {
          throw Exception('Şifreler eşleşmiyor');
        }

        if (state.nameController.text.isEmpty ||
            state.usernameController.text.isEmpty ||
            state.emailController.text.isEmpty ||
            state.passwordController.text.isEmpty) {
          throw Exception('Lütfen tüm alanları doldurunuz');
        }

        await _authService.createUser(
          email: state.emailController.text.trim(),
          password: state.passwordController.text,
          confirmPassword: state.confirmPasswordController.text,
          name: state.nameController.text.trim(),
          username: state.usernameController.text.trim(),
        );

        _clearFormFields();
      } catch (e) {
        debugPrint('❌ Kayıt hatası: $e');
        rethrow;
      } finally {
        if (mounted) {
          state = state.copyWith(isLoading: false);
        }
      }
    } else {
      throw Exception('Lütfen tüm alanları doğru şekilde doldurunuz');
    }
  }

  // Form validasyonları
  String? validateEmail(String? value) => _authService.validateEmail(value);
  String? validatePassword(String? value) =>
      _authService.validatePassword(value);
  String? validateName(String? value) => _authService.validateName(value);
  String? validateUsername(String? value) =>
      _authService.validateUsername(value);

  // Şifre tekrarı validasyonu
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı boş bırakılamaz';
    }
    if (value != state.passwordController.text) {
      return 'Şifreler eşleşmiyor';
    }
    return null;
  }

  // Şifre görünürlüğünü değiştir
  void togglePasswordVisibility() {
    state = state.copyWith(isObscured: !state.isObscured);
  }

  // Form alanlarını temizle
  void _clearFormFields() {
    state.emailController.clear();
    state.passwordController.clear();
    state.confirmPasswordController.clear();
    state.nameController.clear();
    state.usernameController.clear();
  }

  // Controller'ları dispose et
  @override
  void dispose() {
    state.emailController.dispose();
    state.passwordController.dispose();
    state.confirmPasswordController.dispose();
    state.nameController.dispose();
    state.usernameController.dispose();
    super.dispose();
  }
}

// Provider tanımlaması
final signupProvider = StateNotifierProvider<SignupNotifier, SignupState>((
  ref,
) {
  final authService = ref.watch(authServiceProvider);
  return SignupNotifier(authService);
});
