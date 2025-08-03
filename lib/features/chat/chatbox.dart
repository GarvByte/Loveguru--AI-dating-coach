import 'package:flutter/material.dart';
import 'package:loveguru/config/theme/app_colors.dart';
import 'package:loveguru/models/chatbotProvider_model/chatbot_provider_model.dart';
import 'package:loveguru/models/imageProvider_model/image_provider_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loveguru/models/supabaseProvider_model/supabase_provider_model.dart';

class Chatbox extends ConsumerStatefulWidget {
  const Chatbox({super.key});

  @override
  ConsumerState<Chatbox> createState() => _ChatboxState();
}

class _ChatboxState extends ConsumerState<Chatbox> {
  final TextEditingController userController = TextEditingController();

  @override
  void dispose() {
    userController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageprovidermodel = ref.read(imageprovider.notifier);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      height: 60,
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(18),
              backgroundColor: AppColors.background,
            ),
            onPressed: () => imageprovidermodel.getImageFromUser(ref),
            child: Icon(Icons.upload, color: AppColors.secondary, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: userController,
              style: TextStyle(color: AppColors.primary),
              showCursor: true,
              cursorColor: AppColors.secondary,
              decoration: InputDecoration(
                fillColor: AppColors.background,
                filled: true,
                hintText: "Type a message...",
                hintStyle: TextStyle(color: AppColors.secondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            padding: const EdgeInsets.all(10),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.background,
              iconSize: 50,
            ),
            onPressed: () {
              final message = userController.text.trim();

              if (message.isNotEmpty) {
                ref
                    .read(supabaseprovider.notifier)
                    .uploadChatsToSupabase(message, ref, true);
                ref
                    .read(chatbotprovider.notifier)
                    .sendAndGetResultFromChatbot(message, ref);
                userController.clear();
              }
            },
            icon: const Icon(
              Icons.send_rounded,
              size: 30,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
