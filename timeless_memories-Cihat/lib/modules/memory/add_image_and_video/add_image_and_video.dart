import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timeless_memories/modules/memory/add_image_and_video/state.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:timeless_memories/core/utils/date_formatter.dart';

class AddImagePage extends ConsumerWidget {
  const AddImagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addImageProvider);
    final notifier = ref.read(addImageProvider.notifier);

    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(context, state, notifier),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Yeni Anı',
        style: TextStyle(
          fontSize: 20,
          fontFamily: GoogleFonts.inter().fontFamily,
          fontWeight: FontWeight.w600,
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

  Widget _buildBody(
    BuildContext context,
    AddImageState state,
    AddImageNotifier notifier,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImageSelector(context, state, notifier),
          const SizedBox(height: 16),
          // Açıklama metni için başlık
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Anı Açıklaması',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
                fontFamily: GoogleFonts.inter().fontFamily,
              ),
            ),
          ),
          _buildDescriptionField(state),
          const SizedBox(height: 24),
          _buildDatePicker(context, state, notifier),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 16),
            _buildErrorMessage(state.errorMessage!),
          ],
          const SizedBox(height: 36),
          _buildSaveButton(context, state, notifier),
        ],
      ),
    );
  }

  Widget _buildImageSelector(
    BuildContext context,
    AddImageState state,
    AddImageNotifier notifier,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap:
              state.selectedMedia.length >= 5
                  ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('En fazla 5 medya ekleyebilirsiniz'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  : () => _showMediaSourceOptions(context, notifier),
          child: SizedBox(
            width: 350,
            height: 200,
            child: DottedBorder(
              borderType: BorderType.RRect,
              radius: const Radius.circular(12),
              color: Colors.blueGrey,
              strokeWidth: 2,
              dashPattern: const [8, 4],
              child:
                  state.selectedMedia.isEmpty
                      ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              size: 36,
                              color: Color(0xFF0D7055),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Fotoğraf veya Video Ekle',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      )
                      : PageView.builder(
                        itemCount: state.selectedMedia.length,
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child:
                                state.isVideoList[index]
                                    ? Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.file(
                                          File(state.selectedMedia[index].path),
                                          width: 350,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        ),
                                        const Icon(
                                          Icons.play_circle_outline,
                                          size: 50,
                                          color: Colors.white,
                                        ),
                                      ],
                                    )
                                    : Image.file(
                                      File(state.selectedMedia[index].path),
                                      width: 350,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                          );
                        },
                      ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (state.selectedMedia.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${state.selectedMedia.length}/5 medya seçildi',
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
              IconButton(
                icon: const Icon(
                  Icons.add_photo_alternate,
                  color: Colors.blueGrey,
                ),
                onPressed:
                    state.selectedMedia.length >= 5
                        ? null
                        : () => _showMediaSourceOptions(context, notifier),
              ),
            ],
          ),
      ],
    );
  }

  void _showMediaSourceOptions(
    BuildContext context,
    AddImageNotifier notifier,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Medya Seç',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                    color: Color(0xFF07B183),
                  ),
                  title: const Text('Kamera ile Çek'),
                  onTap: () {
                    Navigator.pop(context);
                    notifier.pickMedia(ImageSource.camera, false);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: Color(0xFF07B183),
                  ),
                  title: const Text('Fotoğraf veya Video Seç'),
                  onTap: () {
                    Navigator.pop(context);
                    notifier.pickFromGallery(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    AddImageState state,
    AddImageNotifier notifier,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: state.selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF0A906C),
                  onPrimary: Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          notifier.selectDate(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFF0A906C)),
            const SizedBox(width: 12),
            Text(
              formatTurkishDate(state.selectedDate), // Değişen kısım
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField(AddImageState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextFormField(
        controller: state.descriptionController,
        cursorColor: const Color(0xFF0A906C),
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Bu anıyla ilgili bir şeyler yaz...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
          contentPadding: const EdgeInsets.all(16),
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
            borderSide: const BorderSide(color: Color(0xFF0A906C), width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        maxLines: 4,
        maxLength: 500, // Maksimum karakter sınırı
        textInputAction: TextInputAction.done,
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
    AddImageState state,
    AddImageNotifier notifier,
  ) {
    return Column(
      children: [
        if (state.uploadProgress != null && state.uploadProgress! > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: state.uploadProgress,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF07B183),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Yükleniyor: ${(state.uploadProgress! * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        SizedBox(
          height: 60,
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ).copyWith(
              backgroundColor: MaterialStateProperty.all(Colors.transparent),
            ),
            onPressed:
                state.isLoading ? null : () => _saveMemory(context, notifier),
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
                          'KAYDET',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                        ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveMemory(
    BuildContext context,
    AddImageNotifier notifier,
  ) async {
    if (!context.mounted) return;

    final success = await notifier.saveMemory();

    if (success && context.mounted) {
      // Yükleme başarılı olduğunda state'i sıfırla
      notifier.resetState();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anı başarıyla kaydedildi'),
          backgroundColor: Colors.green,
        ),
      );

      // Gecikmeli pop işlemini kaldır, direkt yönlendir
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }
}
