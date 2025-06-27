import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeless_memories/modules/galery/create_future_letter_screen.dart';
import 'future_letter_model.dart';

enum LetterRecipient { self, other }

class FutureLetterScreen extends StatefulWidget {
  const FutureLetterScreen({Key? key}) : super(key: key);

  @override
  _FutureLetterScreenState createState() => _FutureLetterScreenState();
}

class _FutureLetterScreenState extends State<FutureLetterScreen> {
  LetterRecipient _recipient = LetterRecipient.self;
  final _recipientController = TextEditingController();
  final _textController = TextEditingController();
  DateTime? _openDate;

  bool _isRecording = false;
  String? _audioPath;

  late List<FutureLetter> _letters;

  @override
  void initState() {
    super.initState();
    _letters = FutureLetter.generateSampleLetters();
  }

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

  void _addLetter(FutureLetter newLetter) {
    setState(() {
      _letters.insert(0, newLetter);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geleceğe Mektuplar'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _letters.length,
        itemBuilder: (context, index) {
          return LetterCard(letter: _letters[index]);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateFutureLetterScreen(),
            ),
          );
          if (result != null && result is FutureLetter) {
            _addLetter(result);
          }
        },
        label: const Text('Mektup Yaz'),
        icon: const Icon(Icons.edit_outlined),
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

class LetterCard extends StatelessWidget {
  const LetterCard({Key? key, required this.letter}) : super(key: key);

  final FutureLetter letter;

  @override
  Widget build(BuildContext context) {
    final cardColor =
        letter.isLocked
            ? Colors.grey.shade300
            : Theme.of(context).colorScheme.surface;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(context),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alıcı: ${letter.recipient}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Açılış Tarihi: ${DateFormat.yMMMMd('tr_TR').format(letter.openDate)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                letter.isLocked
                    ? CountdownTimer(openDate: letter.openDate)
                    : _buildUnlockedActions(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        letter.coverImageUrl != null
            ? Image.network(
              letter.coverImageUrl!,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stack) => _buildPlaceholder(context),
            )
            : _buildPlaceholder(context),
        Container(
          height: 150,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              stops: const [0.5, 1.0],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                letter.isLocked
                    ? Icons.lock_clock_outlined
                    : Icons.lock_open_outlined,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                letter.isLocked ? 'Kilitli' : 'Kilidi Açık',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      height: 150,
      color: Theme.of(context).primaryColorLight,
      child: const Center(
        child: Icon(Icons.mail_outline, size: 60, color: Colors.white70),
      ),
    );
  }

  Widget _buildUnlockedActions(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          // Mektubu okuma ekranı açılacak
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${letter.id} ID\'li mektup görüntüleniyor.'),
            ),
          );
        },
        icon: const Icon(Icons.drafts_outlined),
        label: const Text('Şimdi Oku'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
        ),
      ),
    );
  }
}

class CountdownTimer extends StatefulWidget {
  final DateTime openDate;

  const CountdownTimer({Key? key, required this.openDate}) : super(key: key);

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  late Duration _remainingTime;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.openDate.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        _remainingTime = widget.openDate.difference(DateTime.now());
        if (_remainingTime.isNegative) {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remainingTime.isNegative) {
      return Center(
        child: Text(
          'Mektubun kilidi şimdi açıldı!',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final days = _remainingTime.inDays;
    final hours = twoDigits(_remainingTime.inHours.remainder(24));
    final minutes = twoDigits(_remainingTime.inMinutes.remainder(60));
    final seconds = twoDigits(_remainingTime.inSeconds.remainder(60));

    return Column(
      children: [
        Text(
          'Kalan Süre',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 8),
        Text(
          '$days gün $hours:$minutes:$seconds',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
