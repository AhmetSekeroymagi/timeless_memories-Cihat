import 'dart:io';

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
    GlobalKey<FormState>(), // Added key for the new structure
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
  Sharing _sharing = Sharing.private;

  // Step 4: NFC & Save
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _textNoteController.dispose();
    super.dispose();
  }

  // --- Actions ---
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) setState(() => _image = File(pickedFile.path));
  }

  Future<void> _pickVideo() async {
    final XFile? pickedFile = await _picker.pickVideo(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) setState(() => _video = File(pickedFile.path));
  }

  void _recordAudio() {
    setState(() => _audioPath = 'kaydedildi.mp3');
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
    if (picked != null && picked != _openDate)
      setState(() => _openDate = picked);
  }

  void _onStepContinue() {
    // Validate current step before proceeding
    bool isStepValid =
        _formKeys[_currentStep].currentState?.validate() ?? false;

    if (isStepValid) {
      if (_currentStep < _steps().length - 1) {
        setState(() => _currentStep++);
      } else {
        _saveCapsule();
      }
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _saveCapsule() async {
    // All forms are already validated step-by-step
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isSaving = false);
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kapsül başarıyla oluşturuldu!')),
      );
    }
  }

  // --- UI Descriptions ---
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Kapsül Oluştur')),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepTapped: (step) => setState(() => _currentStep = step),
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        steps: _steps(),
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
      ),
    );
  }

  List<Step> _steps() {
    return [
      Step(
        title: const Text('Temel Bilgiler'),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        content: Form(
          key: _formKeys[0],
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Kapsül Başlığı',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (v) => v!.isEmpty ? 'Başlık boş olamaz' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Açıklama',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                    validator: (v) => v!.isEmpty ? 'Açıklama boş olamaz' : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      Step(
        title: const Text('İçerik Ekle'),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        content: Form(
          key: _formKeys[1],
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_image != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _image!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (_image != null) const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMediaPickerBox(
                        icon: Icons.photo_library,
                        label: 'Fotoğraf',
                        onTap: _pickImage,
                      ),
                      _buildMediaPickerBox(
                        icon: Icons.video_library,
                        label: 'Video',
                        onTap: _pickVideo,
                      ),
                      _buildMediaPickerBox(
                        icon: Icons.mic,
                        label: 'Ses',
                        onTap: _recordAudio,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _textNoteController,
                    decoration: const InputDecoration(
                      labelText: 'Metin Notu Ekle',
                      prefixIcon: Icon(Icons.article),
                    ),
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      Step(
        title: const Text('Yapılandırma'),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
        content: Form(
          key: _formKeys[2],
          child: Column(
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.calendar_today,
                    color: Colors.blueAccent,
                  ),
                  title: const Text('Açılış Tarihi'),
                  subtitle: Text(
                    _openDate == null
                        ? 'Lütfen bir tarih seçin'
                        : DateFormat(
                          'dd MMMM yyyy',
                          'tr_TR',
                        ).format(_openDate!),
                  ),
                  onTap: () => _selectDate(context),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children:
                        Sharing.values.map((sharing) {
                          return RadioListTile<Sharing>(
                            title: Text(
                              sharing.toString().split('.').last.toUpperCase(),
                            ),
                            secondary: Icon(getSharingIcon(sharing)),
                            value: sharing,
                            groupValue: _sharing,
                            onChanged: (v) => setState(() => _sharing = v!),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Step(
        title: const Text('Kaydet ve Tamamla'),
        isActive: _currentStep >= 3,
        state: _isSaving ? StepState.editing : StepState.indexed,
        content: Form(
          key: _formKeys[3],
          child:
              _isSaving
                  ? const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Kapsül kaydediliyor..."),
                      ],
                    ),
                  )
                  : Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Özet',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.title),
                            title: Text(_titleController.text),
                            subtitle: const Text("Başlık"),
                          ),
                          ListTile(
                            leading: const Icon(Icons.calendar_month),
                            title: Text(
                              _openDate != null
                                  ? DateFormat('dd.MM.yyyy').format(_openDate!)
                                  : "Belirtilmedi",
                            ),
                            subtitle: const Text("Açılış Tarihi"),
                          ),
                          ListTile(
                            leading: Icon(_sharingIcon),
                            title: Text(
                              _sharing.toString().split('.').last.toUpperCase(),
                            ),
                            subtitle: Text(_sharingDescription),
                          ),
                          const Divider(),
                          const SizedBox(height: 10),
                          const Text(
                            'NFC Kolye Eşleştirme',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Kaydettikten sonra kapsülünüzü bir NFC kolyeye bağlayabilirsiniz.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
        ),
      ),
    ];
  }

  Widget _buildMediaPickerBox({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  IconData getSharingIcon(Sharing sharing) {
    switch (sharing) {
      case Sharing.private:
        return Icons.lock;
      case Sharing.family:
        return Icons.group;
      case Sharing.public:
        return Icons.public;
    }
  }
}
