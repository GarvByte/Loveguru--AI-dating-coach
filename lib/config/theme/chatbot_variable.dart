class ChatbotVariable {
  List<Map> allMessages;
  String textStream;
  List<Map> streamingChats;
  String errorName;
  bool error;
  String previousReplies;
  ChatbotVariable({
    required this.allMessages,
    required this.textStream,
    required this.streamingChats,
    required this.errorName,
    required this.error,
    required this.previousReplies,
  });

  ChatbotVariable copyWith({
    List<Map>? allMessages,
    String? textStream,
    List<Map>? streamingChats,
    String? errorName,
    bool? error,
    String? previousReplies,
  }) {
    return ChatbotVariable(
      allMessages: allMessages ?? this.allMessages,
      textStream: textStream ?? this.textStream,
      streamingChats: streamingChats ?? this.streamingChats,
      errorName: errorName ?? this.errorName,
      error: error ?? this.error,
      previousReplies: previousReplies ?? this.previousReplies,
    );
  }
}
