import 'package:flutter/material.dart';
import 'package:loveguru/config/theme/app_colors.dart';
import 'package:loveguru/models/chatbotProvider_model/chatbot_provider_model.dart';
import 'package:loveguru/models/supabaseProvider_model/supabase_provider_model.dart';
import 'package:loveguru/features/chat/chatbox.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatUi extends ConsumerStatefulWidget {
  const ChatUi({super.key});

  @override
  ConsumerState<ChatUi> createState() => _ChatUiState();
}

class _ChatUiState extends ConsumerState<ChatUi> {
  final ScrollController _scrollController = ScrollController();
  bool scrollButton = false;
  bool initialScrollDone = false;
  bool isAtBottom = true;
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(supabaseprovider.notifier).getChatsFromSupabase(ref);
    });

    _scrollController.addListener(() {
      final atBottom =
          _scrollController.offset >=
          _scrollController.position.maxScrollExtent - 50;
      if (atBottom != isAtBottom) {
        setState(() {
          isAtBottom = atBottom;
          scrollButton = !atBottom;
        });
      }
    });
  }

  void scrollToBottom() {
    setState(() {
      scrollButton = false;
    });

    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    final chatbot = ref.watch(chatbotprovider.notifier);

    return Scaffold(
      
      appBar: AppBar(
        title: Text("LOVEGURU"),

        centerTitle: true,
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.text,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            top: 20,
            left: 20,
            bottom: 80,
            right: 20,
            child: StreamBuilder(
              stream: chatbot.messageStream.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data as List;

                // Scroll to bottom when new message arrives and user is at bottom
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients && isAtBottom) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 50),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  itemCount: messages.length,
                  controller: _scrollController,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isUser = message['isUser'] == true;

                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          message['bot_reply'],
                          style: TextStyle(color: AppColors.background),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(alignment: Alignment.bottomCenter, child: Chatbox()),
          if (scrollButton)
            Positioned(
              bottom: 80, // just above Chatbox
              right: 50, // adjust for alignment
              left: 50,
              child: IconButton(
                iconSize: 20,
                color: AppColors.primary,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.background,
                  shape: const CircleBorder(),
                  elevation: 4,
                  shadowColor: Colors.black26,
                ),
                onPressed: scrollToBottom,
                icon: const Icon(Icons.arrow_downward),
              ),
            ),
        ],
      ),
    );
  }
}
