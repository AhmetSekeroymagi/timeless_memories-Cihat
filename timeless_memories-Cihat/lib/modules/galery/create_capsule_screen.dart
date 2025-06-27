import 'package:flutter/material.dart';

class CreateCapsuleScreen extends StatefulWidget {
  const CreateCapsuleScreen({Key? key}) : super(key: key);

  @override
  State<CreateCapsuleScreen> createState() => _CreateCapsuleScreenState();
}

class _CreateCapsuleScreenState extends State<CreateCapsuleScreen> {
  int _currentStep = 0;

  // Adım 1
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // Adım 2
  String? _photoPath;
  String? _videoPath;
  String? _audioPath;
  final TextEditingController _noteController = TextEditingController();

  // Adım 3
  DateTime? _lockDate;
  String? _location;

  // Adım 4 - Önizleme için
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveCapsule() async {
    setState(() {
      _isSaving = true;
    });
    await Future.delayed(const Duration(seconds: 1)); // Dummy kayıt işlemi
    setState(() {
      _isSaving = false;
    });
    if (mounted) {
      Navigator.of(context).pop(); // Kapsüller listesine dön
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kapsül başarıyla oluşturuldu!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kapsül Oluştur')),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 3) {
            setState(() => _currentStep++);
          } else {
            _saveCapsule();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          } else {
            Navigator.of(context).pop();
          }
        },
        steps: [
          Step(
            title: const Text('Genel Bilgi'),
            isActive: _currentStep >= 0,
            content: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Başlık'),
                ),
                TextField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Açıklama'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Medya Ekle'),
            isActive: _currentStep >= 1,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _photoPath = 'dummy_photo.jpg';
                    });
                  },
                  icon: const Icon(Icons.photo),
                  label: Text(_photoPath == null ? 'Fotoğraf Ekle' : 'Fotoğraf Eklendi'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _videoPath = 'dummy_video.mp4';
                    });
                  },
                  icon: const Icon(Icons.videocam),
                  label: Text(_videoPath == null ? 'Video Ekle' : 'Video Eklendi'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _audioPath = 'dummy_audio.aac';
                    });
                  },
                  icon: const Icon(Icons.mic),
                  label: Text(_audioPath == null ? 'Ses Kaydet' : 'Ses Eklendi'),
                ),
                TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(labelText: 'Metin Notu'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Kilit Seçenekleri'),
            isActive: _currentStep >= 2,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.date_range),
                  title: Text(_lockDate == null
                      ? 'Tarih seç'
                      : '📅 ${_lockDate!.day}.${_lockDate!.month}.${_lockDate!.year} tarihine kadar kilitli'),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => _lockDate = picked);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(_location == null
                      ? 'Konum seç'
                      : '📍 $_location konumunda açılacak'),
                  onTap: () {
                    setState(() {
                      _location = 'Dummy Konum';
                    });
                  },
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Önizleme & Kaydet'),
            isActive: _currentStep >= 3,
            content: _isSaving
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Başlık: ${_titleController.text}'),
                      Text('Açıklama: ${_descController.text}'),
                      Text('Fotoğraf: ${_photoPath ?? "Yok"}'),
                      Text('Video: ${_videoPath ?? "Yok"}'),
                      Text('Ses: ${_audioPath ?? "Yok"}'),
                      Text('Not: ${_noteController.text.isEmpty ? "Yok" : _noteController.text}'),
                      Text('Kilit Tarihi: ${_lockDate != null ? "${_lockDate!.day}.${_lockDate!.month}.${_lockDate!.year}" : "Yok"}'),
                      Text('Konum: ${_location ?? "Yok"}'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _saveCapsule,
                        icon: const Icon(Icons.save),
                        label: const Text('📦 Kapsül Oluştur'),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
} 