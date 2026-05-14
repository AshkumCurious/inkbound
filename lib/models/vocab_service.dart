import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class VocabWord {
  final String word;
  final String definition;
  final String? example;
  final DateTime addedAt;

  VocabWord({
    required this.word,
    required this.definition,
    this.example,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() => {
        'word': word,
        'definition': definition,
        'example': example,
        'addedAt': addedAt.toIso8601String(),
      };

  factory VocabWord.fromJson(Map<String, dynamic> json) => VocabWord(
        word: json['word'],
        definition: json['definition'],
        example: json['example'],
        addedAt: DateTime.parse(json['addedAt']),
      );
}

class VocabService {
  static const String _key = 'user_vocabulary';

  static Future<List<VocabWord>> getVocabulary() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data == null) return [];
    final List<dynamic> list = jsonDecode(data);
    return list.map((e) => VocabWord.fromJson(e)).toList();
  }

  static Future<void> addWord(VocabWord word) async {
    final prefs = await SharedPreferences.getInstance();
    final List<VocabWord> current = await getVocabulary();
    
    // Avoid duplicates
    if (current.any((w) => w.word.toLowerCase() == word.word.toLowerCase())) return;
    
    current.add(word);
    await prefs.setString(_key, jsonEncode(current.map((w) => w.toJson()).toList()));
  }
}