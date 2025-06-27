import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:timeless_memories/modules/service/storage_service.dart';

class MemoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StorageService _storageService = StorageService();

  User? get currentUser => _auth.currentUser;

  // Anı Ekle
  Future<String> addMemory(Map<String, dynamic> memoryData) async {
    try {
      if (currentUser == null) {
        throw Exception('Kullanıcı oturum açmamış');
      }

      // Anı tarihi için Timestamp oluştur
      final memoryDate = memoryData['memoryDate'] as DateTime;
      final selectedTimestamp = Timestamp.fromDate(memoryDate);

      // Firestore'a kaydedilecek veriyi hazırla
      final memoryDoc = {
        'userId': currentUser!.uid,
        'description': memoryData['description'], // Açıklama alanı
        'mediaUrls':
            memoryData['mediaUrls'] ??
            [], // Başlangıçta boş veya mevcut URL'ler
        'localMediaPaths':
            memoryData['localMediaPaths'] ?? [], // Yeni: Yerel yollar
        'isVideoList': memoryData['isVideoList'],
        'mediaCount': memoryData['mediaCount'],
        'createdAt': FieldValue.serverTimestamp(),
        'memoryDate': selectedTimestamp,
        'date': DateFormat('dd.MM.yyyy').format(memoryDate),
        'year': memoryDate.year,
        'month': memoryDate.month,
        'day': memoryDate.day,
        'lastModified': FieldValue.serverTimestamp(),
        'isPending':
            memoryData['isPending'] ?? false, // Yeni: Senkronizasyon durumu
      };

      // Firestore'a kaydet
      final docRef = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('memories')
          .add(memoryDoc);

      log('Anı başarıyla eklendi: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      log('Anı eklenemedi: $e');
      throw Exception('Memory addition failed: $e');
    }
  }

  // Tarihe göre anıları getir
  Stream<List<Map<String, dynamic>>> fetchMemoriesByDate(DateTime date) {
    try {
      if (currentUser == null) {
        throw Exception('Kullanıcı oturum açmamış');
      }

      return _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('memories')
          .where('year', isEqualTo: date.year)
          .where('month', isEqualTo: date.month)
          .where('day', isEqualTo: date.day)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                'description': data['description'], // Açıklama alanını al
                ...data,
              };
            }).toList();
          });
    } catch (e) {
      log('Anılar getirilemedi: $e');
      throw Exception('Fetching memories failed: $e');
    }
  }

  // Anılar Listesini Getir (Stream ile)
  Stream<List<Map<String, dynamic>>> fetchMemories() {
    try {
      if (currentUser == null) {
        throw Exception('Kullanıcı oturum açmamış');
      }

      return _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('memories')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .asyncMap((snapshot) async {
            final List<Map<String, dynamic>> memories = [];

            for (var doc in snapshot.docs) {
              final data = doc.data();
              final userId = data['userId'];

              // Kullanıcı bilgilerini çek
              final userDoc =
                  await _firestore.collection('users').doc(userId).get();

              if (userDoc.exists) {
                final userData = userDoc.data()!;
                memories.add({
                  'id': doc.id,
                  'userName': userData['name'] ?? 'İsimsiz Kullanıcı',
                  'userPhotoUrl': userData['photoUrl'],
                  ...data,
                });
              } else {
                memories.add({
                  'id': doc.id,
                  'userName': 'İsimsiz Kullanıcı',
                  ...data,
                });
              }
            }
            return memories;
          });
    } catch (e) {
      log('Anılar getirilemedi: $e');
      throw Exception('Fetching memories failed: $e');
    }
  }

  // Anı Güncelle
  Future<void> updateMemory(String memoryId, Map<String, dynamic> data) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'Kullanıcı oturumu bulunamadı';

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('memories')
          .doc(memoryId)
          .update({...data, 'lastModified': FieldValue.serverTimestamp()});
    } catch (e) {
      debugPrint('❌ Anı güncelleme hatası: $e');
      rethrow;
    }
  }

  // Anı Sil
  Future<void> deleteMemory(String id) async {
    try {
      if (currentUser == null) {
        throw Exception('Kullanıcı oturum açmamış');
      }

      final docRef = _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('memories')
          .doc(id);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        final localPaths = List<String>.from(data['localMediaPaths'] ?? []);
        // Silmeden önce yerel dosyaları temizle
        await _deleteLocalFiles(localPaths);
      }

      // Storage'dan ilgili klasörü sil
      await _storageService.deleteMemoryFolder(currentUser!.uid, id);

      // Sonra Firestore'dan anıyı sil
      await docRef.delete();

      log('Anı tamamen silindi: $id');
    } catch (e) {
      log('Anı silinemedi: $e');
      throw Exception('Memory deletion failed: $e');
    }
  }

  Future<void> _deleteLocalFiles(List<String> paths) async {
    for (final path in paths) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
          log('🗑️ Yerel dosya temizlendi: $path');
        }
      } catch (e) {
        log('🗑️ Yerel dosya temizlenirken hata oluştu: $e');
      }
    }
  }

  // Beklemedeki anıları senkronize et
  Future<void> syncPendingMemories() async {
    if (currentUser == null) return;

    log('🔄 Beklemedeki anılar senkronize ediliyor...');

    try {
      final querySnapshot =
          await _firestore
              .collection('users')
              .doc(currentUser!.uid)
              .collection('memories')
              .where('isPending', isEqualTo: true)
              .get();

      if (querySnapshot.docs.isEmpty) {
        log('✅ Senkronize edilecek anı bulunamadı.');
        return;
      }

      log('${querySnapshot.docs.length} adet anı senkronize edilecek.');

      for (final doc in querySnapshot.docs) {
        final memoryId = doc.id;
        final data = doc.data();
        final localPaths = List<String>.from(data['localMediaPaths'] ?? []);

        if (localPaths.isEmpty) {
          await doc.reference.update({'isPending': false});
          continue;
        }

        try {
          final List<String> uploadedUrls = await _storageService
              .uploadMultipleMedia(localPaths, currentUser!.uid, memoryId);

          await doc.reference.update({
            'mediaUrls': FieldValue.arrayUnion(uploadedUrls),
            'localMediaPaths': [],
            'isPending': false,
            'lastModified': FieldValue.serverTimestamp(),
          });
          log('✅ Anı başarıyla senkronize edildi: $memoryId');

          // Senkronizasyon sonrası yerel dosyaları temizle
          await _deleteLocalFiles(localPaths);
        } catch (e) {
          log(
            '❌ Anı senkronizasyonu sırasında hata oluştu: $memoryId, Hata: $e',
          );
          // Hata durumunda döngüye devam et, diğerlerini etkileme
        }
      }
    } on FirebaseException catch (e) {
      log('🔥 Firestore hatası: Beklemedeki anılar getirilemedi: ${e.message}');
    } catch (e) {
      log('💣 Beklenmedik hata: $e');
    }
  }
}
