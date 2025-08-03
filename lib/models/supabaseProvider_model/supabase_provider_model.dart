import 'package:loveguru/models/chatbotProvider_model/chatbot_provider_model.dart';
import 'package:loveguru/models/ocrProvider_model/ocr_provider_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupabaseProviderModel extends Notifier<List<Map<dynamic, dynamic>>> {
  @override
  List<Map<dynamic, dynamic>> build() {
    return [];
  }

  final supabase = Supabase.instance.client;
  List<Map> chats = [];
  Future<void> getAndUploadtoSupabase(List<XFile> images, WidgetRef ref) async {
    print("Entered into supabase model");
    List links = [];

    for (var i = 0; i < images.length; i++) {
      final image = images[i];
      print("Entered loop");
      final fileExtension = image.name.split('.').last.toLowerCase();
      // e.g., image/png, image/jpg
      final imageBytes = await image.readAsBytes();
      print("got imagefile bytes");

      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Optional: You can use path extension from image.name
      final filename = "user1/$timestamp.$fileExtension";
      print(filename);

      try {
        // Upload binary image
        await supabase.storage
            .from("chat-screenshots")
            .uploadBinary(
              filename,
              imageBytes,
              fileOptions: const FileOptions(contentType: 'image/jpeg'),
            );

        print("Successfully uploaded to Supabase");

        // Get public URL
        final link = supabase.storage
            .from("chat-screenshots")
            .getPublicUrl(filename);

        print("Successfully got public URL: $link");
        links.add(link);
      } catch (e) {
        print("Upload error: $e");
      }
    }
    ref.read(ocrprovider.notifier).getAndUploadImageToOcr(links, ref);
    // ocrprovider.getAndUploadImageToOcr(context, links);
  }

  Future<void> uploadChatsToSupabase(
    chatbotReplies,
    WidgetRef ref,
    isUser,
  ) async {
    try {
      final uid = supabase.auth.currentUser!.id;
      final nickname = supabase.auth.currentUser!.userMetadata!['nickname'];
      await supabase.from("user_chats").insert({
        "user_id": uid,
        "username": nickname,
        "bot_reply": "$chatbotReplies",
        "isUser": isUser,
      });

      print("uploaded chats to supabase successfully");
      getChatsFromSupabase(ref);
    } catch (e) {
      print("error in uploadingchats = $e");
    }
  }

  Future<void> getChatsFromSupabase(WidgetRef ref) async {
    print("entered getchatsfrom supabase");
    final uid = supabase.auth.currentUser!.id;
    try {
      final getchats = await supabase
          .from("user_chats")
          .select("bot_reply, isUser")
          .eq("user_id", uid)
          .order("created_at", ascending: true);
      chats = getchats;
      state = chats;
      ref.read(chatbotprovider.notifier).allMessages = state;
      ref.read(chatbotprovider.notifier).loadAllMessages();
    } catch (e) {
      print("error fetching chats from supabase = $e");
    }
  }

  Future<void> writeNicknameToDatabase(uid, nickname) async {
    await supabase.from("users").insert({"user_id": uid, "username": nickname});
    print("wrote nickanme to supabase");
  }
}

final supabaseprovider =
    NotifierProvider<SupabaseProviderModel, List<Map<dynamic, dynamic>>>(() {
      return SupabaseProviderModel();
    });
