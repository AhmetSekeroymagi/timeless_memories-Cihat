import 'package:flutter/material.dart';
import 'package:timeless_memories/modules/galery/capsule_model.dart';

class FamilyMember {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;

  FamilyMember({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
  });
}

class FamilySharingScreen extends StatefulWidget {
  const FamilySharingScreen({super.key});

  @override
  State<FamilySharingScreen> createState() => _FamilySharingScreenState();
}

class _FamilySharingScreenState extends State<FamilySharingScreen> {
  final List<FamilyMember> _familyMembers = [
    FamilyMember(
      id: '1',
      name: 'Anne',
      email: 'anne@example.com',
      avatarUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026704d',
    ),
    FamilyMember(
      id: '2',
      name: 'Baba',
      email: 'baba@example.com',
      avatarUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026704e',
    ),
    FamilyMember(
      id: '3',
      name: 'Kardeş',
      email: 'kardes@example.com',
      avatarUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026704f',
    ),
  ];

  final List<Capsule> _sharedCapsules = [
    Capsule(
      id: 's1',
      title: 'Aile Tatili 2023',
      imageUrl:
          'https://images.unsplash.com/photo-1527617897042-5527b1a1b1a2?auto=format&fit=crop&w=400&q=80',
      createdAt: DateTime.now().subtract(const Duration(days: 50)),
      openAt: DateTime.now(),
      isOpened: true,
      mediaTypes: [MediaType.photo, MediaType.video],
      owner: 'Baba',
    ),
  ];

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final emailController = TextEditingController();
        return AlertDialog(
          title: const Text('Yeni Üye Ekle'),
          content: TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Üyenin E-postası'),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                // Dummy add logic
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Davet gönderildi!')),
                );
              },
              child: const Text('Davet Et'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aile Paylaşımı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddMemberDialog,
            tooltip: 'Yeni Üye Ekle',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNecklaceCard(),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Aile Üyeleri', _familyMembers.length),
          _buildFamilyMemberList(),
          const SizedBox(height: 24),
          _buildSectionTitle(
            context,
            'Paylaşılan Kapsüller',
            _sharedCapsules.length,
          ),
          _buildSharedCapsuleList(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ortak anı oluşturma ekranı açılacak.'),
            ),
          );
        },
        label: const Text('Ortak Anı Oluştur'),
        icon: const Icon(Icons.add_photo_alternate_outlined),
      ),
    );
  }

  Widget _buildNecklaceCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.auto_stories, size: 40, color: Colors.brown),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bizim Aile Kolyesi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Tüm aile anılarınız burada birleşiyor.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          Text('$count adet', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildFamilyMemberList() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _familyMembers.length,
        itemBuilder: (context, index) {
          final member = _familyMembers[index];
          return SizedBox(
            width: 80,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(member.avatarUrl),
                ),
                const SizedBox(height: 8),
                Text(member.name, overflow: TextOverflow.ellipsis),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSharedCapsuleList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _sharedCapsules.length,
      itemBuilder: (context, index) {
        final capsule = _sharedCapsules[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Image.network(
              capsule.imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
            title: Text(capsule.title),
            subtitle: Text('Sahibi: ${capsule.owner}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to capsule detail
            },
          ),
        );
      },
    );
  }
}
