import 'package:flutter/material.dart';
import 'dart:async';
import 'capsule_detail_screen.dart';

class NfcScanScreen extends StatefulWidget {
  const NfcScanScreen({Key? key}) : super(key: key);

  @override
  State<NfcScanScreen> createState() => _NfcScanScreenState();
}

class _NfcScanScreenState extends State<NfcScanScreen> with SingleTickerProviderStateMixin {
  bool _isScanning = false;
  bool _scanSuccess = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startScan() async {
    setState(() {
      _isScanning = true;
      _scanSuccess = false;
    });
    await Future.delayed(const Duration(seconds: 2));
    // Dummy: %70 başarı şansı
    final success = DateTime.now().millisecond % 10 < 7;
    if (success) {
      setState(() {
        _scanSuccess = true;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CapsuleDetailScreen(
              title: 'NFC ile Açılan Kapsül',
              description: 'Bu kapsül fiziksel kolye ile açıldı.',
              isLocked: false,
              openAt: DateTime.now(),
              photoUrl: 'https://via.placeholder.com/100',
              videoUrl: null,
              audioUrl: null,
              note: 'NFC ile açılan kapsül notu.',
              location: 'İstanbul',
            ),
          ),
        );
      }
    } else {
      setState(() {
        _isScanning = false;
        _scanSuccess = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('NFC okuma başarısız! Lütfen tekrar deneyin.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NFC ile Kapsül Aç')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '📳 Kolyeyi telefonuna yaklaştır',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1 + 0.1 * _controller.value,
                  child: child,
                );
              },
              child: Icon(
                Icons.nfc,
                size: 80,
                color: _isScanning ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            _isScanning
                ? const Text('NFC taranıyor...', style: TextStyle(color: Colors.green))
                : ElevatedButton.icon(
                    onPressed: _startScan,
                    icon: const Icon(Icons.nfc),
                    label: const Text('NFC Taramasını Başlat'),
                  ),
          ],
        ),
      ),
    );
  }
} 