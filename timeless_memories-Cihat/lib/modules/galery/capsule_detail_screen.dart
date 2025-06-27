import 'package:flutter/material.dart';

class CapsuleDetailScreen extends StatelessWidget {
  final String title;
  final String description;
  final bool isLocked;
  final DateTime openAt;
  final String? photoUrl;
  final String? videoUrl;
  final String? audioUrl;
  final String? note;
  final String? location;

  const CapsuleDetailScreen({
    Key? key,
    required this.title,
    required this.description,
    required this.isLocked,
    required this.openAt,
    this.photoUrl,
    this.videoUrl,
    this.audioUrl,
    this.note,
    this.location,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kapsül Detayı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Paylaş',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Paylaş butonuna tıklandı!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Düzenle',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Düzenle butonuna tıklandı!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Sil',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sil butonuna tıklandı!')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            if (isLocked)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_clock, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text('⏳ ${openAt.day}.${openAt.month}.${openAt.year} tarihine kadar açılamaz'),
                  ],
                ),
              )
            else ...[
              if (photoUrl != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text('Fotoğraf:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(photoUrl!, height: 180, fit: BoxFit.cover),
                    ),
                  ],
                ),
              if (videoUrl != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text('Video:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      height: 180,
                      color: Colors.black12,
                      child: const Center(child: Icon(Icons.videocam, size: 48)),
                    ),
                    const Text('(Video oynatıcı dummy)'),
                  ],
                ),
              if (audioUrl != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text('Ses:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      height: 56,
                      color: Colors.black12,
                      child: const Center(child: Icon(Icons.audiotrack, size: 32)),
                    ),
                    const Text('(Ses çalar dummy)'),
                  ],
                ),
              if (note != null && note!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text('Metin Notu:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(note!),
                    ),
                  ],
                ),
              if (location != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text('Konum:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      height: 120,
                      color: Colors.blue[50],
                      child: const Center(child: Icon(Icons.map, size: 48, color: Colors.blue)),
                    ),
                    Text('(Harita dummy) $location'),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// Dummy kapsül ile örnek kullanım:
// Navigator.push(context, MaterialPageRoute(
//   builder: (context) => CapsuleDetailScreen(
//     title: 'İlk Kapsülüm',
//     description: 'Bu bir örnek kapsüldür.',
//     isLocked: false,
//     openAt: DateTime(2024, 7, 1),
//     photoUrl: 'https://via.placeholder.com/100',
//     videoUrl: null,
//     audioUrl: null,
//     note: 'Bu kapsülün notu.',
//     location: 'İstanbul',
//   ),
// )); 