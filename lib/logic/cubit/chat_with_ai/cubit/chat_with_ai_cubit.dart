import 'dart:developer' as developer;
import 'package:wesal/logic/models/message_model.dart';
import 'package:wesal/logic/services/app_secrets.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
part 'chat_with_ai_state.dart';

class ChatWithAi extends Cubit<ChatWithAiState> {
  final Dio _dio = Dio();
  List<Message> _messages = [];

  ChatWithAi() : super(ChatWithAiInitial()) {
    _messages.add(Message(
      text: 'Hello! I\'m here to help with autism care for children. Ask me about behaviors, routines, or anything related. What can I assist you with today?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
    emit(ChatWithAiLoaded(List.from(_messages)));
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    _messages.add(Message(text: message, isUser: true, timestamp: DateTime.now()));
    emit(ChatWithAiLoading(List.from(_messages)));

    try {
      final List<Map<String, String>> chatHistory = [
        {'role': 'system', 'content': autismSystemPrompt},
      ];

      for (final msg in _messages) {
        chatHistory.add({
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.text,
        });
      }

      final response = await _dio.post(
        'https://api.groq.com/openai/v1/chat/completions',
        data: {
          'model': 'llama-3.1-8b-instant',
          'messages': chatHistory,
          'max_tokens': 800,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $kGroqApiKey',
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final text = response.data['choices']?[0]?['message']?['content']
          ?? 'Try another question. I\'m here to help!';

      _messages.add(Message(text: text, isUser: false, timestamp: DateTime.now()));
      emit(ChatWithAiLoaded(List.from(_messages)));
    } catch (e) {
      developer.log('Chatbot error: $e');
      _messages.add(Message(
        text: 'Sorry, I\'m having trouble connecting right now. Please check your internet and try again.',
        isUser: false,
        timestamp: DateTime.now(),
      ));
      emit(ChatWithAiLoaded(List.from(_messages)));
    }
  }

  static const String autismSystemPrompt = """
You are an AI assistant specialized in Autism Spectrum Disorder (ASD) in children.
You help parents understand behaviors, support communication, manage sensory issues, and improve daily routines.
Rules:
- You must NEVER diagnose autism.
- You must NEVER recommend medication.
- You must speak in simple, friendly English.
- You must be supportive, calm, and helpful.
- You must give practical, safe strategies parents can try.
- Redirect any medical or dangerous question to a professional.
Allowed topics:
- Sensory issues, stimming, meltdowns.
- Sleep issues, feeding challenges.
- Communication delay and speech development.
- Emotional regulation and social skills.
- Daily routine tips and behavior guidance.
- When to seek help from a therapist.
If asked about diagnosis: say you cannot diagnose.
If asked about medication: say only doctors can recommend medication.
""";
}
