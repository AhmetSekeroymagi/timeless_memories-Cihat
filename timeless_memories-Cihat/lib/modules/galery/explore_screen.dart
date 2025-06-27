import 'package:flutter/material.dart';
import 'package:timeless_memories/modules/galery/capsule_detail_screen.dart';
import 'capsule_model.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final List<Capsule> _allCapsules = [
    Capsule(
      id: 'p1',
      title: 'Unutulmaz Bir Gün Batımı',
      imageUrl:
          'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      openAt: DateTime.now(),
      isOpened: true,
      mediaTypes: [MediaType.photo],
      owner: 'Gezgin Ruh',
      likes: 152,
      comments: 18,
      tags: ['Seyahat', 'Doğa'],
    ),
    Capsule(
      id: 'p2',
      title: 'Aile Yadigarı',
      imageUrl:
          'https://images.unsplash.com/photo-1541533379473-3151c5d35a78?auto=format&fit=crop&w=400&q=80',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      openAt: DateTime.now(),
      isOpened: true,
      mediaTypes: [MediaType.photo, MediaType.text],
      owner: 'Anı Koleksiyoncusu',
      likes: 345,
      comments: 45,
      tags: ['Aile', 'Anı'],
    ),
  ];

  List<Capsule> _filteredCapsules = [];
  String? _selectedTag;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredCapsules = _allCapsules;
    _searchController.addListener(_filterCapsules);
  }

  void _filterCapsules() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCapsules =
          _allCapsules.where((capsule) {
            final titleMatch = capsule.title.toLowerCase().contains(query);
            final tagMatch =
                _selectedTag == null || capsule.tags.contains(_selectedTag);
            return titleMatch && tagMatch;
          }).toList();
    });
  }

  void _selectTag(String? tag) {
    setState(() {
      _selectedTag = tag;
      _filterCapsules();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allTags = _allCapsules.expand((c) => c.tags).toSet().toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Keşfet')),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(allTags),
          Expanded(
            child:
                _filteredCapsules.isEmpty
                    ? const Center(child: Text('Sonuç bulunamadı.'))
                    : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _filteredCapsules.length,
                      itemBuilder: (context, index) {
                        return _buildCapsuleCard(_filteredCapsules[index]);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Kapsüllerde ara...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0)),
        ),
      ),
    );
  }

  Widget _buildFilterChips(List<String> tags) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          FilterChip(
            label: const Text('Tümü'),
            selected: _selectedTag == null,
            onSelected: (selected) => _selectTag(null),
          ),
          ...tags.map(
            (tag) => Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: FilterChip(
                label: Text(tag),
                selected: _selectedTag == tag,
                onSelected: (selected) => _selectTag(selected ? tag : null),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapsuleCard(Capsule capsule) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Text(
                  capsule.owner,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'report') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Bu gönderi incelenmek üzere rapor edildi.',
                          ),
                        ),
                      );
                    }
                  },
                  itemBuilder:
                      (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'report',
                          child: Text('Rapor Et'),
                        ),
                      ],
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Image.network(
              capsule.imageUrl,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  capsule.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border),
                      onPressed: () {},
                    ),
                    Text('${capsule.likes}'),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.comment_outlined),
                      onPressed: () {},
                    ),
                    Text('${capsule.comments}'),
                    const Spacer(),
                    ElevatedButton(
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      CapsuleDetailScreen(capsule: capsule),
                            ),
                          ),
                      child: const Text('Görüntüle'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
