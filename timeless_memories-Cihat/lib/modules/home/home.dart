import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeless_memories/modules/memory/add_image_and_video/add_image_and_video.dart';
import 'package:timeless_memories/modules/memory/add_voice/add_voice.dart';
import 'package:timeless_memories/modules/service/memory_service.dart';
import 'package:timeless_memories/modules/galery/galery.dart';
import 'package:timeless_memories/modules/user/profile/profile_screen.dart';
import 'package:timeless_memories/modules/lock/lock_dialog.dart';
import 'package:timeless_memories/modules/lock/lock_screen.dart';
import 'dart:io';
import 'package:timeless_memories/modules/memory/edit_memory/edit_memory_page.dart';
import 'package:timeless_memories/modules/galery/explore_screen.dart';
import 'package:timeless_memories/modules/galery/future_letter_screen.dart';
import 'package:timeless_memories/modules/galery/capsule_detail_screen.dart';
import 'package:timeless_memories/modules/galery/location_capsules_screen.dart';
import 'package:timeless_memories/modules/galery/family_sharing_screen.dart';
import 'package:timeless_memories/modules/galery/nfc_scan_screen.dart';
import 'package:timeless_memories/modules/user/profile/settings_help_screen.dart';
import 'package:timeless_memories/modules/galery/notifications_screen.dart';
import 'package:timeless_memories/modules/galery/my_capsules_screen.dart';
import 'package:timeless_memories/modules/galery/album_list_screen.dart';

// 1. MemoryService için bir Provider oluştur
final memoryServiceProvider = Provider<MemoryService>((ref) {
  return MemoryService();
});

// 2. Anıları getiren StreamProvider'ı oluştur
final memoriesStreamProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) {
  // memoryServiceProvider'ı izle ve fetchMemories'i çağır
  return ref.watch(memoryServiceProvider).fetchMemories();
});

// Dummy merkezi paylaşım listesi (ana albüm ve ana sayfa ortak kullanacak)
List<Map<String, dynamic>> globalPosts = [
  {
    'id': '1',
    'type': 'photo',
    'url': 'https://via.placeholder.com/150',
    'desc': 'İlk paylaşım',
    'date': DateTime.now().subtract(const Duration(days: 1)),
  },
  {
    'id': '2',
    'type': 'text',
    'url': '',
    'desc': 'Bugün çok güzel bir gündü!',
    'date': DateTime.now(),
  },
];

