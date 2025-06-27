import 'package:flutter/material.dart';

class FutureLetterScreen extends StatefulWidget {
  const FutureLetterScreen({Key? key}) : super(key: key);

  @override
  State<FutureLetterScreen> createState() => _FutureLetterScreenState();
}

class _FutureLetterScreenState extends State<FutureLetterScreen> {
  String mode = 'text';
  final TextEditingController _textController = TextEditingController();
  DateTime? _openDate;
  String? _audioPath;
  final List<Map<String, dynamic>> sentLetters = [];

  void _sendLetter() {
    if (_openDate == null || (mode == 'text' && _textController.text.isEmpty) || (mode == 'audio' && _audioPath == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun!')),
      );
      return;
    }
    sentLetters.add({
      'mode': mode,
      'text': _textController.text,
      'audio': _audioPath,
      'openDate': _openDate,
      'sentAt': DateTime.now(),
    });
    setState(() {
      _textController.clear();
      _audioPath = null;
      _openDate = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mektubun başarıyla gönderildi!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Geleceğe Mektup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('📝 Yazılı Mesaj'),
                  selected: mode == 'text',
                  onSelected: (_) => setState(() => mode = 'text'),
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('🎙 Sesli Mesaj'),
                  selected: mode == 'audio',
                  onSelected: (_) => setState(() => mode = 'audio'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (mode == 'text')
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Mesajını yaz',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            if (mode == 'audio')
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _audioPath = 'dummy_audio.aac';
                      });
                    },
                    icon: const Icon(Icons.mic),
                    label: Text(_audioPath == null ? 'Ses kaydet' : 'Ses kaydedildi'),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: Text(_openDate == null
                  ? 'Açılma tarihi seç'
                  : 'Açılma tarihi: ${_openDate!.day}.${_openDate!.month}.${_openDate!.year}'),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now().add(const Duration(days: 1)),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => _openDate = picked);
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _sendLetter,
              icon: const Icon(Icons.send),
              label: const Text('📤 Mektubu Gönder'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const Text('Gönderilen Mektuplar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            if (sentLetters.isEmpty)
              const Text('Henüz hiç mektup göndermediniz.'),
            ...sentLetters.map((letter) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: Icon(letter['mode'] == 'text' ? Icons.text_snippet : Icons.mic),
                    title: Text(letter['mode'] == 'text' ? (letter['text'] as String) : 'Sesli mesaj'),
                    subtitle: Text('Açılma tarihi: ${letter['openDate'].day}.${letter['openDate'].month}.${letter['openDate'].year}'),
                  ),
                )),
          ],
        ),
      ),
    );
  }
} 