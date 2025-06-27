import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless_memories/modules/user/login/login_screen.dart';
import 'package:timeless_memories/modules/user/signup/state.dart';

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signupProvider);
    final notifier = ref.read(signupProvider.notifier);

    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: state.formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildLogo(),
                _buildTitle(),
                const SizedBox(height: 15),

                // Full Name Field
                _buildTextField(
                  controller: state.nameController,
                  labelText: 'Ad Soyad',
                  validator: notifier.validateName,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 12),

                // Username Field
                _buildTextField(
                  controller: state.usernameController,
                  labelText: 'Kullanıcı Adı',
                  validator: notifier.validateUsername,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 12),

                // Email Field
                _buildTextField(
                  controller: state.emailController,
                  labelText: 'E-posta',
                  validator: notifier.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),

                // Password Field
                _buildPasswordField(
                  controller: state.passwordController,
                  labelText: 'Şifre',
                  validator: notifier.validatePassword,
                  isObscured: state.isObscured,
                  onToggleVisibility: notifier.togglePasswordVisibility,
                ),
                const SizedBox(height: 12),

                // Confirm Password Field
                _buildPasswordField(
                  controller: state.confirmPasswordController,
                  labelText: 'Şifre Tekrar',
                  validator: notifier.validateConfirmPassword,
                  isObscured: state.isObscured,
                  onToggleVisibility: notifier.togglePasswordVisibility,
                ),
                const SizedBox(height: 20),

                _buildSignupButton(context, state, notifier),
                const SizedBox(height: 12),
                const Divider(color: Colors.black54, thickness: 1),
                const SizedBox(height: 12),
                _buildLoginSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Center(
        child: Text(
          'Timeless Memories',
          style: TextStyle(
            fontSize: 24,
            fontFamily: GoogleFonts.inter().fontFamily,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: const Color(0xFF07B183),
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

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/timeless_logo.png',
      width: 100,
      height: 100,
      color: Colors.black,
    );
  }

  Widget _buildTitle() {
    return Text(
      'Hesap Oluştur',
      style: TextStyle(
        fontSize: 24,
        fontFamily: GoogleFonts.inter().fontFamily,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String? Function(String?) validator,
    required TextInputType keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      cursorColor: Colors.black,
      decoration: _inputDecoration(labelText),
      validator: validator,
      keyboardType: keyboardType,
      textCapitalization:
          keyboardType == TextInputType.name
              ? TextCapitalization.words
              : TextCapitalization.none,
      textInputAction: TextInputAction.next,
      enableSuggestions: keyboardType != TextInputType.visiblePassword,
      autocorrect:
          keyboardType != TextInputType.visiblePassword &&
          keyboardType != TextInputType.emailAddress,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required String? Function(String?) validator,
    required bool isObscured,
    required VoidCallback onToggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      cursorColor: Colors.black,
      decoration: _inputDecoration(labelText).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            isObscured ? Icons.visibility_off : Icons.visibility,
            color: Colors.black,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
      obscureText: isObscured,
      validator: validator,
      textInputAction: TextInputAction.next,
      enableSuggestions: false,
      autocorrect: false,
    );
  }

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

  Widget _buildSignupButton(
    BuildContext context,
    SignupState state,
    SignupNotifier notifier,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: _signupButtonStyle(),
        onPressed:
            state.isLoading
                ? null
                : () => _handleSignup(context, notifier, state),
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
                      'Kayıt Ol',
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

  ButtonStyle _signupButtonStyle() {
    return ElevatedButton.styleFrom(
      padding: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ).copyWith(backgroundColor: MaterialStateProperty.all(Colors.transparent));
  }

  Future<void> _handleSignup(
    BuildContext context,
    SignupNotifier notifier,
    SignupState state,
  ) async {
    if (state.formKey.currentState?.validate() ?? false) {
      try {
        await notifier.handleSignup();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Kayıt başarılı! E-posta adresinize doğrulama linki gönderildi. Doğruladıktan sonra giriş yapabilirsiniz.',
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen tüm alanları doğru şekilde doldurunuz.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildLoginSection(BuildContext context) {
    return Column(
      children: [
        Text(
          'Zaten hesabın var mı?',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: GoogleFonts.inter().fontFamily,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF0D7055), width: 2),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          child: ElevatedButton(
            onPressed:
                () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            child: Text(
              "Giriş Yap",
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
}
