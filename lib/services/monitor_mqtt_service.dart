class Chat {
  final String content;
  final String time;
  final String senderName; // Add senderName field

  const Chat({
    required this.content,
    required this.time,
    required this.senderName,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      content: json['content'] as String,
      time: json['time'] as String,
      senderName: json['senderName'] as String, // Parse senderName
    );
  }

  Map<String, dynamic> toJson() => {
    'content': content,
    'time': time,
    'senderName': senderName, // Include senderName in toJson
  };
}
