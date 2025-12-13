part of 'my_chats_cubit.dart';

@immutable
sealed class MyChatsState {}

final class MyChatsInitial extends MyChatsState {}

class ChatLoading extends MyChatsState {}

class ChatSuccess extends MyChatsState {
  final List<ChatModel> chats;
  ChatSuccess(this.chats);
}

class ChatError extends MyChatsState {
  final String message;
  ChatError(this.message);
}
