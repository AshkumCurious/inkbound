import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inkbound/aiConfig.dart';
import '../models/story_theme.dart';
import '../models/story_state.dart';
import 'quiz_question.dart';

class ClaudeService {
  static const String _baseUrl = AiConfig.baseUrl;
  static const String _apiKey = AiConfig.apikey;

  // ==================== Generate Story Segment ====================
  static Future<StorySegment> generateStory({
    required StoryTheme theme,
    required String prompt,
    required List<StorySegment> history,
  }) async {
    final messages = _buildMessages(theme, prompt, history);

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': AiConfig.model,
        'max_tokens': 600,
        'temperature': 0.85,
        'messages': [
          {'role': 'system', 'content': theme.systemPrompt},
          ...messages,
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('API error ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final rawText = data['choices'][0]['message']['content'] as String;
    return _parseSegment(rawText);
  }

  // ==================== NEW: Generate Quiz ====================
  static Future<List<QuizQuestion>> generateQuiz({
    required StoryTheme theme,
    required List<StorySegment> storyHistory,
  }) async {
    final fullStory = storyHistory.map((s) => s.text).join("\n\n");

    const systemPrompt = '''
You are an expert literature teacher. Create a short multiple choice quiz based on the story so far.
Generate exactly 4 questions.
Each question should have 4 options and only one correct answer.
Focus on important events, character actions, motivations, and key details.
''';

    final userPrompt = '''
Story so far:
$fullStory

Create 4 good MCQ questions that test understanding of the story.
Return the response strictly in the following JSON format:

{
  "questions": [
    {
      "question": "Question text here?",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "correctIndex": 0,
      "explanation": "Short explanation why this is correct"
    }
  ]
}
''';

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': AiConfig.model,
        'max_tokens': 800,
        'temperature': 0.7,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Quiz API error: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final content = data['choices'][0]['message']['content'] as String;

    try {
      final jsonStart = content.indexOf('{');
      final jsonEnd = content.lastIndexOf('}') + 1;
      final jsonString = content.substring(jsonStart, jsonEnd);
      final parsed = jsonDecode(jsonString);

      final List<dynamic> questionsList = parsed['questions'];

      return questionsList
          .map((q) => QuizQuestion(
                question: q['question'],
                options: List<String>.from(q['options']),
                correctIndex: q['correctIndex'],
                explanation: q['explanation'] ?? '',
              ))
          .toList();
    } catch (e) {
      throw Exception('Failed to parse quiz JSON');
    }
  }

  // ==================== Helper Methods ====================
  static List<Map<String, String>> _buildMessages(
    StoryTheme theme,
    String prompt,
    List<StorySegment> history,
  ) {
    final messages = <Map<String, String>>[];

    if (history.isEmpty) {
      messages.add({
        'role': 'user',
        'content': 'Start a story with this premise: $prompt',
      });
    } else {
      messages.add({
        'role': 'user',
        'content':
            'Start a story with this premise: ${history.first.text.split('\n').first}',
      });

      for (int i = 0; i < history.length; i++) {
        final seg = history[i];
        messages.add({
          'role': 'assistant',
          'content': _segmentToText(seg),
        });
        if (seg.choiceMade != null && i < history.length - 1) {
          messages.add({
            'role': 'user',
            'content': 'I choose: ${seg.choiceMade}',
          });
        }
      }

      if (history.last.choiceMade != null) {
        messages.add({
          'role': 'user',
          'content': 'I choose: ${history.last.choiceMade}',
        });
      }
    }

    return messages;
  }

  static String _segmentToText(StorySegment seg) {
    final buffer = StringBuffer(seg.text);
    if (seg.choices.isNotEmpty) {
      buffer.writeln('\n');
      for (int i = 0; i < seg.choices.length; i++) {
        final label = String.fromCharCode(65 + i);
        buffer.writeln('$label) ${seg.choices[i]}');
      }
    }
    return buffer.toString();
  }

  static StorySegment _parseSegment(String raw) {
    final lines = raw.trim().split('\n');
    final choices = <String>[];
    final storyLines = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (RegExp(r'^[A-C]\)').hasMatch(trimmed)) {
        choices.add(trimmed.substring(2).trim());
      } else {
        storyLines.add(trimmed);
      }
    }

    final storyText = storyLines.where((l) => l.isNotEmpty).join('\n').trim();
    return StorySegment(text: storyText, choices: choices);
  }
}


