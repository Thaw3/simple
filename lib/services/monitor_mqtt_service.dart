// This file is part of the Simple project.
class ChatMessage {
  final String topic;
  final String payload;
  final String timestamp;
  final String sender;
  // Constructor for creating a chat message
  ChatMessage({
    required this.topic,
    required this.payload,
    required this.timestamp,
    required this.sender,
  });
  // Factory method to create a ChatMessage from a JSON object
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      topic: json['topic'] ?? '',
      payload: json['payload'] ?? json['msg'] ?? '',
      timestamp: json['timestamp'] ?? '',
      sender: json['sender'] ?? '',
    );
  }
  // Factory method to create a ChatMessage from MQTT topic and payload
  factory ChatMessage.fromMqtt(
    String topic,
    String payload, {
    String sender = '',
  }) {
    return ChatMessage(
      topic: topic,
      payload: payload,
      timestamp: DateTime.now().toIso8601String(),
      sender: sender,
    );
  }
}
