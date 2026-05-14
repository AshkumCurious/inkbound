import 'package:flutter/material.dart';
import '../models/vocab_service.dart';
import '../themes/app_theme.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  List<VocabWord> _words = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVocabulary();
  }

  Future<void> _loadVocabulary() async {
    final words = await VocabService.getVocabulary();
    setState(() {
      _words = words..sort((a, b) => b.addedAt.compareTo(a.addedAt));
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0806), Color(0xFF1F1B16)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      "My Vocabulary",
                      style: AppTextStyles.displaySmall(),
                    ),
                    const Spacer(),
                    Text(
                      "${_words.length} words",
                      style: AppTextStyles.label(size: 15),
                    ),
                  ],
                ),
              ),
              if (_isLoading)
                const Expanded(
                    child: Center(child: CircularProgressIndicator()))
              else if (_words.isEmpty)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bookmark_border,
                            size: 80, color: Colors.white24),
                        SizedBox(height: 16),
                        Text("No words saved yet",
                            style: TextStyle(fontSize: 18)),
                        Text("Tap words while reading to save them",
                            style: TextStyle(color: Colors.white54)),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _words.length,
                    itemBuilder: (context, index) {
                      final word = _words[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.darkCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              word.word.toUpperCase(),
                              style: AppTextStyles.displayMedium(),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              word.definition,
                              style: const TextStyle(fontSize: 16, height: 1.5),
                            ),
                            if (word.example != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                "“${word.example}”",
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              "Saved ${word.addedAt.toString().substring(0, 10)}",
                              style: AppTextStyles.mono(size: 12),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
