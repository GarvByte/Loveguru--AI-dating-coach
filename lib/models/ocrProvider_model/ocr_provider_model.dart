import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loveguru/config/theme/constants.dart';
import 'package:loveguru/models/chatbotProvider_model/chatbot_provider_model.dart';
import 'package:http/http.dart' as http;

class OcrProviderModel extends Notifier<String> {
  // final ChatbotProviderModel chatbotprovider;
  // OcrProviderModel({required this.chatbotprovider});
  @override
  String build() {
    return "";
  }

  String finaltext = "";

  Future<void> getAndUploadImageToOcr(
    imageLinks,
    WidgetRef ref,
  ) async {
    void removeHighlightedText(lines, i) {
      for (var j = 1; j < 3; j++) {
        if (i + j + 1 < lines.length && i + j < lines.length) {
          int difference =
              lines[i + j + 1]['Words'][0]['Top'] -
              lines[i + j]['Words'][0]['Top'];
          // print(
          //   "difference of ${lines[i + j]['LineText']} and ${lines[i + j + 1]['LineText']} is $difference",
          // );

          if ((difference >= 25 && difference <= 40) ||
              (difference >= -40 && difference <= -25)) {
            // print(
            //   // "seeing difference between = ${lines[i + j]['LineText']} and ${lines[i + j + 1]['LineText']}",
            // );
            lines[i + 1]['LineText'] = ".";
            lines[i + 2]['LineText'] = ".";
            continue;
          } else if ((difference >= 50 && difference <= 60) ||
              (difference >= -60 && difference <= -50)) {
            // print("deleting this line = ${lines[i + j]['LineText']}");
            lines[i + j]['LineText'] = ".";
            break;
          }
        } else {
          print("Skipped processing to avoid index out of range: i=$i j=$j");
        }
      }
    }

    print("imageinls = $imageLinks");
    for (var imageUrl in imageLinks) {
      String localTest = "";

      print("using this url = $imageUrl");
      try {
        final url =
            "https://api.ocr.space/parse/imageurl?apikey=$ocrAPikey&isOverlayRequired=true&url=$imageUrl";
        final response = await http.get(Uri.parse(url));
        print("successfully sent image to ocr ");

        if (response.statusCode == 200) {
          final body = jsonDecode(response.body);
          String me = "me :";
          String her = "her:";
          final lines = body['ParsedResults'][0]['TextOverlay']['Lines'];
          final herName = lines[1]['LineText'];

          for (var i = 2; i < lines.length; i++) {
            final line = lines[i];

            if (line["LineText"].contains(":")) {
              continue;
            } else {
              if (line['Words'][0]['Left'] > 130) {
                if (line['LineText'] == herName) {
                  // for my text
                  line['LineText'] = "";
                  removeHighlightedText(lines, i);
                } else {
                  localTest += "$me ${line['LineText']}";
                  localTest;
                  me = "";
                  her = "\nher:";
                }
              } else if (line['Words'][0]['Left'] < 130) {
                //her text
                if (line['LineText'] == "You") {
                  line['LineText'] = "";
                  removeHighlightedText(lines, i);
                } else {
                  localTest += "$her ${line['LineText']}"; // for her text
                  localTest;
                  her = "";
                  me = "\nme :";
                }
              }
            }
          }

          finaltext += "$localTest \n";
        } else {
          print("OCR failed with status: ${response.statusCode}");
        }
      } catch (e) {
        print("Error in OCR processing: $e");
      }
    }
    state = finaltext;
    print(finaltext);
    ref
        .read(chatbotprovider.notifier)
        .sendAndGetResultFromChatbot(state, ref);
  }
}

final ocrprovider = NotifierProvider<OcrProviderModel, String>(() {
  return OcrProviderModel();
});
