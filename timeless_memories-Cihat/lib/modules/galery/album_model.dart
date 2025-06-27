import 'dart:io';

enum AlbumType { time, location }

enum AlbumAccess { onlyMe, specific, multiple }

class Album {
  final String id;
  final String title;
  final String? coverImageUrl;
  final File? coverImageFile;
  final int itemCount;
  final DateTime lastUpdated;
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
    this.coverImageUrl,
    this.coverImageFile,
    required this.itemCount,
    required this.lastUpdated,
    required this.type,
    this.unlockTime,
    this.locationName,
    this.latitude,
    this.longitude,
    required this.contents,
    required this.access,
    required this.accessUserEmails,
  });

  Album copyWith({
    String? id,
    String? title,
    String? coverImageUrl,
    File? coverImageFile,
    int? itemCount,
    DateTime? lastUpdated,
    AlbumType? type,
    DateTime? unlockTime,
    String? locationName,
    double? latitude,
    double? longitude,
    List<AlbumContent>? contents,
    AlbumAccess? access,
    List<String>? accessUserEmails,
  }) {
    return Album(
      id: id ?? this.id,
      title: title ?? this.title,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      coverImageFile: coverImageFile ?? this.coverImageFile,
      itemCount: itemCount ?? this.itemCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      type: type ?? this.type,
      unlockTime: unlockTime ?? this.unlockTime,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      contents: contents ?? this.contents,
      access: access ?? this.access,
      accessUserEmails: accessUserEmails ?? this.accessUserEmails,
    );
  }

  // Örnek veri oluşturmak için yardımcı fabrika
  factory Album.createSample(int index) {
    final titles = [
      'Aile Tatili',
      'Mezuniyet',
      'Doğum Günü',
      'Avrupa Turu',
      'Evcil Hayvanlar',
      'Hafta Sonu Kaçamağı',
    ];
    final images = [
      'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?ixlib=rb-4.0.3&q=85&fm=jpg&crop=entropy&cs=srgb&w=600',
      'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?ixlib=rb-4.0.3&q=85&fm=jpg&crop=entropy&cs=srgb&w=600',
      'https://images.unsplash.com/photo-1501785888041-af3ef285b470?ixlib=rb-4.0.3&q=85&fm=jpg&crop=entropy&cs=srgb&w=600',
      'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?ixlib=rb-4.0.3&q=85&fm=jpg&crop=entropy&cs=srgb&w=600',
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.0.3&q=85&fm=jpg&crop=entropy&cs=srgb&w=600',
      'https://images.unsplash.com/photo-1527698383986-1a8613e52156?ixlib=rb-4.0.3&q=85&fm=jpg&crop=entropy&cs=srgb&w=600',
    ];
    return Album(
      id: 'sample_$index',
      title: titles[index % titles.length],
      coverImageUrl: images[index % images.length],
      itemCount: (index + 1) * 7,
      lastUpdated: DateTime.now().subtract(Duration(days: index * 5)),
      type: index.isEven ? AlbumType.time : AlbumType.location,
      access: AlbumAccess.values[index % AlbumAccess.values.length],
      contents: [],
      accessUserEmails: [],
      unlockTime:
          index.isEven ? DateTime.now().add(Duration(days: index * 2)) : null,
    );
  }
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
