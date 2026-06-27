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
    getCallUserInfo();
  }

  final ChatModel chatModel;
  String? callUserName;
  String? callUserId;
  StreamSubscription? _streamSubscription;
  final supabase = Supabase.instance.client;
  final messageController = TextEditingController();
  Future<void> getCallUserInfo() async {
    try {
      final response = await supabase
          .from("profiles")
          .select("full_name, user_zego_id, id")
          .eq("id", chatModel.callTargetId)
          .single();

      callUserName = response["full_name"] ?? "User";
      callUserId = response["user_zego_id"]?.toString() ?? response["id"].toString();
      log("✅ getCallUserInfo | callTargetId=${chatModel.callTargetId} | callUserId=$callUserId | callUserName=$callUserName");
      emit(state);
    } catch (e) {
      log("❌ getCallUserInfo error: $e");
    }
  }

  Future<void> _initializeChat() async {
    try {
      // Fetch fresh images from profiles table
      final doctorProfile = await supabase
          .from('profiles')
          .select('full_name, avatar_url')
          .eq('id', chatModel.currentUserId)
          .maybeSingle();

      final parentProfile = await supabase
          .from('profiles')
          .select('full_name, avatar_url')
          .eq('id', chatModel.chatPartnerId)
          .maybeSingle();

      await supabase.from("chats").upsert({
        "id": chatModel.id,
        "doctor_id": chatModel.currentUserId,
        "parent_id": chatModel.chatPartnerId,
        "doctor_image": doctorProfile?['avatar_url'] ?? chatModel.currentUserImage,
        "parent_image": parentProfile?['avatar_url'] ?? chatModel.chatPartnerImage,
        "doctor_name": doctorProfile?['full_name'] ?? chatModel.currentUserName,
        "parent_name": parentProfile?['full_name'] ?? chatModel.chatPartnerName,
      }, onConflict: 'id');
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
