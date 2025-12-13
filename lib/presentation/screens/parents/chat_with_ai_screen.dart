import 'package:wesal/logic/cubit/chat_with_ai/cubit/chat_with_ai_cubit.dart';
import 'package:wesal/logic/models/message_model.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const Color primaryColor = Color(0xFF3789C3);

class ChatWithAiScreen extends StatefulWidget {
  const ChatWithAiScreen({super.key});

  @override
  State<ChatWithAiScreen> createState() => _ChatWithAiScreenState();
}

class _ChatWithAiScreenState extends State<ChatWithAiScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool get _isTyping => context.watch<ChatWithAi>().state is ChatWithAiLoading;

  @override
  void initState() {
    super.initState();
    // Request focus on input when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      // Initial scroll to top for chronological order
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR1sKDCAg9h9YO_cyOd-zA2vkBcngRHL593WQ&s",
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "AI Assistant",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatWithAi, ChatWithAiState>(
              builder: (context, state) {
                List<Message> messages = [];
                if (state is ChatWithAiLoaded) {
                  messages = state.messages;
                } else if (state is ChatWithAiLoading) {
                  messages = state.messages;
                } else if (state is ChatWithAiError) {
                  messages = state.messages;
                }

                // Auto-scroll to bottom after new message (for chronological view, bottom is newest)
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: messages.length,
                  reverse: false, // Chronological order: oldest at top, newest at bottom
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isUser = msg.isUser;

                    if (isUser) {
                      // User message on the right
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: BubbleSpecialThree(
                            text: msg.text,
                            color: Colors.grey.shade200,
                            textStyle: const TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                            ),
                            tail: true,
                            isSender: true,
                          ),
                        ),
                      );
                    } else {
                      // AI message on the left with avatar
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundImage: const NetworkImage(
                                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR1sKDCAg9h9YO_cyOd-zA2vkBcngRHL593WQ&s",
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: BubbleSpecialThree(
                                  text: msg.text,
                                  color: primaryColor,
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                  tail: true,
                                  isSender: false,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const CircleAvatar(
                    radius: 14,
                    backgroundImage: NetworkImage(
                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR1sKDCAg9h9YO_cyOd-zA2vkBcngRHL593WQ&s",
                    ),
                  ),
                  const SizedBox(width: 8),
                  _TypingIndicator(),
                ],
              ),
            ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Slightly reduced vertical padding
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: const Border(
            top: BorderSide(color: Colors.black12),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: null,
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: "Ask anything about autism care...",
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: (_) => _sendMessage(),
                onChanged: (value) {
                  // Optional: Clear focus or handle typing
                  if (value.isEmpty) {
                    _focusNode.unfocus();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              mini: true,
              backgroundColor: primaryColor,
              onPressed: _sendMessage,
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    context.read<ChatWithAi>().sendMessage(text);
    _controller.clear();
    _focusNode.unfocus(); // Unfocus after sending to hide keyboard if needed
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _opacity = Tween<double>(begin: 0.2, end: 1.0).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: const Text(
        "Typing...",
        style: TextStyle(
          color: primaryColor,
          fontStyle: FontStyle.italic,
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}