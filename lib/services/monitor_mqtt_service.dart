class ChatMessage {
  final String topic;
  final String payload;
  final String timestamp;

  ChatMessage({
    required this.topic,
    required this.payload,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      topic: json['topic'] ?? '',
      payload: json['payload']?.toString() ?? '', // force to String
      timestamp: json['timestamp'] ?? '',
    );
  }
}
