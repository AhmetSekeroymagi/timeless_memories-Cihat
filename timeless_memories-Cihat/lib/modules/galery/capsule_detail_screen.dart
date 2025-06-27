import 'dart:async';
import 'dart:ui';
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
    if (widget.capsule.openAt.isAfter(DateTime.now())) {
      _countdown = widget.capsule.openAt.difference(DateTime.now());
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
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
    final isLocked = _countdown != null && !_countdown!.isNegative;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, capsule),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(context, capsule),
                  const SizedBox(height: 16),
                  if (isLocked)
                    _buildCountdownCard(context, capsule)
                  else
                    _buildContentSection(context, capsule),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, Capsule capsule) {
    return SliverAppBar(
      expandedHeight: 250.0,
      floating: false,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          capsule.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black54,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
        background: Image.network(
          capsule.imageUrl,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) =>
                  const Center(child: Icon(Icons.broken_image, size: 100)),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          tooltip: 'Paylaş',
          onPressed:
              () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Paylaşma özelliği yakında!')),
              ),
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Düzenle',
          onPressed:
              () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Düzenleme özelliği yakında!')),
              ),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Sil',
          onPressed: () => _showDeleteConfirmation(context),
        ),
      ],
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
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
                child: const Text('Sil', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
    if (confirmed == true && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kapsül silindi (simülasyon).')),
      );
    }
  }

  Widget _buildInfoCard(BuildContext context, Capsule capsule) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Kapsül Hakkında",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Bu kapsül, \"${capsule.owner}\" tarafından oluşturuldu ve gelecekteki bir tarih için mühürlendi. İçindeki anıları keşfetmek için doğru zamanı bekleyin.",
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDateColumn(context, 'Oluşturulma', capsule.createdAt),
                _buildDateColumn(context, 'Açılacak', capsule.openAt),
              ],
            ),
            const SizedBox(height: 16),
            if (capsule.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text("Etiketler", style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children:
                    capsule.tags.map((tag) => Chip(label: Text(tag))).toList(),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 18,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 4),
                Text('${capsule.likes} Beğeni'),
                const SizedBox(width: 16),
                Icon(
                  Icons.comment_outlined,
                  size: 18,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 4),
                Text('${capsule.comments} Yorum'),
                const Spacer(),
                const Icon(Icons.share_outlined, size: 18),
                const SizedBox(width: 4),
                const Text('Aile'),
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
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 2),
        Text(
          DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR').format(date),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCountdownCard(BuildContext context, Capsule capsule) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(
            capsule.imageUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Icon(Icons.lock_clock_outlined, size: 48, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  'Kapsül Kilitli',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDuration(_countdown ?? Duration.zero),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(BuildContext context, Capsule capsule) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Kapsül İçeriği",
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (capsule.mediaTypes.contains(MediaType.photo))
          _buildContentTile(
            context,
            Icons.photo_library_outlined,
            'Fotoğraflar',
            'Anılarınıza göz atın',
          ),
        if (capsule.mediaTypes.contains(MediaType.video))
          _buildContentTile(
            context,
            Icons.video_collection_outlined,
            'Videolar',
            'Kaydedilmiş videoları izleyin',
          ),
        if (capsule.mediaTypes.contains(MediaType.audio))
          _buildContentTile(
            context,
            Icons.multitrack_audio_outlined,
            'Ses Kayıtları',
            'Mesajları ve sesleri dinleyin',
          ),
        if (capsule.mediaTypes.contains(MediaType.text))
          _buildContentTile(
            context,
            Icons.article_outlined,
            'Metin Notları',
            'Yazılmış notları okuyun',
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 32,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap:
            () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$title içeriği görüntülenecek (simülasyon).'),
              ),
            ),
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
