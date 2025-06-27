import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:timeless_memories/modules/galery/capsule_model.dart';
import 'package:timeless_memories/modules/galery/capsule_detail_screen.dart';

class LocationCapsulesScreen extends StatefulWidget {
  const LocationCapsulesScreen({super.key});

  @override
  State<LocationCapsulesScreen> createState() => _LocationCapsulesScreenState();
}

class _LocationCapsulesScreenState extends State<LocationCapsulesScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  Capsule? _selectedCapsule;

  final List<Capsule> _capsules = [
    // Dummy Data
    Capsule(
      id: 'loc1',
      title: 'Galata Kulesi Anısı',
      imageUrl:
          'https://images.unsplash.com/photo-1597902936163-348339d725a2?auto=format&fit=crop&w=400&q=80',
      createdAt: DateTime.now(),
      openAt: DateTime(2025),
      isOpened: false,
      mediaTypes: [MediaType.photo],
      owner: 'Gezgin',
      location: LatLngModel(latitude: 41.0259, longitude: 28.9744),
    ),
    Capsule(
      id: 'loc2',
      title: 'Sultanahmet Meydanı',
      imageUrl:
          'https://images.unsplash.com/photo-1554914383-94a15544614e?auto=format&fit=crop&w=400&q=80',
      createdAt: DateTime.now(),
      openAt: DateTime(2025),
      isOpened: false,
      mediaTypes: [MediaType.photo],
      owner: 'Tarihçi',
      location: LatLngModel(latitude: 41.0086, longitude: 28.9772),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _setMarkers();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Konum servisleri kapalı.')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Konum izni reddedildi.')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Konum izni kalıcı olarak reddedildi, ayarlardan açabilirsiniz.',
          ),
        ),
      );
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
    });
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        14,
      ),
    );
  }

  void _setMarkers() {
    for (var capsule in _capsules) {
      _markers.add(
        Marker(
          markerId: MarkerId(capsule.id),
          position: capsule.location!.toGoogleLatLng(),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          onTap: () {
            setState(() {
              _selectedCapsule = capsule;
            });
          },
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  double _calculateDistance(LatLng pos1, LatLng pos2) {
    return Geolocator.distanceBetween(
      pos1.latitude,
      pos1.longitude,
      pos2.latitude,
      pos2.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konum Kapsülleri')),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target:
                  _currentPosition != null
                      ? LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      )
                      : const LatLng(41.0082, 28.9784), // Fallback to Istanbul
              zoom: 14.0,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onTap: (_) {
              setState(() {
                _selectedCapsule = null;
              });
            },
          ),
          if (_selectedCapsule != null) _buildCapsuleInfoPanel(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Yeni konum kapsülü oluşturma özelliği yakında!'),
            ),
          );
        },
        label: const Text('Yeni Kapsül'),
        icon: const Icon(Icons.add_location_alt),
      ),
    );
  }

  Widget _buildCapsuleInfoPanel() {
    if (_selectedCapsule == null) return const SizedBox.shrink();

    final distance =
        _currentPosition != null
            ? _calculateDistance(
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              _selectedCapsule!.location!.toGoogleLatLng(),
            )
            : null;

    final canOpen = distance != null && distance <= 100; // 100 metre

    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedCapsule!.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text('Sahibi: ${_selectedCapsule!.owner}'),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    canOpen ? Icons.lock_open : Icons.lock_outline,
                    color: canOpen ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    canOpen ? 'Kapsülü açabilirsin!' : 'Yaklaşman gerekiyor',
                  ),
                  const Spacer(),
                  if (distance != null)
                    Text(
                      '${distance.toStringAsFixed(0)}m',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      canOpen
                          ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => CapsuleDetailScreen(
                                    capsule: _selectedCapsule!,
                                  ),
                            ),
                          )
                          : null,
                  icon: const Icon(Icons.visibility),
                  label: const Text('Kapsülü Görüntüle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        canOpen
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
