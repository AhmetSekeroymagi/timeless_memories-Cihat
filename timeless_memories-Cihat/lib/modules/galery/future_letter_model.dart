import 'package:flutter/material.dart';

class FutureLetter {
  final String id;
  final String content;
  final DateTime creationDate;
  final DateTime openDate;
  final String recipient; // 'Kendime' or email/username
  final bool isSent;
  final String? audioPath;
  final String? location;
  final String? coverImageUrl; // İsteğe bağlı kapak fotoğrafı

  FutureLetter({
    required this.id,
    required this.content,
    required this.creationDate,
    required this.openDate,
    required this.recipient,
    this.isSent = false,
    this.audioPath,
    this.location,
    this.coverImageUrl,
  });

  bool get isLocked => DateTime.now().isBefore(openDate);

  Duration get remainingTime => openDate.difference(DateTime.now());

  // Örnek veri oluşturmak için yardımcı fabrika
  static List<FutureLetter> generateSampleLetters() {
    return [
      FutureLetter(
        id: '1',
        content:
            'Sevgili gelecekteki ben, umarım hedeflerine ulaşmışsındır. Unutma, o zamanlar...',
        creationDate: DateTime.now().subtract(const Duration(days: 30)),
        openDate: DateTime.now().add(const Duration(days: 335)),
        recipient: 'Kendime',
        coverImageUrl:
            'https://images.unsplash.com/photo-1531531123414-b51cdae2f017?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1740&q=80',
      ),
      FutureLetter(
        id: '2',
        content:
            'Mezuniyet günün kutlu olsun! Bu mektubu yıllar önce yazdım, umarım kahkahalarla okuyorsundur.',
        creationDate: DateTime.now().subtract(const Duration(days: 1024)),
        openDate: DateTime.now().add(const Duration(days: 50)),
        recipient: 'kardesim@ornek.com',
        coverImageUrl:
            'https://images.unsplash.com/photo-1555949963-ff98c6265d42?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1740&q=80',
      ),
      FutureLetter(
        id: '3',
        content:
            'Bu mektup açıldığında 30 yaşında olacaksın. Hayat nasıl gidiyor? O arabayı alabildin mi?',
        creationDate: DateTime.now().subtract(const Duration(days: 300)),
        openDate: DateTime.now().subtract(
          const Duration(days: 10),
        ), // Kilidi açık bir mektup
        recipient: 'Kendime',
        audioPath: 'dogumgunu_mesaji.mp3',
        coverImageUrl:
            'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1740&q=80',
      ),
      FutureLetter(
        id: '4',
        content: 'Sadece bir test mektubu.',
        creationDate: DateTime.now().subtract(const Duration(days: 2)),
        openDate: DateTime.now().add(
          const Duration(minutes: 5),
        ), // Yakında açılacak
        recipient: 'test@ornek.com',
      ),
    ];
  }
}
