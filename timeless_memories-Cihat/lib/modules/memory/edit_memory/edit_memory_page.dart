import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:timeless_memories/core/utils/date_formatter.dart';
import 'package:timeless_memories/modules/home/home.dart';
import 'package:timeless_memories/modules/service/memory_service.dart';

// 1. State class
class EditMemoryState {
  final TextEditingController descriptionController;
  final DateTime selectedDate;
  final bool isLoading;
  final String? errorMessage;

  EditMemoryState({
    required this.descriptionController,
    required this.selectedDate,
    this.isLoading = false,
    this.errorMessage,
  });

  EditMemoryState copyWith({
    DateTime? selectedDate,
    bool? isLoading,
    String? errorMessage,
  }) {
    return EditMemoryState(
      descriptionController: descriptionController,
      selectedDate: selectedDate ?? this.selectedDate,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// 2. StateNotifier
class EditMemoryNotifier extends StateNotifier<EditMemoryState> {
  final MemoryService _memoryService;
  final Map<String, dynamic> _initialMemory;

  EditMemoryNotifier(this._memoryService, this._initialMemory)
    : super(
        EditMemoryState(
          descriptionController: TextEditingController(
            text: _initialMemory['description'],
          ),
          selectedDate: (_initialMemory['memoryDate'] as dynamic).toDate(),
        ),
      );

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  Future<bool> saveChanges() async {
    state = state.copyWith(isLoading: true);
    try {
      await _memoryService.updateMemory(_initialMemory['id'], {
        'description': state.descriptionController.text,
        'memoryDate': state.selectedDate,
      });
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  @override
  void dispose() {
    state.descriptionController.dispose();
    super.dispose();
  }
}

// 3. Provider
final editMemoryProvider = StateNotifierProvider.family
    .autoDispose<EditMemoryNotifier, EditMemoryState, Map<String, dynamic>>((
      ref,
      memory,
    ) {
      final memoryService = ref.watch(memoryServiceProvider);
      return EditMemoryNotifier(memoryService, memory);
    });

// 4. Page Widget
class EditMemoryPage extends ConsumerWidget {
  final Map<String, dynamic> memory;

  const EditMemoryPage({super.key, required this.memory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editMemoryProvider(memory));
    final notifier = ref.read(editMemoryProvider(memory).notifier);
    final mediaWidgets = _buildMediaWidgets(memory);

    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (mediaWidgets.isNotEmpty) ...[
              SizedBox(height: 200, child: PageView(children: mediaWidgets)),
              const SizedBox(height: 24),
            ],
            _buildSectionTitle('Anı Açıklaması'),
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
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Anıyı Düzenle',
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

  List<Widget> _buildMediaWidgets(Map<String, dynamic> memory) {
    // Bu fonksiyonu home.dart'tan alıp uyarlıyoruz
    final mediaUrls = List<String>.from(memory['mediaUrls'] ?? []);
    final localMediaPaths = List<String>.from(memory['localMediaPaths'] ?? []);
    final isVideoList = List<bool>.from(memory['isVideoList'] ?? []);

    final List<Widget> widgets = [];
    if (localMediaPaths.isNotEmpty) {
      for (int i = 0; i < localMediaPaths.length; i++) {
        widgets.add(
          _mediaItem(
            path: localMediaPaths[i],
            isVideo: isVideoList.length > i ? isVideoList[i] : false,
            isLocal: true,
          ),
        );
      }
    } else if (mediaUrls.isNotEmpty) {
      for (int i = 0; i < mediaUrls.length; i++) {
        widgets.add(
          _mediaItem(
            path: mediaUrls[i],
            isVideo: isVideoList.length > i ? isVideoList[i] : false,
            isLocal: false,
          ),
        );
      }
    }
    return widgets;
  }

  Widget _mediaItem({
    required String path,
    required bool isVideo,
    required bool isLocal,
  }) {
    Widget media =
        isLocal
            ? Image.file(File(path), fit: BoxFit.cover)
            : Image.network(path, fit: BoxFit.cover);
    if (isVideo) {
      return Stack(
        alignment: Alignment.center,
        children: [media, const Icon(Icons.play_circle_outline, size: 50)],
      );
    }
    return ClipRRect(borderRadius: BorderRadius.circular(12), child: media);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
          fontFamily: GoogleFonts.inter().fontFamily,
        ),
      ),
    );
  }

  Widget _buildDescriptionField(EditMemoryState state) {
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
        maxLines: 5,
        maxLength: 500,
        textInputAction: TextInputAction.done,
      ),
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    EditMemoryState state,
    EditMemoryNotifier notifier,
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
              formatTurkishDate(state.selectedDate),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    EditMemoryState state,
    EditMemoryNotifier notifier,
  ) {
    return SizedBox(
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
            state.isLoading
                ? null
                : () async {
                  final success = await notifier.saveChanges();
                  if (success && context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Anı başarıyla güncellendi.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
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
                      'DEĞİŞİKLİKLERİ KAYDET',
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
    );
  }

  Widget _buildErrorMessage(String message) {
    // Bu fonksiyon add_image_and_video.dart'tan kopyalanabilir
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
}
