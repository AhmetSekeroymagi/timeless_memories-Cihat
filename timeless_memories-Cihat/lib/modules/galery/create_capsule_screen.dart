import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

enum Sharing { private, family, public }

class CreateCapsuleScreen extends StatefulWidget {
  const CreateCapsuleScreen({super.key});

  @override
  State<CreateCapsuleScreen> createState() => _CreateCapsuleScreenState();
}

class _CreateCapsuleScreenState extends State<CreateCapsuleScreen> {
  int _currentStep = 0;
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  // Step 1: Details
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Step 2: Content
  File? _image;
  File? _video;
  String? _audioPath; // For dummy recording path
  final _textNoteController = TextEditingController();

  // Step 3: Configuration
  DateTime? _openDate;
  String? _location;
  Sharing _sharing = Sharing.private;

  // Step 4: NFC & Save
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _pickVideo() async {
    final XFile? pickedFile = await _picker.pickVideo(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _video = File(pickedFile.path));
    }
  }

  void _recordAudio() {
    // Dummy audio recording logic
    setState(() => _audioPath = 'recorded_audio.mp3');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ses kaydı tamamlandı (simülasyon).')),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _openDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _openDate) {
      setState(() => _openDate = picked);
    }
  }

  String get _sharingDescription {
    switch (_sharing) {
      case Sharing.private:
        return 'Sadece siz erişebilirsiniz.';
      case Sharing.family:
        return 'Sadece aile grubunuz görebilir.';
      case Sharing.public:
        return 'Herkes tarafından keşfedilebilir.';
    }
  }

  IconData get _sharingIcon {
    switch (_sharing) {
      case Sharing.private:
        return Icons.lock_person_sharp;
      case Sharing.family:
        return Icons.group;
      case Sharing.public:
        return Icons.public;
    }
  }

  void _saveCapsule() async {
    if (_formKeys.every((key) => key.currentState!.validate())) {
      setState(() => _isSaving = true);
      // Dummy save operation
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _isSaving = false);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kapsül başarıyla oluşturuldu!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm gerekli alanları doldurun.')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _textNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Kapsül Oluştur')),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepTapped: (step) => setState(() => _currentStep = step),
        onStepContinue: () {
          if (_currentStep < _steps().length - 1) {
            setState(() => _currentStep++);
          } else {
            _saveCapsule();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(
                    _currentStep == _steps().length - 1 ? 'Kaydet' : 'İleri',
                  ),
                ),
                if (_currentStep > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Geri'),
                  ),
              ],
            ),
          );
        },
        steps: _steps(),
      ),
    );
  }

  List<Step> _steps() {
    return [
      Step(
        title: const Text('Detaylar'),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        content: Form(
          key: _formKeys[0],
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Kapsül Başlığı'),
                validator:
                    (value) => value!.isEmpty ? 'Başlık boş olamaz' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Açıklama'),
                maxLines: 3,
                validator:
                    (value) => value!.isEmpty ? 'Açıklama boş olamaz' : null,
              ),
            ],
          ),
        ),
      ),
      Step(
        title: const Text('İçerik'),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        content: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Fotoğraf Yükle'),
              subtitle:
                  _image != null ? Text(_image!.path.split('/').last) : null,
              onTap: _pickImage,
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Video Yükle'),
              subtitle:
                  _video != null ? Text(_video!.path.split('/').last) : null,
              onTap: _pickVideo,
            ),
            ListTile(
              leading: const Icon(Icons.mic),
              title: const Text('Ses Kaydet'),
              subtitle: _audioPath != null ? Text(_audioPath!) : null,
              onTap: _recordAudio,
            ),
            TextFormField(
              controller: _textNoteController,
              decoration: const InputDecoration(labelText: 'Metin Notu Ekle'),
              maxLines: 4,
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Yapılandırma'),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Açılış Tarihi'),
              subtitle: Text(
                _openDate == null
                    ? 'Tarih Seç'
                    : DateFormat('dd MMMM yyyy', 'tr_TR').format(_openDate!),
              ),
              onTap: () => _selectDate(context),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Paylaşım Seçenekleri",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ...Sharing.values.map(
              (sharing) => RadioListTile<Sharing>(
                title: Text(sharing.toString().split('.').last.toUpperCase()),
                value: sharing,
                groupValue: _sharing,
                onChanged: (Sharing? value) {
                  if (value != null) setState(() => _sharing = value);
                },
              ),
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Kaydet'),
        isActive: _currentStep >= 3,
        state:
            _isSaving
                ? StepState.editing
                : (_currentStep >= 3 ? StepState.complete : StepState.indexed),
        content:
            _isSaving
                ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text("Kapsül kaydediliyor..."),
                    ],
                  ),
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Özet:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Başlık: ${_titleController.text}'),
                    Text(
                      'Açılış: ${_openDate != null ? DateFormat('dd.MM.yyyy').format(_openDate!) : "Belirtilmedi"}',
                    ),
                    ListTile(
                      leading: Icon(_sharingIcon),
                      title: Text(
                        _sharing.toString().split('.').last.toUpperCase(),
                      ),
                      subtitle: Text(_sharingDescription),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'NFC Kolye Eşleştirme',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Kaydettikten sonra kapsülünüzü bir NFC kolyeye bağlayabilirsiniz.',
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'NFC Eşleştirme ekranına yönlendirilecek.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.nfc),
                      label: const Text("Şimdi Eşleştir (Simülasyon)"),
                    ),
                  ],
                ),
      ),
    ];
  }
}
