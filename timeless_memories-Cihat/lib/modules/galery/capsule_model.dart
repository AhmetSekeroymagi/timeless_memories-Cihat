import 'package:google_maps_flutter/google_maps_flutter.dart';

enum MediaType { photo, video, audio, text }

class LatLngModel {
  final double latitude;
  final double longitude;

  LatLngModel({required this.latitude, required this.longitude});

  LatLng toGoogleLatLng() => LatLng(latitude, longitude);
}

class Capsule {
  final String id;
  final String title;
  final String imageUrl; // This can be a preview image
  final DateTime createdAt;
  final DateTime openAt;
  final bool isOpened;
  final List<MediaType> mediaTypes;
  final String owner;
  final int likes;
  final int comments;
  final List<String> tags;
  final LatLngModel? location;

  Capsule({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.createdAt,
    required this.openAt,
    required this.isOpened,
    required this.mediaTypes,
    required this.owner,
    this.likes = 0,
    this.comments = 0,
    this.tags = const [],
    this.location,
  });
}
