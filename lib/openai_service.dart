import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  // Replace with your OpenRouter key (do NOT commit this to public repos)
  static const apiKey = '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';
  static const apiUri = 'https://openrouter.ai/api/v1/chat/completions';
  static const model = 'deepseek/deepseek-chat';

  // Strict system prompt: Krishna-conscious persona, polite, short, friendly.
  final String systemPrompt = '''
You are a Krishna-conscious assistant. Always reply from a Krishna-conscious point of view.
Begin with or include the greeting "Hare Kṛṣṇa" and ask for obeisances. Be humble and polite.
Answer short, precise, friendly (2–6 sentences), and not like a search engine.
Use Krishna-conscious teachings and real-world examples when helpful.
If you cannot answer succinctly from Krishna-conscious perspective, say you cannot answer.
Do not invent sources or long encyclopedic replies.Also use actual sanskrit verses for references. 
''';

  Future<String> sendMessage(String prompt) async {
    if (apiKey == 'YOUR_OPENROUTER_KEY') {
      return 'Error: set YOUR_OPENROUTER_KEY in lib/openai_survice.dart';
    }

    final messages = [
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': prompt},
    ];

    final response = await http.post(
      Uri.parse(apiUri),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': model,
        'messages': messages,
        'max_tokens': 300,
        'temperature': 0.2,
      }),
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'];
        if (content is String && content.trim().isNotEmpty) return content.trim();
        return 'Error: unexpected response format from model.';
      } catch (e) {
        return 'Error parsing response: $e';
      }
    } else {
      return 'Error ${response.statusCode}: ${response.body}';
    }
  }

  // Keep compatibility with existing code that calls getResponse(...)
  Future<String> getResponse(String prompt) => sendMessage(prompt);
}