import 'package:flutter/material.dart';

class FamilySharingScreen extends StatefulWidget {
  const FamilySharingScreen({Key? key}) : super(key: key);

  @override
  State<FamilySharingScreen> createState() => _FamilySharingScreenState();
}

class _FamilySharingScreenState extends State<FamilySharingScreen> {
  final List<Map<String, dynamic>> familyMembers = [
    {'name': 'Anne', 'email': 'anne@example.com'},
    {'name': 'Baba', 'email': 'baba@example.com'},
    {'name': 'Kardeş', 'email': 'kardes@example.com'},
  ];

  final List<Map<String, dynamic>> sharedCapsules = [
    {
      'title': 'Doğum Günü Sürprizi',
      'sharedWith': ['anne@example.com', 'baba@example.com'],
    },
    {
      'title': 'Yılbaşı Mesajı',
      'sharedWith': ['kardes@example.com'],
    },
  ];

  final TextEditingController _emailController = TextEditingController();

  void _addFamilyMember() {
    if (_emailController.text.isEmpty) return;
    setState(() {
      familyMembers.add({'name': 'Yeni Kişi', 'email': _emailController.text});
      _emailController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Aile bireyi eklendi!')),
    );
  }

  void _shareCapsule() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kapsül paylaşıldı! (dummy)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aile Paylaşımı')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Aile Bireyleri', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          ...familyMembers.map((member) => ListTile(
                leading: const Icon(Icons.person),
                title: Text(member['name']),
                subtitle: Text(member['email']),
              )),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-posta ile kişi ekle',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addFamilyMember,
                child: const Text('Ekle'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('QR ile ekleme (dummy)')),);
            },
            icon: const Icon(Icons.qr_code),
            label: const Text('QR ile Kişi Ekle'),
          ),
          const Divider(height: 32),
          const Text('Paylaşılan Kapsüller', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          ...sharedCapsules.map((capsule) => Card(
                child: ListTile(
                  leading: const Icon(Icons.lock_open),
                  title: Text(capsule['title']),
                  subtitle: Text('Paylaşılanlar: ${(capsule['sharedWith'] as List).join(", ")}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.share),
                    tooltip: 'Kapsül Paylaş',
                    onPressed: _shareCapsule,
                  ),
                ),
              )),
        ],
      ),
    );
  }
} 