part of 'chat_with_ai_cubit.dart';

@immutable
sealed class ChatWithAiState {}


class ChatWithAiInitial extends ChatWithAiState {}

class ChatWithAiLoading extends ChatWithAiState {
  final List<Message> messages;
  ChatWithAiLoading(this.messages);
}

class ChatWithAiLoaded extends ChatWithAiState {
  final List<Message> messages;
  ChatWithAiLoaded(this.messages);
}

class ChatWithAiError extends ChatWithAiState {
  final String error;
  final List<Message> messages;
  ChatWithAiError(this.error, this.messages);
}