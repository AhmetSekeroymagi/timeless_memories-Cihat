import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String filter = 'newest';

  final List<Map<String, dynamic>> capsules = [
    {
      'title': 'İlham Veren Anı',
      'description': 'Hayatımda dönüm noktası olan bir gün.',
      'imageUrl': 'https://via.placeholder.com/100',
      'likes': 12,
      'isPopular': true,
    },
    {
      'title': 'Doğa Yürüyüşü',
      'description': 'Doğada huzur bulduğum bir an.',
      'imageUrl': 'https://via.placeholder.com/100',
      'likes': 8,
      'isPopular': false,
    },
    {
      'title': 'Başarı Hikayem',
      'description': 'Zorlu bir sürecin ardından gelen mutluluk.',
      'imageUrl': 'https://via.placeholder.com/100',
      'likes': 20,
      'isPopular': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredCapsules = filter == 'newest'
        ? List.from(capsules)
        : capsules.where((c) => c['isPopular'] == true).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Keşfet')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FilterChip(
                  label: const Text('En Yeni'),
                  selected: filter == 'newest',
                  onSelected: (_) => setState(() => filter = 'newest'),
                ),
                FilterChip(
                  label: const Text('En Popüler'),
                  selected: filter == 'popular',
                  onSelected: (_) => setState(() => filter = 'popular'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredCapsules.length,
              itemBuilder: (context, index) {
                final capsule = filteredCapsules[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        capsule['imageUrl'],
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(capsule['title']),
                    subtitle: Text(capsule['description']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${capsule['likes']}'),
                        IconButton(
                          icon: const Icon(Icons.favorite_border),
                          tooltip: 'Beğen',
                          onPressed: () {
                            setState(() {
                              capsule['likes'] = (capsule['likes'] as int) + 1;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Kapsül beğenildi!')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 