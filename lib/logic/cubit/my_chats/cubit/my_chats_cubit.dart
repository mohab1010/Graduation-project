import 'package:wesal/logic/models/chat_model.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'my_chats_state.dart';

enum UserType { parent, doctor }

class MyChatsCubit extends Cubit<MyChatsState> {
  MyChatsCubit() : super(MyChatsInitial());
  final supabase = Supabase.instance.client;


  List<ChatModel> allChats = [];
  List<ChatModel> filteredChats = [];

  /// ✅ جلب الشات حسب النوع (Parent / Doctor)
  Future<void> getMyChats(UserType type, String id) async {
    emit(ChatLoading());

    try {
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from("chats")
          .select()
          .or(type == UserType.parent
              ? "parent_id.eq.$id"
              : "doctor_id.eq.$id");

      allChats =
          response.map<ChatModel>((json) => ChatModel.fromJson(json)).toList();

      filteredChats = List.from(allChats);

      emit(ChatSuccess(filteredChats));
    } catch (e) {
      emit(ChatError("Failed to load chats: $e"));
    }
  }

  /// 🔍 البحث
  void search(String query) {
    if (query.trim().isEmpty) {
      filteredChats = List.from(allChats);
    } else {
      filteredChats = allChats
          .where((chat) =>
              (chat.chatPartnerName ?? "")
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              (chat.currentUserName ?? "")
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    }

    emit(ChatSuccess(filteredChats));
  }
}