void addGlobalPost(Map<String, dynamic> post) {
  globalPosts.insert(0, post);
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Favoriler Sayfası')));
  }
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const HomeContent(),
    const ExploreScreen(),
    const SizedBox.shrink(), // + butonu için boş
    const NotificationsScreen(),
    ProfileScreen(),
  ];

  void _onPlusPressed(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Yeni Ekle',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAddButton(
                      context: context,
                      icon: Icons.photo_camera,
                      label: 'Fotoğraf',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddImagePage(),
                          ),
                        );
                      },
                    ),
                    _buildAddButton(
                      context: context,
                      icon: Icons.videocam,
                      label: 'Video',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    const AddImagePage(), // Dummy olarak aynı sayfa
                          ),
                        );
                      },
                    ),
                    _buildAddButton(
                      context: context,
                      icon: Icons.mic,
                      label: 'Ses',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddVoicePage(),
                          ),
                        );
                      },
                    ),
                    _buildAddButton(
                      context: context,
                      icon: Icons.mail_outline,
                      label: 'Mektup',
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectedIndex =
                              4; // Profil sekmesinden FutureLetterScreen'e yönlendirme yapılabilir
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FutureLetterScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(color: Color(0xFF07B183)),
                  child: Center(
                    child: Text(
                      'Menü',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: const Text('Kapsüllerim'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyCapsulesScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_album_outlined),
                  title: const Text('Albümler'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AlbumListScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.mail_outline),
                  title: const Text('Geleceğe Mektup'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FutureLetterScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galeri (Eski)'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GalleryPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.map),
                  title: const Text('Konum Kapsülleri'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LocationCapsulesScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.family_restroom),
                  title: const Text('Aile Paylaşımı'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FamilySharingScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.nfc),
                  title: const Text('NFC ile Kapsül Aç'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NfcScanScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Ayarlar & Yardım'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsHelpScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          appBar: AppBar(
            title: Text(
              'Timeless Memories',
              style: TextStyle(
                fontSize: 24,
                fontFamily: GoogleFonts.inter().fontFamily,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF07B183), Color(0xFF0D7055)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            leading: Builder(
              builder:
                  (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.lock_outline, color: Colors.white),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const LockDialog(),
                  );
                },
              ),
            ],
          ),
          body: _pages[_selectedIndex],
          bottomNavigationBar: _buildBottomNavigationBar(context),
        ),
        const LockScreen(),
      ],
    );
  }

  BottomNavigationBar _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (index) {
        if (index == 2) {
          _onPlusPressed(context);
        } else {
          setState(() {
            _selectedIndex = index;
          });
        }
      },
      selectedItemColor: const Color(0xFF07B183),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Anasayfa'),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Keşfet'),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle, size: 40),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Bildirimler',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
    );
  }

  Widget _buildAddButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF07B183),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 3. StreamProvider'ı izle
    final memoriesAsyncValue = ref.watch(memoriesStreamProvider);

    // 4. AsyncValue.when ile UI durumlarını yönet
    return memoriesAsyncValue.when(
      data: (memories) {
        if (memories.isEmpty) {
          return const Center(child: Text('Henüz anı eklenmemiş.'));
        }
        return ListView.builder(
          itemCount: memories.length,
          itemBuilder: (context, index) {
            final memory = memories[index];
            return _buildMemoryItem(context, memory, ref);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stackTrace) =>
              Center(child: Text('Anılar yüklenemedi: $error')),
    );
  }

  Widget _buildMemoryItem(
    BuildContext context,
    Map<String, dynamic> memory,
    WidgetRef ref,
  ) {
    final mediaUrls = List<String>.from(memory['mediaUrls'] ?? []);
    final localMediaPaths = List<String>.from(memory['localMediaPaths'] ?? []);
    final isVideoList = List<bool>.from(memory['isVideoList'] ?? []);
    final bool isPending = memory['isPending'] ?? false;
    final mediaCount = (memory['mediaCount'] as num? ?? 0).toInt();

    final List<Widget> mediaWidgets = [];

    if (localMediaPaths.isNotEmpty) {
      for (int i = 0; i < localMediaPaths.length; i++) {
        mediaWidgets.add(
          _buildMediaWidget(
            mediaPath: localMediaPaths[i],
            isVideo: isVideoList.length > i ? isVideoList[i] : false,
            isLocal: true,
          ),
        );
      }
    } else if (mediaUrls.isNotEmpty) {
      for (int i = 0; i < mediaUrls.length; i++) {
        mediaWidgets.add(
          _buildMediaWidget(
            mediaPath: mediaUrls[i],
            isVideo: isVideoList.length > i ? isVideoList[i] : false,
            isLocal: false,
          ),
        );
      }
    }

    if (mediaWidgets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage:
                      (memory['userPhotoUrl'] != null)
                          ? NetworkImage(memory['userPhotoUrl'])
                          : null,
                  child:
                      (memory['userPhotoUrl'] == null)
                          ? const Icon(Icons.person)
                          : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        memory['userName'] ?? 'Kullanıcı',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Bir anı paylaştı',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // Düzenle ve Sil menüsü
                if (memory['userId'] ==
                    ref.read(memoryServiceProvider).currentUser?.uid)
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      _showMemoryOptionsSheet(context, ref, memory);
                    },
                  ),
              ],
            ),
          ),
          if (mediaWidgets.isNotEmpty)
            SizedBox(
              height: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  PageView(children: mediaWidgets),
                  if (isPending)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.sync, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Beklemede',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (mediaCount > 1)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '1/$mediaCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(memory['description'] ?? ''),
          ),
        ],
      ),
    );
  }

  void _showMemoryOptionsSheet(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> memory,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Anıyı Düzenle'),
                onTap: () {
                  Navigator.of(bc).pop(); // Bottom sheet'i kapat
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditMemoryPage(memory: memory),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Anıyı Sil',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.of(bc).pop(); // Bottom sheet'i kapat
                  _showDeleteConfirmationDialog(context, ref, memory['id']);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    String memoryId,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Anıyı Sil'),
          content: const Text(
            'Bu anıyı kalıcı olarak silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Sil'),
              onPressed: () {
                ref.read(memoryServiceProvider).deleteMemory(memoryId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMediaWidget({
    required String mediaPath,
    required bool isVideo,
    required bool isLocal,
  }) {
    Widget media;
    if (isLocal) {
      media = Image.file(
        File(mediaPath),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.error, color: Colors.red));
        },
      );
    } else {
      media = Image.network(
        mediaPath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.error));
        },
      );
    }

    if (isVideo) {
      return Stack(
        alignment: Alignment.center,
        children: [
          media,
          const Icon(Icons.play_circle_outline, color: Colors.white, size: 50),
        ],
      );
    }
    return media;
  }
}
