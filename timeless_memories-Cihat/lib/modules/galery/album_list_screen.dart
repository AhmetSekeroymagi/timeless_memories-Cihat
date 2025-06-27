import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _picker = ImagePicker();

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

  void _showCreateAlbumSheet() {
    final titleController = TextEditingController();
    File? selectedImageFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateInSheet) {
            Future<void> pickCoverImage() async {
              final XFile? pickedFile = await _picker.pickImage(
                source: ImageSource.gallery,
              );
              if (pickedFile != null) {
                setStateInSheet(
                  () => selectedImageFile = File(pickedFile.path),
                );
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yeni Albüm Oluştur',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  GestureDetector(
                    onTap: pickCoverImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          selectedImageFile != null
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  selectedImageFile!,
                                  fit: BoxFit.cover,
                                ),
                              )
                              : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    color: Colors.grey.shade700,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Kapak Fotoğrafı Seç',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Albüm Adı',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.check),
                      label: const Text('Albümü Oluştur'),
                      onPressed: () {
                        if (titleController.text.isNotEmpty) {
                          setState(() {
                            _albums.insert(
                              0,
                              Album(
                                id:
                                    DateTime.now().millisecondsSinceEpoch
                                        .toString(),
                                title: titleController.text,
                                coverImageFile: selectedImageFile,
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
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
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
        onPressed: _showCreateAlbumSheet,
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
    Widget coverWidget;
    if (album.coverImageFile != null) {
      coverWidget = Image.file(
        album.coverImageFile!,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          return wasSynchronouslyLoaded
              ? child
              : AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: const Duration(seconds: 1),
                curve: Curves.easeOut,
                child: child,
              );
        },
      );
    } else if (album.coverImageUrl != null) {
      coverWidget = Image.network(
        album.coverImageUrl!,
        fit: BoxFit.cover,
        loadingBuilder:
            (context, child, progress) =>
                progress == null
                    ? child
                    : const Center(child: CircularProgressIndicator()),
        errorBuilder:
            (context, error, stackTrace) => Container(
              color: Colors.grey.shade200,
              child: Icon(
                Icons.broken_image,
                size: 40,
                color: Colors.grey.shade400,
              ),
            ),
      );
    } else {
      coverWidget = Container(
        color: Colors.grey.shade200,
        child: Icon(
          Icons.photo_album_outlined,
          size: 50,
          color: Colors.grey.shade400,
        ),
      );
    }

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
            coverWidget,
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
