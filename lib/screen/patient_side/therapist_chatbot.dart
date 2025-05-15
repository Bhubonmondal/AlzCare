import 'dart:convert';
import 'dart:math'; // Keep for Chat widget if it uses it internally, though not directly by our logic
import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class TherapistChatbot extends StatefulWidget {
  const TherapistChatbot({super.key});

  @override
  _TherapistChatbotState createState() => _TherapistChatbotState();
}

class _TherapistChatbotState extends State<TherapistChatbot> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: 'user', firstName: 'You');
  final _bot = const types.User(id: 'bot', firstName: 'TherapistBot');
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _insertBotMessage("Hello! I'm your therapist chatbot. How are you feeling today?");
  }

  void _insertBotMessage(String text) {
    final botMessage = TextMessage(
      id: _uuid.v4(),
      authorId: _bot.id,
      createdAt: DateTime.now().toUtc(),
      text: text,
    );

    _chatController.insertMessage(botMessage);
  }


  void _addBotMessage(String text) {
    final message = types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: _uuid.v4(), // Generate a unique ID for the message
      text: text,
    );
    setState(() {
      _messages.insert(0, message);
    });
  }

  Future<void> _handleSendPressed(types.PartialText message) async {
    final userMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: _uuid.v4(), // Generate a unique ID for the message
      text: message.text,
    );

    setState(() {
      _messages.insert(0, userMessage);
    });

    final botResponseText = await _sendToGemini(message.text);

    _addBotMessage(botResponseText);
  }

  Future<String> _sendToGemini(String userInput) async {
    const String apiKey = 'AIzaSyCRwSx3bu8sR_YXHnnUgV6HLv1gnZV9bns';

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
    );

    // Standard headers for Gemini API
    final headers = {'Content-Type': 'application/json'};

    // Standard request body for Gemini API (text-only input)
    final requestBody = jsonEncode({
      'contents': [
        {
          'parts': [
            {
              'text':
                  "You are a compassionate, non-judgmental therapist. Respond in a calm, friendly, and supportive tone. Be empathetic, listen carefully, and ask open-ended questions to help the user reflect. Here's what the user said: \"$userInput\"",
            },
          ],
        },
      ],
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Parse the response according to Gemini API structure
        // Check for candidates, content, parts, and text to avoid runtime errors
        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty &&
            data['candidates'][0]['content']['parts'][0]['text'] != null) {
          return data['candidates'][0]['content']['parts'][0]['text'];
        } else if (data['promptFeedback'] != null &&
            data['promptFeedback']['blockReason'] != null) {
          // Handle cases where content is blocked
          return 'Response blocked: ${data['promptFeedback']['blockReason']}. ${data['promptFeedback']['blockReasonMessage'] ?? ''}';
        } else {
          // Fallback if the expected response structure is not found
          print('Unexpected response structure: ${response.body}');
          return 'Sorry, I received an unexpected response format.';
        }
      } else {
        // Handle HTTP errors
        print('Error from Gemini API: ${response.statusCode} ${response.body}');
        return 'Error: Unable to get response from therapist bot (Status ${response.statusCode}).';
      }
    } catch (e) {
      // Handle network or other errors
      print('Error sending message to Gemini: $e');
      return 'Error: $e';
    }
  }

  final _chatController = InMemoryChatController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Therapist Chatbot'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Chat(
        onMessageSend: (text) async {
          final userMessage = TextMessage(
            id: _uuid.v4(),
            authorId: _user.id,
            createdAt: DateTime.now().toUtc(),
            text: text,
          );

          _chatController.insertMessage(userMessage);

          // Get response from Gemini
          final botText = await _sendToGemini(text);

          final botMessage = TextMessage(
            id: _uuid.v4(),
            authorId: _bot.id,
            createdAt: DateTime.now().toUtc(),
            text: botText,
          );

          _chatController.insertMessage(botMessage);
        },

        currentUserId: _user.id,
        resolveUser: (id) async {
          if (id == _user.id) {
            return User(id: _user.id, name: _user.firstName);
          } else if (id == _bot.id) {
            return User(id: _bot.id, name: _bot.firstName);
          }
          return User(id: id, name: 'User');
        },

        chatController: _chatController,
      ),
    );
  }
}
