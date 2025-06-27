import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'capsule_model.dart';

class CapsuleDetailScreen extends StatefulWidget {
  final Capsule capsule;

  const CapsuleDetailScreen({super.key, required this.capsule});

  @override
  State<CapsuleDetailScreen> createState() => _CapsuleDetailScreenState();
}

class _CapsuleDetailScreenState extends State<CapsuleDetailScreen> {
  Timer? _timer;
  Duration? _countdown;

  @override
  void initState() {
    super.initState();
    if (!widget.capsule.isOpened) {
      _countdown = widget.capsule.openAt.difference(DateTime.now());
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _countdown = widget.capsule.openAt.difference(DateTime.now());
          if (_countdown!.isNegative) {
            _timer?.cancel();
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return "Kapsül Açıldı!";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final days = duration.inDays;
    final hours = twoDigits(duration.inHours.remainder(24));
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$days gün $hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final capsule = widget.capsule;
    final isLocked =
        !capsule.isOpened && (_countdown != null && !_countdown!.isNegative);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                capsule.title,
                style: const TextStyle(
                  shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                ),
              ),
              background: Image.network(
                capsule.imageUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => const Center(
                      child: Icon(Icons.broken_image, size: 100),
                    ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed:
                    () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Düzenleme özelliği yakında!'),
                      ),
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Kapsülü Sil'),
                          content: const Text(
                            'Bu kapsülü silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('İptal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text(
                                'Sil',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                  );
                  if (confirmed == true) {
                    // Silme işlemini gerçekleştir (şimdilik dummy)
                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kapsül silindi.')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(context),
                  if (isLocked)
                    _buildCountdownCard(context)
                  else
                    _buildContentSection(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final capsule = widget.capsule;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              capsule.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Dummy açıklama. Buraya kapsülün uzun açıklaması gelecek.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDateColumn(context, 'Oluşturulma', capsule.createdAt),
                _buildDateColumn(context, 'Açılma Tarihi', capsule.openAt),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16),
                const SizedBox(width: 8),
                Text('Sahibi: ${capsule.owner}'),
                const Spacer(),
                const Icon(Icons.share_outlined, size: 16),
                const SizedBox(width: 8),
                // This should be based on the sharing property from a more complete model
                const Text('Paylaşım: Aile'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateColumn(BuildContext context, String title, DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodySmall),
        Text(
          DateFormat('dd MMMM yyyy', 'tr_TR').format(date),
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCountdownCard(BuildContext context) {
    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              Icons.lock_clock,
              size: 48,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(height: 16),
            Text(
              'Kapsül Kilitli',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDuration(_countdown ?? Duration.zero),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection(BuildContext context) {
    // Dummy content based on media types
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          "Kapsül İçeriği",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        if (widget.capsule.mediaTypes.contains(MediaType.photo))
          _buildContentTile(
            context,
            Icons.photo_album,
            'Fotoğraflar',
            '1 fotoğraf',
          ),
        if (widget.capsule.mediaTypes.contains(MediaType.video))
          _buildContentTile(
            context,
            Icons.video_collection,
            'Videolar',
            '1 video',
          ),
        if (widget.capsule.mediaTypes.contains(MediaType.audio))
          _buildContentTile(
            context,
            Icons.audiotrack,
            'Ses Kayıtları',
            '1 ses kaydı',
          ),
        if (widget.capsule.mediaTypes.contains(MediaType.text))
          _buildContentTile(
            context,
            Icons.article,
            'Metin Notu',
            'Notu görüntüle',
          ),
      ],
    );
  }

  Widget _buildContentTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title içeriği görüntülenecek.')),
          );
        },
      ),
    );
  }
}

// Dummy kapsül ile örnek kullanım:
// Navigator.push(context, MaterialPageRoute(
//   builder: (context) => CapsuleDetailScreen(
//     title: 'İlk Kapsülüm',
//     description: 'Bu bir örnek kapsüldür.',
//     isLocked: false,
//     openAt: DateTime(2024, 7, 1),
//     photoUrl: 'https://via.placeholder.com/100',
//     videoUrl: null,
//     audioUrl: null,
//     note: 'Bu kapsülün notu.',
//     location: 'İstanbul',
//   ),
// ));
