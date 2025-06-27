import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:timeless_memories/modules/service/storage_service.dart';
import 'package:timeless_memories/modules/service/memory_service.dart';

// AddImage State sınıfı
class AddImageState {
  final GlobalKey<FormState> formKey;
  final TextEditingController descriptionController;
  final List<XFile> selectedMedia;
  final List<bool> isVideoList;
  final bool isLoading;
  final String? errorMessage;
  final DateTime selectedDate;
  final double? uploadProgress;

  AddImageState({
    required this.formKey,
    required this.descriptionController,
    this.selectedMedia = const [],
    this.isVideoList = const [],
    this.isLoading = false,
    this.errorMessage,
    DateTime? selectedDate,
    this.uploadProgress,
  }) : selectedDate = selectedDate ?? DateTime.now();

  // State güncelleme metodu
  AddImageState copyWith({
    GlobalKey<FormState>? formKey,
    TextEditingController? descriptionController,
    List<XFile>? selectedMedia,
    List<bool>? isVideoList,
    bool? isLoading,
    String? errorMessage,
    DateTime? selectedDate,
    double? uploadProgress,
  }) {
    return AddImageState(
      formKey: formKey ?? this.formKey,
      descriptionController:
          descriptionController ?? this.descriptionController,
      selectedMedia: selectedMedia ?? this.selectedMedia,
      isVideoList: isVideoList ?? this.isVideoList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedDate: selectedDate ?? this.selectedDate,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}

// AddImage Notifier sınıfı
class AddImageNotifier extends StateNotifier<AddImageState> {
  final StorageService _storageService = StorageService();
  final MemoryService _memoryService = MemoryService();

  AddImageNotifier()
    : super(
        AddImageState(
          formKey: GlobalKey<FormState>(),
          descriptionController: TextEditingController(),
        ),
      );

  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    state.descriptionController.dispose();
    super.dispose();
  }

  Future<String> _copyFileToPermanentDirectory(XFile file) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String fileName = p.basename(file.path);
    final String savedPath = p.join(appDir.path, 'media', fileName);
    final Directory mediaDir = Directory(p.join(appDir.path, 'media'));

    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    final File savedFile = await File(file.path).copy(savedPath);
    return savedFile.path;
  }

  // Medya seçme metodu
  Future<void> pickMedia(ImageSource source, bool isVideo) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final XFile? media;

      if (isVideo) {
        media = await _picker.pickVideo(
          source: source,
          maxDuration: const Duration(minutes: 10),
        );
      } else {
        media = await _picker.pickImage(
          source: source,
          maxWidth: 1800,
          maxHeight: 1800,
          imageQuality: 85,
        );
      }

      if (media == null) return;

      final permanentPath = await _copyFileToPermanentDirectory(media);
      final permanentXFile = XFile(permanentPath);

      state = state.copyWith(
        selectedMedia: [...state.selectedMedia, permanentXFile],
        isVideoList: [...state.isVideoList, isVideo],
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Medya seçilemedi: ${e.toString()}',
        selectedMedia: null,
      );
      debugPrint('Medya seçme hatası: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> pickFromGallery(BuildContext context) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Show file picker that accepts both images and videos
      final XFile? pickedFile = await _picker.pickMedia(
        imageQuality: 85,
        maxWidth: 1800,
        maxHeight: 1800,
      );

      if (pickedFile != null) {
        final permanentPath = await _copyFileToPermanentDirectory(pickedFile);
        final permanentXFile = XFile(permanentPath);
        final isVideo =
            permanentXFile.path.toLowerCase().endsWith('.mp4') ||
            permanentXFile.path.toLowerCase().endsWith('.mov');

        state = state.copyWith(
          selectedMedia: [...state.selectedMedia, permanentXFile],
          isVideoList: [...state.isVideoList, isVideo],
          errorMessage: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Medya seçilemedi: ${e.toString()}',
        selectedMedia: null,
      );
      debugPrint('Medya seçme hatası: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Başlık doğrulama
  String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Başlık boş bırakılamaz';
    }
    return null;
  }

  Future<String> uploadMediaToStorage(
    File mediaFile,
    String memoryId,
    int index,
    String userId,
  ) async {
    final int maxFileSizeBytes = 100 * 1024 * 1024; // 100MB limit
    final fileSize = await mediaFile.length();

    if (fileSize > maxFileSizeBytes) {
      throw Exception('Dosya boyutu 100MB\'dan büyük olamaz');
    }

    final String fileExtension = mediaFile.path.split('.').last;
    final storageRef = _storage.ref().child(
      'users/$userId/memories/$memoryId/$index.$fileExtension',
    );

    try {
      final uploadTask = storageRef.putFile(mediaFile);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        state = state.copyWith(uploadProgress: progress);
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('Upload error: $e');
      throw Exception('Medya yüklenemedi: $e');
    }
  }

  // State'i sıfırlama metodu ekle
  void resetState() {
    state = AddImageState(
      formKey: GlobalKey<FormState>(),
      descriptionController: TextEditingController(),
    );
  }

  // Anı kaydetme metodu
  Future<bool> saveMemory() async {
    if (state.selectedMedia.isEmpty) {
      state = state.copyWith(errorMessage: 'Lütfen bir medya seçin');
      return false;
    }

    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        state = state.copyWith(errorMessage: 'Kullanıcı oturum açmamış');
        return false;
      }

      final List<String> localPaths =
          state.selectedMedia.map((media) => media.path).toList();

      final memoryData = {
        'description': state.descriptionController.text,
        'localMediaPaths': localPaths,
        'isVideoList': state.isVideoList,
        'mediaCount': localPaths.length,
        'memoryDate': state.selectedDate,
        'isPending': true,
        'mediaUrls': [], // Başlangıçta boş
      };

      await _memoryService.addMemory(memoryData);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Anı kaydedilemedi: $e',
      );
      debugPrint('Anı kaydetme hatası: $e');
      return false;
    }
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }
}

// Provider tanımı
final addImageProvider =
    StateNotifierProvider.autoDispose<AddImageNotifier, AddImageState>(
      (ref) => AddImageNotifier(),
    );
