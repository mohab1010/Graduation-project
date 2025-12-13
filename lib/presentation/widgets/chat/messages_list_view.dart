import 'package:wesal/logic/models/chat_message_model.dart';
import 'package:wesal/logic/services/colors_app.dart';
import 'package:wesal/logic/services/sized_config.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessagesListView extends StatelessWidget {
  const MessagesListView({super.key, required this.messages});
  final List<ChatMessage> messages;
  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client; 
    return Expanded(
      child: messages.isEmpty
          ? SizedBox()
          : ListView.builder(
              padding: EdgeInsets.only(
                top: SizeConfig.height * 0.01,
              ),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return BubbleSpecialThree(
                  isSender: messages[index].id ==
                     supabase.auth.currentUser!.id,
                  text: messages[index].message,
                  color: messages[index].id ==
                          supabase.auth.currentUser!.id
                      ? ColorsApp().primaryColor
                      : Colors.grey.shade300,
                  tail: true,
                  textStyle: messages[index].id ==
                          supabase.auth.currentUser!.id
                      ? TextStyle(color: Colors.white, fontSize: 18)
                      : TextStyle(color: ColorsApp().primaryColor, fontSize: 18),
                );
              },
            ),
    );
  }
}
