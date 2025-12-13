import 'dart:developer' as developer;
import 'package:wesal/logic/models/message_model.dart';
import 'package:wesal/logic/services/variables_app.dart';
import 'package:bloc/bloc.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:meta/meta.dart';
part 'chat_with_ai_state.dart';

class ChatWithAi extends Cubit<ChatWithAiState> {
  late final GenerativeModel _model;
  List<Message> _messages = [];

  ChatWithAi() : super(ChatWithAiInitial()) {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: geminiApiKey,
    );
    // Add initial welcome message
    final welcomeMessage = Message(
      text: 'Hello! I\'m here to help with autism care for children. Ask me about behaviors, routines, or anything related. What can I assist you with today?',
      isUser: false,
      timestamp: DateTime.now(),
    );
    _messages.add(welcomeMessage);
    emit(ChatWithAiLoaded(List.from(_messages)));
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final userMessage = Message(text: message, isUser: true, timestamp: DateTime.now());
    _messages.add(userMessage);
    emit(ChatWithAiLoading(List.from(_messages)));

    try {
      // Build prompt with system + all previous messages (excluding the current user message for context)
      String prompt = autismSystemPrompt + '\n\nPrevious conversation:\n';
      for (int i = 0; i < _messages.length - 1; i++) {
        final msg = _messages[i];
        final role = msg.isUser ? 'User' : 'Assistant';
        prompt += '$role: ${msg.text}\n';
      }
      prompt += 'User: $message\nAssistant:';

      developer.log('Sending prompt: $prompt');

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? 'Try another question. I\'m here to help!';

      developer.log('Received response: $text');

      final assistantMessage = Message(text: text, isUser: false, timestamp: DateTime.now());
      _messages.add(assistantMessage);
      emit(ChatWithAiLoaded(List.from(_messages)));
    } catch (e) {
      developer.log('Error in sendMessage: $e');
      // Keep the user message, add error as assistant message
      final errorMessage = Message(
        text: 'Sorry, I encountered an error. Please try again. Error: ${e.toString()}',
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
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
If asked: "Does my child have autism?" → say you cannot diagnose.
If asked about medication → say only doctors can recommend medication.
""";
}