import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final List<Map<String, dynamic>> posts = [
    {
      'username': 'sekerrrx01',
      'imageUrl': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
      'note': 'Hayatımda dönüm noktası olan bir gün.',
      'likes': 12,
      'liked': false,
      'comments': 3,
    },
    {
      'username': 'sekerrrx01',
      'imageUrl': 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=400&q=80',
      'note': 'Doğada huzur bulduğum bir an.',
      'likes': 8,
      'liked': false,
      'comments': 1,
    },
    {
      'username': 'sekerrrx01',
      'imageUrl': 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=400&q=80',
      'note': 'Zorlu bir sürecin ardından gelen mutluluk.',
      'likes': 20,
      'liked': false,
      'comments': 5,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keşfet')),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kullanıcı adı
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFF07B183),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Text('@${post['username']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Büyük resim
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      post['imageUrl'],
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Not
                  Text(post['note'], style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 8),
                  // Beğen ve Yorum yap
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          post['liked'] ? Icons.favorite : Icons.favorite_border,
                          color: post['liked'] ? Colors.red : null,
                        ),
                        onPressed: post['liked']
                            ? null
                            : () {
                                setState(() {
                                  post['likes'] = (post['likes'] as int) + 1;
                                  post['liked'] = true;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Beğendin!')),
                                );
                              },
                      ),
                      Text('${post['likes']}'),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.comment_outlined),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Yorum özelliği yakında!')),
                          );
                        },
                      ),
                      Text('${post['comments']}'),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 