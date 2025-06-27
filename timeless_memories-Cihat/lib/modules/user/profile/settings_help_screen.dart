import 'package:flutter/material.dart';

final String privacyPolicy = '''
Timeless Memories Gizlilik Politikası

Kullanıcı bilgileriniz ve paylaşımlarınız gizli tutulur, üçüncü şahıslarla paylaşılmaz. Verileriniz yalnızca uygulama deneyiminizi iyileştirmek ve güvenliğinizi sağlamak amacıyla kullanılır. Hiçbir kişisel veri izinsiz olarak saklanmaz veya paylaşılmaz.

Uygulama içi paylaşımlarınız, sadece sizin belirlediğiniz kişilerle veya sadece sizin erişiminize açık olacak şekilde saklanır. Hesabınızı silmeniz durumunda tüm verileriniz kalıcı olarak silinir.

Daha fazla bilgi için bizimle iletişime geçebilirsiniz.
''';

final String termsOfUse = '''
Timeless Memories Kullanım Şartları

Uygulamayı kullanarak, paylaşımlarınızın ve kişisel bilgilerinizin gizlilik politikasına uygun şekilde saklanmasını kabul etmiş olursunuz. Uygulama üzerinden yapılan tüm paylaşımlar, topluluk kurallarına ve yasalara uygun olmalıdır. Uygunsuz içerikler ve kötüye kullanım durumunda hesabınız askıya alınabilir veya silinebilir.

Uygulamanın işleyişiyle ilgili değişiklik yapma hakkı saklıdır. Kullanıcılar, uygulamayı kullanmaya devam ederek bu şartları kabul etmiş sayılır.
''';

class SettingsHelpScreen extends StatelessWidget {
  const SettingsHelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar & Yardım')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Kullanıcı Profili', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Adı Değiştir'),
            onTap: () {
              final TextEditingController _nameController = TextEditingController();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Adı Değiştir'),
                  content: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Yeni Ad'),
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
                          SnackBar(content: Text('Ad değiştirildi: ${_nameController.text} (dummy)')),
                        );
                      },
                      child: const Text('Kaydet'),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('E-posta Değiştir'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('E-posta Değiştir'),
                  content: const Text('Bu özellik yakında eklenecek!'),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tamam'))],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Parola Değiştir'),
            onTap: () {
              final TextEditingController _oldPass = TextEditingController();
              final TextEditingController _newPass = TextEditingController();
              final TextEditingController _newPass2 = TextEditingController();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Parola Değiştir'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _oldPass,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Eski Parola'),
                      ),
                      TextField(
                        controller: _newPass,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Yeni Parola'),
                      ),
                      TextField(
                        controller: _newPass2,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Yeni Parola (Tekrar)'),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('İptal'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (_newPass.text != _newPass2.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Yeni parolalar eşleşmiyor!')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Parola değiştirildi (dummy)')),
                          );
                        }
                      },
                      child: const Text('Kaydet'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 32),
          const Text('Yardım', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          ExpansionTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Sıkça Sorulan Sorular (SSS)'),
            children: [
              ListTile(
                title: const Text('Kapsül nasıl oluşturulur?'),
                subtitle: const Text('Galeri veya Anasayfa üzerinden + butonuna tıklayarak kapsül oluşturabilirsiniz.'),
              ),
              ListTile(
                title: const Text('Kapsül paylaşımı nasıl yapılır?'),
                subtitle: const Text('Kapsül detayında 📤 paylaş butonunu kullanabilirsiniz.'),
              ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text('Destek Talebi Gönder'),
            onTap: () {
              final TextEditingController _emailController = TextEditingController();
              final TextEditingController _msgController = TextEditingController();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Destek Talebi'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'E-posta adresiniz'),
                      ),
                      TextField(
                        controller: _msgController,
                        decoration: const InputDecoration(labelText: 'Mesajınız'),
                        maxLines: 3,
                      ),
                    ],
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
                          const SnackBar(content: Text('Destek talebiniz gönderildi (dummy)')),
                        );
                      },
                      child: const Text('Gönder'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 32),
          const Text('Yasal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Gizlilik Politikası'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Gizlilik Politikası'),
                  content: Text(privacyPolicy),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Kapat'))],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Kullanım Şartları'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Kullanım Şartları'),
                  content: Text(termsOfUse),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Kapat'))],
                ),
              );
            },
          ),
          const Divider(height: 32),
          const Text('Hakkımızda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Timeless Memories, anılarınızı güvenle saklamanızı ve paylaşmanızı sağlayan bir dijital kapsül uygulamasıdır.'),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Sürüm: 1.0.0',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
} 