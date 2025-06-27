import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

typedef ProgressCallback = void Function(double progress);

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final int maxFileSizeBytes = 100 * 1024 * 1024; // 100MB

  User? get currentUser => _auth.currentUser;

  Future<String> uploadMediaWithProgress(
    String filePath,
    String userId,
    String memoryId,
    String fileName, {
    ProgressCallback? onProgress,
  }) async {
    try {
      if (currentUser == null || currentUser!.uid != userId) {
        throw Exception('Yetkilendirme hatası');
      }

      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Dosya bulunamadı');
      }

      final fileSize = await file.length();
      if (fileSize > maxFileSizeBytes) {
        throw Exception('Dosya boyutu çok büyük');
      }

      final String path = 'users/$userId/memories/$memoryId/$fileName';
      final ref = _storage.ref().child(path);

      final metadata = SettableMetadata(
        contentType:
            fileName.toLowerCase().endsWith('.mp4')
                ? 'video/mp4'
                : 'image/jpeg',
        customMetadata: {'userId': userId, 'memoryId': memoryId},
      );

      final uploadTask = ref.putFile(file, metadata);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      log('Firebase Storage hatası: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Genel yükleme hatası: $e');
      rethrow;
    }
  }

  Future<List<String>> uploadMultipleMedia(
    List<String> filePaths,
    String userId,
    String memoryId, {
    ProgressCallback? onProgress,
  }) async {
    try {
      final List<String> downloadUrls = [];
      double totalProgress = 0;

      for (int i = 0; i < filePaths.length; i++) {
        try {
          final fileName = 'media_$i.${filePaths[i].split('.').last}';
          final url = await uploadMediaWithProgress(
            filePaths[i],
            userId,
            memoryId,
            fileName,
            onProgress: (progress) {
              totalProgress = (i + progress) / filePaths.length;
              onProgress?.call(totalProgress);
            },
          );
          downloadUrls.add(url);
        } catch (e) {
          log('Medya $i yüklenemedi: $e');
          continue;
        }
      }

      if (downloadUrls.isEmpty) {
        throw Exception('Hiçbir medya yüklenemedi');
      }

      return downloadUrls;
    } catch (e) {
      log('Toplu yükleme hatası: $e');
      rethrow;
    }
  }

  Future<void> deleteMemoryFolder(String userId, String memoryId) async {
    try {
      final Reference ref = _storage.ref().child(
        'users/$userId/memories/$memoryId',
      );
      final ListResult result = await ref.listAll();

      await Future.wait([
        ...result.items.map((item) => item.delete()),
        ...result.prefixes.map((prefix) => deleteFolder(prefix)),
      ]);

      log('Anı klasörü silindi: $memoryId');
    } catch (e) {
      log('Klasör silme hatası: $e');
      throw Exception('Anı klasörü silinemedi: $e');
    }
  }

  Future<void> deleteFolder(Reference folderRef) async {
    final ListResult result = await folderRef.listAll();
    await Future.wait([
      ...result.items.map((item) => item.delete()),
      ...result.prefixes.map((prefix) => deleteFolder(prefix)),
    ]);
  }
}
