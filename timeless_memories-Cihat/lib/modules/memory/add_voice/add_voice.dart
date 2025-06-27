import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'state.dart';

class AddVoicePage extends ConsumerWidget {
  const AddVoicePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addVoiceProvider);
    final notifier = ref.read(addVoiceProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sesli Anı Ekle',
          style: TextStyle(
            fontSize: 20,
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildVoiceRecorder(state, notifier),
            const SizedBox(height: 16),
            _buildDescriptionField(state),
            const Spacer(),
            if (state.errorMessage != null)
              _buildErrorMessage(state.errorMessage!),
            _buildSaveButton(context, state, notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceRecorder(AddVoiceState state, AddVoiceNotifier notifier) {
    return GestureDetector(
      onTap: () async {
        if (state.isRecording) {
          await notifier.stopRecording();
        } else if (state.audioPath == null) {
          await notifier.startRecording();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(
              state.audioPath != null ? Icons.mic : Icons.mic_none,
              color: state.isRecording ? Colors.red : const Color(0xFF07B183),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              state.audioPath != null
                  ? 'Ses Kaydı Alındı'
                  : state.isRecording
                  ? 'Kaydı Durdur'
                  : 'Kaydetmek için dokun',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
                fontFamily: GoogleFonts.inter().fontFamily,
              ),
            ),
            if (state.audioPath != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => notifier.deleteAudio(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField(AddVoiceState state) {
    return TextFormField(
      controller: state.descriptionController,
      cursorColor: Colors.black,
      decoration: _inputDecoration('Bir açıklama ekle...'),
      maxLines: 5,
      textInputAction: TextInputAction.done,
    );
  }

  Widget _buildErrorMessage(String message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red[50],
          border: Border.all(color: Colors.red[300]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: Colors.red[700],
            fontFamily: GoogleFonts.inter().fontFamily,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    AddVoiceState state,
    AddVoiceNotifier notifier,
  ) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed:
            state.isLoading ? null : () => _saveVoiceMemory(context, notifier),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF07B183),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        child:
            state.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                  'KAYDET',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.inter().fontFamily,
                  ),
                ),
      ),
    );
  }

  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(
        color: Colors.grey[700],
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF07B183), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }

  Future<void> _saveVoiceMemory(
    BuildContext context,
    AddVoiceNotifier notifier,
  ) async {
    if (!context.mounted) return;

    final success = await notifier.saveVoiceMemory();

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ses kaydı başarıyla kaydedildi'),
          backgroundColor: Colors.green,
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted) {
          Navigator.pop(context);
        }
      });
    }
  }
}
