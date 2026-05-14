import 'package:http/http.dart' as http;

import '../exports.dart';

class DefinitionBottomSheet extends StatefulWidget {
  final String word;
  final StoryTheme theme;

  const DefinitionBottomSheet(
      {super.key, required this.word, required this.theme});

  @override
  State<DefinitionBottomSheet> createState() => DefinitionBottomSheetState();
}

class DefinitionBottomSheetState extends State<DefinitionBottomSheet> {
  bool _loading = true;
  String? _definition;
  String? _example;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDefinition();
  }

  Future<void> _fetchDefinition() async {
    try {

        final cleanWord = widget.word
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .trim();
      final response = await http.get(
        Uri.parse(
            'https://api.dictionaryapi.dev/api/v2/entries/en/$cleanWord'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)[0];
        setState(() {
          _definition = data['meanings'][0]['definitions'][0]['definition'];
          _example = data['meanings'][0]['definitions'][0]['example'];
          _loading = false;
        });
      } else {
        setState(() {
          _error = "No definition found";
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Failed to fetch definition";
        _loading = false;
      });
    }
  }

  Future<void> _addToVocab() async {
    if (_definition == null) return;
    await VocabService.addWord(VocabWord(
      word: widget.word,
      definition: _definition!,
      example: _example,
      addedAt: DateTime.now(),
    ));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.word} added to vocabulary'),
          backgroundColor: widget.theme.primary,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: t.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.word.toUpperCase(),
              style: AppTextStyles.displayMedium(color: t.primary)),
          const SizedBox(height: 16),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red))
          else ...[
            Text(_definition ?? '',
                style: const TextStyle(fontSize: 17, height: 1.6)),
            if (_example != null) ...[
              const SizedBox(height: 16),
              Text('"$_example"',
                  style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: t.primary.withValues(alpha: 0.8))),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addToVocab,
                icon: const Icon(Icons.add),
                label: const Text('Add to My Vocabulary'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: t.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
