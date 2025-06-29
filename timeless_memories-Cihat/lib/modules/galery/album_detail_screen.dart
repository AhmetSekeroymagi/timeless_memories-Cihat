import 'package:flutter/material.dart';
import 'album_model.dart';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AlbumDetailScreen extends StatefulWidget {
  final Album album;
  const AlbumDetailScreen({Key? key, required this.album}) : super(key: key);

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  late Album album;

  @override
  void initState() {
    super.initState();
    album = widget.album;
  }

  bool get isLocked {
    if (album.type == AlbumType.time && album.unlockTime != null) {
      return DateTime.now().isBefore(album.unlockTime!);
    }
    if (album.type == AlbumType.location &&
        album.latitude != null &&
        album.longitude != null) {
      // Dummy: Kullanıcı konumu sabit, mesafe 300m (kilitli)
      double userLat = 41.0082;
      double userLon = 28.9784;
      double dist = _calculateDistance(
        userLat,
        userLon,
        album.latitude!,
        album.longitude!,
      );
      return dist > 0.2; // 200 metre
    }
    return false;
  }

  double _calculateDistance(lat1, lon1, lat2, lon2) {
    const double R = 6371; // km
    double dLat = _deg2rad(lat2 - lat1);
    double dLon = _deg2rad(lon2 - lon1);
    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  void _addContent(String type) {
    setState(() {
      album.contents.add(
        AlbumContent(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: type,
          urlOrText:
              type == 'text'
                  ? 'Yeni metin notu'
                  : 'https://via.placeholder.com/100',
          createdAt: DateTime.now(),
        ),
      );
    });
  }

  void _addPhoto() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        album.contents.add(
          AlbumContent(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: 'photo',
            urlOrText: pickedFile.path, // Cihazdan seçilen fotoğrafın yolu
            createdAt: DateTime.now(),
          ),
        );
      });
    }
  }

  void _addVideo() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        album.contents.add(
          AlbumContent(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: 'video',
            urlOrText: pickedFile.path, // Cihazdan seçilen video yolu
            createdAt: DateTime.now(),
          ),
        );
      });
    }
  }

  void _addText() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Metin Ekle'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Metin'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      setState(() {
        album.contents.add(
          AlbumContent(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: 'text',
            urlOrText: result.trim(),
            createdAt: DateTime.now(),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(album.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLocked)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      album.type == AlbumType.time
                          ? '⏳ ${album.unlockTime!.day}.${album.unlockTime!.month}.${album.unlockTime!.year} tarihine kadar kilitli'
                          : '📍 Konuma yaklaşınca açılacak',
                    ),
                  ],
                ),
              )
            else ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _addPhoto,
                      icon: const Icon(Icons.photo),
                      label: const Text('Fotoğraf'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _addVideo,
                      icon: const Icon(Icons.videocam),
                      label: const Text('Video'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _addContent('audio'),
                      icon: const Icon(Icons.mic),
                      label: const Text('Ses'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _addText,
                      icon: const Icon(Icons.text_snippet),
                      label: const Text('Metin'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child:
                    album.contents.isEmpty
                        ? const Center(child: Text('Henüz içerik yok.'))
                        : ListView.builder(
                          itemCount: album.contents.length,
                          itemBuilder: (context, i) {
                            final c = album.contents[i];
                            return Card(
                              child: ListTile(
                                leading: c.type == 'photo'
                                    ? (c.urlOrText.startsWith('http')
                                        ? Image.network(c.urlOrText, width: 48, height: 48, fit: BoxFit.cover)
                                        : Image.file(
                                            File(c.urlOrText),
                                            width: 48,
                                            height: 48,
                                            fit: BoxFit.cover,
                                          ))
                                    : c.type == 'video'
                                        ? const Icon(Icons.videocam, size: 36, color: Colors.blueGrey)
                                        : c.type == 'audio'
                                            ? const Icon(Icons.mic, size: 32, color: Colors.orange)
                                            : const Icon(Icons.text_snippet, size: 32, color: Colors.green),
                                title: Text(c.type.toUpperCase()),
                                subtitle: Text(
                                  c.type == 'text' ? c.urlOrText : '',
                                ),
                                trailing: Text(
                                  '${c.createdAt.hour}:${c.createdAt.minute.toString().padLeft(2, '0')}',
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
