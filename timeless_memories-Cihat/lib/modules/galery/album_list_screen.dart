import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'album_model.dart';
import 'album_detail_screen.dart';

enum _SortOption { byDate, byName }

class AlbumListScreen extends StatefulWidget {
  const AlbumListScreen({Key? key}) : super(key: key);

  @override
  State<AlbumListScreen> createState() => _AlbumListScreenState();
}

class _AlbumListScreenState extends State<AlbumListScreen> {
  late List<Album> _albums;
  _SortOption _currentSortOption = _SortOption.byDate;

  @override
  void initState() {
    super.initState();
    _albums = List.generate(8, (index) => Album.createSample(index));
    _sortAlbums();
  }

  void _sortAlbums() {
    setState(() {
      if (_currentSortOption == _SortOption.byDate) {
        _albums.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
      } else {
        _albums.sort((a, b) => a.title.compareTo(b.title));
      }
    });
  }

  void _showCreateAlbumDialog() {
    final titleController = TextEditingController();
    // The original dialog logic is simplified for this modern UI
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Yeni Albüm Oluştur'),
            content: TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Albüm Adı',
                hintText: 'Örn: Muhteşem Anlar',
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty) {
                    setState(() {
                      _albums.insert(
                        0,
                        Album(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleController.text,
                          coverImageUrl:
                              'https://images.unsplash.com/photo-1534294247424-FF8881a2480b?q=80&w=2070&auto=format&fit=crop',
                          itemCount: 0,
                          lastUpdated: DateTime.now(),
                          type: AlbumType.time,
                          contents: [],
                          access: AlbumAccess.onlyMe,
                          accessUserEmails: [],
                        ),
                      );
                      _sortAlbums();
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Oluştur'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Albümlerim'),
        actions: [
          PopupMenuButton<_SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: "Sırala",
            onSelected: (option) {
              setState(() {
                _currentSortOption = option;
                _sortAlbums();
              });
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: _SortOption.byDate,
                    child: Text('Tarihe Göre Sırala'),
                  ),
                  const PopupMenuItem(
                    value: _SortOption.byName,
                    child: Text('İsme Göre Sırala'),
                  ),
                ],
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          childAspectRatio: 1.0,
        ),
        itemCount: _albums.length,
        itemBuilder: (context, index) {
          return _AlbumCard(album: _albums[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateAlbumDialog,
        tooltip: 'Albüm Oluştur',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({Key? key, required this.album}) : super(key: key);

  final Album album;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlbumDetailScreen(album: album),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              album.coverImageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                return progress == null
                    ? child
                    : const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade200,
                  child: Icon(
                    Icons.broken_image,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                );
              },
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Son güncelleme: ${DateFormat.yMd().format(album.lastUpdated)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    if (album.access != AlbumAccess.onlyMe)
                      const Padding(
                        padding: EdgeInsets.only(right: 4.0),
                        child: Icon(
                          Icons.people,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    Text(
                      '${album.itemCount} anı',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
