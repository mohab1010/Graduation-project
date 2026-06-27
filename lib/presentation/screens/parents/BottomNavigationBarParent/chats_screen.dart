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

    context.read<MyChatsCubit>().getMyChats(
      UserType.parent,
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
                                    return ChatScreen(chatModel: chat,);
                                  },
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.only(left: 10),
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                horizontalTitleGap: 10,

                                title: Text(
                                  chat.currentUserName ?? "Doctor",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                subtitle: Row(
                                  children: [
                                    Icon(
                                      Icons.medical_services_outlined,
                                      size: 18,
                                      color: ColorsApp().primaryColor,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Specialist',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),

                                trailing: Padding(
                                  padding:  EdgeInsets.only(right: 12.0),
                                  child: Icon(
                                    CupertinoIcons.chat_bubble,
                                    color: ColorsApp().primaryColor,
                                    size: 24,
                                  ),
                                ),

                                leading: CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage: (chat.currentUserImage != null &&
                                          chat.currentUserImage!.startsWith('http'))
                                      ? NetworkImage(chat.currentUserImage!) as ImageProvider
                                      : const AssetImage('assets/images/doctors4.jpg'),
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
