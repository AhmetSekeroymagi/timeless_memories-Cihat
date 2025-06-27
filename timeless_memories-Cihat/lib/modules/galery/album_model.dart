enum AlbumType { time, location }

enum AlbumAccess { onlyMe, specific, multiple }

class Album {
  final String id;
  final String title;
  final String description;
  final AlbumType type;
  final DateTime? unlockTime;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final List<AlbumContent> contents;
  final AlbumAccess access;
  final List<String> accessUserEmails; // erişim verilen kullanıcılar

  Album({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.unlockTime,
    this.locationName,
    this.latitude,
    this.longitude,
    required this.contents,
    required this.access,
    required this.accessUserEmails,
  });
}

class AlbumContent {
  final String id;
  final String type; // photo, video, audio, text
  final String urlOrText;
  final DateTime createdAt;

  AlbumContent({
    required this.id,
    required this.type,
    required this.urlOrText,
    required this.createdAt,
  });
} 