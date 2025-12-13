import 'dart:async';
import 'dart:developer';
import 'package:wesal/logic/models/chat_model.dart';
import 'package:wesal/logic/models/chat_message_model.dart';
import 'package:wesal/logic/services/supabase_services.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({required this.chatModel}) : super(ChatLoading()) {
    _initializeChat().then((_) => _loadMessages());
  }

  final ChatModel chatModel;
  String? callUserName;
  String? callUserId;
  StreamSubscription? _streamSubscription;
  final supabase = Supabase.instance.client;
  final messageController = TextEditingController();
  getCallUserInfo() async {
    try {
      if (supabase.auth.currentUser!.id == chatModel.currentUserId) {
        final response = await supabase
            .from("profiles")
            .select("full_name,user_zego_id")
            .eq("id", chatModel.chatPartnerId)
            .single();
        callUserName = response["full_name"];
        callUserId = (response["user_zego_id"]).toString();
      }
      else{
        final response = await supabase
            .from("profiles")
            .select("full_name,user_zego_id")
            .eq("id", chatModel.currentUserId)
            .single();
        callUserName = response["full_name"];
        callUserId = (response["user_zego_id"]).toString();
      }
    } catch (e) {}
  }

  Future<void> _initializeChat() async {
    try {
      final existing = await supabase
          .from("chats")
          .select("id")
          .eq("id", chatModel.id)
          .maybeSingle();

      if (existing == null) {
        await supabase.from("chats").insert({
          "id": chatModel.id,
          "doctor_id": chatModel.currentUserId,
          "parent_id": chatModel.chatPartnerId,
          "doctor_image": chatModel.currentUserImage,
          "parent_image": chatModel.chatPartnerImage,
          "doctor_name": chatModel.currentUserName,
          "parent_name": chatModel.chatPartnerName,
        });
      } else {
        log("✅ Chat with id '$chatModel.id' already exists.");
      }
    } catch (e, stack) {
      log("❌ Error initializing chat: $e");
      log("🪜 Stack trace: $stack");
    }
  }

  void _loadMessages() {
    try {
      _streamSubscription = SupabaseServices()
          .streamDataWithSpecificId(
            tableName: "chats",
            id: chatModel.id,
            primaryKey: 'id',
          )
          .listen(
            (data) {
              if (data.isNotEmpty) {
                final dynamic messagesData = data[0]['messages'];
                final List<dynamic> messagesJson = (messagesData is List)
                    ? messagesData
                    : [];
                final List<ChatMessage> messages = messagesJson
                    .map((json) => ChatMessage.fromJson(json))
                    .toList();
                emit(ChatLoaded(messages: messages));
              } else {
                emit(ChatLoaded(messages: []));
              }
            },
            onError: (error) {
              log(error.toString());
            },
          );
    } on Exception catch (e) {
      log(e.toString());
    }
  }

  Future<void> addMessage({required String text}) async {
    try {
      if (messageController.text.isNotEmpty) {
        log("📥 Starting to add message...");

        try {
          final chatData = await supabase
              .from("chats")
              .select("messages")
              .eq("id", chatModel.id)
              .single();
          final dynamic messagesData = chatData['messages'];
          final List<dynamic> messagesJson = (messagesData is List)
              ? messagesData
              : [];
          final List<ChatMessage> messages = messagesJson
              .map((json) => ChatMessage.fromJson(json))
              .toList();
          final newMessage = ChatMessage(
            message: text,
            id: supabase.auth.currentUser!.id,
          );
          messages.add(newMessage);
          await supabase
              .from("chats")
              .update({"messages": messages.map((m) => m.toJson()).toList()})
              .eq("id", chatModel.id);
          messageController.clear();
        } catch (e) {
          emit(ChatFailed(error: e.toString()));
        }
      } else {}
    } on Exception catch (e) {
      log(e.toString());
    }
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
