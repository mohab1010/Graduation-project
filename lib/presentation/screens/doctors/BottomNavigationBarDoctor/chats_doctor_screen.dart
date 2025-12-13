import 'package:wesal/logic/cubit/my_chats/cubit/my_chats_cubit.dart';
import 'package:wesal/logic/models/chat_model.dart';
import 'package:wesal/logic/services/colors_app.dart';
import 'package:wesal/presentation/screens/chat/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    /// 🟦 تحميل الشات للـ parent
    context.read<MyChatsCubit>().getMyChats(
      UserType.doctor,
      Supabase.instance.client.auth.currentUser!.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'Chats',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Icon(Icons.chat, color: ColorsApp().primaryColor),
                ],
              ),
              const SizedBox(height: 15),

              // 🔹 Search + Filter
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                      controller: searchController,
                      cursorColor: ColorsApp().primaryColor,
                      onChanged: (value) =>
                          context.read<MyChatsCubit>().search(value),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[300],
                        hintText: 'Search...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: ColorsApp().primaryColor,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 🔵 Chats List
              Expanded(
                child: BlocBuilder<MyChatsCubit, MyChatsState>(
                  builder: (context, state) {
                    if (state is ChatLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is ChatError) {
                      return Center(child: Text(state.message));
                    }

                    if (state is ChatSuccess) {
                      if (state.chats.isEmpty) {
                        return const Center(
                          child: Text(
                            "No Chats Found",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: state.chats.length,
                        itemBuilder: (context, index) {
                          ChatModel chat = state.chats[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ChatScreen(chatModel: chat);
                                  },
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                top: 10,
                                bottom: 10,
                              ),
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                horizontalTitleGap: 10,
                                title: Text(
                                  chat.chatPartnerName ?? "Doctor",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                
                                trailing: Padding(
                                  padding: EdgeInsets.only(right: 12.0),
                                  child: Icon(
                                    CupertinoIcons.chat_bubble,
                                    color: ColorsApp().primaryColor,
                                    size: 24,
                                  ),
                                ),

                                leading: Container(
                                  width: 55,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    image: DecorationImage(
                                      image: chat.chatPartnerImage != null
                                          ? NetworkImage(chat.chatPartnerImage!)
                                          : const AssetImage(
                                                  'assets/images/doctors4.jpg',
                                                )
                                                as ImageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }

                    return Container();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
