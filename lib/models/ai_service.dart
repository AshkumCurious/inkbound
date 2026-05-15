import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:inkbound/aiConfig.dart';
import '../models/story_theme.dart';
import '../models/story_state.dart';
import 'quiz_question.dart';

class ClaudeService {
  // ==================== GENERATE STORY ====================
  static Future<StorySegment> generateStory({
    required StoryTheme theme,
    required String prompt,
    required List<StorySegment> history,
  }) async {
    final fullPrompt = _buildStoryPrompt(
      theme: theme,
      prompt: prompt,
      history: history,
    );

    final raw = await _generateText(prompt: fullPrompt);

    return _parseSegment(raw);
  }

  // ==================== GENERATE QUIZ ====================
  static Future<List<QuizQuestion>> generateQuiz({
    required StoryTheme theme,
    required List<StorySegment> storyHistory,
  }) async {
    final storyText = storyHistory.map((e) => e.text).join("\n\n");

    final prompt = '''
Create 4 MCQ questions from the story.

Rules:
- 4 options each
- 1 correct answer
- Return ONLY JSON

Story:
$storyText

Format:
{
  "questions": [
    {
      "question": "",
      "options": ["A", "B", "C", "D"],
      "correctIndex": 0,
      "explanation": ""
    }
  ]
}
''';

    final raw = await _generateText(prompt: prompt);

    return _parseQuiz(raw);
  }

  // ==================== GEMINI VIA CLOUD FUNCTION ====================
  static Future<String> _generateText({
    required String prompt,
  }) async {
    final url = Uri.parse(AiConfig.baseUrl);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "prompt": prompt,
      }),
    );
    print(response.statusCode);
    print(response.body);
    if (response.statusCode != 200) {
      throw Exception('Worker Error ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body);

    return data['text'] ?? "No response";
  }

  // ==================== PROMPT BUILDER ====================
  static String _buildStoryPrompt({
    required StoryTheme theme,
    required String prompt,
    required List<StorySegment> history,
  }) {
    final buffer = StringBuffer();

    buffer.writeln(theme.systemPrompt);
    buffer.writeln("\nWrite an interactive story.\n");

    if (history.isEmpty) {
      buffer.writeln("Start story with:");
      buffer.writeln(prompt);
    } else {
      buffer.writeln("Continue story.\n");

      for (final seg in history) {
        buffer.writeln("STORY:");
        buffer.writeln(seg.text);

        if (seg.choices.isNotEmpty) {
          buffer.writeln("\nCHOICES:");
          for (int i = 0; i < seg.choices.length; i++) {
            final label = String.fromCharCode(65 + i);
            buffer.writeln("$label) ${seg.choices[i]}");
          }
        }

        if (seg.choiceMade != null) {
          buffer.writeln("\nUSER CHOSE: ${seg.choiceMade}");
        }

        buffer.writeln("\n---\n");
      }
    }

    buffer.writeln('''
IMPORTANT:
- Story first
- Then 3–4 choices (A, B, C, D)
- Keep it engaging
''');

    return buffer.toString();
  }

  // ==================== PARSE STORY ====================
  static StorySegment _parseSegment(String raw) {
    final lines = raw.trim().split('\n');

    final choices = <String>[];
    final story = <String>[];

    for (final line in lines) {
      final t = line.trim();

      if (RegExp(r'^[A-D]\)').hasMatch(t)) {
        choices.add(t.substring(2).trim());
      } else {
        story.add(t);
      }
    }

    return StorySegment(
      text: story.join('\n').trim(),
      choices: choices,
    );
  }

  // ==================== PARSE QUIZ ====================
  static List<QuizQuestion> _parseQuiz(String raw) {
    try {
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}') + 1;

      final jsonStr = raw.substring(start, end);
      final data = jsonDecode(jsonStr);

      return (data['questions'] as List).map((q) {
        return QuizQuestion(
          question: q['question'],
          options: List<String>.from(q['options']),
          correctIndex: q['correctIndex'],
          explanation: q['explanation'] ?? '',
        );
      }).toList();
    } catch (e) {
      throw Exception('Quiz parsing failed: $e\nRAW: $raw');
    }
  }
}
