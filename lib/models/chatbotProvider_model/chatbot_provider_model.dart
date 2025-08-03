import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loveguru/config/theme/constants.dart';
import 'package:http/http.dart' as http;
import 'package:loveguru/models/supabaseProvider_model/supabase_provider_model.dart';

class ChatbotProviderModel extends Notifier<String> {
  @override
  String build() => "";

  List<Map> allMessages = [];
  StreamController<List> messageStream = StreamController.broadcast();
  String textStream = "";
  List<Map> streamingChats = [];
  String previousReplies = "";

  void loadAllMessages() {
    messageStream.add(allMessages);
    addPreviousMessage();
  }

  void addPreviousMessage() {
    final messages = allMessages.reversed.toList();
    print("entered fiucntion");
    for (var i = messages.length <= 10 ? messages.length - 1 : 10; i > 0; i--) {
      print("enetered previous messages");
      previousReplies += messages[i]["bot_reply"];
    }
    print("previoyus repoy = $previousReplies");

    // print("messages = $messages");
  }

  Future<void> sendAndGetResultFromChatbot(String text, WidgetRef ref) async {
    textStream = "";
    streamingChats.clear();

    print("ebeterd chatboit");

    const url = "https://openrouter.ai/api/v1/chat/completions";
    const apiKey = ChatmodelAPIkey; // ❗Replace with a valid one, keep it secret
    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $apiKey",
    };

    final body = {
      "model": "google/gemini-2.5-flash-lite-preview-06-17",
      "messages": [
        {
          "role": "system",
          "content":
              "You are a loveguru. Ignore all the dates mentioned in the chats like 24 may, 2025, etc... and make sure to keep the message under 100-150 words and highlighting only the important points using bullet points not asterisks. I am also providing you with yours and mine previous chats but chats might not be of the same person so only give follow up reply if user asks something and if i give you some chats of me and other person then also give me friendzone score out of 100",
        },
        {
          "role": "user",
          "content":
              "Previous Replies of you and me are $previousReplies and current one is $text",
        },
      ],
      "stream": true,
    };

    try {
      final request = http.Request('POST', Uri.parse(url));
      request.headers.addAll(headers);
      request.body = jsonEncode(body);
      final streamResponse = await request.send();
      streamResponse.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) async {
            if (line.startsWith("data")) {
              final jsonPart = line.substring(6).trim();
              if (jsonPart == "[DONE]") {
                print("stream finished message recieved");
                state = textStream;
                ref
                    .read(supabaseprovider.notifier)
                    .uploadChatsToSupabase(state, ref, false);
                return;
              }
              final body = jsonDecode(jsonPart);
              textStream += body['choices'][0]['delta']['content'];
              final combined = [
                ...allMessages,
                // ✅ Previous chats
                {"bot_reply": textStream}, // ✅ Current streamed message
              ];

              messageStream.add(combined);
              await Future.delayed(const Duration(milliseconds: 50));
            }
          });
    } catch (e) {
      print("error in stream $e");
    }
  }
}

final chatbotprovider = NotifierProvider<ChatbotProviderModel, String>(() {
  return ChatbotProviderModel();
});
