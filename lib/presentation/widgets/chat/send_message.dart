import 'package:wesal/logic/cubit/chat/chat_cubit.dart';
import 'package:wesal/logic/services/colors_app.dart';
import 'package:wesal/logic/services/sized_config.dart';
import 'package:flutter/material.dart';

class SendMessage extends StatelessWidget {
  const SendMessage({super.key, required this.cubit});
  final ChatCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.width * 0.03,
        vertical: SizeConfig.height * 0.012,
      ),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextFormField(
                controller: cubit.messageController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "enter your message",
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              cubit.addMessage(text: cubit.messageController.text);
              cubit.messageController.clear();
            },
            child: CircleAvatar(
              radius: 24,
              backgroundColor: ColorsApp().primaryColor,
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
