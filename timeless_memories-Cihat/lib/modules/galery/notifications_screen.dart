import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum NotificationType { capsuleOpen, newShare, nostalgia, familyUpdate }

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime date;
  bool isRead;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.date,
    this.isRead = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<AppNotification> _notifications = [
    AppNotification(
      id: '1',
      type: NotificationType.capsuleOpen,
      title: 'Kapsülün Açıldı!',
      body: '"Mezuniyet Günü" adlı anı kapsülün artık görüntülenebilir.',
      date: DateTime.now(),
    ),
    AppNotification(
      id: '2',
      type: NotificationType.newShare,
      title: 'Yeni Paylaşım',
      body: 'Ayşe seninle "Tatil Anıları" albümünü paylaştı.',
      date: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    AppNotification(
      id: '3',
      type: NotificationType.nostalgia,
      title: '1 Yıl Önce Bugün',
      body:
          'Geçen yıl bu zamanlar oluşturduğun bir anıyı hatırlamak ister misin?',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AppNotification(
      id: '4',
      type: NotificationType.familyUpdate,
      title: 'Aile Grubuna Katıldı',
      body: 'Mehmet aile grubuna katıldı.',
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    AppNotification(
      id: '5',
      type: NotificationType.capsuleOpen,
      title: 'Kapsülün Açıldı!',
      body: '"İlk İş Günü" adlı anı kapsülün artık görüntülenebilir.',
      date: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.capsuleOpen:
        return Icons.lock_open_outlined;
      case NotificationType.newShare:
        return Icons.people_alt_outlined;
      case NotificationType.nostalgia:
        return Icons.history_outlined;
      case NotificationType.familyUpdate:
        return Icons.family_restroom_outlined;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Bugün';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else {
      return DateFormat('dd MMMM yyyy', 'tr_TR').format(date);
    }
  }

  Map<String, List<AppNotification>> _groupNotifications() {
    final Map<String, List<AppNotification>> grouped = {};
    for (var notif in _notifications) {
      final key = _formatDate(notif.date);
      if (grouped[key] == null) {
        grouped[key] = [];
      }
      grouped[key]!.add(notif);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedNotifications = _groupNotifications();
    final sortedKeys = groupedNotifications.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Navigate to settings screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bildirim ayarları ekranı açılacak.'),
                ),
              );
            },
          ),
        ],
      ),
      body:
          groupedNotifications.isEmpty
              ? const Center(child: Text('Hiç bildiriminiz yok.'))
              : ListView.builder(
                itemCount: sortedKeys.length,
                itemBuilder: (context, index) {
                  final dateKey = sortedKeys[index];
                  final notificationsForDate = groupedNotifications[dateKey]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          dateKey,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(color: Colors.grey),
                        ),
                      ),
                      ...notificationsForDate.map(
                        (notif) => _buildNotificationTile(notif),
                      ),
                    ],
                  );
                },
              ),
    );
  }

  Widget _buildNotificationTile(AppNotification notif) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              notif.isRead
                  ? Colors.transparent
                  : Theme.of(context).primaryColor,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColorLight,
          child: Icon(
            _getIconForType(notif.type),
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          notif.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(notif.body),
        trailing: Text(DateFormat.Hm('tr_TR').format(notif.date)),
        onTap: () {
          setState(() {
            notif.isRead = true;
          });
          // Navigate to relevant content if any
        },
      ),
    );
  }
}
