import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'capsule_detail_screen.dart';
import 'create_capsule_screen.dart';
import 'capsule_model.dart';

class MyCapsulesScreen extends StatelessWidget {
  MyCapsulesScreen({super.key});

  final List<Capsule> capsules = [
    Capsule(
      id: '1',
      title: 'İlk Kapsülüm',
      imageUrl:
          'https://images.unsplash.com/photo-1506744038136-46273834b3fb?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80',
      createdAt: DateTime(2023, 5, 1),
      openAt: DateTime(2024, 7, 1),
      isOpened: false,
      mediaTypes: [MediaType.photo, MediaType.text],
      owner: 'Cihat',
    ),
    Capsule(
      id: '2',
      title: 'Doğum Günü Sürprizi',
      imageUrl:
          'https://images.unsplash.com/photo-1541533379473-3151c5d35a78?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1081&q=80',
      createdAt: DateTime(2023, 6, 10),
      openAt: DateTime(2024, 1, 1),
      isOpened: true,
      mediaTypes: [MediaType.video, MediaType.audio],
      owner: 'Ayşe',
    ),
    Capsule(
      id: '3',
      title: 'Yılbaşı Mesajı',
      imageUrl:
          'https://images.unsplash.com/photo-1513297887114-162092233b7f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80',
      createdAt: DateTime(2023, 12, 31),
      openAt: DateTime(2025, 1, 1),
      isOpened: false,
      mediaTypes: [MediaType.text],
      owner: 'Cihat',
    ),
  ];

  String formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  IconData _getMediaTypeIcon(MediaType type) {
    switch (type) {
      case MediaType.photo:
        return Icons.photo_camera;
      case MediaType.video:
        return Icons.videocam;
      case MediaType.audio:
        return Icons.mic;
      case MediaType.text:
        return Icons.article;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kapsüllerim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateCapsuleScreen(),
                  ),
                ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: capsules.length,
        itemBuilder: (context, index) {
          final capsule = capsules[index];
          final isLocked = !capsule.isOpened;
          final duration = capsule.openAt.difference(DateTime.now());

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CapsuleDetailScreen(capsule: capsule),
                ),
              );
            },
            child: Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child: Image.network(
                      capsule.imageUrl,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported, size: 150),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          capsule.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Sahibi: ${capsule.owner}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const Spacer(),
                            ...capsule.mediaTypes.map(
                              (type) => Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Icon(
                                  _getMediaTypeIcon(type),
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Oluşturulma',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey),
                                ),
                                Text(formatDate(capsule.createdAt)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Açılma Tarihi',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey),
                                ),
                                Text(formatDate(capsule.openAt)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isLocked
                              ? Colors.amber.shade100
                              : Colors.green.shade100,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(15),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isLocked
                              ? Icons.lock_outline
                              : Icons.lock_open_outlined,
                          size: 18,
                          color:
                              isLocked
                                  ? Colors.amber.shade800
                                  : Colors.green.shade800,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isLocked
                              ? '${duration.inDays} gün sonra açılacak'
                              : 'Kapsül Açık',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                isLocked
                                    ? Colors.amber.shade800
                                    : Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateCapsuleScreen(),
            ),
          );
        },
        label: const Text('Yeni Kapsül'),
        icon: const Icon(Icons.add),
        tooltip: 'Yeni Kapsül Oluştur',
      ),
    );
  }
}
