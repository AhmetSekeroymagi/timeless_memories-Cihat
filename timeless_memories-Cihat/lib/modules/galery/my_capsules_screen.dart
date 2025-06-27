import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'capsule_detail_screen.dart';
import 'create_capsule_screen.dart';
import 'capsule_model.dart';

class MyCapsulesScreen extends StatefulWidget {
  const MyCapsulesScreen({super.key});

  @override
  State<MyCapsulesScreen> createState() => _MyCapsulesScreenState();
}

class _MyCapsulesScreenState extends State<MyCapsulesScreen> {
  // Kapsül listesi artık state içinde yönetiliyor
  final List<Capsule> _capsules = [
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

  Future<void> _navigateToCreateCapsule() async {
    final newCapsule = await Navigator.push<Capsule>(
      context,
      MaterialPageRoute(builder: (context) => const CreateCapsuleScreen()),
    );

    if (newCapsule != null) {
      setState(() {
        _capsules.insert(0, newCapsule);
      });
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Kapsül başarıyla oluşturuldu ve eklendi!'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kapsüllerim'),
        // AppBar'daki + butonu kaldırıldı, FAB yeterli
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _capsules.length,
        itemBuilder: (context, index) {
          final capsule = _capsules[index];
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
                          capsule.openAt.isAfter(DateTime.now())
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
                          capsule.openAt.isAfter(DateTime.now())
                              ? Icons.lock_outline
                              : Icons.lock_open_outlined,
                          size: 18,
                          color:
                              capsule.openAt.isAfter(DateTime.now())
                                  ? Colors.amber.shade800
                                  : Colors.green.shade800,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          capsule.openAt.isAfter(DateTime.now())
                              ? '${capsule.openAt.difference(DateTime.now()).inDays} gün sonra açılacak'
                              : 'Kapsül Açık',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                capsule.openAt.isAfter(DateTime.now())
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
        onPressed: _navigateToCreateCapsule,
        label: const Text('Yeni Kapsül'),
        icon: const Icon(Icons.add),
        tooltip: 'Yeni Kapsül Oluştur',
      ),
    );
  }
}
