import 'package:flutter/material.dart';
import 'capsule_detail_screen.dart';

class Capsule {
  final String id;
  final String title;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime openAt;
  final bool isOpened;

  Capsule({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.createdAt,
    required this.openAt,
    required this.isOpened,
  });
}

class MyCapsulesScreen extends StatelessWidget {
  MyCapsulesScreen({Key? key}) : super(key: key);

  final List<Capsule> capsules = [
    Capsule(
      id: '1',
      title: 'İlk Kapsülüm',
      imageUrl: 'https://via.placeholder.com/100',
      createdAt: DateTime(2023, 5, 1),
      openAt: DateTime(2024, 7, 1),
      isOpened: false,
    ),
    Capsule(
      id: '2',
      title: 'Doğum Günü Sürprizi',
      imageUrl: 'https://via.placeholder.com/100',
      createdAt: DateTime(2023, 6, 10),
      openAt: DateTime(2024, 1, 1),
      isOpened: true,
    ),
    Capsule(
      id: '3',
      title: 'Yılbaşı Mesajı',
      imageUrl: 'https://via.placeholder.com/100',
      createdAt: DateTime(2023, 12, 31),
      openAt: DateTime(2025, 1, 1),
      isOpened: false,
    ),
  ];

  String formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kapsüllerim')),
      body: ListView.builder(
        itemCount: capsules.length,
        itemBuilder: (context, index) {
          final capsule = capsules[index];
          return GestureDetector(
            onTap: () {
              // Detay ekranına yönlendirme
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CapsuleDetailScreen(
                    title: capsule.title,
                    description: 'Bu kapsülün açıklaması (dummy)',
                    isLocked: !capsule.isOpened,
                    openAt: capsule.openAt,
                    photoUrl: capsule.imageUrl,
                    videoUrl: null,
                    audioUrl: null,
                    note: 'Bu kapsülün notu (dummy)',
                    location: 'İstanbul',
                  ),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    capsule.imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(capsule.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Oluşturulma: ${formatDate(capsule.createdAt)}'),
                    Text('Açılma: ${formatDate(capsule.openAt)}'),
                  ],
                ),
                trailing: capsule.isOpened
                    ? Chip(label: Text('🟢 Açıldı'))
                    : Chip(label: Text('📅 ${formatDate(capsule.openAt)}\'te açılacak')),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Kapsül oluşturma ekranına yönlendirme (şimdilik boş)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kapsül Oluştur butonuna tıklandı!')),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Kapsül Oluştur',
      ),
    );
  }
} 