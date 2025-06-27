import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:timeless_memories/modules/galery/future_letter_model.dart';
import 'package:uuid/uuid.dart';

class CreateFutureLetterScreen extends StatefulWidget {
  const CreateFutureLetterScreen({Key? key}) : super(key: key);

  @override
  _CreateFutureLetterScreenState createState() =>
      _CreateFutureLetterScreenState();
}

enum LetterRecipient { self, other }

class _CreateFutureLetterScreenState extends State<CreateFutureLetterScreen> {
  int _currentStep = 0;
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  // Step 1: Alıcı Bilgileri
  LetterRecipient _recipient = LetterRecipient.self;
  final _recipientController = TextEditingController();

  // Step 2: Mektup İçeriği
  final _textController = TextEditingController();
  File? _coverImage;
  bool _isRecording = false;
  String? _audioPath;

  // Step 3: Zamanlama
  DateTime? _openDate;

  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = Uuid();

  Future<void> _pickCoverImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _coverImage = File(pickedFile.path));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _openDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime(2101),
      helpText: 'MEKTUBUN AÇILACAĞI TARİHİ SEÇİN',
    );
    if (picked != null && picked != _openDate) {
      setState(() => _openDate = picked);
    }
  }

  void _onStepContinue() {
    if (_formKeys[_currentStep].currentState!.validate()) {
      if (_currentStep < 2) {
        setState(() => _currentStep += 1);
      } else {
        _saveAndFinish();
      }
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  void _saveAndFinish() {
    // Create the letter object
    final newLetter = FutureLetter(
      id: _uuid.v4(),
      content: _textController.text,
      creationDate: DateTime.now(),
      openDate: _openDate!,
      recipient:
          _recipient == LetterRecipient.self
              ? 'Kendime'
              : _recipientController.text,
      audioPath: _audioPath,
      // coverImageUrl will be handled by an upload service in a real app
      // For now, we pass the local file path to the model if needed, or handle it differently.
      // Let's assume the model can take a File and the list screen can display it.
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Geleceğe mektubunuz başarıyla zamanlandı!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop(newLetter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Mektup Oluştur')),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepTapped: (step) => setState(() => _currentStep = step),
        onStepCancel: _onStepCancel,
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(
                    _currentStep == 2 ? 'Bitir ve Kaydet' : 'Sonraki Adım',
                  ),
                ),
                const SizedBox(width: 8),
                if (_currentStep > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Geri'),
                  ),
              ],
            ),
          );
        },
        steps: [_buildRecipientStep(), _buildContentStep(), _buildTimingStep()],
      ),
    );
  }

  Step _buildRecipientStep() {
    return Step(
      title: const Text('Alıcı'),
      subtitle: const Text('Bu mektup kime?'),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _formKeys[0],
        child: Column(
          children: [
            CupertinoSlidingSegmentedControl<LetterRecipient>(
              groupValue: _recipient,
              onValueChanged: (value) => setState(() => _recipient = value!),
              children: const {
                LetterRecipient.self: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Kendime'),
                ),
                LetterRecipient.other: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Başkasına'),
                ),
              },
            ),
            if (_recipient == LetterRecipient.other)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextFormField(
                  controller: _recipientController,
                  decoration: const InputDecoration(
                    labelText: 'Alıcının e-postası',
                    icon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (_recipient == LetterRecipient.other &&
                        (value == null ||
                            value.isEmpty ||
                            !value.contains('@'))) {
                      return 'Lütfen geçerli bir e-posta adresi girin.';
                    }
                    return null;
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Step _buildContentStep() {
    return Step(
      title: const Text('İçerik'),
      subtitle: const Text('Aklındakileri yaz'),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _formKeys[1],
        child: Column(
          children: [
            TextFormField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Geleceğe notun...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Mektup içeriği boş olamaz.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.mic_none),
              title: const Text('Sesli Mesaj Ekle'),
              subtitle: const Text('(Yakında)'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.photo_outlined),
              title: const Text('Kapak Fotoğrafı Ekle'),
              subtitle:
                  _coverImage != null
                      ? Text(Uri.file(_coverImage!.path).pathSegments.last)
                      : const Text('İsteğe bağlı'),
              onTap: _pickCoverImage,
            ),
          ],
        ),
      ),
    );
  }

  Step _buildTimingStep() {
    return Step(
      title: const Text('Zamanlama'),
      subtitle: const Text('Ne zaman açılsın?'),
      isActive: _currentStep >= 2,
      state: _currentStep == 2 ? StepState.editing : StepState.indexed,
      content: Form(
        key: _formKeys[2],
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Açılış Tarihi'),
              subtitle: Text(
                _openDate == null
                    ? 'Henüz seçilmedi'
                    : DateFormat('dd MMMM yyyy', 'tr_TR').format(_openDate!),
                style: TextStyle(
                  color: _openDate == null ? Colors.red.shade700 : null,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _selectDate(context),
            ),
            if (_openDate == null)
              const Padding(
                padding: EdgeInsets.only(left: 16.0, top: 4.0),
                child: Text(
                  'Lütfen bir tarih seçin.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
