import 'dart:developer';

import 'package:wesal/logic/cubit/chat/chat_cubit.dart';
import 'package:wesal/logic/models/chat_model.dart';
import 'package:wesal/logic/services/colors_app.dart';
import 'package:wesal/logic/services/sized_config.dart';
import 'package:wesal/logic/services/zego_services/zego_services.dart';
import 'package:wesal/presentation/widgets/chat/chat_screen_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, required this.chatModel});
  final ChatModel chatModel;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(chatModel: chatModel),
      child: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          var cubit = context.read<ChatCubit>();
          cubit.getCallUserInfo();
          return Scaffold(
            appBar: AppBar(
              elevation: 2,
              backgroundColor: ColorsApp().primaryColor.withOpacity(0.8),
              titleSpacing: 0,
              foregroundColor: Colors.white,
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(
                      chatModel.chatPartnerId ==
                              Supabase.instance.client.auth.currentUser!.id
                          ? chatModel.currentUserImage!
                          : chatModel.chatPartnerImage!,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    chatModel.chatPartnerId ==
                            Supabase.instance.client.auth.currentUser!.id
                        ? chatModel.currentUserName!
                        : chatModel.chatPartnerName ?? "Chat",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    ZegoServices.callWithZego(
                      isVideoCall: false,
                      userId: cubit.callUserId!,
                      userName: cubit.callUserName!,
                    );
                  },
                  icon: Icon(Icons.call, size: SizeConfig.width * 0.07),
                ),
                IconButton(
                  onPressed: () {
                    ZegoServices.callWithZego(
                      isVideoCall: true,
                      userId: cubit.callUserId!,
                      userName: cubit.callUserName!,
                    );
                  },
                  icon: Icon(
                    color: Colors.white,
                    Icons.video_chat_outlined,
                    size: SizeConfig.width * 0.07,
                  ),
                ),
              ],
            ),
            body: ChatScreenBody(chatModel: chatModel),
          );
        },
      ),
    );
  }
}
