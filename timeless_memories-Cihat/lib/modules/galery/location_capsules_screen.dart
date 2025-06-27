import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';

class LocationCapsulesScreen extends StatefulWidget {
  const LocationCapsulesScreen({Key? key}) : super(key: key);

  @override
  State<LocationCapsulesScreen> createState() => _LocationCapsulesScreenState();
}

class _LocationCapsulesScreenState extends State<LocationCapsulesScreen> {
  late GoogleMapController _mapController;
  final LatLng _userLocation = const LatLng(41.0082, 28.9784); // İstanbul dummy

  final List<Map<String, dynamic>> capsules = [
    {
      'id': '1',
      'title': 'Galata Kulesi Anısı',
      'description': 'Galata Kulesi önünde çekilen fotoğraf.',
      'location': const LatLng(41.0256, 28.9744),
      'isActive': false,
    },
    {
      'id': '2',
      'title': 'Sultanahmet Hatırası',
      'description': 'Sultanahmet Meydanı gezisi.',
      'location': const LatLng(41.0054, 28.9768),
      'isActive': false,
    },
  ];

  Set<Marker> get _markers {
    return capsules.map((capsule) {
      return Marker(
        markerId: MarkerId(capsule['id']),
        position: capsule['location'],
        infoWindow: InfoWindow(
          title: capsule['title'],
          snippet: capsule['description'],
          onTap: () {
            _checkProximityAndNotify(capsule);
          },
        ),
        onTap: () {
          _checkProximityAndNotify(capsule);
        },
      );
    }).toSet();
  }

  void _checkProximityAndNotify(Map<String, dynamic> capsule) {
    double distance = _calculateDistance(
      _userLocation.latitude,
      _userLocation.longitude,
      capsule['location'].latitude,
      capsule['location'].longitude,
    );
    if (distance < 0.2) { // 200 metre
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('📍 Anı aktif hale geldi: ${capsule['title']}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bu anıya yaklaşmalısın! (Mesafe: ${distance.toStringAsFixed(2)} km)')),
      );
    }
  }

  double _calculateDistance(lat1, lon1, lat2, lon2) {
    const double R = 6371; // km
    double dLat = _deg2rad(lat2 - lat1);
    double dLon = _deg2rad(lon2 - lon1);
    double a =
        sin(dLat / 2) * sin(dLat / 2) + cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konum Kapsülleri')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _userLocation,
          zoom: 13,
        ),
        markers: _markers,
        myLocationEnabled: true,
        onMapCreated: (controller) => _mapController = controller,
      ),
    );
  }
} 