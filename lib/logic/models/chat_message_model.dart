class ChatMessage {
  final String message;
  final String id;

  ChatMessage({required this.message, required this.id});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      message: json["message"],
      id: json["id"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "message": message,
      "id": id,
    };
  }}
