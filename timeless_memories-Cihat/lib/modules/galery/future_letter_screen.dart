import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum LetterRecipient { self, other }

class FutureLetterScreen extends StatefulWidget {
  const FutureLetterScreen({super.key});

  @override
  State<FutureLetterScreen> createState() => _FutureLetterScreenState();
}

class _FutureLetterScreenState extends State<FutureLetterScreen> {
  LetterRecipient _recipient = LetterRecipient.self;
  final _recipientController = TextEditingController();
  final _textController = TextEditingController();
  DateTime? _openDate;

  bool _isRecording = false;
  String? _audioPath;

  void _onSaveLetter() {
    if (_openDate == null || _textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen metin ve tarih alanlarını doldurun.'),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Geleceğe mektubunuz başarıyla kaydedildi!'),
      ),
    );
    Navigator.of(context).pop();
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

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (!_isRecording) {
        // Simulate saving a recording
        _audioPath = "gelecek_kaydi.mp3";
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ses kaydı tamamlandı (simülasyon).')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geleceğe Mektup'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _onSaveLetter),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildRecipientSelector(),
          const SizedBox(height: 24),
          _buildLetterContent(),
          const SizedBox(height: 24),
          _buildConfiguration(),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _onSaveLetter,
              icon: const Icon(Icons.send_and_archive_outlined),
              label: const Text('Kaydet ve Bitir'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipientSelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Alıcıyı Seçin',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Bu mektubu kime göndermek istersiniz?'),
            const SizedBox(height: 16),
            CupertinoSlidingSegmentedControl<LetterRecipient>(
              groupValue: _recipient,
              onValueChanged: (value) {
                if (value != null) setState(() => _recipient = value);
              },
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
                child: TextField(
                  controller: _recipientController,
                  decoration: const InputDecoration(
                    labelText: 'Alıcının e-postası veya kullanıcı adı',
                    icon: Icon(Icons.person_search),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterContent() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '2. Mesajınızı Oluşturun',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Gelecekteki size veya sevdiklerinize notunuz...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 6,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(
                _isRecording ? Icons.stop_circle_outlined : Icons.mic_none,
                color: _isRecording ? Colors.red : null,
              ),
              title: Text(
                _isRecording
                    ? 'Kaydediliyor...'
                    : (_audioPath != null
                        ? 'Kayıt Tamamlandı'
                        : 'Sesli Mesaj Kaydet'),
              ),
              subtitle: _audioPath != null ? Text(_audioPath!) : null,
              onTap: _toggleRecording,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfiguration() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '3. Zaman ve Bağlantı',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Açılış Tarihi'),
              subtitle: Text(
                _openDate == null
                    ? 'Henüz seçilmedi'
                    : DateFormat('dd MMMM yyyy', 'tr_TR').format(_openDate!),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _selectDate(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('Konum Ekle (İsteğe Bağlı)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Konum seçme ekranı açılacak.')),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.nfc_outlined),
              title: const Text('NFC Etiketine Bağla (İsteğe Bağlı)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('NFC eşleştirme ekranı açılacak.'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
