import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timeless_memories/modules/user/login/login_screen.dart';
import 'package:timeless_memories/modules/galery/family_sharing_screen.dart';
import 'package:timeless_memories/modules/galery/nfc_scan_screen.dart';
import 'package:timeless_memories/modules/user/profile/settings_help_screen.dart';
import 'state.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);

    // Dummy kullanıcı adı verisi
    final List<Map<String, String>> friends = [
      {'username': 'sekerrrx01', 'email': 'sekerrrx01@example.com'},
      {'username': 'deneme1', 'email': 'deneme1@example.com'},
      {'username': 'deneme2', 'email': 'deneme2@example.com'},
      {'username': 'deneme3', 'email': 'deneme3@example.com'},
    ];
    final List<Map<String, String>> followers = [
      {'username': 'sekerrrx01', 'email': 'sekerrrx01@example.com'},
      {'username': 'deneme1', 'email': 'deneme1@example.com'},
      {'username': 'deneme2', 'email': 'deneme2@example.com'},
    ];
    final List<Map<String, String>> following = [
      {'username': 'sekerrrx01', 'email': 'sekerrrx01@example.com'},
      {'username': 'deneme1', 'email': 'deneme1@example.com'},
      {'username': 'deneme3', 'email': 'deneme3@example.com'},
    ];

    void showAddFriendDialog() {
      final TextEditingController _emailController = TextEditingController();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Arkadaş Ekle'),
          content: TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'E-posta'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${_emailController.text} eklendi (dummy)')),
                );
              },
              child: const Text('Ekle'),
            ),
          ],
        ),
      );
    }

    void showFriendsList() {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => SizedBox(
          height: 400,
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text('Arkadaşlar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Expanded(
                child: ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: const Icon(Icons.person),
                    title: Text('@${friends[index]['username']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      tooltip: 'Arkadaşı Çıkar',
                      onPressed: () {
                        // Dummy çıkarma
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('@${friends[index]['username']} çıkarıldı (dummy)')),
                        );
                      },
                    ),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  showAddFriendDialog();
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Arkadaş Ekle'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    }

    void showFollowersList() {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => SizedBox(
          height: 400,
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text('Takipçiler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Expanded(
                child: ListView.builder(
                  itemCount: followers.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: const Icon(Icons.person),
                    title: Text('@${followers[index]['username']}'),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    void showFollowingList() {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => SizedBox(
          height: 400,
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text('Takip Edilenler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Expanded(
                child: ListView.builder(
                  itemCount: following.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: const Icon(Icons.person),
                    title: Text('@${following[index]['username']}'),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body:
          state.isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF07B183)),
              )
              : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    _buildProfileHeader(context, state, ref),
                    const SizedBox(height: 16),
                    // Arkadaş, takipçi, takip edilen sayıları
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: showFriendsList,
                          child: Column(
                            children: [
                              Text('${friends.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              const Text('Arkadaş'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),
                        GestureDetector(
                          onTap: showFollowersList,
                          child: Column(
                            children: [
                              Text('${followers.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              const Text('Takipçi'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),
                        GestureDetector(
                          onTap: showFollowingList,
                          child: Column(
                            children: [
                              Text('${following.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              const Text('Takip Edilen'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSettingsSection(context, ref),
                  ],
                ),
              ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    ProfileState state,
    WidgetRef ref,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar ve kamera butonu
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF07B183), width: 2),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      state.user?.photoURL != null
                          ? NetworkImage(state.user!.photoURL!)
                          : null,
                  child:
                      state.user?.photoURL == null
                          ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey,
                          )
                          : null,
                  backgroundColor: Colors.grey[200],
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final image = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                      maxWidth: 800,
                    );
                    if (image != null) {
                      await ref
                          .read(profileProvider.notifier)
                          .updateProfileImage(File(image.path));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF07B183),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // İsim
          Text(
            state.userData?['name'] ?? '',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          // Kullanıcı adı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '@${state.userData?['username'] ?? ''}',
              style: GoogleFonts.inter(
                color: Colors.grey[800],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Email
          Text(
            state.userData?['email'] ?? '',
            style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.family_restroom, color: Color(0xFF07B183)),
            title: const Text('Aile Paylaşımı'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FamilySharingScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.nfc, color: Color(0xFF07B183)),
            title: const Text('NFC ile Kapsül Aç'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NfcScanScreen(),
                ),
              );
            },
          ),
          _buildSettingItem(
            icon: Icons.privacy_tip,
            title: 'Gizlilik Ayarları',
            onTap: () {
              // TODO: Navigate to privacy settings
            },
          ),
          _buildSettingItem(
            icon: Icons.notifications,
            title: 'Bildirim Tercihleri',
            onTap: () {
              // TODO: Navigate to notification settings
            },
          ),
          _buildSettingItem(
            icon: Icons.security,
            title: 'Hesap Güvenliği',
            onTap: () {
              // TODO: Navigate to security settings
            },
          ),
          _buildSettingItem(
            icon: Icons.info,
            title: 'Uygulama Hakkında',
            onTap: () {
              // TODO: Navigate to about page
            },
          ),
          _buildSettingItem(
            icon: Icons.exit_to_app,
            title: 'Çıkış Yap',
            onTap: () async {
              await ref.read(profileProvider.notifier).signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Ayarlar & Yardım'),
            onTap: () {
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
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF07B183)),
      title: Text(
        title,
        style: GoogleFonts.inter(color: Colors.black, fontSize: 16),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
