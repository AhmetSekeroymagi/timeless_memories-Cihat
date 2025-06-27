import 'package:flutter/material.dart';
import 'package:timeless_memories/modules/service/memory_service.dart';
import 'package:timeless_memories/modules/galery/location_capsules_screen.dart';
import 'album_list_screen.dart';
import '../../modules/home/home.dart';

class FullScreenMediaView extends StatelessWidget {
  final List<Map<String, dynamic>> allMedia;
  final int initialIndex;

  const FullScreenMediaView({
    super.key,
    required this.allMedia,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PageView.builder(
        itemCount: allMedia.length,
        controller: PageController(initialPage: initialIndex),
        itemBuilder: (context, index) {
          final media = allMedia[index];

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!(media['isAudio'] as bool))
                  Expanded(
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Image.network(media['url'], fit: BoxFit.contain),
                    ),
                  )
                else
                  const ListTile(
                    leading: Icon(
                      Icons.audiotrack,
                      color: Colors.white,
                      size: 40,
                    ),
                    title: Text(
                      'Ses Kaydı',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                if (media['description'] != null &&
                    media['description'].toString().isNotEmpty)
                  Container(
                    width: double.infinity,
                    color: Colors.black54,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          media['description'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          media['date'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  bool _firstOpen = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_firstOpen) {
      _firstOpen = false;
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Albüm Oluştur'),
            content: const Text('Albüm oluşturmak için üstteki veya aşağıdaki butonları kullanabilirsin. Albümlere doğrudan içerik ekleme özelliği yoktur, içerik eklemek için albüm detayına git.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tamam'),
              ),
            ],
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final memoryService = MemoryService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Galeri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: 'Konum Kapsülleri',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LocationCapsulesScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('Ana Albüm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          // Ana Albüm sadece gösterim (globalPosts)
          SizedBox(
            height: 120,
            child: globalPosts.isEmpty
                ? const Center(child: Text('Henüz paylaşım yok.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: globalPosts.length,
                    itemBuilder: (context, i) {
                      final post = globalPosts[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          width: 120,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (post['type'] == 'photo')
                                Image.network(post['url'], width: 60, height: 60, fit: BoxFit.cover)
                              else if (post['type'] == 'text')
                                Icon(Icons.text_snippet, size: 40, color: Colors.grey[600]),
                              const SizedBox(height: 8),
                              Text(post['desc'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('Diğer Albümler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AlbumListScreen(), // Zaman kapsülü için
                        ),
                      );
                    },
                    icon: const Icon(Icons.lock_clock),
                    label: const Text('Zaman Albümü Ekle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF07B183),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(44),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AlbumListScreen(), // Konum kapsülü için
                        ),
                      );
                    },
                    icon: const Icon(Icons.location_on),
                    label: const Text('Konum Albümü Ekle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D7055),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(44),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AlbumListScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Albüm Ekle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF07B183),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(44),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
