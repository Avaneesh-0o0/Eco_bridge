import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GroqAIService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  static String get _apiKey {
    final key = dotenv.env['GROQ_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('Groq API Key not found in .env');
    }
    return key;
  }

  /// Analyzes raw text describing food and returns structured data
  static Future<Map<String, dynamic>> analyzeFoodDonation(String rawDescription) async {
    final systemPrompt = '''
You are FoodBridge AI, an assistant that extracts structured food donation data from messy user input.
Return ONLY a valid JSON object with the following keys and appropriate values based on the input. Do not include markdown formatting like ```json or any other text.
Keys:
"foodName" (String, a concise title)
"category" (String, choose from: "Cooked Food", "Raw Ingredients", "Bakery", "Snacks", "Packaged Goods")
"estimatedServings" (Number, extract or intelligently guess based on quantity)
"description" (String, a polite, clear, and complete description of what is being donated)
''';

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama3-8b-8192', // Using a fast model
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': rawDescription},
          ],
          'temperature': 0.1, // Low temperature for consistent JSON output
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        // Remove any potential markdown block wrappers just in case
        final cleanContent = content.toString().replaceAll('```json', '').replaceAll('```', '').trim();
        return jsonDecode(cleanContent) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to communicate with Groq: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('AI Analysis Failed: $e');
    }
  }

  /// Sends a message to the AI Chatbot and returns the text response
  static Future<String> chatWithFoodBridgeAI(List<Map<String, String>> chatHistory) async {
    final systemPrompt = '''
You are FoodBridge AI, a helpful, friendly, and expert assistant for a Food Rescue application.
You help Donors figure out what is safe to donate. 
You help NGOs figure out how to repurpose and preserve food.
You help Volunteers with delivery tips.
Keep your answers concise, encouraging, and highly relevant to food rescue, zero-waste, and community support.
''';

    final messages = [
      {'role': 'system', 'content': systemPrompt},
      ...chatHistory,
    ];

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama3-70b-8192', // A more capable model for chat
          'messages': messages,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].toString().trim();
      } else {
        throw Exception('Failed to communicate with Groq: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Chat failed: $e');
    }
  }
}
