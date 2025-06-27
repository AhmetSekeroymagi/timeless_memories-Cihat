import 'package:flutter/material.dart';
import 'album_model.dart';
import 'album_detail_screen.dart';

class AlbumListScreen extends StatefulWidget {
  const AlbumListScreen({Key? key}) : super(key: key);

  @override
  State<AlbumListScreen> createState() => _AlbumListScreenState();
}

class _AlbumListScreenState extends State<AlbumListScreen> {
  List<Album> albums = [
    Album(
      id: '1',
      title: 'İstanbul Gezisi',
      description: 'İstanbul anıları',
      type: AlbumType.location,
      locationName: 'Galata Kulesi',
      latitude: 41.0256,
      longitude: 28.9744,
      unlockTime: null,
      contents: [],
      access: AlbumAccess.onlyMe,
      accessUserEmails: [],
    ),
    Album(
      id: '2',
      title: 'Doğum Günü',
      description: 'Doğum günü kutlaması',
      type: AlbumType.time,
      unlockTime: DateTime.now().add(const Duration(days: 5)),
      locationName: null,
      latitude: null,
      longitude: null,
      contents: [],
      access: AlbumAccess.multiple,
      accessUserEmails: ['ahmet@example.com', 'zeynep@example.com'],
    ),
  ];

  // Dummy arkadaş listesi
  final List<String> dummyFriends = [
    'ahmet@example.com',
    'zeynep@example.com',
    'mehmet@example.com',
    'ayse@example.com',
  ];

  void _showCreateAlbumDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    AlbumType selectedType = AlbumType.time;
    DateTime? unlockTime;
    String? locationName;
    double? latitude;
    double? longitude;
    AlbumAccess access = AlbumAccess.onlyMe;
    List<String> selectedEmails = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Albüm Oluştur'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Albüm Adı'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Açıklama'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Tür: '),
                    DropdownButton<AlbumType>(
                      value: selectedType,
                      items: const [
                        DropdownMenuItem(value: AlbumType.time, child: Text('Zaman Tabanlı')),
                        DropdownMenuItem(value: AlbumType.location, child: Text('Konum Tabanlı')),
                      ],
                      onChanged: (val) => setState(() => selectedType = val!),
                    ),
                  ],
                ),
                if (selectedType == AlbumType.time)
                  ListTile(
                    leading: const Icon(Icons.lock_clock),
                    title: Text(unlockTime == null
                        ? 'Açılma tarihi seç'
                        : 'Açılma tarihi: ${unlockTime!.day}.${unlockTime!.month}.${unlockTime!.year}'),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => unlockTime = picked);
                    },
                  ),
                if (selectedType == AlbumType.location)
                  Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(labelText: 'Konum Adı'),
                        onChanged: (val) => locationName = val,
                      ),
                      // Dummy olarak sabit konum
                      const SizedBox(height: 8),
                      const Text('Konum: Galata Kulesi (dummy)'),
                    ],
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Erişim: '),
                    DropdownButton<AlbumAccess>(
                      value: access,
                      items: const [
                        DropdownMenuItem(value: AlbumAccess.onlyMe, child: Text('Sadece Ben')),
                        DropdownMenuItem(value: AlbumAccess.specific, child: Text('Belirli Kişi')),
                        DropdownMenuItem(value: AlbumAccess.multiple, child: Text('Birden Fazla Kişi')),
                      ],
                      onChanged: (val) => setState(() => access = val!),
                    ),
                  ],
                ),
                if (access != AlbumAccess.onlyMe)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Erişim verilecek arkadaş(lar):'),
                      Wrap(
                        spacing: 8,
                        children: dummyFriends.map((email) {
                          final selected = selectedEmails.contains(email);
                          return FilterChip(
                            label: Text(email),
                            selected: selected,
                            onSelected: (val) {
                              setState(() {
                                if (val) {
                                  selectedEmails.add(email);
                                } else {
                                  selectedEmails.remove(email);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  albums.add(
                    Album(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleController.text,
                      description: descController.text,
                      type: selectedType,
                      unlockTime: unlockTime,
                      locationName: locationName,
                      latitude: selectedType == AlbumType.location ? 41.0256 : null,
                      longitude: selectedType == AlbumType.location ? 28.9744 : null,
                      contents: [],
                      access: access,
                      accessUserEmails: selectedEmails,
                    ),
                  );
                });
                Navigator.pop(context);
              },
              child: const Text('Oluştur'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Albüm Listesi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Albüm Oluştur',
            onPressed: _showCreateAlbumDialog,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: albums.length,
        itemBuilder: (context, index) {
          final album = albums[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListTile(
              leading: Icon(album.type == AlbumType.time ? Icons.lock_clock : Icons.location_on),
              title: Text(album.title),
              subtitle: Text(album.description),
              trailing: album.access == AlbumAccess.onlyMe
                  ? const Chip(label: Text('Sadece Ben'))
                  : Chip(label: Text('Paylaşılan: ${album.accessUserEmails.join(', ')}')),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AlbumDetailScreen(album: album),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
} 